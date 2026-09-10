[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Project,

    [Parameter(Position = 1)]
    [string] $Configuration,

    [string] $IarBuild,

    [string] $OutputDirectory,

    [string[]] $ExtraDefine = @()
)

$ErrorActionPreference = 'Stop'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class WindowsCommandLine {
    [DllImport("shell32.dll", SetLastError = true)]
    private static extern IntPtr CommandLineToArgvW(
        [MarshalAs(UnmanagedType.LPWStr)] string commandLine,
        out int argc);

    [DllImport("kernel32.dll")]
    private static extern IntPtr LocalFree(IntPtr memory);

    public static string[] Split(string commandLine) {
        int argc;
        IntPtr argv = CommandLineToArgvW(commandLine, out argc);
        if (argv == IntPtr.Zero) {
            throw new System.ComponentModel.Win32Exception();
        }

        try {
            string[] result = new string[argc];
            for (int index = 0; index < argc; index++) {
                IntPtr item = Marshal.ReadIntPtr(argv, index * IntPtr.Size);
                result[index] = Marshal.PtrToStringUni(item);
            }
            return result;
        }
        finally {
            LocalFree(argv);
        }
    }
}
'@

function Resolve-ProjectPath {
    param([string] $RequestedProject)

    if ($RequestedProject) {
        return (Resolve-Path -LiteralPath $RequestedProject).Path
    }

    $projects = @(Get-ChildItem -LiteralPath (Get-Location) -Filter '*.ewp' -File -Recurse)
    if ($projects.Count -eq 1) {
        return $projects[0].FullName
    }
    if ($projects.Count -eq 0) {
        throw 'No .ewp project was found below the current directory. Pass -Project explicitly.'
    }

    $choices = ($projects.FullName | ForEach-Object { "  $_" }) -join [Environment]::NewLine
    throw "More than one .ewp project was found. Pass -Project explicitly:$([Environment]::NewLine)$choices"
}

function Resolve-ConfigurationName {
    param(
        [string] $ProjectPath,
        [string] $RequestedConfiguration
    )

    [xml] $projectXml = Get-Content -Raw -LiteralPath $ProjectPath
    $names = @($projectXml.project.configuration | ForEach-Object { [string] $_.name })
    if ($RequestedConfiguration) {
        if ($names -notcontains $RequestedConfiguration) {
            throw "Configuration '$RequestedConfiguration' was not found. Available: $($names -join ', ')"
        }
        return $RequestedConfiguration
    }
    if ($names.Count -eq 1) {
        return $names[0]
    }

    throw "This project has multiple configurations. Pass -Configuration. Available: $($names -join ', ')"
}

function Resolve-IarBuildPath {
    param([string] $RequestedIarBuild)

    if ($RequestedIarBuild) {
        return (Resolve-Path -LiteralPath $RequestedIarBuild).Path
    }
    if ($env:IARBUILD -and (Test-Path -LiteralPath $env:IARBUILD)) {
        return (Resolve-Path -LiteralPath $env:IARBUILD).Path
    }

    $command = Get-Command 'IarBuild.exe' -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $knownLocations = @(
        'C:\Program Files\IAR Systems\Embedded Workbench\common\bin\IarBuild.exe',
        'C:\Program Files (x86)\IAR Systems\Embedded Workbench\common\bin\IarBuild.exe'
    )
    foreach ($candidate in $knownLocations) {
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw 'IarBuild.exe was not found. Pass -IarBuild or set the IARBUILD environment variable.'
}

function Find-RepositoryRoot {
    param([string] $StartDirectory)

    $directory = [IO.DirectoryInfo]::new($StartDirectory)
    while ($directory) {
        if (Test-Path -LiteralPath (Join-Path $directory.FullName '.git')) {
            return $directory.FullName
        }
        $directory = $directory.Parent
    }
    return $StartDirectory
}

function Normalize-IncludePath {
    param([string] $Path)

    $trimmed = $Path.TrimEnd('\', '/')
    if ([IO.Path]::IsPathRooted($trimmed)) {
        return [IO.Path]::GetFullPath($trimmed)
    }
    return $trimmed
}

function Convert-Cpu {
    param([string] $IarCpu)
    return $IarCpu.ToLowerInvariant().Replace('_', '-').Replace(' ', '')
}

function Convert-Fpu {
    param([string] $IarFpu)

    switch ($IarFpu.ToLowerInvariant()) {
        'vfpv4_sp' { return 'fpv4-sp-d16' }
        'vfpv5_sp' { return 'fpv5-sp-d16' }
        'vfpv5_d16' { return 'fpv5-d16' }
        'none' { return $null }
        default { return $IarFpu.ToLowerInvariant().Replace('_', '-') }
    }
}

function Convert-IarCommand {
    param(
        [string[]] $Tokens,
        [string] $WorkingDirectory,
        [string] $CompatInclude,
        [string[]] $AdditionalDefines
    )

    if ($Tokens.Count -lt 2) {
        return $null
    }

    $source = [IO.Path]::GetFullPath($Tokens[1])
    $extension = [IO.Path]::GetExtension($source).ToLowerInvariant()
    if ($extension -notin @('.c', '.cc', '.cpp', '.cxx', '.c++')) {
        return $null
    }

    $defines = [Collections.Generic.List[string]]::new()
    $includes = [Collections.Generic.List[string]]::new()
    $preincludes = [Collections.Generic.List[string]]::new()
    $other = [Collections.Generic.List[string]]::new()
    $cpu = $null
    $fpu = $null

    for ($index = 2; $index -lt $Tokens.Count; $index++) {
        $argument = $Tokens[$index]
        switch -Regex ($argument) {
            '^-D$' {
                if (++$index -lt $Tokens.Count) { $defines.Add($Tokens[$index]) }
                continue
            }
            '^-D(.+)$' {
                $defines.Add($Matches[1])
                continue
            }
            '^-I$' {
                if (++$index -lt $Tokens.Count) { $includes.Add((Normalize-IncludePath $Tokens[$index])) }
                continue
            }
            '^-I(.+)$' {
                $includes.Add((Normalize-IncludePath $Matches[1]))
                continue
            }
            '^--preinclude$' {
                if (++$index -lt $Tokens.Count) { $preincludes.Add($Tokens[$index]) }
                continue
            }
            '^--cpu=(.+)$' {
                $cpu = Convert-Cpu $Matches[1]
                continue
            }
            '^--fpu=(.+)$' {
                $fpu = Convert-Fpu $Matches[1]
                continue
            }
            '^--endian=big$' {
                $other.Add('-mbig-endian')
                continue
            }
            '^--char_is_signed$' {
                $other.Add('-fsigned-char')
                continue
            }
            '^--char_is_unsigned$' {
                $other.Add('-funsigned-char')
                continue
            }
        }
    }

    $officialIndexerDefines = @(
        '__fp16=float',
        '__constrange(...)=',
        '__c99_generic(...)=',
        '__spec_string=',
        '__data=',
        '__func__=""',
        '__alignof__(a)=1',
        '__ALIGNOF__=__alignof__',
        '__section_begin(...)=((void*)0)',
        '__section_end(...)=((void*)0)',
        '__section_size(...)=((size_t)0)',
        '__segment_begin(...)=((void*)0)',
        '__segment_end(...)=((void*)0)',
        '__segment_size(...)=((size_t)0)',
        '__DATA_MEMORY_LIST1__()=',
        '__ramfunc=',
        '__weak=__attribute__((weak))'
    )

    $arguments = [Collections.Generic.List[string]]::new()
    $arguments.Add('clang')
    $arguments.Add('--target=arm-none-eabi')
    if ($cpu) { $arguments.Add("-mcpu=$cpu") }
    if ($fpu) {
        $arguments.Add("-mfpu=$fpu")
        $arguments.Add('-mfloat-abi=hard')
    }
    if ($extension -eq '.c') {
        $arguments.Add('-std=gnu11')
    }
    else {
        $arguments.Add('-std=gnu++17')
    }
    $arguments.AddRange([string[]] $other)
    $arguments.Add("-I$CompatInclude")

    foreach ($define in @($officialIndexerDefines) + @($AdditionalDefines) + @($defines)) {
        $arguments.Add("-D$define")
    }
    foreach ($include in $includes | Select-Object -Unique) {
        $arguments.Add("-I$include")
    }
    foreach ($preinclude in $preincludes) {
        $arguments.Add('-include')
        $arguments.Add($preinclude)
    }
    $arguments.Add('-c')
    $arguments.Add($source)

    return [ordered]@{
        directory = $WorkingDirectory
        file = $source
        arguments = $arguments.ToArray()
    }
}

$projectPath = Resolve-ProjectPath $Project
$configurationName = Resolve-ConfigurationName $projectPath $Configuration
$iarBuildPath = Resolve-IarBuildPath $IarBuild
$projectDirectory = Split-Path -Parent $projectPath
$destinationDirectory = if ($OutputDirectory) {
    [IO.Path]::GetFullPath($OutputDirectory)
}
else {
    Find-RepositoryRoot $projectDirectory
}

$compatInclude = Join-Path $PSScriptRoot 'clangd-compat\include'
if (-not (Test-Path -LiteralPath $compatInclude)) {
    throw "Compatibility headers were not found: $compatInclude"
}

Write-Host "Reading IAR configuration '$configurationName' from $projectPath"
$dryRunOutput = @(& $iarBuildPath $projectPath '-dryrun' $configurationName '-log' 'all' 2>&1 | ForEach-Object { $_.ToString() })

$entries = [Collections.Generic.List[object]]::new()
foreach ($line in $dryRunOutput) {
    if ($line -match '^>iccarm\.exe\s+') {
        $tokens = [WindowsCommandLine]::Split($line.Substring(1))
        $entry = Convert-IarCommand $tokens $destinationDirectory $compatInclude $ExtraDefine
        if ($entry) { $entries.Add($entry) }
    }
}

if ($entries.Count -eq 0) {
    $tail = ($dryRunOutput | Select-Object -Last 20) -join [Environment]::NewLine
    throw "IAR did not emit any C/C++ compiler commands. Output tail:$([Environment]::NewLine)$tail"
}

[IO.Directory]::CreateDirectory($destinationDirectory) | Out-Null
$outputPath = Join-Path $destinationDirectory 'compile_commands.json'
$json = ConvertTo-Json -InputObject $entries.ToArray() -Depth 6
[IO.File]::WriteAllText($outputPath, $json, [Text.UTF8Encoding]::new($false))

Write-Host "Generated $outputPath"
Write-Host "Compiler entries: $($entries.Count)"
Write-Host 'Restart clangd after regeneration (:lsp restart in Neovim).'

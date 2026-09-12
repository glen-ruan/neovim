[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Project,

    [Parameter(Position = 1)]
    [string] $Target,

    [string] $UV4,

    [string] $OutputDirectory,

    [string[]] $ExtraDefine = @()
)

$ErrorActionPreference = 'Stop'

function Resolve-UV4Path {
    param([string] $RequestedPath)

    if ($RequestedPath) {
        return (Resolve-Path -LiteralPath $RequestedPath).Path
    }
    if ($env:UV4_EXE -and (Test-Path -LiteralPath $env:UV4_EXE)) {
        return (Resolve-Path -LiteralPath $env:UV4_EXE).Path
    }

    $command = Get-Command 'UV4.exe' -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    foreach ($candidate in @(
        'C:\Keil_v5\UV4\UV4.exe',
        'C:\Keil\UV4\UV4.exe'
    )) {
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw 'UV4.exe was not found. Pass -UV4 or set the UV4_EXE environment variable.'
}
function Resolve-TargetName {
    param(
        [xml] $ProjectXml,
        [string] $RequestedTarget
    )

    $names = @($ProjectXml.Project.Targets.Target | ForEach-Object { [string] $_.TargetName })
    if ($RequestedTarget) {
        if ($names -notcontains $RequestedTarget) {
            throw "Target '$RequestedTarget' was not found. Available: $($names -join ', ')"
        }
        return $RequestedTarget
    }
    if ($names.Count -eq 1) {
        return $names[0]
    }
    throw "This project has multiple targets. Pass -Target. Available: $($names -join ', ')"
}

function Quote-ProcessArgument {
    param([string] $Value)
    return '"' + $Value.Replace('\', '\').Replace('"', '\"') + '"'
}

function Split-List {
    param([string] $Value)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return @()
    }
    return @($Value -split '[;,]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

function Resolve-RelativePath {
    param(
        [string] $BaseDirectory,
        [string] $Path
    )
    if ([IO.Path]::IsPathRooted($Path)) {
        return [IO.Path]::GetFullPath($Path.TrimEnd('\', '/'))
    }
    return [IO.Path]::GetFullPath((Join-Path $BaseDirectory $Path.TrimEnd('\', '/')))
}

function Get-ClangCpu {
    param([string] $CpuDescription)

    if ($CpuDescription -match 'CPUTYPE\("([^"]+)"\)') {
        return $Matches[1].ToLowerInvariant().Replace('_', '-').Replace(' ', '')
    }
    throw "Could not determine the CPU from: $CpuDescription"
}

function Get-ClangFpu {
    param(
        [string] $Cpu,
        [string] $FpuDescription
    )

    if ($FpuDescription -notmatch 'SP_FPU|DP_FPU') {
        return $null
    }
    if ($Cpu -match 'cortex-m7|cortex-m33|cortex-m35|cortex-m55|cortex-m85') {
        return if ($FpuDescription -match 'DP_FPU') { 'fpv5-d16' } else { 'fpv5-sp-d16' }
    }
    return 'fpv4-sp-d16'
}

function Get-FileValues {
    param(
        [object] $FileNode,
        [string] $Name
    )
    $property = $FileNode.PSObject.Properties[$Name]
    if (-not $property) { return @() }
    return Split-List ([string] $property.Value
    )
}

$projectPath = (Resolve-Path -LiteralPath $Project).Path
if ([IO.Path]::GetExtension($projectPath) -ne '.uvprojx') {
    throw 'Project must be a .uvprojx file.'
}

[xml] $projectXml = Get-Content -Raw -LiteralPath $projectPath
$targetName = Resolve-TargetName $projectXml $Target
$projectDirectory = Split-Path -Parent $projectPath
$uv4Path = Resolve-UV4Path $UV4
$destinationDirectory = if ($OutputDirectory) {
    [IO.Path]::GetFullPath($OutputDirectory)
}
else {
    $projectDirectory
}

$targetNode = @($projectXml.Project.Targets.Target | Where-Object { [string] $_.TargetName -eq $targetName })[0]
$cpuDescription = [string] $targetNode.TargetOption.TargetCommonOption.Cpu
$cpu = Get-ClangCpu $cpuDescription

$projectBaseName = [IO.Path]::GetFileNameWithoutExtension($projectPath)
$cprjPath = Join-Path $projectDirectory "$projectBaseName.$targetName.cprj"
$previousCprj = if (Test-Path -LiteralPath $cprjPath) { [IO.File]::ReadAllBytes($cprjPath) } else { $null }

try {
    Write-Host "Exporting Keil target '$targetName' from $projectPath"
    $argumentLine = @(
        '-j0',
        '-et',
        (Quote-ProcessArgument $projectPath),
        '-t',
        (Quote-ProcessArgument $targetName)
    ) -join ' '

    $process = Start-Process -FilePath $uv4Path -ArgumentList $argumentLine -Wait -PassThru -WindowStyle Hidden
    if ($process.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $cprjPath)) {
        throw "µVision export failed with exit code $($process.ExitCode)."
    }

    [xml] $cprj = Get-Content -Raw -LiteralPath $cprjPath
    $compiler = [string] $cprj.cprj.compilers.compiler.name
    $cprjTarget = $cprj.cprj.target
    $fpu = Get-ClangFpu $cpu ([string] $cprjTarget.Dfpu)

    $baseIncludes = @(Split-List ([string] $cprjTarget.includes) | ForEach-Object {
        Resolve-RelativePath $projectDirectory $_
    })
    $baseDefines = @(Split-List ([string] $cprjTarget.defines))
    $compatInclude = Join-Path $PSScriptRoot 'clangd-compat\include'
    if (-not (Test-Path -LiteralPath $compatInclude)) {
        throw "Compatibility headers were not found: $compatInclude"
    }

    $compatDefines = @(
        '__weak=__attribute__((weak))',
        '__packed=__attribute__((packed))',
        '__align(x)=__attribute__((aligned(x)))',
        '__forceinline=inline __attribute__((always_inline))',
        '__irq=',
        '__pure=__attribute__((pure))',
        '__value_in_regs=',
        '__softfp='
    )

    $entries = [Collections.Generic.List[object]]::new()
    foreach ($group in @($cprj.cprj.files.group)) {
        foreach ($file in @($group.file)) {
            $category = [string] $file.category
            if ($category -notin @('sourceC', 'sourceCpp', 'sourceCxx')) {
                continue
            }

            $source = Resolve-RelativePath $projectDirectory ([string] $file.name)
            $arguments = [Collections.Generic.List[string]]::new()
            $arguments.Add('clang')
            $arguments.Add('--target=arm-none-eabi')
            $arguments.Add("-mcpu=$cpu")
            if ($fpu) {
                $arguments.Add("-mfpu=$fpu")
                $arguments.Add('-mfloat-abi=softfp')
            }
            if ([IO.Path]::GetExtension($source).ToLowerInvariant() -eq '.c') {
                $arguments.Add('-std=gnu11')
            }
            else {
                $arguments.Add('-std=gnu++17')
            }
            if ([string] $cprjTarget.Dendian -match '^Big') {
                $arguments.Add('-mbig-endian')
            }
            $arguments.Add('-fms-extensions')

            foreach ($define in @($compatDefines) + @($ExtraDefine) + @($baseDefines) + @(Get-FileValues $file 'defines')) {
                $arguments.Add("-D$define")
            }
            $allIncludes = @($baseIncludes) + @(Get-FileValues $file 'includes' | ForEach-Object {
                Resolve-RelativePath $projectDirectory $_
            })
            foreach ($include in $allIncludes | Select-Object -Unique) {
                $arguments.Add("-I$include")
            }
            # 兜底桩头必须排在 include 搜索路径的最后：放在最前会遮蔽 ArmCC 与
            # clang 自带的 stdio.h / string.h 等，让桩里没声明的符号全部报未声明。
            $arguments.Add("-I$compatInclude")
            $arguments.Add('-c')
            $arguments.Add($source)

            $entries.Add([ordered]@{
                directory = $destinationDirectory
                file = $source
                arguments = $arguments.ToArray()
            })
        }
    }

    if ($entries.Count -eq 0) {
        throw 'The exported target contains no C/C++ source files.'
    }

    [IO.Directory]::CreateDirectory($destinationDirectory) | Out-Null
    $outputPath = Join-Path $destinationDirectory 'compile_commands.json'
    $json = ConvertTo-Json -InputObject $entries.ToArray() -Depth 6
    [IO.File]::WriteAllText($outputPath, $json, [Text.UTF8Encoding]::new($false))

    $selectionPath = Join-Path $destinationDirectory '.clangd-keil-project.json'
    $selection = [ordered]@{
        project = $projectPath
        target = $targetName
        compiler = $compiler
        generatedAt = [DateTime]::Now.ToString('s')
    } | ConvertTo-Json
    [IO.File]::WriteAllText($selectionPath, $selection, [Text.UTF8Encoding]::new($false))

    Write-Host "Generated $outputPath"
    Write-Host "Target: $targetName; compiler: $compiler; CPU: $cpu; source entries: $($entries.Count)"
    Write-Host 'Restart clangd after regeneration (:lsp restart in Neovim).'
}
finally {
    if ($null -ne $previousCprj) {
        [IO.File]::WriteAllBytes($cprjPath, $previousCprj)
    }
    elseif (Test-Path -LiteralPath $cprjPath) {
        Remove-Item -LiteralPath $cprjPath -Force
    }
}

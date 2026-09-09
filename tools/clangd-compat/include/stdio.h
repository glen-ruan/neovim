#ifndef CLANGD_COMPAT_STDIO_H
#define CLANGD_COMPAT_STDIO_H

#include <stdarg.h>
#include <stddef.h>

typedef struct __clangd_compat_FILE {
    unsigned char __opaque;
} FILE;

#ifndef EOF
#define EOF (-1)
#endif

extern FILE *stdin;
extern FILE *stdout;
extern FILE *stderr;

int printf(const char *format, ...);
int sprintf(char *buffer, const char *format, ...);
int snprintf(char *buffer, size_t size, const char *format, ...);
int vsnprintf(char *buffer, size_t size, const char *format, va_list args);
int vprintf(const char *format, va_list args);
int fputc(int character, FILE *stream);
int puts(const char *text);

#endif

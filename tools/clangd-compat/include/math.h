#ifndef CLANGD_COMPAT_MATH_H
#define CLANGD_COMPAT_MATH_H

#define HUGE_VAL (__builtin_huge_val())
#define HUGE_VALF (__builtin_huge_valf())
#define INFINITY (__builtin_inff())
#define NAN (__builtin_nanf(""))

double sin(double value);
float sinf(float value);
double cos(double value);
float cosf(float value);
double sqrt(double value);
float sqrtf(float value);
double fabs(double value);
float fabsf(float value);
double pow(double base, double exponent);
float powf(float base, float exponent);
double atan2(double y, double x);
float atan2f(float y, float x);

#endif

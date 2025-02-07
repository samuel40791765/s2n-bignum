/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "LICENSE" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

// ****************************************************************************
// Benchmark the various s2n-bignum functions
// ****************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <time.h>
#include <math.h>

#include "../include/s2n-bignum.h"

// Controls whether an explanatory header goes on the output

#define EXPLANATION 1

// Parameters controlling the number of repetitions. The total number of
// repetitions per function is OUTER_REPS * 65 * INNER_REPS, with the 65
// arising because the function is systematically run on pseudo-random
// numbers with bit densities from d=0...64 to check for variations.

#define INNER_REPS UINT64_C(10000)
#define OUTER_REPS 5

// Big buffers for testing purposes

#define BUFFERSIZE 350
static uint64_t b0[BUFFERSIZE];
static uint64_t b1[BUFFERSIZE];
static uint64_t b2[BUFFERSIZE];
static uint64_t b3[BUFFERSIZE];

static uint64_t bb[16][BUFFERSIZE];

// Source of random 64-bit numbers with bit density
// 0 = all zeros, 32 = "average", 64 = all ones
// Then a generic one with the density itself randomized

uint64_t random64d(int density)
{ int i;
  uint64_t r = 0, b = 0;
  for (i = 0; i < 64; i++)
   { b = ((rand() & 0x3F) < density);
     r = (r + r) + b;
   }
  return r;
}

uint64_t random64(void)
{ int d = ((unsigned) rand() & 0xFFFF) % 65;
  return random64d(d);
}

// Fill size-k bignum array with random digits, again with density option

void random_bignumd(uint64_t k,uint64_t *a,int density)
{ uint64_t i;
  for (i = 0; i < k; ++i) a[i] = random64d(density);
}

void random_bignum(uint64_t k,uint64_t *a)
{ int d = ((unsigned) rand() & 0xFFFF) % 65;
  random_bignumd(k,a,d);
}

// Core repetition of the function being benchmarked. The function
// is recomputed on the same inputs each time without trying to
// enforce serial dependency.

#define repeat(bod) {int i; for (i = 0; i < INNER_REPS; ++i) bod; }

#define CORE_REPS (65 * OUTER_REPS)
#define CORE_REPF ((double) CORE_REPS)

// Time a single function harness "f" for function "name".
// The "enabled" flag allows machine-dependent enabling or disabling of a test.

static double arithmean = 0.0, geomean = 0.0;
int tests = 0;

void timingtest(int enabled,char *name,void (*f)(void))
{ uint64_t t, i, d;
  double mean, variance, stddev, opsec, tt, dd;
  double timing[CORE_REPS];
  double covariance, dvariance, dstddev;
  clock_t start_time, finish_time, time_diff;

  if (!enabled)
   { printf("%-32s:             *** NOT APPLICABLE  ***\n",name);
     return;
   }

  // One more little warmup

  (*f)();

  // Main timing loop, recording runtimes in nanoseconds in timing[i]

  for (i = 0; i < CORE_REPS; ++i)
   { d = i % 65;
     random_bignumd(BUFFERSIZE,b0,d);
     random_bignumd(BUFFERSIZE,b1,d);
     random_bignumd(BUFFERSIZE,b2,d);
     random_bignumd(BUFFERSIZE,b3,d);
     start_time = clock();
     (*f)();
     finish_time = clock();
     time_diff = finish_time - start_time;
     timing[i] = (1e9 * (double) time_diff) / ((double) INNER_REPS * (double) CLOCKS_PER_SEC);
   }

  // Compute the statistics

  mean = 0.0;
  for (i = 0; i < CORE_REPS; ++i) mean += timing[i];
  mean = mean / CORE_REPF;

  variance = covariance = dvariance = 0.0;
  for (i = 0; i < CORE_REPS; ++i)
   { tt = timing[i] - mean;
     dd = (double) (i % 65) - 32.5;
     variance += tt * tt;
     dvariance += dd * dd;
     covariance += tt * dd;
   }
  variance = variance / CORE_REPF;
  covariance = covariance / CORE_REPF;;
  dvariance = dvariance / CORE_REPF;;

  stddev = sqrt(variance);
  dstddev = sqrt(dvariance);
  opsec = 1e9 / mean;

  printf("%-32s: %7.1f ns each (var %4.1f%%, corr %5.2f) = %10.0f ops/sec\n",
         name,mean,100.0*stddev/mean,covariance / (stddev * dstddev),opsec);

  arithmean += mean;
  geomean += log(mean);
  ++tests;
}

// Decide whether machine supports BMI and ADX in the x86 case

#ifdef __x86_64__

int cpuid_extendedfeatures(void)
{ int a = 7, b = 0, c = 0, d = 0;
  asm ("cpuid\n\t"
    : "=a" (a), "=b" (b), "=c" (c), "=d" (d)
    : "0" (a), "2" (c));
  return b;
}

int full_isa_support(void)
{ int c = cpuid_extendedfeatures();
  return (c & (1ul<<8)) && (c & (1ul<<19));
}

#else

int full_isa_support(void)
{ return 1;
}

#endif

// Wrappers round the functions to call uniformly

void call_bignum_add__4_4(void) repeat(bignum_add(4,b0,4,b1,4,b2))

void call_bignum_add__6_6(void) repeat(bignum_add(6,b0,6,b1,6,b2))

void call_bignum_add__32_32(void) repeat(bignum_add(32,b0,32,b1,32,b2))

void call_bignum_sub__4_4(void) repeat(bignum_sub(4,b0,4,b1,4,b2))

void call_bignum_sub__6_6(void) repeat(bignum_sub(6,b0,6,b1,6,b2))

void call_bignum_sub__32_32(void) repeat(bignum_sub(32,b0,32,b1,32,b2))

void call_bignum_add_p25519(void) repeat(bignum_add_p25519(b0,b1,b2))

void call_bignum_add_p256(void) repeat(bignum_add_p256(b0,b1,b2))

void call_bignum_add_p256k1(void) repeat(bignum_add_p256k1(b0,b1,b2))

void call_bignum_add_p384(void) repeat(bignum_add_p384(b0,b1,b2))

void call_bignum_add_p521(void) repeat(bignum_add_p521(b0,b1,b2))

void call_bignum_sub_p25519(void) repeat(bignum_sub_p25519(b0,b1,b2))

void call_bignum_sub_p256(void) repeat(bignum_sub_p256(b0,b1,b2))

void call_bignum_sub_p256k1(void) repeat(bignum_sub_p256k1(b0,b1,b2))

void call_bignum_sub_p384(void) repeat(bignum_sub_p384(b0,b1,b2))

void call_bignum_sub_p521(void) repeat(bignum_sub_p521(b0,b1,b2))

void call_bignum_cmul_p25519(void) repeat(bignum_cmul_p25519(b0,b1[0],b2))

void call_bignum_cmul_p25519_alt(void) repeat(bignum_cmul_p25519_alt(b0,b1[0],b2))

void call_bignum_cmul_p256(void) repeat(bignum_cmul_p256(b0,b1[0],b2))

void call_bignum_cmul_p256_alt(void) repeat(bignum_cmul_p256_alt(b0,b1[0],b2))

void call_bignum_cmul_p256k1(void) repeat(bignum_cmul_p256k1(b0,b1[0],b2))

void call_bignum_cmul_p256k1_alt(void) repeat(bignum_cmul_p256k1_alt(b0,b1[0],b2))

void call_bignum_cmul_p384(void) repeat(bignum_cmul_p384(b0,b1[0],b2))

void call_bignum_cmul_p384_alt(void) repeat(bignum_cmul_p384_alt(b0,b1[0],b2))

void call_bignum_cmul_p521(void) repeat(bignum_cmul_p521(b0,b1[0],b2))

void call_bignum_cmul_p521_alt(void) repeat(bignum_cmul_p521_alt(b0,b1[0],b2))

void call_bignum_optneg_p256(void) repeat(bignum_optneg_p256(b0,b1[0],b2))

void call_bignum_optneg_p256k1(void) repeat(bignum_optneg_p256k1(b0,b1[0],b2))

void call_bignum_optneg_p384(void) repeat(bignum_optneg_p384(b0,b1[0],b2))

void call_bignum_optneg_p521(void) repeat(bignum_optneg_p521(b0,b1[0],b2))

void call_bignum_deamont_p256(void) repeat(bignum_deamont_p256(b0,b1))

void call_bignum_deamont_p256_alt(void) repeat(bignum_deamont_p256_alt(b0,b1))

void call_bignum_deamont_p256k1(void) repeat(bignum_deamont_p256k1(b0,b1))

void call_bignum_deamont_p384(void) repeat(bignum_deamont_p384(b0,b1))

void call_bignum_deamont_p384_alt(void) repeat(bignum_deamont_p384_alt(b0,b1))

void call_bignum_deamont_p521(void) repeat(bignum_deamont_p521(b0,b1))

void call_bignum_demont_p256(void) repeat(bignum_demont_p256(b0,b1))

void call_bignum_demont_p256_alt(void) repeat(bignum_demont_p256_alt(b0,b1))

void call_bignum_demont_p256k1(void) repeat(bignum_demont_p256k1(b0,b1))

void call_bignum_demont_p384(void) repeat(bignum_demont_p384(b0,b1))

void call_bignum_demont_p384_alt(void) repeat(bignum_demont_p384_alt(b0,b1))

void call_bignum_demont_p521(void) repeat(bignum_demont_p521(b0,b1))

void call_bignum_tomont_p256(void) repeat(bignum_tomont_p256(b0,b1))

void call_bignum_tomont_p256_alt(void) repeat(bignum_tomont_p256_alt(b0,b1))

void call_bignum_tomont_p256k1(void) repeat(bignum_tomont_p256k1(b0,b1))

void call_bignum_tomont_p256k1_alt(void) repeat(bignum_tomont_p256k1_alt(b0,b1))

void call_bignum_tomont_p384(void) repeat(bignum_tomont_p384(b0,b1))

void call_bignum_tomont_p384_alt(void) repeat(bignum_tomont_p384_alt(b0,b1))

void call_bignum_tomont_p521(void) repeat(bignum_tomont_p521(b0,b1))

void call_bignum_double_p256(void) repeat(bignum_double_p256(b0,b1))

void call_bignum_double_p256k1(void) repeat(bignum_double_p256k1(b0,b1))

void call_bignum_double_p384(void) repeat(bignum_double_p384(b0,b1))

void call_bignum_double_p521(void) repeat(bignum_double_p521(b0,b1))

void call_bignum_half_p256(void) repeat(bignum_half_p256(b0,b1))

void call_bignum_half_p256k1(void) repeat(bignum_half_p256k1(b0,b1))

void call_bignum_half_p384(void) repeat(bignum_half_p384(b0,b1))

void call_bignum_half_p521(void) repeat(bignum_half_p521(b0,b1))

void call_bignum_triple_p256(void) repeat(bignum_triple_p256(b0,b1))

void call_bignum_triple_p256_alt(void) repeat(bignum_triple_p256_alt(b0,b1))

void call_bignum_triple_p256k1(void) repeat(bignum_triple_p256k1(b0,b1))

void call_bignum_triple_p256k1_alt(void) repeat(bignum_triple_p256k1_alt(b0,b1))

void call_bignum_triple_p384(void) repeat(bignum_triple_p384(b0,b1))

void call_bignum_triple_p384_alt(void) repeat(bignum_triple_p384_alt(b0,b1))

void call_bignum_triple_p521(void) repeat(bignum_triple_p521(b0,b1))

void call_bignum_triple_p521_alt(void) repeat(bignum_triple_p521_alt(b0,b1))

void call_bignum_montmul_p256(void) repeat(bignum_montmul_p256(b0,b1,b2))

void call_bignum_montmul_p256_alt(void) repeat(bignum_montmul_p256_alt(b0,b1,b2))

void call_bignum_montmul_p256k1(void) repeat(bignum_montmul_p256k1(b0,b1,b2))

void call_bignum_montmul_p256k1_alt(void) repeat(bignum_montmul_p256k1_alt(b0,b1,b2))

void call_bignum_montmul_p384(void) repeat(bignum_montmul_p384(b0,b1,b2))

void call_bignum_montmul_p384_alt(void) repeat(bignum_montmul_p384_alt(b0,b1,b2))

void call_bignum_montmul_p521(void) repeat(bignum_montmul_p521(b0,b1,b2))

void call_bignum_montmul_p521_alt(void) repeat(bignum_montmul_p521_alt(b0,b1,b2))

void call_bignum_montsqr_p256(void) repeat(bignum_montsqr_p256(b0,b1))

void call_bignum_montsqr_p256_alt(void) repeat(bignum_montsqr_p256_alt(b0,b1))

void call_bignum_montsqr_p256k1(void) repeat(bignum_montsqr_p256k1(b0,b1))

void call_bignum_montsqr_p256k1_alt(void) repeat(bignum_montsqr_p256k1_alt(b0,b1))

void call_bignum_montsqr_p384(void) repeat(bignum_montsqr_p384(b0,b1))

void call_bignum_montsqr_p384_alt(void) repeat(bignum_montsqr_p384_alt(b0,b1))

void call_bignum_montsqr_p521(void) repeat(bignum_montsqr_p521(b0,b1))

void call_bignum_montsqr_p521_alt(void) repeat(bignum_montsqr_p521_alt(b0,b1))

void call_bignum_neg_p25519(void) repeat(bignum_neg_p25519(b0,b1))

void call_bignum_neg_p256(void) repeat(bignum_neg_p256(b0,b1))

void call_bignum_neg_p256k1(void) repeat(bignum_neg_p256k1(b0,b1))

void call_bignum_neg_p384(void) repeat(bignum_neg_p384(b0,b1))

void call_bignum_neg_p521(void) repeat(bignum_neg_p521(b0,b1))

void call_bignum_sqr_p25519(void) repeat(bignum_sqr_p25519(b0,b1))

void call_bignum_sqr_p25519_alt(void) repeat(bignum_sqr_p25519_alt(b0,b1))

void call_bignum_sqr_p256k1(void) repeat(bignum_sqr_p256k1(b0,b1))

void call_bignum_sqr_p256k1_alt(void) repeat(bignum_sqr_p256k1_alt(b0,b1))

void call_bignum_sqr_p521(void) repeat(bignum_sqr_p521(b0,b1))

void call_bignum_sqr_p521_alt(void) repeat(bignum_sqr_p521_alt(b0,b1))

void call_bignum_mul_p25519(void) repeat(bignum_mul_p25519(b0,b1,b2))

void call_bignum_mul_p25519_alt(void) repeat(bignum_mul_p25519_alt(b0,b1,b2))

void call_bignum_mul_p256k1(void) repeat(bignum_mul_p256k1(b0,b1,b2))

void call_bignum_mul_p256k1_alt(void) repeat(bignum_mul_p256k1_alt(b0,b1,b2))

void call_bignum_mul_p521(void) repeat(bignum_mul_p521(b0,b1,b2))

void call_bignum_mul_p521_alt(void) repeat(bignum_mul_p521_alt(b0,b1,b2))

void call_bignum_mul_4_8(void) repeat(bignum_mul_4_8(b0,b1,b2))

void call_bignum_mul_4_8_alt(void) repeat(bignum_mul_4_8_alt(b0,b1,b2))

void call_bignum_mul_6_12(void) repeat(bignum_mul_6_12(b0,b1,b2))

void call_bignum_mul_6_12_alt(void) repeat(bignum_mul_6_12_alt(b0,b1,b2))

void call_bignum_mul_8_16(void) repeat(bignum_mul_8_16(b0,b1,b2))

void call_bignum_mul_8_16_alt(void) repeat(bignum_mul_8_16_alt(b0,b1,b2))

void call_bignum_sqr_4_8(void) repeat(bignum_sqr_4_8(b0,b1))

void call_bignum_sqr_4_8_alt(void) repeat(bignum_sqr_4_8_alt(b0,b1))

void call_bignum_sqr_6_12(void) repeat(bignum_sqr_6_12(b0,b1))

void call_bignum_sqr_6_12_alt(void) repeat(bignum_sqr_6_12_alt(b0,b1))

void call_bignum_sqr_8_16(void) repeat(bignum_sqr_8_16(b0,b1))

void call_bignum_sqr_8_16_alt(void) repeat(bignum_sqr_8_16_alt(b0,b1))

void call_bignum_kmul_16_32(void) repeat(bignum_kmul_16_32(b0,b1,b2,b3))

void call_bignum_ksqr_16_32(void) repeat(bignum_ksqr_16_32(b0,b1,b2))

void call_bignum_kmul_32_64(void) repeat(bignum_kmul_32_64(b0,b1,b2,b3))

void call_bignum_ksqr_32_64(void) repeat(bignum_ksqr_32_64(b0,b1,b2))

void call_bignum_mul__4_8(void) repeat(bignum_mul(8,b0,4,b1,4,b2))

void call_bignum_mul__6_12(void) repeat(bignum_mul(12,b0,6,b1,6,b2))

void call_bignum_mul__8_16(void) repeat(bignum_mul(16,b0,8,b1,8,b2))

void call_bignum_mul__16_32(void) repeat(bignum_mul(32,b0,16,b1,16,b2))

void call_bignum_mul__32_64(void) repeat(bignum_mul(64,b0,32,b1,32,b2))

void call_bignum_madd__4_8(void) repeat(bignum_madd(8,b0,4,b1,4,b2))

void call_bignum_madd__6_12(void) repeat(bignum_madd(12,b0,6,b1,6,b2))

void call_bignum_madd__8_16(void) repeat(bignum_madd(16,b0,8,b1,8,b2))

void call_bignum_madd__16_32(void) repeat(bignum_madd(32,b0,16,b1,16,b2))

void call_bignum_madd__32_64(void) repeat(bignum_madd(64,b0,32,b1,32,b2))

void call_bignum_sqr__4_8(void) repeat(bignum_sqr(8,b0,4,b1))

void call_bignum_sqr__6_12(void) repeat(bignum_sqr(12,b0,6,b1))

void call_bignum_sqr__8_16(void) repeat(bignum_sqr(16,b0,8,b1))

void call_bignum_sqr__16_32(void) repeat(bignum_sqr(32,b0,16,b1))

void call_bignum_sqr__32_64(void) repeat(bignum_sqr(64,b0,32,b1))

void call_word_bytereverse(void) repeat(word_bytereverse(b0[0]))

void call_word_clz(void) repeat(word_clz(b0[0]))

void call_word_ctz(void) repeat(word_ctz(b0[0]))

void call_word_max(void) repeat(word_max(b0[0],b1[0]))

void call_word_min(void) repeat(word_min(b0[0],b1[0]))

void call_word_negmodinv(void) repeat(word_negmodinv(b0[0]))

void call_word_recip(void) repeat(word_recip(b0[0]))

void call_bignum_bigendian_4(void) repeat(bignum_bigendian_4(b0,b1))
void call_bignum_littleendian_4(void) repeat(bignum_littleendian_4(b0,b1))
void call_bignum_tolebytes_4(void) repeat(bignum_tolebytes_4((unsigned char *)b0,b1))
void call_bignum_tobebytes_4(void) repeat(bignum_tobebytes_4((unsigned char *)b0,b1))
void call_bignum_fromlebytes_4(void) repeat(bignum_fromlebytes_4(b0,(unsigned char *) b1))
void call_bignum_frombebytes_4(void) repeat(bignum_frombebytes_4(b0,(unsigned char *) b1))

void call_bignum_bigendian_6(void) repeat(bignum_bigendian_6(b0,b1))
void call_bignum_littleendian_6(void) repeat(bignum_littleendian_6(b0,b1))
void call_bignum_tolebytes_6(void) repeat(bignum_tolebytes_6((unsigned char *)b0,b1))
void call_bignum_tolebytes_p521(void) repeat(bignum_tolebytes_p521((unsigned char *)b0,b1))
void call_bignum_tobebytes_6(void) repeat(bignum_tobebytes_6((unsigned char *)b0,b1))
void call_bignum_fromlebytes_6(void) repeat(bignum_fromlebytes_6(b0,(unsigned char *) b1))
void call_bignum_fromlebytes_p521(void) repeat(bignum_fromlebytes_p521(b0,(unsigned char *) b1))
void call_bignum_frombebytes_6(void) repeat(bignum_frombebytes_6(b0,(unsigned char *) b1))

void call_bignum_mod_n256_4(void) repeat(bignum_mod_n256_4(b0,b1))
void call_bignum_mod_p256_4(void) repeat(bignum_mod_p256_4(b0,b1))
void call_bignum_mod_n256k1_4(void) repeat(bignum_mod_n256k1_4(b0,b1))
void call_bignum_mod_p256k1_4(void) repeat(bignum_mod_p256k1_4(b0,b1))
void call_bignum_mod_n384_6(void) repeat(bignum_mod_n384_6(b0,b1))
void call_bignum_mod_p384_6(void) repeat(bignum_mod_p384_6(b0,b1))
void call_bignum_mod_n521_9(void) repeat(bignum_mod_n521_9(b0,b1))
void call_bignum_mod_n521_9_alt(void) repeat(bignum_mod_n521_9_alt(b0,b1))
void call_bignum_mod_p521_9(void) repeat(bignum_mod_p521_9(b0,b1))

void call_bignum_mod_n256__8(void) repeat(bignum_mod_n256(b0,8,b1))
void call_bignum_mod_n256_alt__8(void) repeat(bignum_mod_n256_alt(b0,8,b1))
void call_bignum_mod_n384__12(void) repeat(bignum_mod_n384(b0,12,b1))
void call_bignum_mod_n384_alt__12(void) repeat(bignum_mod_n384_alt(b0,12,b1))
void call_bignum_mod_p256__8(void) repeat(bignum_mod_p256(b0,8,b1))
void call_bignum_mod_p256_alt__8(void) repeat(bignum_mod_p256_alt(b0,8,b1))
void call_bignum_mod_p384__12(void) repeat(bignum_mod_p384(b0,12,b1))
void call_bignum_mod_p384_alt__12(void) repeat(bignum_mod_p384_alt(b0,12,b1))

void call_bignum_nonzero_4(void) repeat(bignum_nonzero_4(b0))
void call_bignum_nonzero_6(void) repeat(bignum_nonzero_6(b0))

void call_bignum_mux_4(void) repeat(bignum_mux_4(b1[0],b0,b2,b3))
void call_bignum_mux_6(void) repeat(bignum_mux_6(b1[0],b0,b2,b3))

void call_bignum_bitfield__32(void) repeat(bignum_bitfield(32,b0,(b1[0] % 1000),(b2[0] % 70)))
void call_bignum_digit__32(void) repeat(bignum_digit(32,b0,(b1[0] % 70)))

void call_bignum_cmul__4_4(void) repeat(bignum_cmul(4,b0,b1[0],4,b2))
void call_bignum_cmul__6_6(void) repeat(bignum_cmul(6,b0,b1[0],6,b2))
void call_bignum_cmul__32_32(void) repeat(bignum_cmul(32,b0,b1[0],32,b2))

void call_bignum_cmadd__4_4(void) repeat(bignum_cmadd(4,b0,b1[0],4,b2))
void call_bignum_cmadd__6_6(void) repeat(bignum_cmadd(6,b0,b1[0],6,b2))
void call_bignum_cmadd__32_32(void) repeat(bignum_cmadd(32,b0,b1[0],32,b2))

void call_bignum_cmnegadd__4_4(void) repeat(bignum_cmnegadd(4,b0,b1[0],4,b2))
void call_bignum_cmnegadd__6_6(void) repeat(bignum_cmnegadd(6,b0,b1[0],6,b2))
void call_bignum_cmnegadd__32_32(void) repeat(bignum_cmnegadd(32,b0,b1[0],32,b2))

void call_bignum_cdiv__4_4(void) repeat(bignum_cdiv(4,b0,4,b1,b2[0]))
void call_bignum_cdiv__6_6(void) repeat(bignum_cdiv(6,b0,6,b1,b2[0]))
void call_bignum_cdiv__32_32(void) repeat(bignum_cdiv(32,b0,32,b1,b2[0]))

void call_bignum_cdiv_exact__4_4(void) repeat(bignum_cdiv_exact(4,b0,4,b1,b2[0]))
void call_bignum_cdiv_exact__6_6(void) repeat(bignum_cdiv_exact(6,b0,6,b1,b2[0]))
void call_bignum_cdiv_exact__32_32(void) repeat(bignum_cdiv_exact(32,b0,32,b1,b2[0]))

void call_bignum_cmod__4(void) repeat(bignum_cmod(4,b0,b1[0]))
void call_bignum_cmod__6(void) repeat(bignum_cmod(6,b0,b1[0]))
void call_bignum_cmod__32(void) repeat(bignum_cmod(32,b0,b1[0]))

void call_bignum_of_word__32(void) repeat(bignum_of_word(32,b0,b1[0]))
void call_bignum_divmod10__32(void) repeat(bignum_divmod10(32,b0))
void call_bignum_muladd10__32(void) repeat(bignum_muladd10(32,b0,b1[0]))

void call_bignum_normalize__32(void) repeat(bignum_normalize(32,b0))

void call_bignum_shl_small__32_32(void) repeat(bignum_shl_small(32,b0,32,b1,b2[0]))
void call_bignum_shr_small__32_32(void) repeat(bignum_shr_small(32,b0,32,b1,b2[0]))

void call_bignum_amontredc__32_16(void) repeat(bignum_amontredc(16,b0,32,b1,b2,16))
void call_bignum_montredc__32_16(void) repeat(bignum_montredc(16,b0,32,b1,b2,16))

void call_bignum_emontredc__4(void) repeat(bignum_emontredc(4,b0,b1,b2[0]))
void call_bignum_emontredc__6(void) repeat(bignum_emontredc(6,b0,b1,b2[0]))
void call_bignum_emontredc__32(void) repeat(bignum_emontredc(32,b0,b1,b2[0]))

void call_bignum_emontredc_8n__32(void) repeat(bignum_emontredc_8n(32,b0,b1,b2[0]))

void call_bignum_modoptneg__32(void) repeat(bignum_modoptneg(32,b0,b1[0],b2,b3))

void call_bignum_amontifier__32(void) repeat(bignum_amontifier(32,b0,b1,b2))

void call_bignum_amontmul__32(void) repeat(bignum_amontmul(32,b0,b1,b2,b3))

void call_bignum_amontsqr__32(void) repeat(bignum_amontsqr(32,b0,b1,b2))

void call_bignum_bitsize__32(void) repeat(bignum_bitsize(32,b1))

void call_bignum_cld__32(void) repeat(bignum_cld(32,b1))

void call_bignum_clz__32(void) repeat(bignum_clz(32,b1))

void call_bignum_coprime__4_4(void) repeat(bignum_coprime(4,b1,4,b2,b3))

void call_bignum_coprime__6_6(void) repeat(bignum_coprime(6,b1,6,b2,b3))

void call_bignum_coprime__16_16(void) repeat(bignum_coprime(16,b1,16,b2,b3))

void call_bignum_copy__32_32(void) repeat(bignum_copy(32,b0,32,b1))

void call_bignum_ctd__32(void) repeat(bignum_ctd(32,b1))

void call_bignum_ctz__32(void) repeat(bignum_ctz(32,b1))

void call_bignum_demont__32(void) repeat(bignum_demont(32,b0,b1,b2))

void call_bignum_digitsize__32(void) repeat(bignum_digitsize(32,b1))

void call_bignum_eq__32_32(void) repeat(bignum_eq(32,b1,32,b2))

void call_bignum_even__32(void) repeat(bignum_even(32,b1))

void call_bignum_ge__32_32(void) repeat(bignum_ge(32,b1,32,b2))

void call_bignum_gt__32_32(void) repeat(bignum_gt(32,b1,32,b2))

void call_bignum_iszero__32(void) repeat(bignum_iszero(32,b1))

void call_bignum_le__32_32(void) repeat(bignum_le(32,b1,32,b2))

void call_bignum_lt__32_32(void) repeat(bignum_lt(32,b1,32,b2))

void call_bignum_modadd__32(void) repeat(bignum_modadd(32,b0,b1,b2,b3))

void call_bignum_moddouble__32(void) repeat(bignum_moddouble(32,b0,b1,b2))

void call_bignum_modifier__32(void) repeat(bignum_modifier(32,b0,b1,b2))

void call_bignum_modinv__4(void) repeat(bignum_modinv(4,b0,b1,b2,b3))

void call_bignum_modinv__6(void) repeat(bignum_modinv(6,b0,b1,b2,b3))

void call_bignum_modinv__9(void) repeat(bignum_modinv(9,b0,b1,b2,b3))

void call_bignum_modinv__16(void) repeat(bignum_modinv(16,b0,b1,b2,b3))

void call_bignum_modsub__32(void) repeat(bignum_modsub(32,b0,b1,b2,b3))

void call_bignum_montifier__32(void) repeat(bignum_montifier(32,b0,b1,b2))

void call_bignum_montmul__32(void) repeat(bignum_montmul(32,b0,b1,b2,b3))

void call_bignum_montsqr__32(void) repeat(bignum_montsqr(32,b0,b1,b2))

void call_bignum_negmodinv__32(void) repeat(bignum_negmodinv(32,b0,b1))

void call_bignum_nonzero__32(void) repeat(bignum_nonzero(32,b1))

void call_bignum_odd__32(void) repeat(bignum_odd(32,b1))

void call_bignum_optadd__32(void) repeat(bignum_optadd(32,b0,b1,b2[0],b3))

void call_bignum_optneg__32(void) repeat(bignum_optneg(32,b0,b1[0],b2))

void call_bignum_optsub__32(void) repeat(bignum_optsub(32,b0,b1,b2[0],b3))

void call_bignum_optsubadd__32(void) repeat(bignum_optsubadd(32,b0,b1,b2[0],b3))

void call_bignum_pow2__32(void) repeat(bignum_pow2(32,b0,b1[0] % 1000))

void call_bignum_mux16__4()
{ int i, j;
  for (i = 0; i < 16; ++i) for (j = 0; j < 4; ++j)
    bb[i][j] = b1[(i+j)%BUFFERSIZE];
  repeat(bignum_mux16(4,b0,(uint64_t *)bb,b2[0]%16));
}

void call_bignum_mux16__6()
{ int i, j;
  for (i = 0; i < 16; ++i) for (j = 0; j < 6; ++j)
    bb[i][j] = b1[(i+j)%BUFFERSIZE];
  repeat(bignum_mux16(6,b0,(uint64_t *)bb,b2[0]%16));
}

void call_bignum_mux16__32()
{ int i, j;
  for (i = 0; i < 16; ++i) for (j = 0; j < 32; ++j)
    bb[i][j] = b1[(i+j)%BUFFERSIZE];
  repeat(bignum_mux16(32,b0,(uint64_t *)bb,b2[0]%16));
}

void call_curve25519_x25519(void) repeat(curve25519_x25519(b0,b1,b2))
void call_curve25519_x25519_alt(void) repeat(curve25519_x25519_alt(b0,b1,b2))

void call_curve25519_ladderstep(void) repeat(curve25519_ladderstep(b0,b1,b2,*b3))
void call_curve25519_ladderstep_alt(void) repeat(curve25519_ladderstep_alt(b0,b1,b2,*b3))
void call_curve25519_pxscalarmul(void) repeat(curve25519_pxscalarmul(b0,b1,b2))
void call_curve25519_pxscalarmul_alt(void) repeat(curve25519_pxscalarmul_alt(b0,b1,b2))

void call_p256_montjadd(void) repeat(p256_montjadd(b1,b2,b3))
void call_p256_montjdouble(void) repeat(p256_montjdouble(b1,b2))
void call_p256_montjmixadd(void) repeat(p256_montjmixadd(b1,b2,b3))

void call_p384_montjadd(void) repeat(p384_montjadd(b1,b2,b3))
void call_p384_montjdouble(void) repeat(p384_montjdouble(b1,b2))
void call_p384_montjmixadd(void) repeat(p384_montjmixadd(b1,b2,b3))

void call_p521_jadd(void) repeat(p521_jadd(b1,b2,b3))
void call_p521_jdouble(void) repeat(p521_jdouble(b1,b2))
void call_p521_jmixadd(void) repeat(p521_jmixadd(b1,b2,b3))

void call_secp256k1_jadd(void) repeat(secp256k1_jadd(b1,b2,b3))
void call_secp256k1_jdouble(void) repeat(secp256k1_jdouble(b1,b2))
void call_secp256k1_jmixadd(void) repeat(secp256k1_jmixadd(b1,b2,b3))

int main(void)
{
  int bmi = full_isa_support();
  int all = 1;

  // Explain the results first if EXPLANATION is set

  #if EXPLANATION
  printf("---------------------------------------------------------------------------------\n");
  printf("Timings in nanoseconds (ns) per call of function, average across input values.\n");
  printf("var = coefficient of variation (stddev / mean) across input values, as percentage.\n");
  printf("corr = correlation coefficient versus the bit density of input values.\n");
  printf("ops/sec = average number of operations per second = 10^9 / average timing.\n");
  printf("ARITHMEAN = arithmetic mean of all average function times, in nanoseconds.\n");
  printf("GEOMEAN = geometric mean of all average function times, in nanoseconds.\n");
  printf("---------------------------------------------------------------------------------\n\n");
  #endif

  // Initialize the random seed to a known but arbitrary value

  srand(1234567);

  // Warm things up? This is a bit ad hoc but may help determinacy

  int i;
  for (i = 0; i < 1000000; ++i) bignum_montmul(12,b0,b1,b2,b3);

  // Now the main tests

  timingtest(all,"bignum_add (4x4->4)",call_bignum_add__4_4);
  timingtest(all,"bignum_add (6x6->6)",call_bignum_add__6_6);
  timingtest(all,"bignum_add (32x32->32)",call_bignum_add__32_32);
  timingtest(all,"bignum_add_p25519",call_bignum_add_p25519);
  timingtest(all,"bignum_add_p256",call_bignum_add_p256);
  timingtest(all,"bignum_add_p256k1",call_bignum_add_p256k1);
  timingtest(all,"bignum_add_p384",call_bignum_add_p384);
  timingtest(all,"bignum_add_p521",call_bignum_add_p521);
  timingtest(all,"bignum_amontifier (32)",call_bignum_amontifier__32);
  timingtest(all,"bignum_amontmul (32)",call_bignum_amontmul__32);
  timingtest(all,"bignum_amontredc (32/16 -> 16)",call_bignum_amontredc__32_16);
  timingtest(all,"bignum_amontsqr (32 -> 32)",call_bignum_amontsqr__32);
  timingtest(all,"bignum_bigendian_4",call_bignum_bigendian_4);
  timingtest(all,"bignum_bigendian_6",call_bignum_bigendian_6);
  timingtest(all,"bignum_bitfield (32 -> 1)",call_bignum_bitfield__32);
  timingtest(all,"bignum_bitsize (32 -> 1)",call_bignum_bitsize__32);
  timingtest(all,"bignum_cdiv_exact (4x1->4)",call_bignum_cdiv_exact__4_4);
  timingtest(all,"bignum_cdiv_exact (6x1->6)",call_bignum_cdiv_exact__6_6);
  timingtest(all,"bignum_cdiv_exact (32x1->32)",call_bignum_cdiv_exact__32_32);
  timingtest(all,"bignum_cdiv (4x1->4)",call_bignum_cdiv__4_4);
  timingtest(all,"bignum_cdiv (6x1->6)",call_bignum_cdiv__6_6);
  timingtest(all,"bignum_cdiv (32x1->32)",call_bignum_cdiv__32_32);
  timingtest(all,"bignum_cld (32)" ,call_bignum_cld__32);
  timingtest(all,"bignum_clz (32)" ,call_bignum_clz__32);
  timingtest(all,"bignum_cmadd (1x4->4)",call_bignum_cmadd__4_4);
  timingtest(all,"bignum_cmadd (1x6->6)",call_bignum_cmadd__6_6);
  timingtest(all,"bignum_cmadd (1x32->32)",call_bignum_cmadd__32_32);
  timingtest(all,"bignum_cmnegadd (1x4->4)",call_bignum_cmnegadd__4_4);
  timingtest(all,"bignum_cmnegadd (1x6->6)",call_bignum_cmnegadd__6_6);
  timingtest(all,"bignum_cmnegadd (1x32->32)",call_bignum_cmnegadd__32_32);
  timingtest(all,"bignum_cmod (4 -> 1)",call_bignum_cmod__4);
  timingtest(all,"bignum_cmod (6 -> 1)",call_bignum_cmod__6);
  timingtest(all,"bignum_cmod (32 -> 1)",call_bignum_cmod__32);
  timingtest(all,"bignum_cmul (1x4->4)",call_bignum_cmul__4_4);
  timingtest(all,"bignum_cmul (1x6->6)",call_bignum_cmul__6_6);
  timingtest(all,"bignum_cmul (1x32->32)",call_bignum_cmul__32_32);
  timingtest(bmi,"bignum_cmul_p25519",call_bignum_cmul_p25519);
  timingtest(all,"bignum_cmul_p25519_alt",call_bignum_cmul_p25519_alt);
  timingtest(bmi,"bignum_cmul_p256",call_bignum_cmul_p256);
  timingtest(all,"bignum_cmul_p256_alt",call_bignum_cmul_p256_alt);
  timingtest(bmi,"bignum_cmul_p256k1",call_bignum_cmul_p256k1);
  timingtest(all,"bignum_cmul_p256k1_alt",call_bignum_cmul_p256k1_alt);
  timingtest(bmi,"bignum_cmul_p384",call_bignum_cmul_p384);
  timingtest(all,"bignum_cmul_p384_alt",call_bignum_cmul_p384_alt);
  timingtest(bmi,"bignum_cmul_p521",call_bignum_cmul_p521);
  timingtest(all,"bignum_cmul_p521_alt",call_bignum_cmul_p521_alt);
  timingtest(all,"bignum_coprime (4x4)",call_bignum_coprime__4_4);
  timingtest(all,"bignum_coprime (6x6)",call_bignum_coprime__6_6);
  timingtest(all,"bignum_coprime (16x16)",call_bignum_coprime__16_16);
  timingtest(all,"bignum_copy (32 -> 32)" ,call_bignum_copy__32_32);
  timingtest(all,"bignum_ctd (32)" ,call_bignum_ctd__32);
  timingtest(all,"bignum_ctz (32)" ,call_bignum_ctz__32);
  timingtest(bmi,"bignum_deamont_p256",call_bignum_deamont_p256);
  timingtest(all,"bignum_deamont_p256_alt",call_bignum_deamont_p256_alt);
  timingtest(all,"bignum_deamont_p256k1",call_bignum_deamont_p256k1);
  timingtest(bmi,"bignum_deamont_p384",call_bignum_deamont_p384);
  timingtest(all,"bignum_deamont_p384_alt",call_bignum_deamont_p384_alt);
  timingtest(all,"bignum_deamont_p521",call_bignum_deamont_p521);
  timingtest(all,"bignum_demont (32 -> 32)" ,call_bignum_demont__32);
  timingtest(bmi,"bignum_demont_p256",call_bignum_demont_p256);
  timingtest(all,"bignum_demont_p256_alt",call_bignum_demont_p256_alt);
  timingtest(all,"bignum_demont_p256k1",call_bignum_demont_p256k1);
  timingtest(bmi,"bignum_demont_p384",call_bignum_demont_p384);
  timingtest(all,"bignum_demont_p384_alt",call_bignum_demont_p384_alt);
  timingtest(all,"bignum_demont_p521",call_bignum_demont_p521);
  timingtest(all,"bignum_digit (32 -> 1)",call_bignum_digit__32);
  timingtest(all,"bignum_digitsize (32)" ,call_bignum_digitsize__32);
  timingtest(all,"bignum_divmod10 (32 -> 32)",call_bignum_divmod10__32);
  timingtest(all,"bignum_double_p256",call_bignum_double_p256);
  timingtest(all,"bignum_double_p256k1",call_bignum_double_p256k1);
  timingtest(all,"bignum_double_p384",call_bignum_double_p384);
  timingtest(all,"bignum_double_p521",call_bignum_double_p521);
  timingtest(all,"bignum_emontredc (8 -> 4)",call_bignum_emontredc__4);
  timingtest(all,"bignum_emontredc (12 -> 6)",call_bignum_emontredc__6);
  timingtest(all,"bignum_emontredc (64 -> 32)",call_bignum_emontredc__32);
  timingtest(bmi,"bignum_emontredc_8n (64 -> 32)",call_bignum_emontredc_8n__32);
  timingtest(all,"bignum_eq (32x32)" ,call_bignum_eq__32_32);
  timingtest(all,"bignum_even (32)" ,call_bignum_even__32);
  timingtest(all,"bignum_frombebytes_4",call_bignum_frombebytes_4);
  timingtest(all,"bignum_frombebytes_6",call_bignum_frombebytes_6);
  timingtest(all,"bignum_fromlebytes_4",call_bignum_fromlebytes_4);
  timingtest(all,"bignum_fromlebytes_6",call_bignum_fromlebytes_6);
  timingtest(all,"bignum_fromlebytes_p521",call_bignum_fromlebytes_p521);
  timingtest(all,"bignum_ge (32x32)" ,call_bignum_ge__32_32);
  timingtest(all,"bignum_gt (32x32)" ,call_bignum_gt__32_32);
  timingtest(all,"bignum_half_p256",call_bignum_half_p256);
  timingtest(all,"bignum_half_p256k1",call_bignum_half_p256k1);
  timingtest(all,"bignum_half_p384",call_bignum_half_p384);
  timingtest(all,"bignum_half_p521",call_bignum_half_p521);
  timingtest(all,"bignum_iszero (32)" ,call_bignum_iszero__32);
  timingtest(bmi,"bignum_kmul_16_32",call_bignum_kmul_16_32);
  timingtest(bmi,"bignum_kmul_32_64",call_bignum_kmul_32_64);
  timingtest(bmi,"bignum_ksqr_16_32",call_bignum_ksqr_16_32);
  timingtest(bmi,"bignum_ksqr_32_64",call_bignum_ksqr_32_64);
  timingtest(all,"bignum_le (32x32)" ,call_bignum_le__32_32);
  timingtest(all,"bignum_littleendian_4",call_bignum_littleendian_4);
  timingtest(all,"bignum_littleendian_6",call_bignum_littleendian_6);
  timingtest(all,"bignum_lt (32x32)" ,call_bignum_lt__32_32);
  timingtest(all,"bignum_madd (4x4 -> 8)",call_bignum_madd__4_8);
  timingtest(all,"bignum_madd (6x6 -> 12)",call_bignum_madd__6_12);
  timingtest(all,"bignum_madd (8x8 -> 16)",call_bignum_madd__8_16);
  timingtest(all,"bignum_madd (16x16 -> 32)",call_bignum_madd__16_32);
  timingtest(all,"bignum_madd (32x32 -> 64)",call_bignum_madd__32_64);
  timingtest(bmi,"bignum_mod_n256 (8 -> 4)",call_bignum_mod_n256__8);
  timingtest(all,"bignum_mod_n256_alt (8 -> 4)",call_bignum_mod_n256_alt__8);
  timingtest(all,"bignum_mod_n256_4",call_bignum_mod_n256_4);
  timingtest(all,"bignum_mod_n256k1_4",call_bignum_mod_n256k1_4);
  timingtest(bmi,"bignum_mod_n384 (12 -> 6)",call_bignum_mod_n384__12);
  timingtest(all,"bignum_mod_n384_alt (12 -> 6)",call_bignum_mod_n384_alt__12);
  timingtest(all,"bignum_mod_n384_6",call_bignum_mod_n384_6);
  timingtest(bmi,"bignum_mod_n521_9",call_bignum_mod_n521_9);
  timingtest(all,"bignum_mod_n521_9_alt",call_bignum_mod_n521_9_alt);
  timingtest(bmi,"bignum_mod_p256 (8 -> 4)",call_bignum_mod_p256__8);
  timingtest(all,"bignum_mod_p256_alt (8 -> 4)",call_bignum_mod_p256_alt__8);
  timingtest(all,"bignum_mod_p256_4",call_bignum_mod_p256_4);
  timingtest(all,"bignum_mod_p256k1_4",call_bignum_mod_p256k1_4);
  timingtest(bmi,"bignum_mod_p384 (12 -> 6)",call_bignum_mod_p384__12);
  timingtest(all,"bignum_mod_p384_alt (12 -> 6)",call_bignum_mod_p384_alt__12);
  timingtest(all,"bignum_mod_p384_6",call_bignum_mod_p384_6);
  timingtest(all,"bignum_mod_p521_9",call_bignum_mod_p521_9);
  timingtest(all,"bignum_modadd (32 -> 32)" ,call_bignum_modadd__32);
  timingtest(all,"bignum_moddouble (32 -> 32)" ,call_bignum_moddouble__32);
  timingtest(all,"bignum_modifier (32)",call_bignum_modifier__32);
  timingtest(all,"bignum_modinv (4x4 -> 4)",call_bignum_modinv__4);
  timingtest(all,"bignum_modinv (6x6 -> 6)",call_bignum_modinv__6);
  timingtest(all,"bignum_modinv (9x9 -> 9)",call_bignum_modinv__9);
  timingtest(all,"bignum_modinv (16x16 -> 16)",call_bignum_modinv__16);
  timingtest(all,"bignum_modoptneg (32 -> 32)",call_bignum_modoptneg__32);
  timingtest(all,"bignum_modsub (32 -> 32)" ,call_bignum_modsub__32);
  timingtest(all,"bignum_montifier (32)",call_bignum_montifier__32);
  timingtest(all,"bignum_montmul (32x32 -> 32)" ,call_bignum_montmul__32);
  timingtest(bmi,"bignum_montmul_p256",call_bignum_montmul_p256);
  timingtest(all,"bignum_montmul_p256_alt",call_bignum_montmul_p256_alt);
  timingtest(bmi,"bignum_montmul_p256k1",call_bignum_montmul_p256k1);
  timingtest(all,"bignum_montmul_p256k1_alt",call_bignum_montmul_p256k1_alt);
  timingtest(bmi,"bignum_montmul_p384",call_bignum_montmul_p384);
  timingtest(all,"bignum_montmul_p384_alt",call_bignum_montmul_p384_alt);
  timingtest(bmi,"bignum_montmul_p521",call_bignum_montmul_p521);
  timingtest(all,"bignum_montmul_p521_alt",call_bignum_montmul_p521_alt);
  timingtest(all,"bignum_montredc (32/16 -> 16)",call_bignum_montredc__32_16);
  timingtest(all,"bignum_montsqr (32 -> 32)" ,call_bignum_montsqr__32);
  timingtest(bmi,"bignum_montsqr_p256",call_bignum_montsqr_p256);
  timingtest(all,"bignum_montsqr_p256_alt",call_bignum_montsqr_p256_alt);
  timingtest(bmi,"bignum_montsqr_p256k1",call_bignum_montsqr_p256k1);
  timingtest(all,"bignum_montsqr_p256k1_alt",call_bignum_montsqr_p256k1_alt);
  timingtest(bmi,"bignum_montsqr_p384",call_bignum_montsqr_p384);
  timingtest(all,"bignum_montsqr_p384_alt",call_bignum_montsqr_p384_alt);
  timingtest(bmi,"bignum_montsqr_p521",call_bignum_montsqr_p521);
  timingtest(all,"bignum_montsqr_p521_alt",call_bignum_montsqr_p521_alt);
  timingtest(all,"bignum_mul (4x4 -> 8)",call_bignum_mul__4_8);
  timingtest(all,"bignum_mul (6x6 -> 12)",call_bignum_mul__6_12);
  timingtest(all,"bignum_mul (8x8 -> 16)",call_bignum_mul__8_16);
  timingtest(all,"bignum_mul (16x16 -> 32)",call_bignum_mul__16_32);
  timingtest(all,"bignum_mul (32x32 -> 64)",call_bignum_mul__32_64);
  timingtest(bmi,"bignum_mul_4_8",call_bignum_mul_4_8);
  timingtest(all,"bignum_mul_4_8_alt",call_bignum_mul_4_8_alt);
  timingtest(bmi,"bignum_mul_6_12",call_bignum_mul_6_12);
  timingtest(all,"bignum_mul_6_12_alt",call_bignum_mul_6_12_alt);
  timingtest(bmi,"bignum_mul_8_16",call_bignum_mul_8_16);
  timingtest(all,"bignum_mul_8_16_alt",call_bignum_mul_8_16_alt);
  timingtest(bmi,"bignum_mul_p25519",call_bignum_mul_p25519);
  timingtest(all,"bignum_mul_p25519_alt",call_bignum_mul_p25519_alt);
  timingtest(bmi,"bignum_mul_p256k1",call_bignum_mul_p256k1);
  timingtest(all,"bignum_mul_p256k1_alt",call_bignum_mul_p256k1_alt);
  timingtest(bmi,"bignum_mul_p521",call_bignum_mul_p521);
  timingtest(all,"bignum_mul_p521_alt",call_bignum_mul_p521_alt);
  timingtest(all,"bignum_muladd10 (32 -> 32)",call_bignum_muladd10__32);
  timingtest(all,"bignum_mux16 (4 -> 4)",call_bignum_mux16__4);
  timingtest(all,"bignum_mux16 (6 -> 6)",call_bignum_mux16__6);
  timingtest(all,"bignum_mux16 (32 -> 32)",call_bignum_mux16__32);
  timingtest(all,"bignum_mux_4",call_bignum_mux_4);
  timingtest(all,"bignum_mux_6",call_bignum_mux_6);
  timingtest(all,"bignum_neg_p25519",call_bignum_neg_p25519);
  timingtest(all,"bignum_neg_p256",call_bignum_neg_p256);
  timingtest(all,"bignum_neg_p256k1",call_bignum_neg_p256k1);
  timingtest(all,"bignum_neg_p384",call_bignum_neg_p384);
  timingtest(all,"bignum_neg_p521",call_bignum_neg_p521);
  timingtest(all,"bignum_negmodinv (32)" ,call_bignum_negmodinv__32);
  timingtest(all,"bignum_nonzero (32)" ,call_bignum_nonzero__32);
  timingtest(all,"bignum_nonzero_4",call_bignum_nonzero_4);
  timingtest(all,"bignum_nonzero_6",call_bignum_nonzero_6);
  timingtest(all,"bignum_normalize (32 -> 32)",call_bignum_normalize__32);
  timingtest(all,"bignum_odd (32)" ,call_bignum_odd__32);
  timingtest(all,"bignum_of_word (1 -> 32)",call_bignum_of_word__32);
  timingtest(all,"bignum_optadd (32x32 -> 32)" ,call_bignum_optadd__32);
  timingtest(all,"bignum_optneg (32 -> 32)" ,call_bignum_optneg__32);
  timingtest(all,"bignum_optneg_p256",call_bignum_optneg_p256);
  timingtest(all,"bignum_optneg_p256k1",call_bignum_optneg_p256k1);
  timingtest(all,"bignum_optneg_p384",call_bignum_optneg_p384);
  timingtest(all,"bignum_optneg_p521",call_bignum_optneg_p521);
  timingtest(all,"bignum_optsub (32x32 -> 32)",call_bignum_optsub__32);
  timingtest(all,"bignum_optsubadd (32x32 -> 32)",call_bignum_optsubadd__32);
  timingtest(all,"bignum_pow2 (32)" ,call_bignum_pow2__32);
  timingtest(all,"bignum_shl_small (32 -> 32)",call_bignum_shl_small__32_32);
  timingtest(all,"bignum_shr_small (32 -> 32)",call_bignum_shr_small__32_32);
  timingtest(all,"bignum_sqr (4 -> 8)",call_bignum_sqr__4_8);
  timingtest(all,"bignum_sqr (6 -> 12)",call_bignum_sqr__6_12);
  timingtest(all,"bignum_sqr (8 -> 16)",call_bignum_sqr__8_16);
  timingtest(all,"bignum_sqr (16 -> 32)",call_bignum_sqr__16_32);
  timingtest(all,"bignum_sqr (32 -> 64)",call_bignum_sqr__32_64);
  timingtest(bmi,"bignum_sqr_4_8",call_bignum_sqr_4_8);
  timingtest(all,"bignum_sqr_4_8_alt",call_bignum_sqr_4_8_alt);
  timingtest(bmi,"bignum_sqr_6_12",call_bignum_sqr_6_12);
  timingtest(all,"bignum_sqr_6_12_alt",call_bignum_sqr_6_12_alt);
  timingtest(bmi,"bignum_sqr_8_16",call_bignum_sqr_8_16);
  timingtest(all,"bignum_sqr_8_16_alt",call_bignum_sqr_8_16_alt);
  timingtest(bmi,"bignum_sqr_p25519",call_bignum_sqr_p25519);
  timingtest(all,"bignum_sqr_p25519_alt",call_bignum_sqr_p25519_alt);
  timingtest(bmi,"bignum_sqr_p256k1",call_bignum_sqr_p256k1);
  timingtest(all,"bignum_sqr_p256k1_alt",call_bignum_sqr_p256k1_alt);
  timingtest(bmi,"bignum_sqr_p521",call_bignum_sqr_p521);
  timingtest(all,"bignum_sqr_p521_alt",call_bignum_sqr_p521_alt);
  timingtest(all,"bignum_sub (4x4->4)",call_bignum_sub__4_4);
  timingtest(all,"bignum_sub (6x6->6)",call_bignum_sub__6_6);
  timingtest(all,"bignum_sub (32x32->32)",call_bignum_sub__32_32);
  timingtest(all,"bignum_sub_p25519",call_bignum_sub_p25519);
  timingtest(all,"bignum_sub_p256",call_bignum_sub_p256);
  timingtest(all,"bignum_sub_p256k1",call_bignum_sub_p256k1);
  timingtest(all,"bignum_sub_p384",call_bignum_sub_p384);
  timingtest(all,"bignum_sub_p521",call_bignum_sub_p521);
  timingtest(all,"bignum_tobebytes_4",call_bignum_tobebytes_4);
  timingtest(all,"bignum_tobebytes_6",call_bignum_tobebytes_6);
  timingtest(all,"bignum_tolebytes_4",call_bignum_tolebytes_4);
  timingtest(all,"bignum_tolebytes_6",call_bignum_tolebytes_6);
  timingtest(all,"bignum_tolebytes_p521",call_bignum_tolebytes_p521);
  timingtest(bmi,"bignum_tomont_p256",call_bignum_tomont_p256);
  timingtest(all,"bignum_tomont_p256_alt",call_bignum_tomont_p256_alt);
  timingtest(bmi,"bignum_tomont_p256k1",call_bignum_tomont_p256k1);
  timingtest(all,"bignum_tomont_p256k1_alt",call_bignum_tomont_p256k1_alt);
  timingtest(bmi,"bignum_tomont_p384",call_bignum_tomont_p384);
  timingtest(all,"bignum_tomont_p384_alt",call_bignum_tomont_p384_alt);
  timingtest(all,"bignum_tomont_p521",call_bignum_tomont_p521);
  timingtest(bmi,"bignum_triple_p256",call_bignum_triple_p256);
  timingtest(all,"bignum_triple_p256_alt",call_bignum_triple_p256_alt);
  timingtest(bmi,"bignum_triple_p256k1",call_bignum_triple_p256k1);
  timingtest(all,"bignum_triple_p256k1_alt",call_bignum_triple_p256k1_alt);
  timingtest(bmi,"bignum_triple_p384",call_bignum_triple_p384);
  timingtest(all,"bignum_triple_p384_alt",call_bignum_triple_p384_alt);
  timingtest(bmi,"bignum_triple_p521",call_bignum_triple_p521);
  timingtest(all,"bignum_triple_p521_alt",call_bignum_triple_p521_alt);
  timingtest(bmi,"curve25519_ladderstep",call_curve25519_ladderstep);
  timingtest(all,"curve25519_ladderstep_alt",call_curve25519_ladderstep_alt);
  timingtest(bmi,"curve25519_pxscalarmul",call_curve25519_pxscalarmul);
  timingtest(all,"curve25519_pxscalarmul_alt",call_curve25519_pxscalarmul_alt);
  timingtest(bmi,"curve25519_x25519",call_curve25519_x25519);
  timingtest(all,"curve25519_x25519_alt",call_curve25519_x25519_alt);
  timingtest(bmi,"p256_montjadd",call_p256_montjadd);
  timingtest(bmi,"p256_montjdouble",call_p256_montjdouble);
  timingtest(bmi,"p256_montjmixadd",call_p256_montjmixadd);
  timingtest(bmi,"p384_montjadd",call_p384_montjadd);
  timingtest(bmi,"p384_montjdouble",call_p384_montjdouble);
  timingtest(bmi,"p384_montjmixadd",call_p384_montjmixadd);
  timingtest(bmi,"p521_jadd",call_p521_jadd);
  timingtest(bmi,"p521_jdouble",call_p521_jdouble);
  timingtest(bmi,"p521_jmixadd",call_p521_jmixadd);
  timingtest(bmi,"secp256k1_jadd",call_secp256k1_jadd);
  timingtest(bmi,"secp256k1_jdouble",call_secp256k1_jdouble);
  timingtest(bmi,"secp256k1_jmixadd",call_secp256k1_jmixadd);
  timingtest(all,"word_bytereverse",call_word_bytereverse);
  timingtest(all,"word_clz",call_word_clz);
  timingtest(all,"word_ctz",call_word_ctz);
  timingtest(all,"word_max",call_word_max);
  timingtest(all,"word_min",call_word_min);
  timingtest(all,"word_negmodinv",call_word_negmodinv);
  timingtest(all,"word_recip",call_word_recip);

  // Summarize performance in arithmetic and geometric means

  arithmean /= (double) tests;
  geomean /= (double) tests; geomean = exp(geomean);
  printf("ARITHMEAN (%3d tests)    : %6.1f ns\n",tests,arithmean);
  printf("GEOMEAN   (%3d tests)    : %6.1f ns\n",tests,geomean);

  return 0;
}

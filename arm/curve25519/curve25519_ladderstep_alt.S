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

// ----------------------------------------------------------------------------
// Montgomery ladder step on pairs of (X,Z)-projective curve25519 points
//
// extern void curve25519_ladderstep_alt
//   (uint64_t rr[16],uint64_t point[8],uint64_t pp[16],uint64_t b)
//
// If point = (X,1) and pp = (n * (X,1),[n+1] * (X,1)) then the output
// rr = (n' * (X,1),[n'+1] * (X,1)) where n' = 2 * n + b, with input
// b assumed to be 0 or 1; in this setting, each pair (X,Z) is assumed to
// be a projective y-free representation of an affine curve25519 point
// (X/Z,y), with the initial "differential" point having Z = 1 and X its
// affine x coordinate. In other words, the ladderstep operation is a
// combination of doubling, differential addition and optional swapping.
//
// Standard ARM ABI: X0 = rr, X1 = point, X2 = pp, X3 = b
// ----------------------------------------------------------------------------
#include "_internal_s2n_bignum.h"

        S2N_BN_SYM_VISIBILITY_DIRECTIVE(curve25519_ladderstep_alt)
        S2N_BN_SYM_PRIVACY_DIRECTIVE(curve25519_ladderstep_alt)

        .text
        .balign 4

// Size of individual field elements

#define NUMSIZE 32

// Stable homes for input arguments during main code sequence

#define rr x17
#define point x19
#define pp x20
#define b x21

// Pointer-offset pairs for inputs and outputs

#define x point, #0
#define z point, #NUMSIZE
#define xn pp, #0
#define zn pp, #NUMSIZE
#define xm pp, #(2*NUMSIZE)
#define zm pp, #(3*NUMSIZE)
#define res0 rr, #0
#define res1 rr, #NUMSIZE
#define res2 rr, #(2*NUMSIZE)
#define res3 rr, #(3*NUMSIZE)

// Pointer-offset pairs for temporaries on stack
// dmsn and dnsm need space for >= 5 digits, and we allocate 8

#define sm sp, #(0*NUMSIZE)
#define sn sp, #(1*NUMSIZE)
#define dm sp, #(2*NUMSIZE)
#define dn sp, #(3*NUMSIZE)
#define dmsn sp, #(4*NUMSIZE)
#define dnsm sp, #(6*NUMSIZE)
#define s sp, #(8*NUMSIZE)
#define d sp, #(9*NUMSIZE)
#define p sp, #(10*NUMSIZE)

// More, but aliases to above

#define sumx sm
#define sumz sn
#define dubx dm
#define dubz dn
#define e dubz
#define spro dnsm
#define dpro sumz

// Total size to reserve on the stack

#define NSPACE (12*NUMSIZE)

// Macros wrapping up the basic field operation calls
// bignum_mul_p25519_alt and bignum_sqr_p25519_alt.
// These two are only trivially different from pure
// function calls to those subroutines.

#define mul_p25519(p0,p1,p2)                    \
        ldp     x3, x4, [p1];                   \
        ldp     x7, x8, [p2];                   \
        mul     x12, x3, x7;                    \
        umulh   x13, x3, x7;                    \
        mul     x11, x3, x8;                    \
        umulh   x14, x3, x8;                    \
        adds    x13, x13, x11;                  \
        ldp     x9, x10, [p2+16];               \
        mul     x11, x3, x9;                    \
        umulh   x15, x3, x9;                    \
        adcs    x14, x14, x11;                  \
        mul     x11, x3, x10;                   \
        umulh   x16, x3, x10;                   \
        adcs    x15, x15, x11;                  \
        adc     x16, x16, xzr;                  \
        ldp     x5, x6, [p1+16];                \
        mul     x11, x4, x7;                    \
        adds    x13, x13, x11;                  \
        mul     x11, x4, x8;                    \
        adcs    x14, x14, x11;                  \
        mul     x11, x4, x9;                    \
        adcs    x15, x15, x11;                  \
        mul     x11, x4, x10;                   \
        adcs    x16, x16, x11;                  \
        umulh   x3, x4, x10;                    \
        adc     x3, x3, xzr;                    \
        umulh   x11, x4, x7;                    \
        adds    x14, x14, x11;                  \
        umulh   x11, x4, x8;                    \
        adcs    x15, x15, x11;                  \
        umulh   x11, x4, x9;                    \
        adcs    x16, x16, x11;                  \
        adc     x3, x3, xzr;                    \
        mul     x11, x5, x7;                    \
        adds    x14, x14, x11;                  \
        mul     x11, x5, x8;                    \
        adcs    x15, x15, x11;                  \
        mul     x11, x5, x9;                    \
        adcs    x16, x16, x11;                  \
        mul     x11, x5, x10;                   \
        adcs    x3, x3, x11;                    \
        umulh   x4, x5, x10;                    \
        adc     x4, x4, xzr;                    \
        umulh   x11, x5, x7;                    \
        adds    x15, x15, x11;                  \
        umulh   x11, x5, x8;                    \
        adcs    x16, x16, x11;                  \
        umulh   x11, x5, x9;                    \
        adcs    x3, x3, x11;                    \
        adc     x4, x4, xzr;                    \
        mul     x11, x6, x7;                    \
        adds    x15, x15, x11;                  \
        mul     x11, x6, x8;                    \
        adcs    x16, x16, x11;                  \
        mul     x11, x6, x9;                    \
        adcs    x3, x3, x11;                    \
        mul     x11, x6, x10;                   \
        adcs    x4, x4, x11;                    \
        umulh   x5, x6, x10;                    \
        adc     x5, x5, xzr;                    \
        umulh   x11, x6, x7;                    \
        adds    x16, x16, x11;                  \
        umulh   x11, x6, x8;                    \
        adcs    x3, x3, x11;                    \
        umulh   x11, x6, x9;                    \
        adcs    x4, x4, x11;                    \
        adc     x5, x5, xzr;                    \
        mov     x7, #38;                        \
        mul     x11, x7, x16;                   \
        umulh   x9, x7, x16;                    \
        adds    x12, x12, x11;                  \
        mul     x11, x7, x3;                    \
        umulh   x3, x7, x3;                     \
        adcs    x13, x13, x11;                  \
        mul     x11, x7, x4;                    \
        umulh   x4, x7, x4;                     \
        adcs    x14, x14, x11;                  \
        mul     x11, x7, x5;                    \
        umulh   x5, x7, x5;                     \
        adcs    x15, x15, x11;                  \
        cset    x16, hs;                        \
        adds    x13, x13, x9;                   \
        adcs    x14, x14, x3;                   \
        adcs    x15, x15, x4;                   \
        adc     x16, x16, x5;                   \
        cmn     x15, x15;                       \
        orr     x15, x15, #0x8000000000000000;  \
        adc     x8, x16, x16;                   \
        mov     x7, #19;                        \
        madd    x11, x7, x8, x7;                \
        adds    x12, x12, x11;                  \
        adcs    x13, x13, xzr;                  \
        adcs    x14, x14, xzr;                  \
        adcs    x15, x15, xzr;                  \
        csel    x7, x7, xzr, lo;                \
        subs    x12, x12, x7;                   \
        sbcs    x13, x13, xzr;                  \
        sbcs    x14, x14, xzr;                  \
        sbc     x15, x15, xzr;                  \
        and     x15, x15, #0x7fffffffffffffff;  \
        stp     x12, x13, [p0];                 \
        stp     x14, x15, [p0+16]

#define sqr_p25519(p0,p1)                       \
        ldp     x2, x3, [p1];                   \
        mul     x9, x2, x3;                     \
        umulh   x10, x2, x3;                    \
        ldp     x4, x5, [p1+16];                \
        mul     x11, x2, x5;                    \
        umulh   x12, x2, x5;                    \
        mul     x7, x2, x4;                     \
        umulh   x6, x2, x4;                     \
        adds    x10, x10, x7;                   \
        adcs    x11, x11, x6;                   \
        mul     x7, x3, x4;                     \
        umulh   x6, x3, x4;                     \
        adc     x6, x6, xzr;                    \
        adds    x11, x11, x7;                   \
        mul     x13, x4, x5;                    \
        umulh   x14, x4, x5;                    \
        adcs    x12, x12, x6;                   \
        mul     x7, x3, x5;                     \
        umulh   x6, x3, x5;                     \
        adc     x6, x6, xzr;                    \
        adds    x12, x12, x7;                   \
        adcs    x13, x13, x6;                   \
        adc     x14, x14, xzr;                  \
        adds    x9, x9, x9;                     \
        adcs    x10, x10, x10;                  \
        adcs    x11, x11, x11;                  \
        adcs    x12, x12, x12;                  \
        adcs    x13, x13, x13;                  \
        adcs    x14, x14, x14;                  \
        cset    x6, hs;                         \
        umulh   x7, x2, x2;                     \
        mul     x8, x2, x2;                     \
        adds    x9, x9, x7;                     \
        mul     x7, x3, x3;                     \
        adcs    x10, x10, x7;                   \
        umulh   x7, x3, x3;                     \
        adcs    x11, x11, x7;                   \
        mul     x7, x4, x4;                     \
        adcs    x12, x12, x7;                   \
        umulh   x7, x4, x4;                     \
        adcs    x13, x13, x7;                   \
        mul     x7, x5, x5;                     \
        adcs    x14, x14, x7;                   \
        umulh   x7, x5, x5;                     \
        adc     x6, x6, x7;                     \
        mov     x3, #38;                        \
        mul     x7, x3, x12;                    \
        umulh   x4, x3, x12;                    \
        adds    x8, x8, x7;                     \
        mul     x7, x3, x13;                    \
        umulh   x13, x3, x13;                   \
        adcs    x9, x9, x7;                     \
        mul     x7, x3, x14;                    \
        umulh   x14, x3, x14;                   \
        adcs    x10, x10, x7;                   \
        mul     x7, x3, x6;                     \
        umulh   x6, x3, x6;                     \
        adcs    x11, x11, x7;                   \
        cset    x12, hs;                        \
        adds    x9, x9, x4;                     \
        adcs    x10, x10, x13;                  \
        adcs    x11, x11, x14;                  \
        adc     x12, x12, x6;                   \
        cmn     x11, x11;                       \
        orr     x11, x11, #0x8000000000000000;  \
        adc     x2, x12, x12;                   \
        mov     x3, #19;                        \
        madd    x7, x3, x2, x3;                 \
        adds    x8, x8, x7;                     \
        adcs    x9, x9, xzr;                    \
        adcs    x10, x10, xzr;                  \
        adcs    x11, x11, xzr;                  \
        csel    x3, x3, xzr, lo;                \
        subs    x8, x8, x3;                     \
        sbcs    x9, x9, xzr;                    \
        sbcs    x10, x10, xzr;                  \
        sbc     x11, x11, xzr;                  \
        and     x11, x11, #0x7fffffffffffffff;  \
        stp     x8, x9, [p0];                   \
        stp     x10, x11, [p0+16]

// Multiplication just giving a 5-digit result (actually < 39 * 2^256)
// by not doing anything beyond the first stage of reduction

#define mul_5(p0,p1,p2)                         \
        ldp     x3, x4, [p1];                   \
        ldp     x7, x8, [p2];                   \
        mul     x12, x3, x7;                    \
        umulh   x13, x3, x7;                    \
        mul     x11, x3, x8;                    \
        umulh   x14, x3, x8;                    \
        adds    x13, x13, x11;                  \
        ldp     x9, x10, [p2+16];               \
        mul     x11, x3, x9;                    \
        umulh   x15, x3, x9;                    \
        adcs    x14, x14, x11;                  \
        mul     x11, x3, x10;                   \
        umulh   x16, x3, x10;                   \
        adcs    x15, x15, x11;                  \
        adc     x16, x16, xzr;                  \
        ldp     x5, x6, [p1+16];                \
        mul     x11, x4, x7;                    \
        adds    x13, x13, x11;                  \
        mul     x11, x4, x8;                    \
        adcs    x14, x14, x11;                  \
        mul     x11, x4, x9;                    \
        adcs    x15, x15, x11;                  \
        mul     x11, x4, x10;                   \
        adcs    x16, x16, x11;                  \
        umulh   x3, x4, x10;                    \
        adc     x3, x3, xzr;                    \
        umulh   x11, x4, x7;                    \
        adds    x14, x14, x11;                  \
        umulh   x11, x4, x8;                    \
        adcs    x15, x15, x11;                  \
        umulh   x11, x4, x9;                    \
        adcs    x16, x16, x11;                  \
        adc     x3, x3, xzr;                    \
        mul     x11, x5, x7;                    \
        adds    x14, x14, x11;                  \
        mul     x11, x5, x8;                    \
        adcs    x15, x15, x11;                  \
        mul     x11, x5, x9;                    \
        adcs    x16, x16, x11;                  \
        mul     x11, x5, x10;                   \
        adcs    x3, x3, x11;                    \
        umulh   x4, x5, x10;                    \
        adc     x4, x4, xzr;                    \
        umulh   x11, x5, x7;                    \
        adds    x15, x15, x11;                  \
        umulh   x11, x5, x8;                    \
        adcs    x16, x16, x11;                  \
        umulh   x11, x5, x9;                    \
        adcs    x3, x3, x11;                    \
        adc     x4, x4, xzr;                    \
        mul     x11, x6, x7;                    \
        adds    x15, x15, x11;                  \
        mul     x11, x6, x8;                    \
        adcs    x16, x16, x11;                  \
        mul     x11, x6, x9;                    \
        adcs    x3, x3, x11;                    \
        mul     x11, x6, x10;                   \
        adcs    x4, x4, x11;                    \
        umulh   x5, x6, x10;                    \
        adc     x5, x5, xzr;                    \
        umulh   x11, x6, x7;                    \
        adds    x16, x16, x11;                  \
        umulh   x11, x6, x8;                    \
        adcs    x3, x3, x11;                    \
        umulh   x11, x6, x9;                    \
        adcs    x4, x4, x11;                    \
        adc     x5, x5, xzr;                    \
        mov     x7, #38;                        \
        mul     x11, x7, x16;                   \
        umulh   x9, x7, x16;                    \
        adds    x12, x12, x11;                  \
        mul     x11, x7, x3;                    \
        umulh   x3, x7, x3;                     \
        adcs    x13, x13, x11;                  \
        mul     x11, x7, x4;                    \
        umulh   x4, x7, x4;                     \
        adcs    x14, x14, x11;                  \
        mul     x11, x7, x5;                    \
        umulh   x5, x7, x5;                     \
        adcs    x15, x15, x11;                  \
        cset    x16, hs;                        \
        adds    x13, x13, x9;                   \
        adcs    x14, x14, x3;                   \
        adcs    x15, x15, x4;                   \
        adc     x16, x16, x5;                   \
        stp     x12, x13, [p0];                 \
        stp     x14, x15, [p0+16];              \
        str     x16, [p0+32]

// Squaring just giving a result < 2 * p_25519, which is done by
// basically skipping the +1 in the quotient estimate and the final
// optional correction.

#define sqr_4(p0,p1)                            \
        ldp     x2, x3, [p1];                   \
        mul     x9, x2, x3;                     \
        umulh   x10, x2, x3;                    \
        ldp     x4, x5, [p1+16];                \
        mul     x11, x2, x5;                    \
        umulh   x12, x2, x5;                    \
        mul     x7, x2, x4;                     \
        umulh   x6, x2, x4;                     \
        adds    x10, x10, x7;                   \
        adcs    x11, x11, x6;                   \
        mul     x7, x3, x4;                     \
        umulh   x6, x3, x4;                     \
        adc     x6, x6, xzr;                    \
        adds    x11, x11, x7;                   \
        mul     x13, x4, x5;                    \
        umulh   x14, x4, x5;                    \
        adcs    x12, x12, x6;                   \
        mul     x7, x3, x5;                     \
        umulh   x6, x3, x5;                     \
        adc     x6, x6, xzr;                    \
        adds    x12, x12, x7;                   \
        adcs    x13, x13, x6;                   \
        adc     x14, x14, xzr;                  \
        adds    x9, x9, x9;                     \
        adcs    x10, x10, x10;                  \
        adcs    x11, x11, x11;                  \
        adcs    x12, x12, x12;                  \
        adcs    x13, x13, x13;                  \
        adcs    x14, x14, x14;                  \
        cset    x6, hs;                         \
        umulh   x7, x2, x2;                     \
        mul     x8, x2, x2;                     \
        adds    x9, x9, x7;                     \
        mul     x7, x3, x3;                     \
        adcs    x10, x10, x7;                   \
        umulh   x7, x3, x3;                     \
        adcs    x11, x11, x7;                   \
        mul     x7, x4, x4;                     \
        adcs    x12, x12, x7;                   \
        umulh   x7, x4, x4;                     \
        adcs    x13, x13, x7;                   \
        mul     x7, x5, x5;                     \
        adcs    x14, x14, x7;                   \
        umulh   x7, x5, x5;                     \
        adc     x6, x6, x7;                     \
        mov     x3, #38;                        \
        mul     x7, x3, x12;                    \
        umulh   x4, x3, x12;                    \
        adds    x8, x8, x7;                     \
        mul     x7, x3, x13;                    \
        umulh   x13, x3, x13;                   \
        adcs    x9, x9, x7;                     \
        mul     x7, x3, x14;                    \
        umulh   x14, x3, x14;                   \
        adcs    x10, x10, x7;                   \
        mul     x7, x3, x6;                     \
        umulh   x6, x3, x6;                     \
        adcs    x11, x11, x7;                   \
        cset    x12, hs;                        \
        adds    x9, x9, x4;                     \
        adcs    x10, x10, x13;                  \
        adcs    x11, x11, x14;                  \
        adc     x12, x12, x6;                   \
        cmn     x11, x11;                       \
        bic     x11, x11, #0x8000000000000000;  \
        adc     x2, x12, x12;                   \
        mov     x3, #19;                        \
        mul     x7, x3, x2;                     \
        adds    x8, x8, x7;                     \
        adcs    x9, x9, xzr;                    \
        adcs    x10, x10, xzr;                  \
        adc     x11, x11, xzr;                  \
        stp     x8, x9, [p0];                   \
        stp     x10, x11, [p0+16]

// Plain 4-digit add without any normalization
// With inputs < p_25519 (indeed < 2^255) it still gives a 4-digit result

#define add_4(p0,p1,p2)                         \
        ldp     x0, x1, [p1];                   \
        ldp     x4, x5, [p2];                   \
        adds    x0, x0, x4;                     \
        adcs    x1, x1, x5;                     \
        ldp     x2, x3, [p1+16];                \
        ldp     x6, x7, [p2+16];                \
        adcs    x2, x2, x6;                     \
        adcs    x3, x3, x7;                     \
        stp     x0, x1, [p0];                   \
        stp     x2, x3, [p0+16]

// Add 5-digit inputs and normalize to 4 digits

#define add5_4(p0,p1,p2)                        \
        ldp     x0, x1, [p1];                   \
        ldp     x4, x5, [p2];                   \
        adds    x0, x0, x4;                     \
        adcs    x1, x1, x5;                     \
        ldp     x2, x3, [p1+16];                \
        ldp     x6, x7, [p2+16];                \
        adcs    x2, x2, x6;                     \
        adcs    x3, x3, x7;                     \
        ldr     x4, [p1+32];                    \
        ldr     x5, [p2+32];                    \
        adc     x4, x4, x5;                     \
        cmn     x3, x3;                         \
        bic     x3, x3, #0x8000000000000000;    \
        adc     x8, x4, x4;                     \
        mov     x7, #19;                        \
        mul     x11, x7, x8;                    \
        adds    x0, x0, x11;                    \
        adcs    x1, x1, xzr;                    \
        adcs    x2, x2, xzr;                    \
        adc     x3, x3, xzr;                    \
        stp     x0, x1, [p0];                   \
        stp     x2, x3, [p0+16]

// Subtraction of a pair of numbers < p_25519 just sufficient
// to give a 4-digit result. It actually always does (x - z) + (2^255-19)
// which in turn is done by (x - z) - (2^255+19) discarding the 2^256
// implicitly

#define sub_4(p0,p1,p2)                         \
        ldp     x5, x6, [p1];                   \
        ldp     x4, x3, [p2];                   \
        subs    x5, x5, x4;                     \
        sbcs    x6, x6, x3;                     \
        ldp     x7, x8, [p1+16];                \
        ldp     x4, x3, [p2+16];                \
        sbcs    x7, x7, x4;                     \
        sbcs    x8, x8, x3;                     \
        mov     x3, #19;                        \
        subs    x5, x5, x3;                     \
        sbcs    x6, x6, xzr;                    \
        sbcs    x7, x7, xzr;                    \
        mov     x4, #0x8000000000000000;        \
        sbc     x8, x8, x4;                     \
        stp     x5, x6, [p0];                   \
        stp     x7, x8, [p0+16]

// Modular subtraction with double modulus 2 * p_25519 = 2^256 - 38

#define sub_twice4(p0,p1,p2)                    \
        ldp     x5, x6, [p1];                   \
        ldp     x4, x3, [p2];                   \
        subs    x5, x5, x4;                     \
        sbcs    x6, x6, x3;                     \
        ldp     x7, x8, [p1+16];                \
        ldp     x4, x3, [p2+16];                \
        sbcs    x7, x7, x4;                     \
        sbcs    x8, x8, x3;                     \
        mov     x4, #38;                        \
        csel    x3, x4, xzr, lo;                \
        subs    x5, x5, x3;                     \
        sbcs    x6, x6, xzr;                    \
        sbcs    x7, x7, xzr;                    \
        sbc     x8, x8, xzr;                    \
        stp     x5, x6, [p0];                   \
        stp     x7, x8, [p0+16]

// 5-digit subtraction with upward bias to make it positive, adding
// 1000 * (2^255 - 19) = 2^256 * 500 - 19000, then normalizing to 4 digits

#define sub5_4(p0,p1,p2)                        \
        ldp     x0, x1, [p1];                   \
        ldp     x4, x5, [p2];                   \
        subs    x0, x0, x4;                     \
        sbcs    x1, x1, x5;                     \
        ldp     x2, x3, [p1+16];                \
        ldp     x6, x7, [p2+16];                \
        sbcs    x2, x2, x6;                     \
        sbcs    x3, x3, x7;                     \
        ldr     x4, [p1+32];                    \
        ldr     x5, [p2+32];                    \
        sbc     x4, x4, x5;                     \
        mov     x7, -19000;                     \
        adds x0, x0, x7;                        \
        sbcs    x1, x1, xzr;                    \
        sbcs    x2, x2, xzr;                    \
        sbcs    x3, x3, xzr;                    \
        mov     x7, 499;                        \
        adc     x4, x4, x7;                     \
        cmn     x3, x3;                         \
        bic     x3, x3, #0x8000000000000000;    \
        adc     x8, x4, x4;                     \
        mov     x7, #19;                        \
        mul     x11, x7, x8;                    \
        adds    x0, x0, x11;                    \
        adcs    x1, x1, xzr;                    \
        adcs    x2, x2, xzr;                    \
        adc     x3, x3, xzr;                    \
        stp     x0, x1, [p0];                   \
        stp     x2, x3, [p0+16]

// Combined z = c * x + y with reduction only < 2 * p_25519
// where c is initially in the X1 register. It is assumed
// that 19 * (c * x + y) < 2^60 * 2^256 so we don't need a
// high mul in the final part.

#define cmadd_4(p0,p2,p3)                       \
        ldp     x7, x8, [p2];                   \
        ldp     x9, x10, [p2+16];               \
        mul     x3, x1, x7;                     \
        mul     x4, x1, x8;                     \
        mul     x5, x1, x9;                     \
        mul     x6, x1, x10;                    \
        umulh   x7, x1, x7;                     \
        umulh   x8, x1, x8;                     \
        umulh   x9, x1, x9;                     \
        umulh   x10, x1, x10;                   \
        adds    x4, x4, x7;                     \
        adcs    x5, x5, x8;                     \
        adcs    x6, x6, x9;                     \
        adc     x10, x10, xzr;                  \
        ldp     x7, x8, [p3];                   \
        adds    x3, x3, x7;                     \
        adcs    x4, x4, x8;                     \
        ldp     x7, x8, [p3+16];                \
        adcs    x5, x5, x7;                     \
        adcs    x6, x6, x8;                     \
        adc     x10, x10, xzr;                  \
        cmn     x6, x6;                         \
        bic     x6, x6, #0x8000000000000000;    \
        adc     x8, x10, x10;                   \
        mov     x9, #19;                        \
        mul     x7, x8, x9;                     \
        adds    x3, x3, x7;                     \
        adcs    x4, x4, xzr;                    \
        adcs    x5, x5, xzr;                    \
        adc     x6, x6, xzr;                    \
        stp     x3, x4, [p0];                   \
        stp     x5, x6, [p0+16]

// Multiplex: z := if NZ then x else y

#define mux_4(p0,p1,p2)                         \
        ldp     x0, x1, [p1];                   \
        ldp     x2, x3, [p2];                   \
        csel    x0, x0, x2, ne;                 \
        csel    x1, x1, x3, ne;                 \
        stp     x0, x1, [p0];                   \
        ldp     x0, x1, [p1+16];                \
        ldp     x2, x3, [p2+16];                \
        csel    x0, x0, x2, ne;                 \
        csel    x1, x1, x3, ne;                 \
        stp     x0, x1, [p0+16]

// Paired multiplex: (w,z) := if NZ then (y,x) else (x,y)

#define muxpair_4(p0,p1,p2,p3)                  \
        ldp     x0, x1, [p2];                   \
        ldp     x2, x3, [p3];                   \
        csel    x4, x0, x2, eq;                 \
        csel    x6, x0, x2, ne;                 \
        csel    x5, x1, x3, eq;                 \
        csel    x7, x1, x3, ne;                 \
        stp     x4, x5, [p0];                   \
        stp     x6, x7, [p1];                   \
        ldp     x0, x1, [p2+16];                \
        ldp     x2, x3, [p3+16];                \
        csel    x4, x0, x2, eq;                 \
        csel    x6, x0, x2, ne;                 \
        csel    x5, x1, x3, eq;                 \
        csel    x7, x1, x3, ne;                 \
        stp     x4, x5, [p0+16];                \
        stp     x6, x7, [p1+16]

S2N_BN_SYMBOL(curve25519_ladderstep_alt):

// Save regs and make room for temporaries

        stp     x19, x30, [sp, -16]!
        stp     x20, x21, [sp, -16]!
        sub     sp, sp, #NSPACE

// Move the input arguments to stable places

        mov     rr, x0
        mov     point, x1
        mov     pp, x2
        mov     b, x3

// sm = xm + zm; sn = xn + zn; dm = xm - zm; dn = xn - zn
// The adds don't need any normalization as they're fed to muls
// Just make sure the subs fit in 4 digits

        sub_4(dm, xm, zm)
        add_4(sn, xn, zn)
        sub_4(dn, xn, zn)
        add_4(sm, xm, zm)

// ADDING: dmsn = dm * sn; dnsm = sm * dn
// DOUBLING: mux d = xt - zt and s = xt + zt for appropriate choice of (xt,zt)

        mul_5(dmsn,dm,sn)

        cmp     b, xzr
        mux_4(d,dm,dn)
        mux_4(s,sm,sn)

        mul_5(dnsm,sm,dn)

// DOUBLING: d = (xt - zt)^2 normalized only to 4 digits

        sqr_4(d,d)

// ADDING: dpro = (dmsn - dnsm)^2, spro = (dmsn + dnsm)^2
// DOUBLING: s = (xt + zt)^2, normalized only to 4 digits

        sub5_4(dpro,dmsn,dnsm)
        sqr_4(s,s)
        add5_4(spro,dmsn,dnsm)
        sqr_4(dpro,dpro)

// DOUBLING: p = 4 * xt * zt = s - d

        sub_twice4(p,s,d)

// ADDING: sumx = (dmsn + dnsm)^2

        sqr_p25519(sumx,spro)

// DOUBLING: e = 121666 * p + d

        mov     x1, 0xdb42
        orr     x1, x1, 0x10000
        cmadd_4(e,p,d)

// DOUBLING: dubx = (xt + zt)^2 * (xt - zt)^2 = s * d

        mul_p25519(dubx,s,d)

// ADDING: sumz = x * (dmsn - dnsm)^2

        mul_p25519(sumz,dpro,x)

// DOUBLING: dubz = (4 * xt * zt) * ((xt - zt)^2 + 121666 * (4 * xt * zt))
//                = p * (d + 121666 * p)

        mul_p25519(dubz,p,e)

// Multiplex the outputs

        cmp     b, xzr
        muxpair_4(res0,res2,dubx,sumx)
        muxpair_4(res1,res3,dubz,sumz)

// Restore stack and registers

        add     sp, sp, #NSPACE
        ldp     x20, x21, [sp], 16
        ldp     x19, x30, [sp], 16

        ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack, "", %progbits
#endif

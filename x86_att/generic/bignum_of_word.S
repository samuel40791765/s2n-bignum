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
// Convert single digit to bignum, z := n
// Input n; output z[k]
//
//    extern void bignum_of_word (uint64_t k, uint64_t *z, uint64_t n);
//
// Create a k-digit (digit=64 bits) bignum at z with value n (mod 2^k)
// where n is a word. The "mod 2^k" only matters in the degenerate k = 0 case.
//
// Standard x86-64 ABI: RDI = k, RSI = z, RDX = n
// Microsoft x64 ABI:   RCX = k, RDX = z, R8 = n
// ----------------------------------------------------------------------------

#include "_internal_s2n_bignum.h"


        S2N_BN_SYM_VISIBILITY_DIRECTIVE(bignum_of_word)
        S2N_BN_SYM_PRIVACY_DIRECTIVE(bignum_of_word)
        .text

S2N_BN_SYMBOL(bignum_of_word):

#if WINDOWS_ABI
        pushq   %rdi
        pushq   %rsi
        movq    %rcx, %rdi
        movq    %rdx, %rsi
        movq    %r8, %rdx
#endif

// If k = 0 do nothing

        testq   %rdi, %rdi
        jz      end

bignum_of_word_nontrivial:

// Write lowest word and jump to end if k = 1

        movq    %rdx, (%rsi)
        decq    %rdi
        jz      end

// Zero %rdx and write it to all z[i] for i = k-1 down to 1
// It's a bit more compact to iterate "high to low" like this.
// But at the cost of bumping up %rsi by lea %rsi, [%rsi+8]
// each time round the loop (which also modifies one more reg)
// we could go "low to high" if it helps with prefetch etc.

        xorq    %rdx, %rdx
loop:
        movq    %rdx, (%rsi,%rdi,8)
        decq    %rdi
        jnz     loop

end:
#if WINDOWS_ABI
        popq   %rsi
        popq   %rdi
#endif
        ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif

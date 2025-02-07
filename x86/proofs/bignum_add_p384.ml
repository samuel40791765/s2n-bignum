(*
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
 *)

(* ========================================================================= *)
(* Addition modulo p_384, the field characteristic for the NIST P-384 curve. *)
(* ========================================================================= *)

(**** print_literal_from_elf "x86/p384/bignum_add_p384.o";;
 ****)

let bignum_add_p384_mc = define_assert_from_elf "bignum_add_p384_mc" "x86/p384/bignum_add_p384.o"
[
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0x03; 0x02;        (* ADD (% rax) (Memop Quadword (%% (rdx,0))) *)
  0x48; 0x8b; 0x4e; 0x08;  (* MOV (% rcx) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0x13; 0x4a; 0x08;  (* ADC (% rcx) (Memop Quadword (%% (rdx,8))) *)
  0x4c; 0x8b; 0x46; 0x10;  (* MOV (% r8) (Memop Quadword (%% (rsi,16))) *)
  0x4c; 0x13; 0x42; 0x10;  (* ADC (% r8) (Memop Quadword (%% (rdx,16))) *)
  0x4c; 0x8b; 0x4e; 0x18;  (* MOV (% r9) (Memop Quadword (%% (rsi,24))) *)
  0x4c; 0x13; 0x4a; 0x18;  (* ADC (% r9) (Memop Quadword (%% (rdx,24))) *)
  0x4c; 0x8b; 0x56; 0x20;  (* MOV (% r10) (Memop Quadword (%% (rsi,32))) *)
  0x4c; 0x13; 0x52; 0x20;  (* ADC (% r10) (Memop Quadword (%% (rdx,32))) *)
  0x4c; 0x8b; 0x5e; 0x28;  (* MOV (% r11) (Memop Quadword (%% (rsi,40))) *)
  0x4c; 0x13; 0x5a; 0x28;  (* ADC (% r11) (Memop Quadword (%% (rdx,40))) *)
  0xba; 0x00; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 0)) *)
  0x48; 0x11; 0xd2;        (* ADC (% rdx) (% rdx) *)
  0x48; 0xbe; 0x01; 0x00; 0x00; 0x00; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% rsi) (Imm64 (word 18446744069414584321)) *)
  0x48; 0x01; 0xf0;        (* ADD (% rax) (% rsi) *)
  0xbe; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% esi) (Imm32 (word 4294967295)) *)
  0x48; 0x11; 0xf1;        (* ADC (% rcx) (% rsi) *)
  0x49; 0x83; 0xd0; 0x01;  (* ADC (% r8) (Imm8 (word 1)) *)
  0x49; 0x83; 0xd1; 0x00;  (* ADC (% r9) (Imm8 (word 0)) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x49; 0x83; 0xd3; 0x00;  (* ADC (% r11) (Imm8 (word 0)) *)
  0x48; 0x83; 0xd2; 0xff;  (* ADC (% rdx) (Imm8 (word 255)) *)
  0x48; 0x21; 0xf2;        (* AND (% rdx) (% rsi) *)
  0x48; 0x31; 0xf6;        (* XOR (% rsi) (% rsi) *)
  0x48; 0x29; 0xd6;        (* SUB (% rsi) (% rdx) *)
  0x48; 0x29; 0xf0;        (* SUB (% rax) (% rsi) *)
  0x48; 0x89; 0x07;        (* MOV (Memop Quadword (%% (rdi,0))) (% rax) *)
  0x48; 0x19; 0xd1;        (* SBB (% rcx) (% rdx) *)
  0x48; 0x89; 0x4f; 0x08;  (* MOV (Memop Quadword (%% (rdi,8))) (% rcx) *)
  0x48; 0x19; 0xc0;        (* SBB (% rax) (% rax) *)
  0x48; 0x21; 0xf2;        (* AND (% rdx) (% rsi) *)
  0x48; 0xf7; 0xd8;        (* NEG (% rax) *)
  0x49; 0x19; 0xd0;        (* SBB (% r8) (% rdx) *)
  0x4c; 0x89; 0x47; 0x10;  (* MOV (Memop Quadword (%% (rdi,16))) (% r8) *)
  0x49; 0x83; 0xd9; 0x00;  (* SBB (% r9) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x4f; 0x18;  (* MOV (Memop Quadword (%% (rdi,24))) (% r9) *)
  0x49; 0x83; 0xda; 0x00;  (* SBB (% r10) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x57; 0x20;  (* MOV (Memop Quadword (%% (rdi,32))) (% r10) *)
  0x49; 0x83; 0xdb; 0x00;  (* SBB (% r11) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x5f; 0x28;  (* MOV (Memop Quadword (%% (rdi,40))) (% r11) *)
  0xc3                     (* RET *)
];;

let BIGNUM_ADD_P384_EXEC = X86_MK_CORE_EXEC_RULE bignum_add_p384_mc;;

(* ------------------------------------------------------------------------- *)
(* Proof.                                                                    *)
(* ------------------------------------------------------------------------- *)

let p_384 = new_definition `p_384 = 39402006196394479212279040100143613805079739270465446667948293404245721771496870329047266088258938001861606973112319`;;

let BIGNUM_ADD_P384_CORRECT = time prove
 (`!z x y m n pc.
        nonoverlapping (word pc,0x9e) (z,8 * 6)
        ==> ensures x86
             (\s. bytes_loaded s (word pc) (BUTLAST bignum_add_p384_mc) /\
                  read RIP s = word pc /\
                  C_ARGUMENTS [z; x; y] s /\
                  bignum_from_memory (x,6) s = m /\
                  bignum_from_memory (y,6) s = n)
             (\s. read RIP s = word (pc + 0x9d) /\
                  (m < p_384 /\ n < p_384
                   ==> bignum_from_memory (z,6) s = (m + n) MOD p_384))
          (MAYCHANGE [RIP; RSI; RAX; RCX; RDX; R8; R9; R10; R11] ,,
           MAYCHANGE SOME_FLAGS ,,
           MAYCHANGE [memory :> bignum(z,6)])`,
  MAP_EVERY X_GEN_TAC
   [`z:int64`; `x:int64`; `y:int64`; `m:num`; `n:num`; `pc:num`] THEN
  REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  BIGNUM_DIGITIZE_TAC "m_" `read (memory :> bytes (x,8 * 6)) s0` THEN
  BIGNUM_DIGITIZE_TAC "n_" `read (memory :> bytes (y,8 * 6)) s0` THEN

  X86_ACCSTEPS_TAC BIGNUM_ADD_P384_EXEC (1--23) (1--23) THEN
  X86_ACCSTEPS_TAC BIGNUM_ADD_P384_EXEC [27;29;34;36;38;40] (24--41) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN

  SUBGOAL_THEN
   `sum_s23:int64 = word_neg(word(bitval(m + n < p_384))) /\
    (carry_s23 <=> ~(m + n < p_384))`
  (CONJUNCTS_THEN SUBST_ALL_TAC) THENL
   [ONCE_REWRITE_TAC[TAUT `(p <=> ~q) <=> (~p <=> q)`] THEN
    MATCH_MP_TAC FLAG_AND_MASK_FROM_CARRY_LT THEN
    EXISTS_TAC `384` THEN REWRITE_TAC[GSYM REAL_OF_NUM_MUL] THEN
    GEN_REWRITE_TAC I [CONJ_ASSOC] THEN CONJ_TAC THENL
     [MAP_EVERY UNDISCH_TAC [`m < p_384`; `n < p_384`] THEN
      REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; p_384] THEN REAL_ARITH_TAC;
      MAP_EVERY EXPAND_TAC ["m"; "n"] THEN
      REWRITE_TAC[p_384; REAL_BITVAL_NOT; GSYM REAL_OF_NUM_CLAUSES] THEN
      RULE_ASSUM_TAC(REWRITE_RULE[VAL_WORD_BITVAL; REAL_BITVAL_NOT]) THEN
      ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
      DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN BOUNDER_TAC[]];
    ALL_TAC] THEN

  CONV_TAC(LAND_CONV BIGNUM_EXPAND_CONV) THEN
  ASM_REWRITE_TAC[] THEN DISCARD_STATE_TAC "s41" THEN
  ASM_SIMP_TAC[MOD_CASES; ARITH_RULE `m < p /\ n < p ==> m + n < 2 * p`] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_EQ; GSYM REAL_OF_NUM_ADD] THEN
  ONCE_REWRITE_TAC[COND_RAND] THEN
  SIMP_TAC[GSYM REAL_OF_NUM_SUB; GSYM NOT_LT] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_MUL; GSYM REAL_OF_NUM_POW] THEN
  MATCH_MP_TAC EQUAL_FROM_CONGRUENT_REAL THEN
  MAP_EVERY EXISTS_TAC [`384`; `&0:real`] THEN ASM_REWRITE_TAC[] THEN
  CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN CONJ_TAC THENL
   [MAP_EVERY UNDISCH_TAC [`m < p_384`; `n < p_384`] THEN
    REWRITE_TAC[p_384; GSYM REAL_OF_NUM_CLAUSES] THEN REAL_ARITH_TAC;
    ALL_TAC] THEN
  CONJ_TAC THENL [REAL_INTEGER_TAC; ALL_TAC] THEN
  MAP_EVERY EXPAND_TAC ["m"; "n"] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_ADD] THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_MUL; GSYM REAL_OF_NUM_POW] THEN

  ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ) THEN
  REWRITE_TAC[WORD_BITVAL_EQ_0; WORD_NEG_EQ_0] THEN
  COND_CASES_TAC THEN
  ASM_REWRITE_TAC[VAL_WORD_BITVAL; BITVAL_CLAUSES; REAL_BITVAL_NOT] THEN
  CONV_TAC WORD_REDUCE_CONV THENL
   [ALL_TAC;
    REWRITE_TAC[REAL_ARITH
     `&2 pow 64 * (&1 - &0) + &0:real = b + &18446744073709551615 + c <=>
      c = &1 - b`] THEN
    ASM_CASES_TAC `&(bitval carry_s22):real = &1 - &(bitval carry_s12)` THEN
    ASM_REWRITE_TAC[]] THEN
  REWRITE_TAC[p_384] THEN
  DISCH_THEN(MP_TAC o end_itlist CONJ o DESUM_RULE o CONJUNCTS) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC);;

let BIGNUM_ADD_P384_SUBROUTINE_CORRECT = time prove
 (`!z x y m n pc stackpointer returnaddress.
        nonoverlapping (word pc,0x9e) (z,8 * 6) /\
        nonoverlapping (stackpointer,8) (z,8 * 6)
        ==> ensures x86
             (\s. bytes_loaded s (word pc) bignum_add_p384_mc /\
                  read RIP s = word pc /\
                  read RSP s = stackpointer /\
                  read (memory :> bytes64 stackpointer) s = returnaddress /\
                  C_ARGUMENTS [z; x; y] s /\
                  bignum_from_memory (x,6) s = m /\
                  bignum_from_memory (y,6) s = n)
             (\s. read RIP s = returnaddress /\
                  read RSP s = word_add stackpointer (word 8) /\
                  (m < p_384 /\ n < p_384
                   ==> bignum_from_memory (z,6) s = (m + n) MOD p_384))
          (MAYCHANGE [RIP; RSP; RSI; RAX; RCX; RDX; R8; R9; R10; R11] ,,
           MAYCHANGE SOME_FLAGS ,,
           MAYCHANGE [memory :> bignum(z,6)])`,
  X86_PROMOTE_RETURN_NOSTACK_TAC bignum_add_p384_mc BIGNUM_ADD_P384_CORRECT);;

(* ------------------------------------------------------------------------- *)
(* Correctness of Windows ABI version.                                       *)
(* ------------------------------------------------------------------------- *)

let windows_bignum_add_p384_mc = define_from_elf
   "windows_bignum_add_p384_mc" "x86/p384/bignum_add_p384.obj";;

let WINDOWS_BIGNUM_ADD_P384_SUBROUTINE_CORRECT = time prove
 (`!z x y m n pc stackpointer returnaddress.
        ALL (nonoverlapping (word_sub stackpointer (word 16),16))
            [(word pc,0xab); (x,8 * 6); (y,8 * 6)] /\
        nonoverlapping (word pc,0xab) (z,8 * 6) /\
        nonoverlapping (word_sub stackpointer (word 16),24) (z,8 * 6)
        ==> ensures x86
             (\s. bytes_loaded s (word pc) windows_bignum_add_p384_mc /\
                  read RIP s = word pc /\
                  read RSP s = stackpointer /\
                  read (memory :> bytes64 stackpointer) s = returnaddress /\
                  WINDOWS_C_ARGUMENTS [z; x; y] s /\
                  bignum_from_memory (x,6) s = m /\
                  bignum_from_memory (y,6) s = n)
             (\s. read RIP s = returnaddress /\
                  read RSP s = word_add stackpointer (word 8) /\
                  (m < p_384 /\ n < p_384
                   ==> bignum_from_memory (z,6) s = (m + n) MOD p_384))
          (MAYCHANGE [RIP; RSP; RAX; RCX; RDX; R8; R9; R10; R11] ,,
           MAYCHANGE SOME_FLAGS ,,
           MAYCHANGE [memory :> bignum(z,6);
                      memory :> bytes(word_sub stackpointer (word 16),16)])`,
  WINDOWS_X86_WRAP_NOSTACK_TAC windows_bignum_add_p384_mc bignum_add_p384_mc
    BIGNUM_ADD_P384_CORRECT);;

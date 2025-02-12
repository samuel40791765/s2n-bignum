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
(* Addition modulo p_521, the field characteristic for the NIST P-521 curve. *)
(* ========================================================================= *)

(**** print_literal_from_elf "x86/p521/bignum_add_p521.o";;
 ****)

let bignum_add_p521_mc = define_assert_from_elf "bignum_add_p521_mc" "x86/p521/bignum_add_p521.o"
[
  0x53;                    (* PUSH (% rbx) *)
  0x41; 0x54;              (* PUSH (% r12) *)
  0xf9;                    (* STCF *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0x13; 0x02;        (* ADC (% rax) (Memop Quadword (%% (rdx,0))) *)
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
  0x4c; 0x8b; 0x66; 0x30;  (* MOV (% r12) (Memop Quadword (%% (rsi,48))) *)
  0x4c; 0x13; 0x62; 0x30;  (* ADC (% r12) (Memop Quadword (%% (rdx,48))) *)
  0x48; 0x8b; 0x5e; 0x38;  (* MOV (% rbx) (Memop Quadword (%% (rsi,56))) *)
  0x48; 0x13; 0x5a; 0x38;  (* ADC (% rbx) (Memop Quadword (%% (rdx,56))) *)
  0x48; 0x8b; 0x76; 0x40;  (* MOV (% rsi) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0x13; 0x72; 0x40;  (* ADC (% rsi) (Memop Quadword (%% (rdx,64))) *)
  0x48; 0xc7; 0xc2; 0x00; 0x02; 0x00; 0x00;
                           (* MOV (% rdx) (Imm32 (word 512)) *)
  0x48; 0x21; 0xf2;        (* AND (% rdx) (% rsi) *)
  0x48; 0x81; 0xfa; 0x00; 0x02; 0x00; 0x00;
                           (* CMP (% rdx) (Imm32 (word 512)) *)
  0x48; 0x83; 0xd8; 0x00;  (* SBB (% rax) (Imm8 (word 0)) *)
  0x48; 0x89; 0x07;        (* MOV (Memop Quadword (%% (rdi,0))) (% rax) *)
  0x48; 0x83; 0xd9; 0x00;  (* SBB (% rcx) (Imm8 (word 0)) *)
  0x48; 0x89; 0x4f; 0x08;  (* MOV (Memop Quadword (%% (rdi,8))) (% rcx) *)
  0x49; 0x83; 0xd8; 0x00;  (* SBB (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x47; 0x10;  (* MOV (Memop Quadword (%% (rdi,16))) (% r8) *)
  0x49; 0x83; 0xd9; 0x00;  (* SBB (% r9) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x4f; 0x18;  (* MOV (Memop Quadword (%% (rdi,24))) (% r9) *)
  0x49; 0x83; 0xda; 0x00;  (* SBB (% r10) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x57; 0x20;  (* MOV (Memop Quadword (%% (rdi,32))) (% r10) *)
  0x49; 0x83; 0xdb; 0x00;  (* SBB (% r11) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x5f; 0x28;  (* MOV (Memop Quadword (%% (rdi,40))) (% r11) *)
  0x49; 0x83; 0xdc; 0x00;  (* SBB (% r12) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x67; 0x30;  (* MOV (Memop Quadword (%% (rdi,48))) (% r12) *)
  0x48; 0x83; 0xdb; 0x00;  (* SBB (% rbx) (Imm8 (word 0)) *)
  0x48; 0x89; 0x5f; 0x38;  (* MOV (Memop Quadword (%% (rdi,56))) (% rbx) *)
  0x48; 0x19; 0xd6;        (* SBB (% rsi) (% rdx) *)
  0x48; 0x89; 0x77; 0x40;  (* MOV (Memop Quadword (%% (rdi,64))) (% rsi) *)
  0x41; 0x5c;              (* POP (% r12) *)
  0x5b;                    (* POP (% rbx) *)
  0xc3                     (* RET *)
];;

let BIGNUM_ADD_P521_EXEC = X86_MK_CORE_EXEC_RULE bignum_add_p521_mc;;

(* ------------------------------------------------------------------------- *)
(* Proof.                                                                    *)
(* ------------------------------------------------------------------------- *)

let p_521 = new_definition `p_521 = 6864797660130609714981900799081393217269435300143305409394463459185543183397656052122559640661454554977296311391480858037121987999716643812574028291115057151`;;

let BIGNUM_ADD_P521_CORRECT = time prove
 (`!z x y m n pc.
        nonoverlapping (word pc,0xa5) (z,8 * 9)
        ==> ensures x86
             (\s. bytes_loaded s (word pc) (BUTLAST bignum_add_p521_mc) /\
                  read RIP s = word(pc + 0x3) /\
                  C_ARGUMENTS [z; x; y] s /\
                  bignum_from_memory (x,9) s = m /\
                  bignum_from_memory (y,9) s = n)
             (\s. read RIP s = word (pc + 0xa1) /\
                  (m < p_521 /\ n < p_521
                   ==> bignum_from_memory (z,9) s = (m + n) MOD p_521))
          (MAYCHANGE [RIP; RSI; RAX; RCX; RDX; R8; R9; R10; R11; RBX; R12] ,,
           MAYCHANGE SOME_FLAGS ,,
           MAYCHANGE [memory :> bignum(z,9)])`,
  MAP_EVERY X_GEN_TAC
   [`z:int64`; `x:int64`; `y:int64`; `m:num`; `n:num`; `pc:num`] THEN
  REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN

  (*** Globalize the m < p_521 /\ n < p_521 assumption ***)

  ASM_CASES_TAC `m < p_521 /\ n < p_521` THENL
   [ASM_REWRITE_TAC[]; X86_SIM_TAC BIGNUM_ADD_P521_EXEC (1--40)] THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  BIGNUM_LDIGITIZE_TAC "m_" `read (memory :> bytes (x,8 * 9)) s0` THEN
  BIGNUM_LDIGITIZE_TAC "n_" `read (memory :> bytes (y,8 * 9)) s0` THEN

  (*** Initial non-overflowing addition s = x + y + 1 ***)

  X86_ACCSTEPS_TAC BIGNUM_ADD_P521_EXEC [3;5;7;9;11;13;15;17;19] (1--19) THEN
  SUBGOAL_THEN
   `bignum_of_wordlist
     [sum_s3;sum_s5;sum_s7;sum_s9;sum_s11;sum_s13;sum_s15;sum_s17;sum_s19] =
    m + n + 1`
  ASSUME_TAC THENL
   [REWRITE_TAC[bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
    MATCH_MP_TAC EQUAL_FROM_CONGRUENT_REAL THEN
    MAP_EVERY EXISTS_TAC [`576`; `&0:real`] THEN
    CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN
    CONJ_TAC THENL
     [MAP_EVERY UNDISCH_TAC [`m < p_521`; `n < p_521`] THEN
      REWRITE_TAC[GSYM REAL_OF_NUM_LT; GSYM REAL_OF_NUM_ADD] THEN
      REWRITE_TAC[p_521] THEN REAL_ARITH_TAC;
      REWRITE_TAC[INTEGER_CLOSED]] THEN
    MAP_EVERY EXPAND_TAC ["m"; "n"] THEN
    REWRITE_TAC[bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  (*** The net comparison s >= 2^521 <=> x + y >= p_521 ***)

  X86_STEPS_TAC BIGNUM_ADD_P521_EXEC (20--21) THEN
  RULE_ASSUM_TAC(REWRITE_RULE
   [SYM(NUM_REDUCE_CONV `2 EXP 9`); GSYM WORD_OF_BITS_SING_AS_WORD;
    WORD_OF_BITS_SING_AND_WORD]) THEN
  RULE_ASSUM_TAC(REWRITE_RULE
   [WORD_OF_BITS_SING_AS_WORD; NUM_REDUCE_CONV `2 EXP 9`]) THEN
  SUBGOAL_THEN `bit 9 (sum_s19:int64) <=> p_521 <= m + n` SUBST_ALL_TAC THENL
   [REWRITE_TAC[BIT_VAL_MOD] THEN
    SUBGOAL_THEN `val(sum_s19:int64) = (m + n + 1) DIV 2 EXP 512`
    SUBST1_TAC THENL
     [FIRST_X_ASSUM(fun th ->
        GEN_REWRITE_TAC (RAND_CONV o LAND_CONV) [SYM th]) THEN
      CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
      REWRITE_TAC[];
      MATCH_MP_TAC(MESON[MOD_LT]
       `y < n /\ (x <= y <=> q) ==> (x <= y MOD n <=> q)`) THEN
      MAP_EVERY UNDISCH_TAC [`m < p_521`; `n < p_521`] THEN
      REWRITE_TAC[p_521] THEN ARITH_TAC];
    ALL_TAC] THEN
  X86_STEPS_TAC BIGNUM_ADD_P521_EXEC [22] THEN
  SUBGOAL_THEN
   `val(if p_521 <= m + n then word 512 else word 0:int64) < 512 <=>
    ~(p_521 <= m + n)`
  SUBST_ALL_TAC THENL
   [COND_CASES_TAC THEN ASM_REWRITE_TAC[] THEN
    CONV_TAC WORD_REDUCE_CONV THEN CONV_TAC NUM_REDUCE_CONV;
    ALL_TAC] THEN

  (*** The final optional subtraction of either 1 or 2^521 ***)

  X86_ACCSTEPS_TAC BIGNUM_ADD_P521_EXEC
   [23;25;27;29;31;33;35;37;39] (23--40) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  CONV_TAC SYM_CONV THEN CONV_TAC(RAND_CONV BIGNUM_LEXPAND_CONV) THEN
  ASM_REWRITE_TAC[] THEN MATCH_MP_TAC EQUAL_FROM_CONGRUENT_MOD_MOD THEN
  MAP_EVERY EXISTS_TAC
   [`64 * 9`;
    `if p_521 <= m + n then &(m + n + 1) - &2 pow 521
     else &(m + n + 1) - &1:real`] THEN
  REPEAT CONJ_TAC THENL
   [MATCH_MP_TAC BIGNUM_OF_WORDLIST_BOUND THEN
    REWRITE_TAC[LENGTH] THEN ARITH_TAC;
    REWRITE_TAC[p_521] THEN ARITH_TAC;
    REWRITE_TAC[p_521] THEN ARITH_TAC;
    ALL_TAC;
    ASM_SIMP_TAC[MOD_ADD_CASES; GSYM NOT_LE; COND_SWAP] THEN
    COND_CASES_TAC THEN ASM_SIMP_TAC[GSYM REAL_OF_NUM_SUB] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; p_521] THEN REAL_ARITH_TAC] THEN
  ABBREV_TAC `s = m + n + 1` THEN POP_ASSUM(K ALL_TAC) THEN EXPAND_TAC "s" THEN
  ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
  REWRITE_TAC[WORD_AND_MASK; GSYM NOT_LE] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; bignum_of_wordlist] THEN
  COND_CASES_TAC THEN ASM_REWRITE_TAC[BITVAL_CLAUSES] THEN
  CONV_TAC NUM_REDUCE_CONV THEN CONV_TAC WORD_REDUCE_CONV THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC);;

let BIGNUM_ADD_P521_SUBROUTINE_CORRECT = time prove
 (`!z x y m n pc stackpointer returnaddress.
        nonoverlapping (word_sub stackpointer (word 16),24) (z,8 * 9) /\
        ALL (nonoverlapping (word_sub stackpointer (word 16),16))
            [(word pc,0xa5); (x,8 * 9); (y,8 * 9)] /\
        nonoverlapping (word pc,0xa5) (z,8 * 9)
        ==> ensures x86
             (\s. bytes_loaded s (word pc) bignum_add_p521_mc /\
                  read RIP s = word pc /\
                  read RSP s = stackpointer /\
                  read (memory :> bytes64 stackpointer) s = returnaddress /\
                  C_ARGUMENTS [z; x; y] s /\
                  bignum_from_memory (x,9) s = m /\
                  bignum_from_memory (y,9) s = n)
             (\s. read RIP s = returnaddress /\
                  read RSP s = word_add stackpointer (word 8) /\
                  (m < p_521 /\ n < p_521
                   ==> bignum_from_memory (z,9) s = (m + n) MOD p_521))
          (MAYCHANGE [RIP; RSP; RSI; RAX; RCX; RDX; R8; R9; R10; R11] ,,
           MAYCHANGE SOME_FLAGS ,,
           MAYCHANGE [memory :> bignum(z,9);
                      memory :> bytes(word_sub stackpointer (word 16),16)])`,
  X86_PROMOTE_RETURN_STACK_TAC bignum_add_p521_mc BIGNUM_ADD_P521_CORRECT
    `[RBX; R12]` 16);;

(* ------------------------------------------------------------------------- *)
(* Correctness of Windows ABI version.                                       *)
(* ------------------------------------------------------------------------- *)

let windows_bignum_add_p521_mc = define_from_elf
   "windows_bignum_add_p521_mc" "x86/p521/bignum_add_p521.obj";;

let WINDOWS_BIGNUM_ADD_P521_SUBROUTINE_CORRECT = time prove
 (`!z x y m n pc stackpointer returnaddress.
        nonoverlapping (word_sub stackpointer (word 32),40) (z,8 * 9) /\
        ALL (nonoverlapping (word_sub stackpointer (word 32),32))
            [(word pc,0xb2); (x,8 * 9); (y,8 * 9)] /\
        nonoverlapping (word pc,0xb2) (z,8 * 9)
        ==> ensures x86
             (\s. bytes_loaded s (word pc) windows_bignum_add_p521_mc /\
                  read RIP s = word pc /\
                  read RSP s = stackpointer /\
                  read (memory :> bytes64 stackpointer) s = returnaddress /\
                  WINDOWS_C_ARGUMENTS [z; x; y] s /\
                  bignum_from_memory (x,9) s = m /\
                  bignum_from_memory (y,9) s = n)
             (\s. read RIP s = returnaddress /\
                  read RSP s = word_add stackpointer (word 8) /\
                  (m < p_521 /\ n < p_521
                   ==> bignum_from_memory (z,9) s = (m + n) MOD p_521))
          (MAYCHANGE [RIP; RSP; RAX; RCX; RDX; R8; R9; R10; R11] ,,
           MAYCHANGE SOME_FLAGS ,,
           MAYCHANGE [memory :> bignum(z,9);
                      memory :> bytes(word_sub stackpointer (word 32),32)])`,
  WINDOWS_X86_WRAP_STACK_TAC windows_bignum_add_p521_mc bignum_add_p521_mc
    BIGNUM_ADD_P521_CORRECT `[RBX; R12]` 16);;

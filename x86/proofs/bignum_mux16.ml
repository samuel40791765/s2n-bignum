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
(* 16-way multiplexing for k-length bignums.                                 *)
(* ========================================================================= *)

(**** print_literal_from_elf "x86/generic/bignum_mux16.o";;
 ****)

let bignum_mux16_mc =
  define_assert_from_elf "bignum_mux16_mc" "x86/generic/bignum_mux16.o"
[
  0x48; 0x85; 0xff;        (* TEST (% rdi) (% rdi) *)
  0x0f; 0x84; 0xf8; 0x00; 0x00; 0x00;
                           (* JE (Imm32 (word 248)) *)
  0x49; 0x89; 0xfa;        (* MOV (% r10) (% rdi) *)
  0x48; 0x89; 0xc8;        (* MOV (% rax) (% rcx) *)
  0x48; 0x89; 0xd1;        (* MOV (% rcx) (% rdx) *)
  0x48; 0xf7; 0xe7;        (* MUL2 (% rdx,% rax) (% rdi) *)
  0x48; 0x8b; 0x11;        (* MOV (% rdx) (Memop Quadword (%% (rcx,0))) *)
  0x49; 0x89; 0xf9;        (* MOV (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x4e; 0x8b; 0x04; 0xc9;  (* MOV (% r8) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x49; 0x39; 0xc1;        (* CMP (% r9) (% rax) *)
  0x49; 0x0f; 0x44; 0xd0;  (* CMOVE (% rdx) (% r8) *)
  0x49; 0x01; 0xf9;        (* ADD (% r9) (% rdi) *)
  0x48; 0x89; 0x16;        (* MOV (Memop Quadword (%% (rsi,0))) (% rdx) *)
  0x48; 0x83; 0xc6; 0x08;  (* ADD (% rsi) (Imm8 (word 8)) *)
  0x48; 0x83; 0xc1; 0x08;  (* ADD (% rcx) (Imm8 (word 8)) *)
  0x49; 0xff; 0xca;        (* DEC (% r10) *)
  0x0f; 0x85; 0x14; 0xff; 0xff; 0xff;
                           (* JNE (Imm32 (word 4294967060)) *)
  0xc3                     (* RET *)
];;

let BIGNUM_MUX16_EXEC = X86_MK_CORE_EXEC_RULE bignum_mux16_mc;;

(* ------------------------------------------------------------------------- *)
(* Correctness proof.                                                        *)
(* ------------------------------------------------------------------------- *)

let BIGNUM_MUX16_CORRECT = prove
 (`!k z xs i n pc.
     nonoverlapping (word pc,0x102) (z,8 * val k) /\
     nonoverlapping (xs,8 * 16 * val k) (z,8 * val k)
     ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST bignum_mux16_mc) /\
                read RIP s = word pc /\
                C_ARGUMENTS [k; z; xs; i] s /\
                (!j. j < 16
                     ==> bignum_from_memory
                          (word_add xs (word(8 * val k * j)),val k) s = n j))
           (\s. read RIP s = word (pc + 0x101) /\
                (val i < 16 ==> bignum_from_memory (z,val k) s = n (val i)))
          (MAYCHANGE [RIP; RSI; RCX; RAX; RDX; R8; R9; R10] ,,
           MAYCHANGE SOME_FLAGS ,,
           MAYCHANGE [memory :> bignum(z,val k)])`,
  W64_GEN_TAC `k:num` THEN
  MAP_EVERY X_GEN_TAC [`z:int64`; `x:int64`] THEN
  W64_GEN_TAC `i:num` THEN
  MAP_EVERY X_GEN_TAC [`n:num->num`; `pc:num`] THEN
  REWRITE_TAC[NONOVERLAPPING_CLAUSES; C_ARGUMENTS; C_RETURN; SOME_FLAGS] THEN
  STRIP_TAC THEN

  (*** We explicitly expand out the 16-fold stuff in many places here.  ***)
  (*** This is tolerable for 16 but still clumsy. It would be better    ***)
  (*** to have the simulation machinery handle bounded quantifiers, but ***)
  (*** currently the automation showing state components are maintained ***)
  (*** (e.g. READ_OVER_WRITE_ORTHOGONAL_TAC) only allows free subterms. ***)
  (*** It would not be hard to fix this, but for now we work around it. ***)

  CONV_TAC(ONCE_DEPTH_CONV EXPAND_CASES_CONV) THEN

  (*** Degenerate k = 0 case ***)

  ASM_CASES_TAC `k = 0` THENL
   [ASM_REWRITE_TAC[BIGNUM_FROM_MEMORY_TRIVIAL] THEN
    REWRITE_TAC[ARITH_RULE `0 = x <=> x = 0`] THEN
    X86_SIM_TAC BIGNUM_MUX16_EXEC (1--2) THEN
    SPEC_TAC(`i:num`,`j:num`) THEN
    CONV_TAC EXPAND_CASES_CONV THEN ASM_REWRITE_TAC[];
    ALL_TAC] THEN

  (*** Get a basic bound on k from the nonoverlapping assumptions ***)

  FIRST_ASSUM(MP_TAC o MATCH_MP (ONCE_REWRITE_RULE[IMP_CONJ]
    NONOVERLAPPING_IMP_SMALL_2)) THEN
  ANTS_TAC THENL [ASM_ARITH_TAC; DISCH_TAC] THEN

  (*** Get bounds on the individual bignums being selected ***)

  MAP_EVERY (BIGNUM_TERMRANGE_TAC `k:num`)
   (map (fun i -> vsubst[mk_small_numeral i,`i:num`] `(n:num->num) i`)
        (0--15)) THEN

  (*** Setup of the main loop ***)

  ENSURES_WHILE_PUP_TAC `k:num` `pc + 0x15` `pc + 0xfb`
   `\j s. (read RDI s = word k /\
           read RSI s = word_add z (word(8 * j)) /\
           read RCX s = word_add x (word(8 * j)) /\
           read RAX s = word(k * i) /\
           read R10 s = word(k - j) /\
           (!l. l < 16
                ==> bignum_from_memory
                     (word_add (word_add x (word (8 * k * l)))
                               (word(8 * j)),k - j) s =
                    highdigits (n l) j) /\
           (i < 16 ==> bignum_from_memory(z,j) s = lowdigits (n i) j)) /\
          (read ZF s <=> j = k)` THEN
  ASM_REWRITE_TAC[] THEN REPEAT CONJ_TAC THENL
   [CONV_TAC(ONCE_DEPTH_CONV EXPAND_CASES_CONV) THEN
    X86_SIM_TAC BIGNUM_MUX16_EXEC (1--6) THEN
    REWRITE_TAC[GSYM BIGNUM_FROM_MEMORY_BYTES; BIGNUM_FROM_MEMORY_TRIVIAL] THEN
    RULE_ASSUM_TAC(REWRITE_RULE[MULT_CLAUSES; WORD_ADD_0]) THEN
    REWRITE_TAC[SUB_0; MULT_CLAUSES; WORD_ADD_0] THEN
    ASM_REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES; HIGHDIGITS_0; LOWDIGITS_0] THEN
    REWRITE_TAC[WORD_ZX_WORD] THEN
    ONCE_REWRITE_TAC[GSYM WORD_MOD_SIZE] THEN
    REWRITE_TAC[MOD_MOD_EXP_MIN; DIMINDEX_64; DIMINDEX_128] THEN
    CONV_TAC NUM_REDUCE_CONV THEN REWRITE_TAC[MULT_AC];
    ALL_TAC; (*** This is the main loop invariant ***)
    X_GEN_TAC `j:num` THEN STRIP_TAC THEN
    CONV_TAC(ONCE_DEPTH_CONV EXPAND_CASES_CONV) THEN
    X86_SIM_TAC BIGNUM_MUX16_EXEC [1];
    X86_SIM_TAC BIGNUM_MUX16_EXEC [1] THEN ASM_SIMP_TAC[] THEN
    DISCH_TAC THEN MATCH_MP_TAC LOWDIGITS_SELF THEN
    UNDISCH_TAC `i:num < 16` THEN SPEC_TAC(`i:num`,`j:num`) THEN
    CONV_TAC EXPAND_CASES_CONV THEN ASM_REWRITE_TAC[]] THEN

  (*** Start to tackle the main loop invariant ***)

  X_GEN_TAC `j:num` THEN STRIP_TAC THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_STEP] THEN
  GEN_REWRITE_TAC (RATOR_CONV o LAND_CONV o ONCE_DEPTH_CONV)
   [BIGNUM_FROM_MEMORY_OFFSET_EQ_HIGHDIGITS] THEN
  ASM_REWRITE_TAC[SUB_EQ_0; GSYM NOT_LT] THEN
  REWRITE_TAC[ARITH_RULE `k - i - 1 = k - (i + 1)`] THEN
  REWRITE_TAC[WORD_RULE
   `word_add (word_add x (word(8 * m))) (word(8 * n)) =
    word_add x (word(8 * (m + n)))`] THEN
  CONV_TAC((RATOR_CONV o LAND_CONV o ONCE_DEPTH_CONV) EXPAND_CASES_CONV) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN

  (*** First show that the next digit is the thing we expect before we
   *** write back. In order to avoid fiddling round too much with the
   *** normalization of addresses during simulation we use VSTEPS instead
   *** of STEPS and then normalize afterwards.
   ***)

  X86_VSTEPS_TAC BIGNUM_MUX16_EXEC (1--62) THEN
  SUBGOAL_THEN `i < 16 ==> read RDX s62 = word(bigdigit (n(i:num)) j)`
  ASSUME_TAC THENL
   [DISCH_TAC THEN ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[VAL_EQ_0; WORD_SUB_EQ_0] THEN
    REWRITE_TAC[GSYM WORD_ADD_ASSOC] THEN
    REWRITE_TAC[GSYM WORD_ADD] THEN
    REWRITE_TAC[ARITH_RULE `k + k = k * 2 /\ k + k * a = k * (a + 1)`] THEN
    CONV_TAC(DEPTH_CONV NUM_ADD_CONV) THEN
    REWRITE_TAC[MESON[MULT_CLAUSES]
     `word k :int64 = word(k * i) <=> word(k * 1) :int64 = word(k * i)`] THEN
    SUBGOAL_THEN
     `!j. j < 16 ==> (word(k * j):int64 = word(k * i) <=> j = i)
`   MP_TAC THENL
     [DISCARD_OLDSTATE_TAC "s62" THEN DISCARD_STATE_TAC "s62" THEN
      X_GEN_TAC `d:num` THEN DISCH_TAC THEN
      TRANS_TAC EQ_TRANS `k * d:num = k * i` THEN
      CONJ_TAC THENL [ALL_TAC; ASM_REWRITE_TAC[EQ_MULT_LCANCEL]] THEN
      REWRITE_TAC[GSYM VAL_EQ] THEN
      BINOP_TAC THEN REWRITE_TAC[VAL_WORD_EQ_EQ] THEN
      REWRITE_TAC[DIMINDEX_64] THEN TRANS_TAC LT_TRANS `k * 16` THEN
      REWRITE_TAC[LT_MULT_LCANCEL] THEN ASM_ARITH_TAC;
      CONV_TAC(LAND_CONV EXPAND_CASES_CONV) THEN
      DISCH_THEN(fun th -> REWRITE_TAC[th])] THEN
    ONCE_REWRITE_TAC[GSYM WORD_MOD_SIZE] THEN
    REWRITE_TAC[VAL_WORD] THEN CONV_TAC MOD_DOWN_CONV THEN
    REWRITE_TAC[WORD_MOD_SIZE] THEN REWRITE_TAC[ARITH_RULE
     `8 * j + 8 * k * d = 8 * (k * d + j)`] THEN
    ASM_REWRITE_TAC[] THEN
    ONCE_REWRITE_TAC[ARITH_RULE `8 * j + 8 * k = 8 * (k * 1 + j)`] THEN
    ASM_REWRITE_TAC[] THEN
    SUBST1_TAC(ARITH_RULE `8 * j  = 8 * (k * 0 + j)`) THEN
    ASM_REWRITE_TAC[] THEN UNDISCH_TAC `i < 16` THEN
    POP_ASSUM_LIST(K ALL_TAC) THEN SPEC_TAC(`i:num`,`i:num`) THEN
    CONV_TAC EXPAND_CASES_CONV THEN CONV_TAC NUM_REDUCE_CONV;
    DISCARD_OLDSTATE_TAC "s62" THEN ABBREV_TAC `nexd = read RDX s62`] THEN

  (*** Now the writeback and tail part of the loop ***)

  X86_STEPS_TAC BIGNUM_MUX16_EXEC (63--66) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  REPEAT CONJ_TAC THENL
   [CONV_TAC WORD_RULE;
    CONV_TAC WORD_RULE;
    REWRITE_TAC[ARITH_RULE `k - (j + 1) = k - j - 1`] THEN
    GEN_REWRITE_TAC RAND_CONV [WORD_SUB] THEN
    ASM_REWRITE_TAC[ARITH_RULE `1 <= k - j <=> j < k`];
    CONV_TAC(ONCE_DEPTH_CONV EXPAND_CASES_CONV) THEN ASM_REWRITE_TAC[];
    ASM_SIMP_TAC[VAL_WORD_BIGDIGIT; LOWDIGITS_CLAUSES] THEN ARITH_TAC;
    ASM_SIMP_TAC[ARITH_RULE `j < k ==> (j + 1 = k <=> k - j = 1)`] THEN
    REWRITE_TAC[VAL_WORD_SUB_EQ_0; VAL_EQ] THEN
    MATCH_MP_TAC WORD_EQ_IMP THEN REWRITE_TAC[DIMINDEX_64] THEN
    UNDISCH_TAC `k < 2 EXP 64` THEN ARITH_TAC]);;

let BIGNUM_MUX16_SUBROUTINE_CORRECT = prove
 (`!k z xs i n pc stackpointer returnaddress.
     nonoverlapping (word pc,0x102) (z,8 * val k) /\
     nonoverlapping (stackpointer,8) (z,8 * val k) /\
     nonoverlapping (xs,8 * 16 * val k) (z,8 * val k)
     ==> ensures x86
           (\s. bytes_loaded s (word pc) bignum_mux16_mc /\
                read RIP s = word pc /\
                read RSP s = stackpointer /\
                read (memory :> bytes64 stackpointer) s = returnaddress /\
                C_ARGUMENTS [k; z; xs; i] s /\
                (!j. j < 16
                     ==> bignum_from_memory
                          (word_add xs (word(8 * val k * j)),val k) s = n j))
           (\s. read RIP s = returnaddress /\
                read RSP s = word_add stackpointer (word 8) /\
                (val i < 16 ==> bignum_from_memory (z,val k) s = n (val i)))
          (MAYCHANGE [RIP; RSP; RSI; RCX; RAX; RDX; R8; R9; R10] ,,
           MAYCHANGE SOME_FLAGS ,,
           MAYCHANGE [memory :> bignum(z,val k)])`,
  X86_PROMOTE_RETURN_NOSTACK_TAC bignum_mux16_mc BIGNUM_MUX16_CORRECT);;

(* ------------------------------------------------------------------------- *)
(* Correctness of Windows ABI version.                                       *)
(* ------------------------------------------------------------------------- *)

let windows_bignum_mux16_mc = define_from_elf
   "windows_bignum_mux16_mc" "x86/generic/bignum_mux16.obj";;

let WINDOWS_BIGNUM_MUX16_SUBROUTINE_CORRECT = prove
 (`!k z xs i n pc stackpointer returnaddress.
        ALL (nonoverlapping (word_sub stackpointer (word 16),16))
            [(word pc,0x112); (xs,8 * 16 * val k)] /\
     nonoverlapping (word pc,0x112) (z,8 * val k) /\
     nonoverlapping (word_sub stackpointer (word 16),24) (z,8 * val k) /\
     nonoverlapping (xs,8 * 16 * val k) (z,8 * val k)
     ==> ensures x86
           (\s. bytes_loaded s (word pc) windows_bignum_mux16_mc /\
                read RIP s = word pc /\
                read RSP s = stackpointer /\
                read (memory :> bytes64 stackpointer) s = returnaddress /\
                WINDOWS_C_ARGUMENTS [k; z; xs; i] s /\
                (!j. j < 16
                     ==> bignum_from_memory
                          (word_add xs (word(8 * val k * j)),val k) s = n j))
           (\s. read RIP s = returnaddress /\
                read RSP s = word_add stackpointer (word 8) /\
                (val i < 16 ==> bignum_from_memory (z,val k) s = n (val i)))
          (MAYCHANGE [RIP; RSP; RCX; RAX; RDX; R8; R9; R10] ,,
           MAYCHANGE SOME_FLAGS ,,
           MAYCHANGE [memory :> bignum(z,val k);
                      memory :> bytes(word_sub stackpointer (word 16),16)])`,
  CONV_TAC(ONCE_DEPTH_CONV EXPAND_CASES_CONV) THEN
  WINDOWS_X86_WRAP_NOSTACK_TAC windows_bignum_mux16_mc bignum_mux16_mc
    (CONV_RULE(ONCE_DEPTH_CONV EXPAND_CASES_CONV) BIGNUM_MUX16_CORRECT));;

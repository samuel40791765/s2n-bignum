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
(* Equality test on bignums.                                                 *)
(* ========================================================================= *)

(**** print_literal_from_elf "x86/generic/bignum_eq.o";;
 ****)

let bignum_eq_mc =
  define_assert_from_elf "bignum_eq_mc" "x86/generic/bignum_eq.o"
[
  0x48; 0x31; 0xc0;        (* XOR (% rax) (% rax) *)
  0x48; 0x39; 0xd7;        (* CMP (% rdi) (% rdx) *)
  0x73; 0x18;              (* JAE (Imm8 (word 24)) *)
  0x48; 0xff; 0xca;        (* DEC (% rdx) *)
  0x48; 0x0b; 0x04; 0xd1;  (* OR (% rax) (Memop Quadword (%%% (rcx,3,rdx))) *)
  0x48; 0x39; 0xd7;        (* CMP (% rdi) (% rdx) *)
  0x75; 0xf4;              (* JNE (Imm8 (word 244)) *)
  0xeb; 0x0c;              (* JMP (Imm8 (word 12)) *)
  0x48; 0xff; 0xcf;        (* DEC (% rdi) *)
  0x48; 0x0b; 0x04; 0xfe;  (* OR (% rax) (Memop Quadword (%%% (rsi,3,rdi))) *)
  0x48; 0x39; 0xd7;        (* CMP (% rdi) (% rdx) *)
  0x75; 0xf4;              (* JNE (Imm8 (word 244)) *)
  0x48; 0x85; 0xff;        (* TEST (% rdi) (% rdi) *)
  0x74; 0x12;              (* JE (Imm8 (word 18)) *)
  0x48; 0x8b; 0x54; 0xfe; 0xf8;
                           (* MOV (% rdx) (Memop Quadword (%%%% (rsi,3,rdi,-- &8))) *)
  0x48; 0x33; 0x54; 0xf9; 0xf8;
                           (* XOR (% rdx) (Memop Quadword (%%%% (rcx,3,rdi,-- &8))) *)
  0x48; 0x09; 0xd0;        (* OR (% rax) (% rdx) *)
  0x48; 0xff; 0xcf;        (* DEC (% rdi) *)
  0x75; 0xee;              (* JNE (Imm8 (word 238)) *)
  0x48; 0xf7; 0xd8;        (* NEG (% rax) *)
  0x48; 0x19; 0xc0;        (* SBB (% rax) (% rax) *)
  0x48; 0xff; 0xc0;        (* INC (% rax) *)
  0xc3                     (* RET *)
];;

let BIGNUM_EQ_EXEC = X86_MK_CORE_EXEC_RULE bignum_eq_mc;;

(* ------------------------------------------------------------------------- *)
(* Correctness proof.                                                        *)
(* ------------------------------------------------------------------------- *)

let BIGNUM_EQ_CORRECT = prove
 (`!m a x n b y pc.
        ensures x86
          (\s. bytes_loaded s (word pc) (BUTLAST bignum_eq_mc) /\
               read RIP s = word pc /\
               C_ARGUMENTS [m;a;n;b] s /\
               bignum_from_memory(a,val m) s = x /\
               bignum_from_memory(b,val n) s = y)
          (\s'. read RIP s' = word (pc + 0x42) /\
                C_RETURN s' = if x = y then word 1 else word 0)
          (MAYCHANGE [RIP; RDI; RDX; RCX; RAX] ,,
           MAYCHANGE SOME_FLAGS)`,
  W64_GEN_TAC `m:num` THEN MAP_EVERY X_GEN_TAC [`a:int64`; `x:num`] THEN
  W64_GEN_TAC `n:num` THEN MAP_EVERY X_GEN_TAC [`b:int64`; `y:num`] THEN
  X_GEN_TAC `pc:num` THEN
  REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; BIGNUM_EQ_EXEC] THEN
  BIGNUM_RANGE_TAC "m" "x" THEN BIGNUM_RANGE_TAC "n" "y" THEN

  (*** Split into subgoals at "mmain" label and do the second part first ***)

  ABBREV_TAC `p = MIN m n` THEN VAL_INT64_TAC `p:num` THEN

  ENSURES_SEQUENCE_TAC `pc + 0x22`
   `\s. read RDI s = word p /\
        read RSI s = a /\
        read RCX s = b /\
        bignum_from_memory (a,m) s = x /\
        bignum_from_memory (b,n) s = y /\
        (read RAX s = word 0 <=> highdigits x p = highdigits y p)` THEN
  CONJ_TAC THENL
   [ALL_TAC;

    ASM_CASES_TAC `p = 0` THENL
     [ASM_REWRITE_TAC[HIGHDIGITS_0] THEN
      GHOST_INTRO_TAC `d:int64` `read RAX` THEN
      ENSURES_INIT_TAC "s0" THEN X86_STEPS_TAC BIGNUM_EQ_EXEC (1--5) THEN
      ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
      COND_CASES_TAC THEN ASM_REWRITE_TAC[BITVAL_CLAUSES] THEN
      CONV_TAC WORD_RULE;
      ALL_TAC] THEN

    ENSURES_WHILE_PDOWN_TAC `p:num` `pc + 0x27` `pc + 0x37`
     `\i s. (read RDI s = word i /\
             read RSI s = a /\
             read RCX s = b /\
             bignum_from_memory (a,m) s = x /\
             bignum_from_memory (b,n) s = y /\
             (read RAX s = word 0 <=> highdigits x i = highdigits y i)) /\
            (read ZF s <=> i = 0)` THEN
    ASM_REWRITE_TAC[] THEN REPEAT CONJ_TAC THENL
     [ASM_REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
      ENSURES_INIT_TAC "s0" THEN X86_STEPS_TAC BIGNUM_EQ_EXEC (1--2) THEN
      ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[];
      ALL_TAC; (*** Main loop invariant ***)
      X_GEN_TAC `i:num` THEN STRIP_TAC THEN VAL_INT64_TAC `i:num` THEN
      ASM_REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
      ENSURES_INIT_TAC "s0" THEN X86_STEPS_TAC BIGNUM_EQ_EXEC [1] THEN
      ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[];
      REWRITE_TAC[HIGHDIGITS_0; BIGNUM_FROM_MEMORY_BYTES] THEN
      GHOST_INTRO_TAC `d:int64` `read RAX` THEN ENSURES_INIT_TAC "s0" THEN
      X86_STEPS_TAC BIGNUM_EQ_EXEC (1--4) THEN
      ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[WORD_SUB_0; VAL_EQ_0] THEN
      COND_CASES_TAC THEN ASM_REWRITE_TAC[BITVAL_CLAUSES] THEN
      CONV_TAC WORD_RULE] THEN
    X_GEN_TAC `i:num` THEN STRIP_TAC THEN
    SUBGOAL_THEN `i:num < m /\ i < n` STRIP_ASSUME_TAC THENL
     [SIMPLE_ARITH_TAC; ALL_TAC] THEN
    MAP_EVERY VAL_INT64_TAC [`i:num`; `i + 1`] THEN
    ASSUME_TAC(WORD_RULE
     `word_sub (word (i + 1)) (word 1):int64 = word i`) THEN
    GHOST_INTRO_TAC `d:int64` `read RAX` THEN
    REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
    ENSURES_INIT_TAC "s0" THEN
    SUBGOAL_THEN
     `read(memory :>
           bytes64(word_add a (word(8 * (i + 1) + 18446744073709551608)))) s0 =
      word(bigdigit x i) /\
      read(memory :>
           bytes64(word_add b (word(8 * (i + 1) + 18446744073709551608)))) s0 =
      word(bigdigit y i)`
    ASSUME_TAC THENL
     [REWRITE_TAC[WORD_INDEX_WRAP] THEN MAP_EVERY EXPAND_TAC ["x"; "y"] THEN
      REWRITE_TAC[GSYM BIGNUM_FROM_MEMORY_BYTES;
                  BIGDIGIT_BIGNUM_FROM_MEMORY] THEN
      ASM_REWRITE_TAC[WORD_VAL];
      ALL_TAC] THEN
    X86_STEPS_TAC BIGNUM_EQ_EXEC (1--4) THEN
    ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[WORD_OR_EQ_0] THEN
    GEN_REWRITE_TAC (RAND_CONV o BINOP_CONV) [HIGHDIGITS_STEP] THEN
    SIMP_TAC[LEXICOGRAPHIC_EQ_64; BIGDIGIT_BOUND] THEN
    AP_TERM_TAC THEN REWRITE_TAC[WORD_XOR_EQ_0] THEN
    MATCH_MP_TAC WORD_EQ_IMP THEN
    REWRITE_TAC[DIMINDEX_64; BIGDIGIT_BOUND]] THEN

  (*** The case m = n, which is a simple drop-through ***)

  ASM_CASES_TAC `m:num = n` THENL
   [UNDISCH_THEN `m:num = n` SUBST_ALL_TAC THEN
    FIRST_X_ASSUM(SUBST1_TAC o MATCH_MP (ARITH_RULE
     `MIN n n = p ==> p = n`)) THEN
    ASM_SIMP_TAC[HIGHDIGITS_ZERO] THEN
    REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
    ENSURES_INIT_TAC "s0" THEN X86_STEPS_TAC BIGNUM_EQ_EXEC (1--4) THEN
    ENSURES_FINAL_STATE_TAC THEN
    ASM_REWRITE_TAC[WORD_SUB_REFL; VAL_WORD_0];
    ALL_TAC] THEN

  (*** Now the n > m and m > n cases respectively, very similar proofs ***)

  FIRST_X_ASSUM(DISJ_CASES_TAC o MATCH_MP (ARITH_RULE
   `~(m:num = n) ==> m < n \/ n < m`)) THEN
  UNDISCH_TAC `MIN m n = p` THEN
  ASM_SIMP_TAC[ARITH_RULE `m < n ==> MIN m n = m`;
               ARITH_RULE `n < m ==> MIN m n = n`] THEN
  DISCH_THEN(SUBST_ALL_TAC o SYM) THEN ASM_SIMP_TAC[HIGHDIGITS_ZERO] THENL
   [ENSURES_WHILE_PDOWN_TAC `n - m:num` `pc + 0x8` `pc + 0x12`
     `\i s. (read RDI s = word m /\
             read RSI s = a /\
             read RDX s = word(m + i) /\
             read RCX s = b /\
             bignum_from_memory (a,m) s = x /\
             bignum_from_memory (b,n) s = y /\
             (read RAX s = word 0 <=> highdigits y (m + i) = 0)) /\
            (read ZF s <=> i = 0)` THEN
    ASM_REWRITE_TAC[] THEN REPEAT CONJ_TAC THENL
     [UNDISCH_TAC `m:num < n` THEN ARITH_TAC;
      ASM_REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
      ENSURES_INIT_TAC "s0" THEN X86_STEPS_TAC BIGNUM_EQ_EXEC (1--3) THEN
      ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
      ASM_SIMP_TAC[GSYM NOT_LT; ARITH_RULE `m:num < n ==> m + n - m = n`] THEN
      ASM_SIMP_TAC[HIGHDIGITS_ZERO];
      ALL_TAC; (*** Main loop invariant ***)
      X_GEN_TAC `i:num` THEN STRIP_TAC THEN
      ASM_REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
      ENSURES_INIT_TAC "s0" THEN X86_STEPS_TAC BIGNUM_EQ_EXEC [1] THEN
      ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[];
      REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
      GHOST_INTRO_TAC `d:int64` `read RAX` THEN ENSURES_INIT_TAC "s0" THEN
      X86_STEPS_TAC BIGNUM_EQ_EXEC (1--2) THEN
      ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[ADD_CLAUSES] THEN
      MESON_TAC[]] THEN
    X_GEN_TAC `i:num` THEN STRIP_TAC THEN
    ASSUME_TAC(WORD_RULE
     `word_sub (word (m + i + 1)) (word 1):int64 = word(m + i)`) THEN
    MAP_EVERY VAL_INT64_TAC [`i:num`; `m + i:num`] THEN
    GHOST_INTRO_TAC `d:int64` `read RAX` THEN
    REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
    ENSURES_INIT_TAC "s0" THEN
    SUBGOAL_THEN
     `read(memory :> bytes64(word_add b (word (8 * (m + i))))) s0 =
      word(bigdigit y (m + i))`
    STRIP_ASSUME_TAC THENL
     [EXPAND_TAC "y" THEN
      REWRITE_TAC[GSYM BIGNUM_FROM_MEMORY_BYTES;
                  BIGDIGIT_BIGNUM_FROM_MEMORY] THEN
      COND_CASES_TAC THEN ASM_REWRITE_TAC[WORD_VAL] THEN SIMPLE_ARITH_TAC;
      ALL_TAC] THEN
    X86_STEPS_TAC BIGNUM_EQ_EXEC (1--3) THEN
    ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[WORD_OR_EQ_0] THEN
    REWRITE_TAC[VAL_EQ_0; WORD_NEG_EQ_0;
      WORD_RULE `word_sub (word m) (word (m + i)) = word_neg(word i)`] THEN
    ASM_REWRITE_TAC[GSYM VAL_EQ_0] THEN
    GEN_REWRITE_TAC (RAND_CONV o LAND_CONV) [HIGHDIGITS_STEP] THEN
    REWRITE_TAC[ADD_EQ_0; MULT_EQ_0; EXP_EQ_0; ARITH_EQ] THEN
    REWRITE_TAC[GSYM ADD_ASSOC] THEN AP_TERM_TAC THEN
    REWRITE_TAC[VAL_EQ_0] THEN MATCH_MP_TAC WORD_EQ_0 THEN
    REWRITE_TAC[DIMINDEX_64; BIGDIGIT_BOUND];

    ENSURES_WHILE_PDOWN_TAC `m - n:num` `pc + 0x16` `pc + 0x20`
     `\i s. (read RDI s = word(n + i) /\
             read RSI s = a /\
             read RDX s = word n /\
             read RCX s = b /\
             bignum_from_memory (a,m) s = x /\
             bignum_from_memory (b,n) s = y /\
             (read RAX s = word 0 <=> highdigits x (n + i) = 0)) /\
            (read ZF s <=> i = 0)` THEN
    ASM_REWRITE_TAC[] THEN REPEAT CONJ_TAC THENL
     [UNDISCH_TAC `n:num < m` THEN ARITH_TAC;
      ASM_REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
      ENSURES_INIT_TAC "s0" THEN
      SUBGOAL_THEN `n:num <= m` ASSUME_TAC THENL
       [ASM_SIMP_TAC[LT_IMP_LE]; ALL_TAC] THEN
      X86_STEPS_TAC BIGNUM_EQ_EXEC (1--4) THEN
      ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
      ASM_SIMP_TAC[ARITH_RULE `m:num < n ==> m + n - m = n`] THEN
      ASM_SIMP_TAC[HIGHDIGITS_ZERO; VAL_EQ_0; WORD_SUB_EQ_0] THEN
      ASM_REWRITE_TAC[GSYM VAL_EQ] THEN
      COND_CASES_TAC THEN ASM_REWRITE_TAC[] THEN SIMPLE_ARITH_TAC;
      ALL_TAC; (*** Main loop invariant ***)
      X_GEN_TAC `i:num` THEN STRIP_TAC THEN
      ASM_REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
      ENSURES_INIT_TAC "s0" THEN X86_STEPS_TAC BIGNUM_EQ_EXEC [1] THEN
      ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[];
      REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
      GHOST_INTRO_TAC `d:int64` `read RAX` THEN ENSURES_INIT_TAC "s0" THEN
      X86_STEPS_TAC BIGNUM_EQ_EXEC [1] THEN
      ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[ADD_CLAUSES]] THEN
    X_GEN_TAC `i:num` THEN STRIP_TAC THEN
    ASSUME_TAC(WORD_RULE
     `word_sub (word (n + i + 1)) (word 1):int64 = word(n + i)`) THEN
    MAP_EVERY VAL_INT64_TAC [`i:num`; `n + i:num`] THEN
    GHOST_INTRO_TAC `d:int64` `read RAX` THEN
    REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
    ENSURES_INIT_TAC "s0" THEN
    SUBGOAL_THEN
     `read(memory :> bytes64(word_add a (word (8 * (n + i))))) s0 =
      word(bigdigit x (n + i))`
    STRIP_ASSUME_TAC THENL
     [EXPAND_TAC "x" THEN
      REWRITE_TAC[GSYM BIGNUM_FROM_MEMORY_BYTES;
                  BIGDIGIT_BIGNUM_FROM_MEMORY] THEN
      COND_CASES_TAC THEN ASM_REWRITE_TAC[WORD_VAL] THEN SIMPLE_ARITH_TAC;
      ALL_TAC] THEN
    X86_STEPS_TAC BIGNUM_EQ_EXEC (1--3) THEN
    ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[WORD_OR_EQ_0] THEN
    ASM_REWRITE_TAC[GSYM VAL_EQ_0; WORD_RULE
     `word_sub (word (n + i)) (word n) = word i`] THEN
    GEN_REWRITE_TAC (RAND_CONV o LAND_CONV) [HIGHDIGITS_STEP] THEN
    REWRITE_TAC[ADD_EQ_0; MULT_EQ_0; EXP_EQ_0; ARITH_EQ] THEN
    REWRITE_TAC[GSYM ADD_ASSOC] THEN AP_TERM_TAC THEN
    REWRITE_TAC[VAL_EQ_0] THEN MATCH_MP_TAC WORD_EQ_0 THEN
    REWRITE_TAC[DIMINDEX_64; BIGDIGIT_BOUND]]);;

let BIGNUM_EQ_SUBROUTINE_CORRECT = prove
 (`!m a x n b y pc stackpointer returnaddress.
        ensures x86
          (\s. bytes_loaded s (word pc) bignum_eq_mc /\
               read RIP s = word pc /\
               read RSP s = stackpointer /\
               read (memory :> bytes64 stackpointer) s = returnaddress /\
               C_ARGUMENTS [m;a;n;b] s /\
               bignum_from_memory(a,val m) s = x /\
               bignum_from_memory(b,val n) s = y)
          (\s'. read RIP s' = returnaddress /\
                read RSP s' = word_add stackpointer (word 8) /\
                C_RETURN s' = if x = y then word 1 else word 0)
          (MAYCHANGE [RIP; RSP; RDI; RDX; RCX; RAX] ,,
           MAYCHANGE SOME_FLAGS)`,
  X86_PROMOTE_RETURN_NOSTACK_TAC bignum_eq_mc BIGNUM_EQ_CORRECT);;

(* ------------------------------------------------------------------------- *)
(* Correctness of Windows ABI version.                                       *)
(* ------------------------------------------------------------------------- *)

let windows_bignum_eq_mc = define_from_elf
   "windows_bignum_eq_mc" "x86/generic/bignum_eq.obj";;

let WINDOWS_BIGNUM_EQ_SUBROUTINE_CORRECT = prove
 (`!m a x n b y pc stackpointer returnaddress.
     ALL (nonoverlapping (word_sub stackpointer (word 16),16))
         [(word pc,0x53); (a,8 * val m); (b,8 * val n)]
     ==> ensures x86
          (\s. bytes_loaded s (word pc) windows_bignum_eq_mc /\
               read RIP s = word pc /\
               read RSP s = stackpointer /\
               read (memory :> bytes64 stackpointer) s = returnaddress /\
               WINDOWS_C_ARGUMENTS [m;a;n;b] s /\
               bignum_from_memory(a,val m) s = x /\
               bignum_from_memory(b,val n) s = y)
          (\s'. read RIP s' = returnaddress /\
                read RSP s' = word_add stackpointer (word 8) /\
                WINDOWS_C_RETURN s' = if x = y then word 1 else word 0)
          (MAYCHANGE [RIP; RSP; RDX; RCX; RAX] ,,
           MAYCHANGE SOME_FLAGS ,,
          MAYCHANGE [memory :> bytes(word_sub stackpointer (word 16),16)])`,
  WINDOWS_X86_WRAP_NOSTACK_TAC windows_bignum_eq_mc bignum_eq_mc
    BIGNUM_EQ_CORRECT);;

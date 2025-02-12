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
(* MULX-based 4x4->8 squaring.                                               *)
(* ========================================================================= *)

(**** print_literal_from_elf "x86/fastmul/bignum_sqr_4_8.o";;
 ****)

let bignum_sqr_4_8_mc =
  define_assert_from_elf "bignum_sqr_4_8_mc" "x86/fastmul/bignum_sqr_4_8.o"
[
  0x55;                    (* PUSH (% rbp) *)
  0x41; 0x54;              (* PUSH (% r12) *)
  0x41; 0x55;              (* PUSH (% r13) *)
  0x48; 0x8b; 0x16;        (* MOV (% rdx) (Memop Quadword (%% (rsi,0))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0x4e; 0x08;
                           (* MULX4 (% r9,% r8) (% rdx,Memop Quadword (%% (rsi,8))) *)
  0xc4; 0x62; 0xab; 0xf6; 0x5e; 0x18;
                           (* MULX4 (% r11,% r10) (% rdx,Memop Quadword (%% (rsi,24))) *)
  0x48; 0x8b; 0x56; 0x10;  (* MOV (% rdx) (Memop Quadword (%% (rsi,16))) *)
  0xc4; 0x62; 0x9b; 0xf6; 0x6e; 0x18;
                           (* MULX4 (% r13,% r12) (% rdx,Memop Quadword (%% (rsi,24))) *)
  0x31; 0xed;              (* XOR (% ebp) (% ebp) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x0e;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsi,0))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd1;
                           (* ADOX (% r10) (% rcx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x4e; 0x08;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsi,8))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd9;
                           (* ADOX (% r11) (% rcx) *)
  0x48; 0x8b; 0x56; 0x18;  (* MOV (% rdx) (Memop Quadword (%% (rsi,24))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x4e; 0x08;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsi,8))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe1;
                           (* ADOX (% r12) (% rcx) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe5;
                           (* ADCX (% r12) (% rbp) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xed;
                           (* ADOX (% r13) (% rbp) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xed;
                           (* ADCX (% r13) (% rbp) *)
  0x31; 0xed;              (* XOR (% ebp) (% ebp) *)
  0x48; 0x8b; 0x16;        (* MOV (% rdx) (Memop Quadword (%% (rsi,0))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x48; 0x89; 0x07;        (* MOV (Memop Quadword (%% (rdi,0))) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% r8) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xc2;
                           (* ADOX (% r8) (% rdx) *)
  0x48; 0x8b; 0x56; 0x08;  (* MOV (% rdx) (Memop Quadword (%% (rsi,8))) *)
  0x4c; 0x89; 0x47; 0x08;  (* MOV (Memop Quadword (%% (rdi,8))) (% r8) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xc9;
                           (* ADCX (% r9) (% r9) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADOX (% r9) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xd2;
                           (* ADCX (% r10) (% r10) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd2;
                           (* ADOX (% r10) (% rdx) *)
  0x48; 0x8b; 0x56; 0x10;  (* MOV (% rdx) (Memop Quadword (%% (rsi,16))) *)
  0x4c; 0x89; 0x4f; 0x10;  (* MOV (Memop Quadword (%% (rdi,16))) (% r9) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADCX (% r11) (% r11) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADOX (% r11) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xe4;
                           (* ADCX (% r12) (% r12) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe2;
                           (* ADOX (% r12) (% rdx) *)
  0x48; 0x8b; 0x56; 0x18;  (* MOV (% rdx) (Memop Quadword (%% (rsi,24))) *)
  0x4c; 0x89; 0x57; 0x18;  (* MOV (Memop Quadword (%% (rdi,24))) (% r10) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x4c; 0x89; 0x5f; 0x20;  (* MOV (Memop Quadword (%% (rdi,32))) (% r11) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xed;
                           (* ADCX (% r13) (% r13) *)
  0x4c; 0x89; 0x67; 0x28;  (* MOV (Memop Quadword (%% (rdi,40))) (% r12) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADOX (% r13) (% rax) *)
  0x4c; 0x89; 0x6f; 0x30;  (* MOV (Memop Quadword (%% (rdi,48))) (% r13) *)
  0x66; 0x48; 0x0f; 0x38; 0xf6; 0xd5;
                           (* ADCX (% rdx) (% rbp) *)
  0xf3; 0x48; 0x0f; 0x38; 0xf6; 0xd5;
                           (* ADOX (% rdx) (% rbp) *)
  0x48; 0x89; 0x57; 0x38;  (* MOV (Memop Quadword (%% (rdi,56))) (% rdx) *)
  0x41; 0x5d;              (* POP (% r13) *)
  0x41; 0x5c;              (* POP (% r12) *)
  0x5d;                    (* POP (% rbp) *)
  0xc3                     (* RET *)
];;

let BIGNUM_SQR_4_8_EXEC = X86_MK_CORE_EXEC_RULE bignum_sqr_4_8_mc;;

(* ------------------------------------------------------------------------- *)
(* Proof.                                                                    *)
(* ------------------------------------------------------------------------- *)

let BIGNUM_SQR_4_8_CORRECT = time prove
 (`!z x a pc.
     nonoverlapping (word pc,0x109) (z,8 * 8) /\
     (x = z \/ nonoverlapping (x,8 * 4) (z,8 * 8))
     ==> ensures x86
          (\s. bytes_loaded s (word pc) (BUTLAST bignum_sqr_4_8_mc) /\
               read RIP s = word(pc + 0x05) /\
               C_ARGUMENTS [z; x] s /\
               bignum_from_memory (x,4) s = a)
          (\s. read RIP s = word (pc + 0x103) /\
               bignum_from_memory (z,8) s = a EXP 2)
          (MAYCHANGE [RIP; RAX; RBP; RCX; RDX;
                      R8; R9; R10; R11; R12; R13] ,,
           MAYCHANGE [memory :> bytes(z,8 * 8)] ,,
           MAYCHANGE SOME_FLAGS)`,
  MAP_EVERY X_GEN_TAC [`z:int64`; `x:int64`; `a:num`; `pc:num`] THEN
  REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  ENSURES_INIT_TAC "s0" THEN
  BIGNUM_DIGITIZE_TAC "x_" `bignum_from_memory (x,4) s0` THEN
  X86_ACCSTEPS_TAC BIGNUM_SQR_4_8_EXEC (1--50) (1--50) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  CONV_TAC(LAND_CONV BIGNUM_EXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  EXPAND_TAC "a" THEN REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES] THEN
  ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC);;

let BIGNUM_SQR_4_8_SUBROUTINE_CORRECT = time prove
 (`!z x a pc stackpointer returnaddress.
     nonoverlapping (word_sub stackpointer (word 24),32) (z,8 * 8) /\
     ALL (nonoverlapping (word_sub stackpointer (word 24),24))
         [(word pc,0x109); (x,8 * 4)] /\
     nonoverlapping (word pc,0x109) (z,8 * 8) /\
     (x = z \/ nonoverlapping (x,8 * 4) (z,8 * 8))
     ==> ensures x86
          (\s. bytes_loaded s (word pc) bignum_sqr_4_8_mc /\
               read RIP s = word pc /\
               read RSP s = stackpointer /\
               read (memory :> bytes64 stackpointer) s = returnaddress /\
               C_ARGUMENTS [z; x] s /\
               bignum_from_memory (x,4) s = a)
          (\s. read RIP s = returnaddress /\
               read RSP s = word_add stackpointer (word 8) /\
               bignum_from_memory (z,8) s = a EXP 2)
          (MAYCHANGE [RIP; RSP; RAX; RCX; RDX; R8; R9; R10; R11] ,,
           MAYCHANGE [memory :> bytes(z,8 * 8);
                     memory :> bytes(word_sub stackpointer (word 24),24)] ,,
           MAYCHANGE SOME_FLAGS)`,
  X86_PROMOTE_RETURN_STACK_TAC bignum_sqr_4_8_mc BIGNUM_SQR_4_8_CORRECT
   `[RBP; R12; R13]` 24);;

(* ------------------------------------------------------------------------- *)
(* Correctness of Windows ABI version.                                       *)
(* ------------------------------------------------------------------------- *)

let windows_bignum_sqr_4_8_mc = define_from_elf
   "windows_bignum_sqr_4_8_mc" "x86/fastmul/bignum_sqr_4_8.obj";;

let WINDOWS_BIGNUM_SQR_4_8_SUBROUTINE_CORRECT = time prove
 (`!z x a pc stackpointer returnaddress.
     nonoverlapping (word_sub stackpointer (word 40),48) (z,8 * 8) /\
     ALL (nonoverlapping (word_sub stackpointer (word 40),40))
         [(word pc,0x113); (x,8 * 4)] /\
     nonoverlapping (word pc,0x113) (z,8 * 8) /\
     (x = z \/ nonoverlapping (x,8 * 4) (z,8 * 8))
     ==> ensures x86
          (\s. bytes_loaded s (word pc) windows_bignum_sqr_4_8_mc /\
               read RIP s = word pc /\
               read RSP s = stackpointer /\
               read (memory :> bytes64 stackpointer) s = returnaddress /\
               WINDOWS_C_ARGUMENTS [z; x] s /\
               bignum_from_memory (x,4) s = a)
          (\s. read RIP s = returnaddress /\
               read RSP s = word_add stackpointer (word 8) /\
               bignum_from_memory (z,8) s = a EXP 2)
          (MAYCHANGE [RIP; RSP; RAX; RCX; RDX; R8; R9; R10; R11] ,,
           MAYCHANGE [memory :> bytes(z,8 * 8);
                     memory :> bytes(word_sub stackpointer (word 40),40)] ,,
           MAYCHANGE SOME_FLAGS)`,
  WINDOWS_X86_WRAP_STACK_TAC windows_bignum_sqr_4_8_mc bignum_sqr_4_8_mc
    BIGNUM_SQR_4_8_CORRECT `[RBP; R12; R13]` 24);;

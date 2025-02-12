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
(* 6x6->12 squaring using traditional x86 mul instructions.                  *)
(* ========================================================================= *)

(**** print_literal_from_elf "x86/fastmul/bignum_sqr_6_12_alt.o";;
 ****)

let bignum_sqr_6_12_alt_mc =
  define_assert_from_elf "bignum_sqr_6_12_alt_mc" "x86/fastmul/bignum_sqr_6_12_alt.o"
[
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x48; 0x89; 0x07;        (* MOV (Memop Quadword (%% (rdi,0))) (% rax) *)
  0x49; 0x89; 0xd0;        (* MOV (% r8) (% rdx) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x4d; 0x31; 0xd2;        (* XOR (% r10) (% r10) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0xf7; 0x66; 0x08;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0x01; 0xc0;        (* ADD (% rax) (% rax) *)
  0x48; 0x11; 0xd2;        (* ADC (% rdx) (% rdx) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x47; 0x08;  (* MOV (Memop Quadword (%% (rdi,8))) (% r8) *)
  0x4d; 0x31; 0xc0;        (* XOR (% r8) (% r8) *)
  0x48; 0x8b; 0x46; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0xf7; 0x66; 0x10;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0x01; 0xc0;        (* ADD (% rax) (% rax) *)
  0x48; 0x11; 0xd2;        (* ADC (% rdx) (% rdx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x4f; 0x10;  (* MOV (Memop Quadword (%% (rdi,16))) (% r9) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0xf7; 0x66; 0x18;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,24))) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x48; 0x89; 0xc1;        (* MOV (% rcx) (% rax) *)
  0x49; 0x89; 0xd3;        (* MOV (% r11) (% rdx) *)
  0x48; 0x8b; 0x46; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0xf7; 0x66; 0x10;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0x01; 0xc1;        (* ADD (% rcx) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x49; 0x83; 0xd1; 0x00;  (* ADC (% r9) (Imm8 (word 0)) *)
  0x48; 0x01; 0xc9;        (* ADD (% rcx) (% rcx) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xc9;        (* ADC (% r9) (% r9) *)
  0x49; 0x01; 0xca;        (* ADD (% r10) (% rcx) *)
  0x4d; 0x11; 0xd8;        (* ADC (% r8) (% r11) *)
  0x49; 0x83; 0xd1; 0x00;  (* ADC (% r9) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x57; 0x18;  (* MOV (Memop Quadword (%% (rdi,24))) (% r10) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0xf7; 0x66; 0x20;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,32))) *)
  0x4d; 0x31; 0xd2;        (* XOR (% r10) (% r10) *)
  0x48; 0x89; 0xc1;        (* MOV (% rcx) (% rax) *)
  0x49; 0x89; 0xd3;        (* MOV (% r11) (% rdx) *)
  0x48; 0x8b; 0x46; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0xf7; 0x66; 0x18;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0x01; 0xc1;        (* ADD (% rcx) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x48; 0x01; 0xc9;        (* ADD (% rcx) (% rcx) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x49; 0x01; 0xc8;        (* ADD (% r8) (% rcx) *)
  0x4d; 0x11; 0xd9;        (* ADC (% r9) (% r11) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x48; 0x8b; 0x46; 0x10;  (* MOV (% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x47; 0x20;  (* MOV (Memop Quadword (%% (rdi,32))) (% r8) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0xf7; 0x66; 0x28;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,40))) *)
  0x4d; 0x31; 0xc0;        (* XOR (% r8) (% r8) *)
  0x48; 0x89; 0xc1;        (* MOV (% rcx) (% rax) *)
  0x49; 0x89; 0xd3;        (* MOV (% r11) (% rdx) *)
  0x48; 0x8b; 0x46; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0xf7; 0x66; 0x20;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,32))) *)
  0x48; 0x01; 0xc1;        (* ADD (% rcx) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x48; 0x8b; 0x46; 0x10;  (* MOV (% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0xf7; 0x66; 0x18;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0x01; 0xc1;        (* ADD (% rcx) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x48; 0x01; 0xc9;        (* ADD (% rcx) (% rcx) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x49; 0x01; 0xc9;        (* ADD (% r9) (% rcx) *)
  0x4d; 0x11; 0xda;        (* ADC (% r10) (% r11) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x4f; 0x28;  (* MOV (Memop Quadword (%% (rdi,40))) (% r9) *)
  0x48; 0x8b; 0x46; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0xf7; 0x66; 0x28;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,40))) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x48; 0x89; 0xc1;        (* MOV (% rcx) (% rax) *)
  0x49; 0x89; 0xd3;        (* MOV (% r11) (% rdx) *)
  0x48; 0x8b; 0x46; 0x10;  (* MOV (% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0xf7; 0x66; 0x20;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,32))) *)
  0x48; 0x01; 0xc1;        (* ADD (% rcx) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x49; 0x83; 0xd1; 0x00;  (* ADC (% r9) (Imm8 (word 0)) *)
  0x48; 0x01; 0xc9;        (* ADD (% rcx) (% rcx) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xc9;        (* ADC (% r9) (% r9) *)
  0x49; 0x01; 0xca;        (* ADD (% r10) (% rcx) *)
  0x4d; 0x11; 0xd8;        (* ADC (% r8) (% r11) *)
  0x49; 0x83; 0xd1; 0x00;  (* ADC (% r9) (Imm8 (word 0)) *)
  0x48; 0x8b; 0x46; 0x18;  (* MOV (% rax) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd0;        (* ADC (% r8) (% rdx) *)
  0x49; 0x83; 0xd1; 0x00;  (* ADC (% r9) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x57; 0x30;  (* MOV (Memop Quadword (%% (rdi,48))) (% r10) *)
  0x48; 0x8b; 0x46; 0x10;  (* MOV (% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0xf7; 0x66; 0x28;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,40))) *)
  0x4d; 0x31; 0xd2;        (* XOR (% r10) (% r10) *)
  0x48; 0x89; 0xc1;        (* MOV (% rcx) (% rax) *)
  0x49; 0x89; 0xd3;        (* MOV (% r11) (% rdx) *)
  0x48; 0x8b; 0x46; 0x18;  (* MOV (% rax) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0xf7; 0x66; 0x20;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,32))) *)
  0x48; 0x01; 0xc1;        (* ADD (% rcx) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x48; 0x01; 0xc9;        (* ADD (% rcx) (% rcx) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x49; 0x01; 0xc8;        (* ADD (% r8) (% rcx) *)
  0x4d; 0x11; 0xd9;        (* ADC (% r9) (% r11) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x47; 0x38;  (* MOV (Memop Quadword (%% (rdi,56))) (% r8) *)
  0x4d; 0x31; 0xc0;        (* XOR (% r8) (% r8) *)
  0x48; 0x8b; 0x46; 0x18;  (* MOV (% rax) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0xf7; 0x66; 0x28;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,40))) *)
  0x48; 0x01; 0xc0;        (* ADD (% rax) (% rax) *)
  0x48; 0x11; 0xd2;        (* ADC (% rdx) (% rdx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x48; 0x8b; 0x46; 0x20;  (* MOV (% rax) (Memop Quadword (%% (rsi,32))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x4f; 0x40;  (* MOV (Memop Quadword (%% (rdi,64))) (% r9) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x48; 0x8b; 0x46; 0x20;  (* MOV (% rax) (Memop Quadword (%% (rsi,32))) *)
  0x48; 0xf7; 0x66; 0x28;  (* MUL2 (% rdx,% rax) (Memop Quadword (%% (rsi,40))) *)
  0x48; 0x01; 0xc0;        (* ADD (% rax) (% rax) *)
  0x48; 0x11; 0xd2;        (* ADC (% rdx) (% rdx) *)
  0x49; 0x83; 0xd1; 0x00;  (* ADC (% r9) (Imm8 (word 0)) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd0;        (* ADC (% r8) (% rdx) *)
  0x49; 0x83; 0xd1; 0x00;  (* ADC (% r9) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x57; 0x48;  (* MOV (Memop Quadword (%% (rdi,72))) (% r10) *)
  0x48; 0x8b; 0x46; 0x28;  (* MOV (% rax) (Memop Quadword (%% (rsi,40))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x47; 0x50;  (* MOV (Memop Quadword (%% (rdi,80))) (% r8) *)
  0x4c; 0x89; 0x4f; 0x58;  (* MOV (Memop Quadword (%% (rdi,88))) (% r9) *)
  0xc3                     (* RET *)
];;

let BIGNUM_SQR_6_12_ALT_EXEC = X86_MK_CORE_EXEC_RULE bignum_sqr_6_12_alt_mc;;

(* ------------------------------------------------------------------------- *)
(* Proof.                                                                    *)
(* ------------------------------------------------------------------------- *)

let BIGNUM_SQR_6_12_ALT_CORRECT = time prove
 (`!z x a pc.
     ALL (nonoverlapping (z,8 * 12)) [(word pc,0x224); (x,8 * 6)]
     ==> ensures x86
          (\s. bytes_loaded s (word pc) (BUTLAST bignum_sqr_6_12_alt_mc) /\
               read RIP s = word pc /\
               C_ARGUMENTS [z; x] s /\
               bignum_from_memory (x,6) s = a)
          (\s. read RIP s = word (pc + 0x223) /\
               bignum_from_memory (z,12) s = a EXP 2)
          (MAYCHANGE [RIP; RAX; RCX; RDX; R8; R9; R10; R11] ,,
           MAYCHANGE [memory :> bytes(z,8 * 12)] ,,
           MAYCHANGE SOME_FLAGS)`,
  MAP_EVERY X_GEN_TAC [`z:int64`; `x:int64`; `a:num`; `pc:num`] THEN
  REWRITE_TAC[C_ARGUMENTS; ALL; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  ENSURES_INIT_TAC "s0" THEN
  BIGNUM_DIGITIZE_TAC "x_" `bignum_from_memory (x,6) s0` THEN
  X86_ACCSTEPS_TAC BIGNUM_SQR_6_12_ALT_EXEC (1--161) (1--161) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  CONV_TAC(LAND_CONV BIGNUM_EXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  EXPAND_TAC "a" THEN REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES] THEN
  ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC);;

let BIGNUM_SQR_6_12_ALT_SUBROUTINE_CORRECT = time prove
 (`!z x a pc stackpointer returnaddress.
     ALL (nonoverlapping (z,8 * 12))
         [(word pc,0x224); (x,8 * 6); (stackpointer,8)]
     ==> ensures x86
          (\s. bytes_loaded s (word pc) bignum_sqr_6_12_alt_mc /\
               read RIP s = word pc /\
               read RSP s = stackpointer /\
               read (memory :> bytes64 stackpointer) s = returnaddress /\
               C_ARGUMENTS [z; x] s /\
               bignum_from_memory (x,6) s = a)
          (\s. read RIP s = returnaddress /\
               read RSP s = word_add stackpointer (word 8) /\
               bignum_from_memory (z,12) s = a EXP 2)
          (MAYCHANGE [RIP; RSP; RAX; RCX; RDX; R8; R9; R10; R11] ,,
           MAYCHANGE [memory :> bytes(z,8 * 12)] ,,
           MAYCHANGE SOME_FLAGS)`,
  X86_PROMOTE_RETURN_NOSTACK_TAC
   bignum_sqr_6_12_alt_mc BIGNUM_SQR_6_12_ALT_CORRECT);;

(* ------------------------------------------------------------------------- *)
(* Correctness of Windows ABI version.                                       *)
(* ------------------------------------------------------------------------- *)

let windows_bignum_sqr_6_12_alt_mc = define_from_elf
   "windows_bignum_sqr_6_12_alt_mc" "x86/fastmul/bignum_sqr_6_12_alt.obj";;

let WINDOWS_BIGNUM_SQR_6_12_ALT_SUBROUTINE_CORRECT = time prove
 (`!z x a pc stackpointer returnaddress.
        ALL (nonoverlapping (word_sub stackpointer (word 16),16))
            [(word pc,0x22e); (x,8 * 6)] /\
     ALL (nonoverlapping (z,8 * 12))
         [(word pc,0x22e); (x,8 * 6); (word_sub stackpointer (word 16),24)]
     ==> ensures x86
          (\s. bytes_loaded s (word pc) windows_bignum_sqr_6_12_alt_mc /\
               read RIP s = word pc /\
               read RSP s = stackpointer /\
               read (memory :> bytes64 stackpointer) s = returnaddress /\
               WINDOWS_C_ARGUMENTS [z; x] s /\
               bignum_from_memory (x,6) s = a)
          (\s. read RIP s = returnaddress /\
               read RSP s = word_add stackpointer (word 8) /\
               bignum_from_memory (z,12) s = a EXP 2)
          (MAYCHANGE [RIP; RSP; RAX; RCX; RDX; R8; R9; R10; R11] ,,
           MAYCHANGE [memory :> bytes(z,8 * 12);
                      memory :> bytes(word_sub stackpointer (word 16),16)] ,,
           MAYCHANGE SOME_FLAGS)`,
  WINDOWS_X86_WRAP_NOSTACK_TAC
   windows_bignum_sqr_6_12_alt_mc bignum_sqr_6_12_alt_mc
   BIGNUM_SQR_6_12_ALT_CORRECT);;

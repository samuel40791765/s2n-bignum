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
(* The x25519 function for curve25519.                                       *)
(* ========================================================================= *)

needs "x86/proofs/base.ml";;
needs "x86/proofs/bignum_modinv.ml";;
needs "common/ecencoding.ml";;

needs "EC/x25519.ml";;

prioritize_int();;
prioritize_real();;
prioritize_num();;

(**** print_literal_from_elf "x86/curve25519/curve25519_x25519.o";;
 ****)

let curve25519_x25519_mc = define_assert_from_elf
  "curve25519_x25519_mc" "x86/curve25519/curve25519_x25519.o"
[
  0x53;                    (* PUSH (% rbx) *)
  0x55;                    (* PUSH (% rbp) *)
  0x41; 0x54;              (* PUSH (% r12) *)
  0x41; 0x55;              (* PUSH (% r13) *)
  0x41; 0x56;              (* PUSH (% r14) *)
  0x41; 0x57;              (* PUSH (% r15) *)
  0x48; 0x81; 0xec; 0xa0; 0x01; 0x00; 0x00;
                           (* SUB (% rsp) (Imm32 (word 416)) *)
  0x48; 0x89; 0xbc; 0x24; 0x80; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,384))) (% rdi) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0x83; 0xe0; 0xf8;  (* AND (% rax) (Imm8 (word 248)) *)
  0x48; 0x89; 0x04; 0x24;  (* MOV (Memop Quadword (%% (rsp,0))) (% rax) *)
  0x48; 0x8b; 0x46; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0x89; 0x44; 0x24; 0x08;
                           (* MOV (Memop Quadword (%% (rsp,8))) (% rax) *)
  0x48; 0x8b; 0x46; 0x10;  (* MOV (% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0x89; 0x44; 0x24; 0x10;
                           (* MOV (Memop Quadword (%% (rsp,16))) (% rax) *)
  0x48; 0x8b; 0x46; 0x18;  (* MOV (% rax) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0x0f; 0xba; 0xe8; 0x3e;
                           (* BTS (% rax) (Imm8 (word 62)) *)
  0x48; 0x89; 0x44; 0x24; 0x18;
                           (* MOV (Memop Quadword (%% (rsp,24))) (% rax) *)
  0x4c; 0x8b; 0x02;        (* MOV (% r8) (Memop Quadword (%% (rdx,0))) *)
  0x4c; 0x8b; 0x4a; 0x08;  (* MOV (% r9) (Memop Quadword (%% (rdx,8))) *)
  0x4c; 0x8b; 0x52; 0x10;  (* MOV (% r10) (Memop Quadword (%% (rdx,16))) *)
  0x4c; 0x8b; 0x5a; 0x18;  (* MOV (% r11) (Memop Quadword (%% (rdx,24))) *)
  0x49; 0x0f; 0xba; 0xf3; 0x3f;
                           (* BTR (% r11) (Imm8 (word 63)) *)
  0x49; 0xc7; 0xc4; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% r12) (Imm32 (word 19)) *)
  0x4d; 0x31; 0xed;        (* XOR (% r13) (% r13) *)
  0x4d; 0x31; 0xf6;        (* XOR (% r14) (% r14) *)
  0x4d; 0x31; 0xff;        (* XOR (% r15) (% r15) *)
  0x4d; 0x01; 0xc4;        (* ADD (% r12) (% r8) *)
  0x4d; 0x11; 0xcd;        (* ADC (% r13) (% r9) *)
  0x4d; 0x11; 0xd6;        (* ADC (% r14) (% r10) *)
  0x4d; 0x11; 0xdf;        (* ADC (% r15) (% r11) *)
  0x49; 0x0f; 0xba; 0xf7; 0x3f;
                           (* BTR (% r15) (Imm8 (word 63)) *)
  0x4d; 0x0f; 0x42; 0xc4;  (* CMOVB (% r8) (% r12) *)
  0x4c; 0x89; 0x44; 0x24; 0x20;
                           (* MOV (Memop Quadword (%% (rsp,32))) (% r8) *)
  0x4d; 0x0f; 0x42; 0xcd;  (* CMOVB (% r9) (% r13) *)
  0x4c; 0x89; 0x4c; 0x24; 0x28;
                           (* MOV (Memop Quadword (%% (rsp,40))) (% r9) *)
  0x4d; 0x0f; 0x42; 0xd6;  (* CMOVB (% r10) (% r14) *)
  0x4c; 0x89; 0x54; 0x24; 0x30;
                           (* MOV (Memop Quadword (%% (rsp,48))) (% r10) *)
  0x4d; 0x0f; 0x42; 0xdf;  (* CMOVB (% r11) (% r15) *)
  0x4c; 0x89; 0x5c; 0x24; 0x38;
                           (* MOV (Memop Quadword (%% (rsp,56))) (% r11) *)
  0x48; 0xc7; 0xc0; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Imm32 (word 1)) *)
  0x48; 0x89; 0x84; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,320))) (% rax) *)
  0x48; 0x89; 0x44; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% rax) *)
  0x31; 0xc0;              (* XOR (% eax) (% eax) *)
  0x48; 0x89; 0x84; 0x24; 0x90; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,400))) (% rax) *)
  0x48; 0x89; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% rax) *)
  0x48; 0x89; 0x84; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,328))) (% rax) *)
  0x48; 0x89; 0x44; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% rax) *)
  0x48; 0x89; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% rax) *)
  0x48; 0x89; 0x84; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,336))) (% rax) *)
  0x48; 0x89; 0x44; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% rax) *)
  0x48; 0x89; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% rax) *)
  0x48; 0x89; 0x84; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,344))) (% rax) *)
  0x48; 0x89; 0x44; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% rax) *)
  0x48; 0x89; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x4c; 0x89; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,256))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,264))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,272))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,280))) (% r11) *)
  0xb8; 0xfe; 0x00; 0x00; 0x00;
                           (* MOV (% eax) (Imm32 (word 254)) *)
  0x48; 0x89; 0x84; 0x24; 0x88; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,392))) (% rax) *)
  0x4c; 0x8b; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,256))) *)
  0x4c; 0x2b; 0x44; 0x24; 0x60;
                           (* SUB (% r8) (Memop Quadword (%% (rsp,96))) *)
  0x4c; 0x8b; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,264))) *)
  0x4c; 0x1b; 0x4c; 0x24; 0x68;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,104))) *)
  0x4c; 0x8b; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* MOV (% r10) (Memop Quadword (%% (rsp,272))) *)
  0x4c; 0x1b; 0x54; 0x24; 0x70;
                           (* SBB (% r10) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0x8b; 0x84; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,280))) *)
  0x48; 0x1b; 0x44; 0x24; 0x78;
                           (* SBB (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x49; 0x83; 0xe8; 0x13;  (* SUB (% r8) (Imm8 (word 19)) *)
  0x4c; 0x89; 0x44; 0x24; 0x40;
                           (* MOV (Memop Quadword (%% (rsp,64))) (% r8) *)
  0x49; 0x83; 0xd9; 0x00;  (* SBB (% r9) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x4c; 0x24; 0x48;
                           (* MOV (Memop Quadword (%% (rsp,72))) (% r9) *)
  0x49; 0x83; 0xda; 0x00;  (* SBB (% r10) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x54; 0x24; 0x50;
                           (* MOV (Memop Quadword (%% (rsp,80))) (% r10) *)
  0x48; 0x83; 0xd8; 0x00;  (* SBB (% rax) (Imm8 (word 0)) *)
  0x48; 0x0f; 0xba; 0xf8; 0x3f;
                           (* BTC (% rax) (Imm8 (word 63)) *)
  0x48; 0x89; 0x44; 0x24; 0x58;
                           (* MOV (Memop Quadword (%% (rsp,88))) (% rax) *)
  0x48; 0x8b; 0x84; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,320))) *)
  0x48; 0x03; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* ADD (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0x89; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,128))) (% rax) *)
  0x48; 0x8b; 0x84; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,328))) *)
  0x48; 0x13; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* ADC (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0x89; 0x84; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,136))) (% rax) *)
  0x48; 0x8b; 0x84; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,336))) *)
  0x48; 0x13; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* ADC (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0x89; 0x84; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,144))) (% rax) *)
  0x48; 0x8b; 0x84; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,344))) *)
  0x48; 0x13; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* ADC (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0x89; 0x84; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,152))) (% rax) *)
  0x4c; 0x8b; 0x84; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,320))) *)
  0x4c; 0x2b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* SUB (% r8) (Memop Quadword (%% (rsp,160))) *)
  0x4c; 0x8b; 0x8c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,328))) *)
  0x4c; 0x1b; 0x8c; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,168))) *)
  0x4c; 0x8b; 0x94; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (% r10) (Memop Quadword (%% (rsp,336))) *)
  0x4c; 0x1b; 0x94; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* SBB (% r10) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0x8b; 0x84; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,344))) *)
  0x48; 0x1b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* SBB (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x49; 0x83; 0xe8; 0x13;  (* SUB (% r8) (Imm8 (word 19)) *)
  0x4c; 0x89; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% r8) *)
  0x49; 0x83; 0xd9; 0x00;  (* SBB (% r9) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x8c; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% r9) *)
  0x49; 0x83; 0xda; 0x00;  (* SBB (% r10) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x94; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% r10) *)
  0x48; 0x83; 0xd8; 0x00;  (* SBB (% rax) (Imm8 (word 0)) *)
  0x48; 0x0f; 0xba; 0xf8; 0x3f;
                           (* BTC (% rax) (Imm8 (word 63)) *)
  0x48; 0x89; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% rax) *)
  0x48; 0x8b; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,256))) *)
  0x48; 0x03; 0x44; 0x24; 0x60;
                           (* ADD (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0x89; 0x44; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% rax) *)
  0x48; 0x8b; 0x84; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,264))) *)
  0x48; 0x13; 0x44; 0x24; 0x68;
                           (* ADC (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0x89; 0x44; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% rax) *)
  0x48; 0x8b; 0x84; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,272))) *)
  0x48; 0x13; 0x44; 0x24; 0x70;
                           (* ADC (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0x89; 0x44; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% rax) *)
  0x48; 0x8b; 0x84; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,280))) *)
  0x48; 0x13; 0x44; 0x24; 0x78;
                           (* ADC (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0x89; 0x44; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% rax) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x40;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,64))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0x8c; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MULX4 (% r9,% r8) (% rdx,Memop Quadword (%% (rsp,128))) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x94; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MULX4 (% r10,% rax) (% rdx,Memop Quadword (%% (rsp,136))) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x9c; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MULX4 (% r11,% rax) (% rdx,Memop Quadword (%% (rsp,144))) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xa4; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MULX4 (% r12,% rax) (% rdx,Memop Quadword (%% (rsp,152))) *)
  0x49; 0x11; 0xc3;        (* ADC (% r11) (% rax) *)
  0x49; 0x11; 0xfc;        (* ADC (% r12) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x48;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,72))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,128))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,136))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,144))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xac; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MULX4 (% r13,% rax) (% rdx,Memop Quadword (%% (rsp,152))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADOX (% r13) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADCX (% r13) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x50;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,80))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,128))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,136))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,144))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xb4; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MULX4 (% r14,% rax) (% rdx,Memop Quadword (%% (rsp,152))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADOX (% r14) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADCX (% r14) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x58;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,88))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,128))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,136))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,144))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf3;
                           (* ADOX (% r14) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xbc; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MULX4 (% r15,% rax) (% rdx,Memop Quadword (%% (rsp,152))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf0;
                           (* ADCX (% r14) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADOX (% r15) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADCX (% r15) (% rdi) *)
  0xba; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 38)) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdc;
                           (* MULX4 (% rbx,% rax) (% rdx,% r12) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xcb;
                           (* ADOX (% r9) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdd;
                           (* MULX4 (% rbx,% rax) (% rdx,% r13) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xde;
                           (* MULX4 (% rbx,% rax) (% rdx,% r14) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0x42; 0xfb; 0xf6; 0xe7;
                           (* MULX4 (% r12,% rax) (% rdx,% r15) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADOX (% r12) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADCX (% r12) (% rdi) *)
  0x4c; 0x89; 0x84; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,192))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,200))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,208))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,216))) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0xe0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,224))) (% r12) *)
  0x48; 0x8b; 0x94; 0x24; 0x88; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,392))) *)
  0x48; 0x89; 0xd1;        (* MOV (% rcx) (% rdx) *)
  0x48; 0xc1; 0xea; 0x06;  (* SHR (% rdx) (Imm8 (word 6)) *)
  0x48; 0x8b; 0x14; 0xd4;  (* MOV (% rdx) (Memop Quadword (%%% (rsp,3,rdx))) *)
  0x48; 0xd3; 0xea;        (* SHR (% rdx) (% cl) *)
  0x48; 0x83; 0xe2; 0x01;  (* AND (% rdx) (Imm8 (word 1)) *)
  0x48; 0x3b; 0x94; 0x24; 0x90; 0x01; 0x00; 0x00;
                           (* CMP (% rdx) (Memop Quadword (%% (rsp,400))) *)
  0x48; 0x89; 0x94; 0x24; 0x90; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,400))) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0x8b; 0x8c; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0x0f; 0x44; 0xc1;  (* CMOVE (% rax) (% rcx) *)
  0x48; 0x89; 0x84; 0x24; 0x60; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,352))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x48;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0x8b; 0x8c; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0x0f; 0x44; 0xc1;  (* CMOVE (% rax) (% rcx) *)
  0x48; 0x89; 0x84; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,360))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,80))) *)
  0x48; 0x8b; 0x8c; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0x0f; 0x44; 0xc1;  (* CMOVE (% rax) (% rcx) *)
  0x48; 0x89; 0x84; 0x24; 0x70; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,368))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x58;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,88))) *)
  0x48; 0x8b; 0x8c; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0x0f; 0x44; 0xc1;  (* CMOVE (% rax) (% rcx) *)
  0x48; 0x89; 0x84; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,376))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0x8b; 0x8c; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,128))) *)
  0x48; 0x0f; 0x44; 0xc1;  (* CMOVE (% rax) (% rcx) *)
  0x48; 0x89; 0x84; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,320))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0x8b; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,136))) *)
  0x48; 0x0f; 0x44; 0xc1;  (* CMOVE (% rax) (% rcx) *)
  0x48; 0x89; 0x84; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,328))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0x8b; 0x8c; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,144))) *)
  0x48; 0x0f; 0x44; 0xc1;  (* CMOVE (% rax) (% rcx) *)
  0x48; 0x89; 0x84; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,336))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0x8b; 0x8c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,152))) *)
  0x48; 0x0f; 0x44; 0xc1;  (* CMOVE (% rax) (% rcx) *)
  0x48; 0x89; 0x84; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,344))) (% rax) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,160))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0x4c; 0x24; 0x60;
                           (* MULX4 (% r9,% r8) (% rdx,Memop Quadword (%% (rsp,96))) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x54; 0x24; 0x68;
                           (* MULX4 (% r10,% rax) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x5c; 0x24; 0x70;
                           (* MULX4 (% r11,% rax) (% rdx,Memop Quadword (%% (rsp,112))) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x64; 0x24; 0x78;
                           (* MULX4 (% r12,% rax) (% rdx,Memop Quadword (%% (rsp,120))) *)
  0x49; 0x11; 0xc3;        (* ADC (% r11) (% rax) *)
  0x49; 0x11; 0xfc;        (* ADC (% r12) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,168))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x60;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,96))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x68;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x70;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,112))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x6c; 0x24; 0x78;
                           (* MULX4 (% r13,% rax) (% rdx,Memop Quadword (%% (rsp,120))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADOX (% r13) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADCX (% r13) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,176))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x60;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,96))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x68;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x70;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,112))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x74; 0x24; 0x78;
                           (* MULX4 (% r14,% rax) (% rdx,Memop Quadword (%% (rsp,120))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADOX (% r14) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADCX (% r14) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,184))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x60;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,96))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x68;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x70;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,112))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf3;
                           (* ADOX (% r14) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x7c; 0x24; 0x78;
                           (* MULX4 (% r15,% rax) (% rdx,Memop Quadword (%% (rsp,120))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf0;
                           (* ADCX (% r14) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADOX (% r15) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADCX (% r15) (% rdi) *)
  0xba; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 38)) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdc;
                           (* MULX4 (% rbx,% rax) (% rdx,% r12) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xcb;
                           (* ADOX (% r9) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdd;
                           (* MULX4 (% rbx,% rax) (% rdx,% r13) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xde;
                           (* MULX4 (% rbx,% rax) (% rdx,% r14) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0x42; 0xfb; 0xf6; 0xe7;
                           (* MULX4 (% r12,% rax) (% rdx,% r15) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADOX (% r12) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADCX (% r12) (% rdi) *)
  0x4c; 0x89; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,256))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,264))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,272))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,280))) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0x20; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,288))) (% r12) *)
  0x48; 0x8b; 0x94; 0x24; 0x60; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,352))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0xfa;
                           (* MULX4 (% r15,% r8) (% rdx,% rdx) *)
  0xc4; 0x62; 0xb3; 0xf6; 0x94; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* MULX4 (% r10,% r9) (% rdx,Memop Quadword (%% (rsp,360))) *)
  0xc4; 0x62; 0xa3; 0xf6; 0xa4; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* MULX4 (% r12,% r11) (% rdx,Memop Quadword (%% (rsp,376))) *)
  0x48; 0x8b; 0x94; 0x24; 0x70; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,368))) *)
  0xc4; 0x62; 0x93; 0xf6; 0xb4; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* MULX4 (% r14,% r13) (% rdx,Memop Quadword (%% (rsp,376))) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x8c; 0x24; 0x60; 0x01; 0x00; 0x00;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,352))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd9;
                           (* ADOX (% r11) (% rcx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x8c; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,360))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe1;
                           (* ADOX (% r12) (% rcx) *)
  0x48; 0x8b; 0x94; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,376))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x8c; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,360))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe9;
                           (* ADOX (% r13) (% rcx) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADCX (% r13) (% rbx) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf3;
                           (* ADOX (% r14) (% rbx) *)
  0x49; 0x11; 0xde;        (* ADC (% r14) (% rbx) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xc9;
                           (* ADCX (% r9) (% r9) *)
  0xf3; 0x4d; 0x0f; 0x38; 0xf6; 0xcf;
                           (* ADOX (% r9) (% r15) *)
  0x48; 0x8b; 0x94; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,360))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xd2;
                           (* ADCX (% r10) (% r10) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADOX (% r10) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADCX (% r11) (% r11) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xda;
                           (* ADOX (% r11) (% rdx) *)
  0x48; 0x8b; 0x94; 0x24; 0x70; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,368))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xe4;
                           (* ADCX (% r12) (% r12) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADOX (% r12) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xed;
                           (* ADCX (% r13) (% r13) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xea;
                           (* ADOX (% r13) (% rdx) *)
  0x48; 0x8b; 0x94; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,376))) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xfa;
                           (* MULX4 (% r15,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xf6;
                           (* ADCX (% r14) (% r14) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf0;
                           (* ADOX (% r14) (% rax) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xfb;
                           (* ADCX (% r15) (% rbx) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xfb;
                           (* ADOX (% r15) (% rbx) *)
  0xba; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 38)) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xcc;
                           (* MULX4 (% rcx,% rax) (% rdx,% r12) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xc9;
                           (* ADOX (% r9) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xcd;
                           (* MULX4 (% rcx,% rax) (% rdx,% r13) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd1;
                           (* ADOX (% r10) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xce;
                           (* MULX4 (% rcx,% rax) (% rdx,% r14) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd9;
                           (* ADOX (% r11) (% rcx) *)
  0xc4; 0x42; 0xfb; 0xf6; 0xe7;
                           (* MULX4 (% r12,% rax) (% rdx,% r15) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADCX (% r12) (% rbx) *)
  0x4d; 0x0f; 0xa4; 0xdc; 0x01;
                           (* SHLD (% r12) (% r11) (Imm8 (word 1)) *)
  0x49; 0x0f; 0xba; 0xf3; 0x3f;
                           (* BTR (% r11) (Imm8 (word 63)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x49; 0x0f; 0xaf; 0xd4;  (* IMUL (% rdx) (% r12) *)
  0x49; 0x01; 0xd0;        (* ADD (% r8) (% rdx) *)
  0x49; 0x11; 0xd9;        (* ADC (% r9) (% rbx) *)
  0x49; 0x11; 0xda;        (* ADC (% r10) (% rbx) *)
  0x49; 0x11; 0xdb;        (* ADC (% r11) (% rbx) *)
  0x4c; 0x89; 0x84; 0x24; 0x60; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,352))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,360))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0x70; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,368))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,376))) (% r11) *)
  0x4c; 0x8b; 0x84; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,192))) *)
  0x4c; 0x2b; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* SUB (% r8) (Memop Quadword (%% (rsp,256))) *)
  0x4c; 0x8b; 0x8c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,200))) *)
  0x4c; 0x1b; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,264))) *)
  0x4c; 0x8b; 0x94; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MOV (% r10) (Memop Quadword (%% (rsp,208))) *)
  0x4c; 0x1b; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* SBB (% r10) (Memop Quadword (%% (rsp,272))) *)
  0x4c; 0x8b; 0x9c; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MOV (% r11) (Memop Quadword (%% (rsp,216))) *)
  0x4c; 0x1b; 0x9c; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* SBB (% r11) (Memop Quadword (%% (rsp,280))) *)
  0x4c; 0x8b; 0xa4; 0x24; 0xe0; 0x00; 0x00; 0x00;
                           (* MOV (% r12) (Memop Quadword (%% (rsp,224))) *)
  0x4c; 0x1b; 0xa4; 0x24; 0x20; 0x01; 0x00; 0x00;
                           (* SBB (% r12) (Memop Quadword (%% (rsp,288))) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0x49; 0x81; 0xe8; 0x38; 0x4a; 0x00; 0x00;
                           (* SUB (% r8) (Imm32 (word 19000)) *)
  0x49; 0x19; 0xd9;        (* SBB (% r9) (% rbx) *)
  0x49; 0x19; 0xda;        (* SBB (% r10) (% rbx) *)
  0x49; 0x19; 0xdb;        (* SBB (% r11) (% rbx) *)
  0x49; 0x19; 0xdc;        (* SBB (% r12) (% rbx) *)
  0x49; 0x81; 0xc4; 0xf4; 0x01; 0x00; 0x00;
                           (* ADD (% r12) (Imm32 (word 500)) *)
  0x4d; 0x0f; 0xa4; 0xdc; 0x01;
                           (* SHLD (% r12) (% r11) (Imm8 (word 1)) *)
  0x49; 0x0f; 0xba; 0xf3; 0x3f;
                           (* BTR (% r11) (Imm8 (word 63)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x49; 0x0f; 0xaf; 0xd4;  (* IMUL (% rdx) (% r12) *)
  0x49; 0x01; 0xd0;        (* ADD (% r8) (% rdx) *)
  0x49; 0x11; 0xd9;        (* ADC (% r9) (% rbx) *)
  0x49; 0x11; 0xda;        (* ADC (% r10) (% rbx) *)
  0x49; 0x11; 0xdb;        (* ADC (% r11) (% rbx) *)
  0x4c; 0x89; 0x44; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% r8) *)
  0x4c; 0x89; 0x4c; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% r9) *)
  0x4c; 0x89; 0x54; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% r10) *)
  0x4c; 0x89; 0x5c; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% r11) *)
  0x48; 0x8b; 0x94; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,320))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0xfa;
                           (* MULX4 (% r15,% r8) (% rdx,% rdx) *)
  0xc4; 0x62; 0xb3; 0xf6; 0x94; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% r10,% r9) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0xc4; 0x62; 0xa3; 0xf6; 0xa4; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MULX4 (% r12,% r11) (% rdx,Memop Quadword (%% (rsp,344))) *)
  0x48; 0x8b; 0x94; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,336))) *)
  0xc4; 0x62; 0x93; 0xf6; 0xb4; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MULX4 (% r14,% r13) (% rdx,Memop Quadword (%% (rsp,344))) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x8c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,320))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd9;
                           (* ADOX (% r11) (% rcx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x8c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe1;
                           (* ADOX (% r12) (% rcx) *)
  0x48; 0x8b; 0x94; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,344))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x8c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe9;
                           (* ADOX (% r13) (% rcx) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADCX (% r13) (% rbx) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf3;
                           (* ADOX (% r14) (% rbx) *)
  0x49; 0x11; 0xde;        (* ADC (% r14) (% rbx) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xc9;
                           (* ADCX (% r9) (% r9) *)
  0xf3; 0x4d; 0x0f; 0x38; 0xf6; 0xcf;
                           (* ADOX (% r9) (% r15) *)
  0x48; 0x8b; 0x94; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,328))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xd2;
                           (* ADCX (% r10) (% r10) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADOX (% r10) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADCX (% r11) (% r11) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xda;
                           (* ADOX (% r11) (% rdx) *)
  0x48; 0x8b; 0x94; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,336))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xe4;
                           (* ADCX (% r12) (% r12) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADOX (% r12) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xed;
                           (* ADCX (% r13) (% r13) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xea;
                           (* ADOX (% r13) (% rdx) *)
  0x48; 0x8b; 0x94; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,344))) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xfa;
                           (* MULX4 (% r15,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xf6;
                           (* ADCX (% r14) (% r14) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf0;
                           (* ADOX (% r14) (% rax) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xfb;
                           (* ADCX (% r15) (% rbx) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xfb;
                           (* ADOX (% r15) (% rbx) *)
  0xba; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 38)) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xcc;
                           (* MULX4 (% rcx,% rax) (% rdx,% r12) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xc9;
                           (* ADOX (% r9) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xcd;
                           (* MULX4 (% rcx,% rax) (% rdx,% r13) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd1;
                           (* ADOX (% r10) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xce;
                           (* MULX4 (% rcx,% rax) (% rdx,% r14) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd9;
                           (* ADOX (% r11) (% rcx) *)
  0xc4; 0x42; 0xfb; 0xf6; 0xe7;
                           (* MULX4 (% r12,% rax) (% rdx,% r15) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADCX (% r12) (% rbx) *)
  0x4d; 0x0f; 0xa4; 0xdc; 0x01;
                           (* SHLD (% r12) (% r11) (Imm8 (word 1)) *)
  0x49; 0x0f; 0xba; 0xf3; 0x3f;
                           (* BTR (% r11) (Imm8 (word 63)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x49; 0x0f; 0xaf; 0xd4;  (* IMUL (% rdx) (% r12) *)
  0x49; 0x01; 0xd0;        (* ADD (% r8) (% rdx) *)
  0x49; 0x11; 0xd9;        (* ADC (% r9) (% rbx) *)
  0x49; 0x11; 0xda;        (* ADC (% r10) (% rbx) *)
  0x49; 0x11; 0xdb;        (* ADC (% r11) (% rbx) *)
  0x4c; 0x89; 0x84; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,320))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,328))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,336))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,344))) (% r11) *)
  0x4c; 0x8b; 0x84; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,192))) *)
  0x4c; 0x03; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* ADD (% r8) (Memop Quadword (%% (rsp,256))) *)
  0x4c; 0x8b; 0x8c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,200))) *)
  0x4c; 0x13; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* ADC (% r9) (Memop Quadword (%% (rsp,264))) *)
  0x4c; 0x8b; 0x94; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MOV (% r10) (Memop Quadword (%% (rsp,208))) *)
  0x4c; 0x13; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* ADC (% r10) (Memop Quadword (%% (rsp,272))) *)
  0x4c; 0x8b; 0x9c; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MOV (% r11) (Memop Quadword (%% (rsp,216))) *)
  0x4c; 0x13; 0x9c; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* ADC (% r11) (Memop Quadword (%% (rsp,280))) *)
  0x4c; 0x8b; 0xa4; 0x24; 0xe0; 0x00; 0x00; 0x00;
                           (* MOV (% r12) (Memop Quadword (%% (rsp,224))) *)
  0x4c; 0x13; 0xa4; 0x24; 0x20; 0x01; 0x00; 0x00;
                           (* ADC (% r12) (Memop Quadword (%% (rsp,288))) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0x4d; 0x0f; 0xa4; 0xdc; 0x01;
                           (* SHLD (% r12) (% r11) (Imm8 (word 1)) *)
  0x49; 0x0f; 0xba; 0xf3; 0x3f;
                           (* BTR (% r11) (Imm8 (word 63)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x49; 0x0f; 0xaf; 0xd4;  (* IMUL (% rdx) (% r12) *)
  0x49; 0x01; 0xd0;        (* ADD (% r8) (% rdx) *)
  0x49; 0x11; 0xd9;        (* ADC (% r9) (% rbx) *)
  0x49; 0x11; 0xda;        (* ADC (% r10) (% rbx) *)
  0x49; 0x11; 0xdb;        (* ADC (% r11) (% rbx) *)
  0x4c; 0x89; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,256))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,264))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,272))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,280))) (% r11) *)
  0x48; 0x8b; 0x54; 0x24; 0x60;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,96))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0xfa;
                           (* MULX4 (% r15,% r8) (% rdx,% rdx) *)
  0xc4; 0x62; 0xb3; 0xf6; 0x54; 0x24; 0x68;
                           (* MULX4 (% r10,% r9) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0xc4; 0x62; 0xa3; 0xf6; 0x64; 0x24; 0x78;
                           (* MULX4 (% r12,% r11) (% rdx,Memop Quadword (%% (rsp,120))) *)
  0x48; 0x8b; 0x54; 0x24; 0x70;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,112))) *)
  0xc4; 0x62; 0x93; 0xf6; 0x74; 0x24; 0x78;
                           (* MULX4 (% r14,% r13) (% rdx,Memop Quadword (%% (rsp,120))) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x4c; 0x24; 0x60;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,96))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd9;
                           (* ADOX (% r11) (% rcx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x4c; 0x24; 0x68;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe1;
                           (* ADOX (% r12) (% rcx) *)
  0x48; 0x8b; 0x54; 0x24; 0x78;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,120))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x4c; 0x24; 0x68;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe9;
                           (* ADOX (% r13) (% rcx) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADCX (% r13) (% rbx) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf3;
                           (* ADOX (% r14) (% rbx) *)
  0x49; 0x11; 0xde;        (* ADC (% r14) (% rbx) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xc9;
                           (* ADCX (% r9) (% r9) *)
  0xf3; 0x4d; 0x0f; 0x38; 0xf6; 0xcf;
                           (* ADOX (% r9) (% r15) *)
  0x48; 0x8b; 0x54; 0x24; 0x68;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,104))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xd2;
                           (* ADCX (% r10) (% r10) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADOX (% r10) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADCX (% r11) (% r11) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xda;
                           (* ADOX (% r11) (% rdx) *)
  0x48; 0x8b; 0x54; 0x24; 0x70;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,112))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xe4;
                           (* ADCX (% r12) (% r12) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADOX (% r12) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xed;
                           (* ADCX (% r13) (% r13) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xea;
                           (* ADOX (% r13) (% rdx) *)
  0x48; 0x8b; 0x54; 0x24; 0x78;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,120))) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xfa;
                           (* MULX4 (% r15,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xf6;
                           (* ADCX (% r14) (% r14) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf0;
                           (* ADOX (% r14) (% rax) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xfb;
                           (* ADCX (% r15) (% rbx) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xfb;
                           (* ADOX (% r15) (% rbx) *)
  0xba; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 38)) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xcc;
                           (* MULX4 (% rcx,% rax) (% rdx,% r12) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xc9;
                           (* ADOX (% r9) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xcd;
                           (* MULX4 (% rcx,% rax) (% rdx,% r13) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd1;
                           (* ADOX (% r10) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xce;
                           (* MULX4 (% rcx,% rax) (% rdx,% r14) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd9;
                           (* ADOX (% r11) (% rcx) *)
  0xc4; 0x42; 0xfb; 0xf6; 0xe7;
                           (* MULX4 (% r12,% rax) (% rdx,% r15) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADCX (% r12) (% rbx) *)
  0x4d; 0x0f; 0xa4; 0xdc; 0x01;
                           (* SHLD (% r12) (% r11) (Imm8 (word 1)) *)
  0x49; 0x0f; 0xba; 0xf3; 0x3f;
                           (* BTR (% r11) (Imm8 (word 63)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x49; 0x0f; 0xaf; 0xd4;  (* IMUL (% rdx) (% r12) *)
  0x49; 0x01; 0xd0;        (* ADD (% r8) (% rdx) *)
  0x49; 0x11; 0xd9;        (* ADC (% r9) (% rbx) *)
  0x49; 0x11; 0xda;        (* ADC (% r10) (% rbx) *)
  0x49; 0x11; 0xdb;        (* ADC (% r11) (% rbx) *)
  0x4c; 0x89; 0x44; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% r8) *)
  0x4c; 0x89; 0x4c; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% r9) *)
  0x4c; 0x89; 0x54; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% r10) *)
  0x4c; 0x89; 0x5c; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% r11) *)
  0x4c; 0x8b; 0x84; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,320))) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0x4c; 0x2b; 0x84; 0x24; 0x60; 0x01; 0x00; 0x00;
                           (* SUB (% r8) (Memop Quadword (%% (rsp,352))) *)
  0x4c; 0x8b; 0x8c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,328))) *)
  0x4c; 0x1b; 0x8c; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,360))) *)
  0xb9; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 38)) *)
  0x4c; 0x8b; 0x94; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (% r10) (Memop Quadword (%% (rsp,336))) *)
  0x4c; 0x1b; 0x94; 0x24; 0x70; 0x01; 0x00; 0x00;
                           (* SBB (% r10) (Memop Quadword (%% (rsp,368))) *)
  0x48; 0x8b; 0x84; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,344))) *)
  0x48; 0x1b; 0x84; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* SBB (% rax) (Memop Quadword (%% (rsp,376))) *)
  0x48; 0x0f; 0x43; 0xcb;  (* CMOVAE (% rcx) (% rbx) *)
  0x49; 0x29; 0xc8;        (* SUB (% r8) (% rcx) *)
  0x49; 0x19; 0xd9;        (* SBB (% r9) (% rbx) *)
  0x49; 0x19; 0xda;        (* SBB (% r10) (% rbx) *)
  0x48; 0x19; 0xd8;        (* SBB (% rax) (% rbx) *)
  0x4c; 0x89; 0x84; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,192))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,200))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,208))) (% r10) *)
  0x48; 0x89; 0x84; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,216))) (% rax) *)
  0x48; 0x8b; 0x94; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,256))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0xfa;
                           (* MULX4 (% r15,% r8) (% rdx,% rdx) *)
  0xc4; 0x62; 0xb3; 0xf6; 0x94; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MULX4 (% r10,% r9) (% rdx,Memop Quadword (%% (rsp,264))) *)
  0xc4; 0x62; 0xa3; 0xf6; 0xa4; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MULX4 (% r12,% r11) (% rdx,Memop Quadword (%% (rsp,280))) *)
  0x48; 0x8b; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,272))) *)
  0xc4; 0x62; 0x93; 0xf6; 0xb4; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MULX4 (% r14,% r13) (% rdx,Memop Quadword (%% (rsp,280))) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x8c; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,256))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd9;
                           (* ADOX (% r11) (% rcx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,264))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe1;
                           (* ADOX (% r12) (% rcx) *)
  0x48; 0x8b; 0x94; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,280))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MULX4 (% rcx,% rax) (% rdx,Memop Quadword (%% (rsp,264))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe9;
                           (* ADOX (% r13) (% rcx) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADCX (% r13) (% rbx) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf3;
                           (* ADOX (% r14) (% rbx) *)
  0x49; 0x11; 0xde;        (* ADC (% r14) (% rbx) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xc9;
                           (* ADCX (% r9) (% r9) *)
  0xf3; 0x4d; 0x0f; 0x38; 0xf6; 0xcf;
                           (* ADOX (% r9) (% r15) *)
  0x48; 0x8b; 0x94; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,264))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xd2;
                           (* ADCX (% r10) (% r10) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADOX (% r10) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADCX (% r11) (% r11) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xda;
                           (* ADOX (% r11) (% rdx) *)
  0x48; 0x8b; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,272))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0xd2;
                           (* MULX4 (% rdx,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xe4;
                           (* ADCX (% r12) (% r12) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADOX (% r12) (% rax) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xed;
                           (* ADCX (% r13) (% r13) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xea;
                           (* ADOX (% r13) (% rdx) *)
  0x48; 0x8b; 0x94; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,280))) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xfa;
                           (* MULX4 (% r15,% rax) (% rdx,% rdx) *)
  0x66; 0x4d; 0x0f; 0x38; 0xf6; 0xf6;
                           (* ADCX (% r14) (% r14) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf0;
                           (* ADOX (% r14) (% rax) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xfb;
                           (* ADCX (% r15) (% rbx) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xfb;
                           (* ADOX (% r15) (% rbx) *)
  0xba; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 38)) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xcc;
                           (* MULX4 (% rcx,% rax) (% rdx,% r12) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xc9;
                           (* ADOX (% r9) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xcd;
                           (* MULX4 (% rcx,% rax) (% rdx,% r13) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd1;
                           (* ADOX (% r10) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xce;
                           (* MULX4 (% rcx,% rax) (% rdx,% r14) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd9;
                           (* ADOX (% r11) (% rcx) *)
  0xc4; 0x42; 0xfb; 0xf6; 0xe7;
                           (* MULX4 (% r12,% rax) (% rdx,% r15) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADCX (% r12) (% rbx) *)
  0x4d; 0x0f; 0xa4; 0xdc; 0x01;
                           (* SHLD (% r12) (% r11) (Imm8 (word 1)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x49; 0x8d; 0x44; 0x24; 0x01;
                           (* LEA (% rax) (%% (r12,1)) *)
  0x49; 0x0f; 0xba; 0xeb; 0x3f;
                           (* BTS (% r11) (Imm8 (word 63)) *)
  0x48; 0x0f; 0xaf; 0xc2;  (* IMUL (% rax) (% rdx) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xd9;        (* ADC (% r9) (% rbx) *)
  0x49; 0x11; 0xda;        (* ADC (% r10) (% rbx) *)
  0x49; 0x11; 0xdb;        (* ADC (% r11) (% rbx) *)
  0x48; 0x0f; 0x42; 0xd3;  (* CMOVB (% rdx) (% rbx) *)
  0x49; 0x29; 0xd0;        (* SUB (% r8) (% rdx) *)
  0x49; 0x19; 0xd9;        (* SBB (% r9) (% rbx) *)
  0x49; 0x19; 0xda;        (* SBB (% r10) (% rbx) *)
  0x49; 0x19; 0xdb;        (* SBB (% r11) (% rbx) *)
  0x49; 0x0f; 0xba; 0xf3; 0x3f;
                           (* BTR (% r11) (Imm8 (word 63)) *)
  0x4c; 0x89; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,256))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,264))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,272))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,280))) (% r11) *)
  0x4c; 0x8b; 0x84; 0x24; 0x60; 0x01; 0x00; 0x00;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,352))) *)
  0x4c; 0x8b; 0x8c; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,360))) *)
  0x4c; 0x8b; 0x94; 0x24; 0x70; 0x01; 0x00; 0x00;
                           (* MOV (% r10) (Memop Quadword (%% (rsp,368))) *)
  0x4c; 0x8b; 0x9c; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* MOV (% r11) (Memop Quadword (%% (rsp,376))) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0xc7; 0xc2; 0x42; 0xdb; 0x01; 0x00;
                           (* MOV (% rdx) (Imm32 (word 121666)) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,192))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xcb;
                           (* ADOX (% r9) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,200))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,208))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,216))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x48; 0x0f; 0x38; 0xf6; 0xdf;
                           (* ADOX (% rbx) (% rdi) *)
  0x66; 0x48; 0x0f; 0x38; 0xf6; 0xdf;
                           (* ADCX (% rbx) (% rdi) *)
  0x4c; 0x0f; 0xa4; 0xdb; 0x01;
                           (* SHLD (% rbx) (% r11) (Imm8 (word 1)) *)
  0x49; 0x0f; 0xba; 0xf3; 0x3f;
                           (* BTR (% r11) (Imm8 (word 63)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x48; 0x0f; 0xaf; 0xda;  (* IMUL (% rbx) (% rdx) *)
  0x49; 0x01; 0xd8;        (* ADD (% r8) (% rbx) *)
  0x49; 0x11; 0xf9;        (* ADC (% r9) (% rdi) *)
  0x49; 0x11; 0xfa;        (* ADC (% r10) (% rdi) *)
  0x49; 0x11; 0xfb;        (* ADC (% r11) (% rdi) *)
  0x4c; 0x89; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% r11) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0x60; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,352))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0x8c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MULX4 (% r9,% r8) (% rdx,Memop Quadword (%% (rsp,320))) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x94; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% r10,% rax) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x9c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MULX4 (% r11,% rax) (% rdx,Memop Quadword (%% (rsp,336))) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xa4; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MULX4 (% r12,% rax) (% rdx,Memop Quadword (%% (rsp,344))) *)
  0x49; 0x11; 0xc3;        (* ADC (% r11) (% rax) *)
  0x49; 0x11; 0xfc;        (* ADC (% r12) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,360))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,320))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,336))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xac; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MULX4 (% r13,% rax) (% rdx,Memop Quadword (%% (rsp,344))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADOX (% r13) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADCX (% r13) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0x70; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,368))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,320))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,336))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xb4; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MULX4 (% r14,% rax) (% rdx,Memop Quadword (%% (rsp,344))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADOX (% r14) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADCX (% r14) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,376))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,320))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,336))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf3;
                           (* ADOX (% r14) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xbc; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MULX4 (% r15,% rax) (% rdx,Memop Quadword (%% (rsp,344))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf0;
                           (* ADCX (% r14) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADOX (% r15) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADCX (% r15) (% rdi) *)
  0xba; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 38)) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdc;
                           (* MULX4 (% rbx,% rax) (% rdx,% r12) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xcb;
                           (* ADOX (% r9) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdd;
                           (* MULX4 (% rbx,% rax) (% rdx,% r13) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xde;
                           (* MULX4 (% rbx,% rax) (% rdx,% r14) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0x42; 0xfb; 0xf6; 0xe7;
                           (* MULX4 (% r12,% rax) (% rdx,% r15) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADOX (% r12) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADCX (% r12) (% rdi) *)
  0x4d; 0x0f; 0xa4; 0xdc; 0x01;
                           (* SHLD (% r12) (% r11) (Imm8 (word 1)) *)
  0x48; 0xb9; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x80;
                           (* MOV (% rcx) (Imm64 (word 9223372036854775808)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x49; 0xff; 0xc4;        (* INC (% r12) *)
  0x49; 0x09; 0xcb;        (* OR (% r11) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdc;
                           (* MULX4 (% rbx,% rax) (% rdx,% r12) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xd9;        (* ADC (% r9) (% rbx) *)
  0x49; 0x11; 0xfa;        (* ADC (% r10) (% rdi) *)
  0x49; 0x11; 0xfb;        (* ADC (% r11) (% rdi) *)
  0x48; 0x19; 0xc0;        (* SBB (% rax) (% rax) *)
  0x48; 0xf7; 0xd0;        (* NOT (% rax) *)
  0x48; 0x21; 0xd0;        (* AND (% rax) (% rdx) *)
  0x49; 0x29; 0xc0;        (* SUB (% r8) (% rax) *)
  0x49; 0x19; 0xf9;        (* SBB (% r9) (% rdi) *)
  0x49; 0x19; 0xfa;        (* SBB (% r10) (% rdi) *)
  0x49; 0x19; 0xfb;        (* SBB (% r11) (% rdi) *)
  0x48; 0xf7; 0xd1;        (* NOT (% rcx) *)
  0x49; 0x21; 0xcb;        (* AND (% r11) (% rcx) *)
  0x4c; 0x89; 0x84; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,320))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,328))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,336))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,344))) (% r11) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x20;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,32))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0x4c; 0x24; 0x60;
                           (* MULX4 (% r9,% r8) (% rdx,Memop Quadword (%% (rsp,96))) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x54; 0x24; 0x68;
                           (* MULX4 (% r10,% rax) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x5c; 0x24; 0x70;
                           (* MULX4 (% r11,% rax) (% rdx,Memop Quadword (%% (rsp,112))) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x64; 0x24; 0x78;
                           (* MULX4 (% r12,% rax) (% rdx,Memop Quadword (%% (rsp,120))) *)
  0x49; 0x11; 0xc3;        (* ADC (% r11) (% rax) *)
  0x49; 0x11; 0xfc;        (* ADC (% r12) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x28;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,40))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x60;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,96))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x68;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x70;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,112))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x6c; 0x24; 0x78;
                           (* MULX4 (% r13,% rax) (% rdx,Memop Quadword (%% (rsp,120))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADOX (% r13) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADCX (% r13) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x30;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,48))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x60;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,96))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x68;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x70;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,112))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x74; 0x24; 0x78;
                           (* MULX4 (% r14,% rax) (% rdx,Memop Quadword (%% (rsp,120))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADOX (% r14) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADCX (% r14) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x38;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,56))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x60;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,96))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x68;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,104))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x5c; 0x24; 0x70;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,112))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf3;
                           (* ADOX (% r14) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x7c; 0x24; 0x78;
                           (* MULX4 (% r15,% rax) (% rdx,Memop Quadword (%% (rsp,120))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf0;
                           (* ADCX (% r14) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADOX (% r15) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADCX (% r15) (% rdi) *)
  0xba; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 38)) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdc;
                           (* MULX4 (% rbx,% rax) (% rdx,% r12) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xcb;
                           (* ADOX (% r9) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdd;
                           (* MULX4 (% rbx,% rax) (% rdx,% r13) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xde;
                           (* MULX4 (% rbx,% rax) (% rdx,% r14) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0x42; 0xfb; 0xf6; 0xe7;
                           (* MULX4 (% r12,% rax) (% rdx,% r15) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADOX (% r12) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADCX (% r12) (% rdi) *)
  0x4d; 0x0f; 0xa4; 0xdc; 0x01;
                           (* SHLD (% r12) (% r11) (Imm8 (word 1)) *)
  0x48; 0xb9; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x80;
                           (* MOV (% rcx) (Imm64 (word 9223372036854775808)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x49; 0xff; 0xc4;        (* INC (% r12) *)
  0x49; 0x09; 0xcb;        (* OR (% r11) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdc;
                           (* MULX4 (% rbx,% rax) (% rdx,% r12) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xd9;        (* ADC (% r9) (% rbx) *)
  0x49; 0x11; 0xfa;        (* ADC (% r10) (% rdi) *)
  0x49; 0x11; 0xfb;        (* ADC (% r11) (% rdi) *)
  0x48; 0x19; 0xc0;        (* SBB (% rax) (% rax) *)
  0x48; 0xf7; 0xd0;        (* NOT (% rax) *)
  0x48; 0x21; 0xd0;        (* AND (% rax) (% rdx) *)
  0x49; 0x29; 0xc0;        (* SUB (% r8) (% rax) *)
  0x49; 0x19; 0xf9;        (* SBB (% r9) (% rdi) *)
  0x49; 0x19; 0xfa;        (* SBB (% r10) (% rdi) *)
  0x49; 0x19; 0xfb;        (* SBB (% r11) (% rdi) *)
  0x48; 0xf7; 0xd1;        (* NOT (% rcx) *)
  0x49; 0x21; 0xcb;        (* AND (% r11) (% rcx) *)
  0x4c; 0x89; 0x44; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% r8) *)
  0x4c; 0x89; 0x4c; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% r9) *)
  0x4c; 0x89; 0x54; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% r10) *)
  0x4c; 0x89; 0x5c; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% r11) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,160))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0x8c; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MULX4 (% r9,% r8) (% rdx,Memop Quadword (%% (rsp,192))) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x94; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MULX4 (% r10,% rax) (% rdx,Memop Quadword (%% (rsp,200))) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x9c; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MULX4 (% r11,% rax) (% rdx,Memop Quadword (%% (rsp,208))) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xa4; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MULX4 (% r12,% rax) (% rdx,Memop Quadword (%% (rsp,216))) *)
  0x49; 0x11; 0xc3;        (* ADC (% r11) (% rax) *)
  0x49; 0x11; 0xfc;        (* ADC (% r12) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,168))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,192))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,200))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,208))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xac; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MULX4 (% r13,% rax) (% rdx,Memop Quadword (%% (rsp,216))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADOX (% r13) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADCX (% r13) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,176))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,192))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,200))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,208))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xb4; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MULX4 (% r14,% rax) (% rdx,Memop Quadword (%% (rsp,216))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADOX (% r14) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADCX (% r14) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x94; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,184))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,192))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,200))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,208))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf3;
                           (* ADOX (% r14) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xbc; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MULX4 (% r15,% rax) (% rdx,Memop Quadword (%% (rsp,216))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf0;
                           (* ADCX (% r14) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADOX (% r15) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADCX (% r15) (% rdi) *)
  0xba; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 38)) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdc;
                           (* MULX4 (% rbx,% rax) (% rdx,% r12) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xcb;
                           (* ADOX (% r9) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdd;
                           (* MULX4 (% rbx,% rax) (% rdx,% r13) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xde;
                           (* MULX4 (% rbx,% rax) (% rdx,% r14) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0x42; 0xfb; 0xf6; 0xe7;
                           (* MULX4 (% r12,% rax) (% rdx,% r15) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADOX (% r12) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADCX (% r12) (% rdi) *)
  0x4d; 0x0f; 0xa4; 0xdc; 0x01;
                           (* SHLD (% r12) (% r11) (Imm8 (word 1)) *)
  0x48; 0xb9; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x80;
                           (* MOV (% rcx) (Imm64 (word 9223372036854775808)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x49; 0xff; 0xc4;        (* INC (% r12) *)
  0x49; 0x09; 0xcb;        (* OR (% r11) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdc;
                           (* MULX4 (% rbx,% rax) (% rdx,% r12) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xd9;        (* ADC (% r9) (% rbx) *)
  0x49; 0x11; 0xfa;        (* ADC (% r10) (% rdi) *)
  0x49; 0x11; 0xfb;        (* ADC (% r11) (% rdi) *)
  0x48; 0x19; 0xc0;        (* SBB (% rax) (% rax) *)
  0x48; 0xf7; 0xd0;        (* NOT (% rax) *)
  0x48; 0x21; 0xd0;        (* AND (% rax) (% rdx) *)
  0x49; 0x29; 0xc0;        (* SUB (% r8) (% rax) *)
  0x49; 0x19; 0xf9;        (* SBB (% r9) (% rdi) *)
  0x49; 0x19; 0xfa;        (* SBB (% r10) (% rdi) *)
  0x49; 0x19; 0xfb;        (* SBB (% r11) (% rdi) *)
  0x48; 0xf7; 0xd1;        (* NOT (% rcx) *)
  0x49; 0x21; 0xcb;        (* AND (% r11) (% rcx) *)
  0x4c; 0x89; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% r11) *)
  0x48; 0x8b; 0x84; 0x24; 0x88; 0x01; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,392))) *)
  0x48; 0x83; 0xe8; 0x01;  (* SUB (% rax) (Imm8 (word 1)) *)
  0x48; 0x89; 0x84; 0x24; 0x88; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,392))) (% rax) *)
  0x0f; 0x83; 0xd6; 0xea; 0xff; 0xff;
                           (* JAE (Imm32 (word 4294961878)) *)
  0x48; 0xc7; 0xc0; 0xed; 0xff; 0xff; 0xff;
                           (* MOV (% rax) (Imm32 (word 4294967277)) *)
  0x48; 0xc7; 0xc1; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% rcx) (Imm32 (word 4294967295)) *)
  0x48; 0xba; 0xff; 0xff; 0xff; 0xff; 0xff; 0xff; 0xff; 0x7f;
                           (* MOV (% rdx) (Imm64 (word 9223372036854775807)) *)
  0x48; 0x89; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,128))) (% rax) *)
  0x48; 0x89; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,136))) (% rcx) *)
  0x48; 0x89; 0x8c; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,144))) (% rcx) *)
  0x48; 0x89; 0x94; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,152))) (% rdx) *)
  0x48; 0xc7; 0xc7; 0x04; 0x00; 0x00; 0x00;
                           (* MOV (% rdi) (Imm32 (word 4)) *)
  0x48; 0x8d; 0x74; 0x24; 0x60;
                           (* LEA (% rsi) (%% (rsp,96)) *)
  0x48; 0x8d; 0x94; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* LEA (% rdx) (%% (rsp,160)) *)
  0x48; 0x8d; 0x8c; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* LEA (% rcx) (%% (rsp,128)) *)
  0x4c; 0x8d; 0x84; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* LEA (% r8) (%% (rsp,192)) *)
  0x48; 0x89; 0x74; 0x24; 0x40;
                           (* MOV (Memop Quadword (%% (rsp,64))) (% rsi) *)
  0x4c; 0x89; 0x44; 0x24; 0x38;
                           (* MOV (Memop Quadword (%% (rsp,56))) (% r8) *)
  0x48; 0x89; 0x4c; 0x24; 0x48;
                           (* MOV (Memop Quadword (%% (rsp,72))) (% rcx) *)
  0x4d; 0x8d; 0x14; 0xf8;  (* LEA (% r10) (%%% (r8,3,rdi)) *)
  0x4c; 0x89; 0x54; 0x24; 0x30;
                           (* MOV (Memop Quadword (%% (rsp,48))) (% r10) *)
  0x4d; 0x8d; 0x3c; 0xfa;  (* LEA (% r15) (%%% (r10,3,rdi)) *)
  0x4d; 0x31; 0xdb;        (* XOR (% r11) (% r11) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x4a; 0x8b; 0x04; 0xca;  (* MOV (% rax) (Memop Quadword (%%% (rdx,3,r9))) *)
  0x4a; 0x8b; 0x1c; 0xc9;  (* MOV (% rbx) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x4b; 0x89; 0x04; 0xca;  (* MOV (Memop Quadword (%%% (r10,3,r9))) (% rax) *)
  0x4b; 0x89; 0x1c; 0xcf;  (* MOV (Memop Quadword (%%% (r15,3,r9))) (% rbx) *)
  0x4b; 0x89; 0x1c; 0xc8;  (* MOV (Memop Quadword (%%% (r8,3,r9))) (% rbx) *)
  0x4e; 0x89; 0x1c; 0xce;  (* MOV (Memop Quadword (%%% (rsi,3,r9))) (% r11) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x49; 0x39; 0xf9;        (* CMP (% r9) (% rdi) *)
  0x72; 0xe0;              (* JB (Imm8 (word 224)) *)
  0x49; 0x8b; 0x00;        (* MOV (% rax) (Memop Quadword (%% (r8,0))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x49; 0x89; 0x18;        (* MOV (Memop Quadword (%% (r8,0))) (% rbx) *)
  0x48; 0x89; 0xc5;        (* MOV (% rbp) (% rax) *)
  0x49; 0x89; 0xc4;        (* MOV (% r12) (% rax) *)
  0x48; 0xc1; 0xe5; 0x02;  (* SHL (% rbp) (Imm8 (word 2)) *)
  0x49; 0x29; 0xec;        (* SUB (% r12) (% rbp) *)
  0x49; 0x83; 0xf4; 0x02;  (* XOR (% r12) (Imm8 (word 2)) *)
  0x4c; 0x89; 0xe5;        (* MOV (% rbp) (% r12) *)
  0x48; 0x0f; 0xaf; 0xe8;  (* IMUL (% rbp) (% rax) *)
  0xb8; 0x02; 0x00; 0x00; 0x00;
                           (* MOV (% eax) (Imm32 (word 2)) *)
  0x48; 0x01; 0xe8;        (* ADD (% rax) (% rbp) *)
  0x48; 0x83; 0xc5; 0x01;  (* ADD (% rbp) (Imm8 (word 1)) *)
  0x4c; 0x0f; 0xaf; 0xe0;  (* IMUL (% r12) (% rax) *)
  0x48; 0x0f; 0xaf; 0xed;  (* IMUL (% rbp) (% rbp) *)
  0xb8; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% eax) (Imm32 (word 1)) *)
  0x48; 0x01; 0xe8;        (* ADD (% rax) (% rbp) *)
  0x4c; 0x0f; 0xaf; 0xe0;  (* IMUL (% r12) (% rax) *)
  0x48; 0x0f; 0xaf; 0xed;  (* IMUL (% rbp) (% rbp) *)
  0xb8; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% eax) (Imm32 (word 1)) *)
  0x48; 0x01; 0xe8;        (* ADD (% rax) (% rbp) *)
  0x4c; 0x0f; 0xaf; 0xe0;  (* IMUL (% r12) (% rax) *)
  0x48; 0x0f; 0xaf; 0xed;  (* IMUL (% rbp) (% rbp) *)
  0xb8; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% eax) (Imm32 (word 1)) *)
  0x48; 0x01; 0xe8;        (* ADD (% rax) (% rbp) *)
  0x4c; 0x0f; 0xaf; 0xe0;  (* IMUL (% r12) (% rax) *)
  0x4c; 0x89; 0x64; 0x24; 0x28;
                           (* MOV (Memop Quadword (%% (rsp,40))) (% r12) *)
  0x48; 0x89; 0xf8;        (* MOV (% rax) (% rdi) *)
  0x48; 0xc1; 0xe0; 0x07;  (* SHL (% rax) (Imm8 (word 7)) *)
  0x48; 0x89; 0x44; 0x24; 0x20;
                           (* MOV (Memop Quadword (%% (rsp,32))) (% rax) *)
  0x4c; 0x8b; 0x6c; 0x24; 0x20;
                           (* MOV (% r13) (Memop Quadword (%% (rsp,32))) *)
  0x49; 0x83; 0xc5; 0x3f;  (* ADD (% r13) (Imm8 (word 63)) *)
  0x49; 0xc1; 0xed; 0x06;  (* SHR (% r13) (Imm8 (word 6)) *)
  0x49; 0x39; 0xfd;        (* CMP (% r13) (% rdi) *)
  0x4c; 0x0f; 0x43; 0xef;  (* CMOVAE (% r13) (% rdi) *)
  0x4d; 0x31; 0xe4;        (* XOR (% r12) (% r12) *)
  0x4d; 0x31; 0xf6;        (* XOR (% r14) (% r14) *)
  0x48; 0x31; 0xed;        (* XOR (% rbp) (% rbp) *)
  0x48; 0x31; 0xf6;        (* XOR (% rsi) (% rsi) *)
  0x4d; 0x31; 0xdb;        (* XOR (% r11) (% r11) *)
  0x4c; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,48))) *)
  0x4d; 0x8d; 0x3c; 0xf8;  (* LEA (% r15) (%%% (r8,3,rdi)) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x4b; 0x8b; 0x1c; 0xc8;  (* MOV (% rbx) (Memop Quadword (%%% (r8,3,r9))) *)
  0x4b; 0x8b; 0x0c; 0xcf;  (* MOV (% rcx) (Memop Quadword (%%% (r15,3,r9))) *)
  0x4d; 0x89; 0xda;        (* MOV (% r10) (% r11) *)
  0x4d; 0x21; 0xe2;        (* AND (% r10) (% r12) *)
  0x49; 0x21; 0xeb;        (* AND (% r11) (% rbp) *)
  0x48; 0x89; 0xd8;        (* MOV (% rax) (% rbx) *)
  0x48; 0x09; 0xc8;        (* OR (% rax) (% rcx) *)
  0x48; 0xf7; 0xd8;        (* NEG (% rax) *)
  0x4d; 0x0f; 0x42; 0xf2;  (* CMOVB (% r14) (% r10) *)
  0x49; 0x0f; 0x42; 0xf3;  (* CMOVB (% rsi) (% r11) *)
  0x4c; 0x0f; 0x42; 0xe3;  (* CMOVB (% r12) (% rbx) *)
  0x48; 0x0f; 0x42; 0xe9;  (* CMOVB (% rbp) (% rcx) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x4d; 0x39; 0xe9;        (* CMP (% r9) (% r13) *)
  0x72; 0xcb;              (* JB (Imm8 (word 203)) *)
  0x4c; 0x89; 0xe0;        (* MOV (% rax) (% r12) *)
  0x48; 0x09; 0xe8;        (* OR (% rax) (% rbp) *)
  0x48; 0x0f; 0xbd; 0xc8;  (* BSR (% rcx) (% rax) *)
  0x48; 0x83; 0xf1; 0x3f;  (* XOR (% rcx) (Imm8 (word 63)) *)
  0x4d; 0x0f; 0xa5; 0xf4;  (* SHLD (% r12) (% r14) (% cl) *)
  0x48; 0x0f; 0xa5; 0xf5;  (* SHLD (% rbp) (% rsi) (% cl) *)
  0x49; 0x8b; 0x00;        (* MOV (% rax) (Memop Quadword (%% (r8,0))) *)
  0x49; 0x89; 0xc6;        (* MOV (% r14) (% rax) *)
  0x49; 0x8b; 0x07;        (* MOV (% rax) (Memop Quadword (%% (r15,0))) *)
  0x48; 0x89; 0xc6;        (* MOV (% rsi) (% rax) *)
  0x41; 0xba; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% r10d) (Imm32 (word 1)) *)
  0x41; 0xbb; 0x00; 0x00; 0x00; 0x00;
                           (* MOV (% r11d) (Imm32 (word 0)) *)
  0xb9; 0x00; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 0)) *)
  0xba; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 1)) *)
  0x41; 0xb9; 0x3a; 0x00; 0x00; 0x00;
                           (* MOV (% r9d) (Imm32 (word 58)) *)
  0x48; 0x89; 0x7c; 0x24; 0x08;
                           (* MOV (Memop Quadword (%% (rsp,8))) (% rdi) *)
  0x4c; 0x89; 0x6c; 0x24; 0x10;
                           (* MOV (Memop Quadword (%% (rsp,16))) (% r13) *)
  0x4c; 0x89; 0x04; 0x24;  (* MOV (Memop Quadword (%% (rsp,0))) (% r8) *)
  0x4c; 0x89; 0x7c; 0x24; 0x18;
                           (* MOV (Memop Quadword (%% (rsp,24))) (% r15) *)
  0x48; 0x89; 0xe8;        (* MOV (% rax) (% rbp) *)
  0x48; 0x89; 0xf7;        (* MOV (% rdi) (% rsi) *)
  0x49; 0x89; 0xcd;        (* MOV (% r13) (% rcx) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0xc7; 0xc3; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm32 (word 1)) *)
  0x48; 0xf7; 0xdf;        (* NEG (% rdi) *)
  0x4c; 0x21; 0xf3;        (* AND (% rbx) (% r14) *)
  0x48; 0x0f; 0x44; 0xc3;  (* CMOVE (% rax) (% rbx) *)
  0x48; 0x0f; 0x44; 0xfb;  (* CMOVE (% rdi) (% rbx) *)
  0x4c; 0x0f; 0x44; 0xeb;  (* CMOVE (% r13) (% rbx) *)
  0x4c; 0x0f; 0x44; 0xfb;  (* CMOVE (% r15) (% rbx) *)
  0x4c; 0x89; 0xe3;        (* MOV (% rbx) (% r12) *)
  0x4c; 0x01; 0xf7;        (* ADD (% rdi) (% r14) *)
  0x49; 0x89; 0xf8;        (* MOV (% r8) (% rdi) *)
  0x48; 0xf7; 0xdf;        (* NEG (% rdi) *)
  0x48; 0x29; 0xc3;        (* SUB (% rbx) (% rax) *)
  0x49; 0x0f; 0x42; 0xec;  (* CMOVB (% rbp) (% r12) *)
  0x49; 0x0f; 0x42; 0xf6;  (* CMOVB (% rsi) (% r14) *)
  0x49; 0x0f; 0x42; 0xca;  (* CMOVB (% rcx) (% r10) *)
  0x49; 0x0f; 0x42; 0xd3;  (* CMOVB (% rdx) (% r11) *)
  0x49; 0x0f; 0x43; 0xf8;  (* CMOVAE (% rdi) (% r8) *)
  0x49; 0x89; 0xdc;        (* MOV (% r12) (% rbx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0xff; 0xc3;        (* INC (% rbx) *)
  0x4c; 0x0f; 0x42; 0xe3;  (* CMOVB (% r12) (% rbx) *)
  0x49; 0x89; 0xfe;        (* MOV (% r14) (% rdi) *)
  0x4d; 0x01; 0xea;        (* ADD (% r10) (% r13) *)
  0x4d; 0x01; 0xfb;        (* ADD (% r11) (% r15) *)
  0x49; 0xd1; 0xec;        (* SHR (% r12) (Imm8 (word 1)) *)
  0x49; 0xd1; 0xee;        (* SHR (% r14) (Imm8 (word 1)) *)
  0x48; 0x8d; 0x0c; 0x09;  (* LEA (% rcx) (%%% (rcx,0,rcx)) *)
  0x48; 0x8d; 0x14; 0x12;  (* LEA (% rdx) (%%% (rdx,0,rdx)) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x75; 0x8b;              (* JNE (Imm8 (word 139)) *)
  0x48; 0x8b; 0x7c; 0x24; 0x08;
                           (* MOV (% rdi) (Memop Quadword (%% (rsp,8))) *)
  0x4c; 0x8b; 0x6c; 0x24; 0x10;
                           (* MOV (% r13) (Memop Quadword (%% (rsp,16))) *)
  0x4c; 0x8b; 0x04; 0x24;  (* MOV (% r8) (Memop Quadword (%% (rsp,0))) *)
  0x4c; 0x8b; 0x7c; 0x24; 0x18;
                           (* MOV (% r15) (Memop Quadword (%% (rsp,24))) *)
  0x4c; 0x89; 0x14; 0x24;  (* MOV (Memop Quadword (%% (rsp,0))) (% r10) *)
  0x4c; 0x89; 0x5c; 0x24; 0x08;
                           (* MOV (Memop Quadword (%% (rsp,8))) (% r11) *)
  0x48; 0x89; 0x4c; 0x24; 0x10;
                           (* MOV (Memop Quadword (%% (rsp,16))) (% rcx) *)
  0x48; 0x89; 0x54; 0x24; 0x18;
                           (* MOV (Memop Quadword (%% (rsp,24))) (% rdx) *)
  0x4c; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,56))) *)
  0x4c; 0x8b; 0x7c; 0x24; 0x40;
                           (* MOV (% r15) (Memop Quadword (%% (rsp,64))) *)
  0x4d; 0x31; 0xf6;        (* XOR (% r14) (% r14) *)
  0x48; 0x31; 0xf6;        (* XOR (% rsi) (% rsi) *)
  0x4d; 0x31; 0xd2;        (* XOR (% r10) (% r10) *)
  0x4d; 0x31; 0xdb;        (* XOR (% r11) (% r11) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x4b; 0x8b; 0x0c; 0xc8;  (* MOV (% rcx) (Memop Quadword (%%% (r8,3,r9))) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x48; 0x83; 0xd2; 0x00;  (* ADC (% rdx) (Imm8 (word 0)) *)
  0x49; 0x89; 0xd4;        (* MOV (% r12) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x01; 0xc6;        (* ADD (% rsi) (% rax) *)
  0x48; 0x83; 0xd2; 0x00;  (* ADC (% rdx) (Imm8 (word 0)) *)
  0x48; 0x89; 0xd5;        (* MOV (% rbp) (% rdx) *)
  0x4b; 0x8b; 0x0c; 0xcf;  (* MOV (% rcx) (Memop Quadword (%%% (r15,3,r9))) *)
  0x48; 0x8b; 0x44; 0x24; 0x08;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x0f; 0xac; 0xf2; 0x3a;
                           (* SHRD (% r10) (% r14) (Imm8 (word 58)) *)
  0x4f; 0x89; 0x14; 0xc8;  (* MOV (Memop Quadword (%%% (r8,3,r9))) (% r10) *)
  0x4d; 0x89; 0xf2;        (* MOV (% r10) (% r14) *)
  0x4d; 0x89; 0xe6;        (* MOV (% r14) (% r12) *)
  0x48; 0x8b; 0x44; 0x24; 0x18;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x01; 0xc6;        (* ADD (% rsi) (% rax) *)
  0x48; 0x11; 0xd5;        (* ADC (% rbp) (% rdx) *)
  0x49; 0x0f; 0xac; 0xf3; 0x3a;
                           (* SHRD (% r11) (% rsi) (Imm8 (word 58)) *)
  0x4f; 0x89; 0x1c; 0xcf;  (* MOV (Memop Quadword (%%% (r15,3,r9))) (% r11) *)
  0x49; 0x89; 0xf3;        (* MOV (% r11) (% rsi) *)
  0x48; 0x89; 0xee;        (* MOV (% rsi) (% rbp) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x49; 0x39; 0xf9;        (* CMP (% r9) (% rdi) *)
  0x72; 0x93;              (* JB (Imm8 (word 147)) *)
  0x4d; 0x0f; 0xa4; 0xd6; 0x06;
                           (* SHLD (% r14) (% r10) (Imm8 (word 6)) *)
  0x4c; 0x0f; 0xa4; 0xde; 0x06;
                           (* SHLD (% rsi) (% r11) (Imm8 (word 6)) *)
  0x4c; 0x8b; 0x7c; 0x24; 0x48;
                           (* MOV (% r15) (Memop Quadword (%% (rsp,72))) *)
  0x49; 0x8b; 0x18;        (* MOV (% rbx) (Memop Quadword (%% (r8,0))) *)
  0x4c; 0x8b; 0x64; 0x24; 0x28;
                           (* MOV (% r12) (Memop Quadword (%% (rsp,40))) *)
  0x4c; 0x0f; 0xaf; 0xe3;  (* IMUL (% r12) (% rbx) *)
  0x49; 0x8b; 0x07;        (* MOV (% rax) (Memop Quadword (%% (r15,0))) *)
  0x49; 0xf7; 0xe4;        (* MUL2 (% rdx,% rax) (% r12) *)
  0x48; 0x01; 0xd8;        (* ADD (% rax) (% rbx) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x41; 0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% r9d) (Imm32 (word 1)) *)
  0x48; 0x89; 0xf9;        (* MOV (% rcx) (% rdi) *)
  0x48; 0xff; 0xc9;        (* DEC (% rcx) *)
  0x74; 0x24;              (* JE (Imm8 (word 36)) *)
  0x4f; 0x13; 0x14; 0xc8;  (* ADC (% r10) (Memop Quadword (%%% (r8,3,r9))) *)
  0x48; 0x19; 0xdb;        (* SBB (% rbx) (% rbx) *)
  0x4b; 0x8b; 0x04; 0xcf;  (* MOV (% rax) (Memop Quadword (%%% (r15,3,r9))) *)
  0x49; 0xf7; 0xe4;        (* MUL2 (% rdx,% rax) (% r12) *)
  0x48; 0x29; 0xda;        (* SUB (% rdx) (% rbx) *)
  0x4c; 0x01; 0xd0;        (* ADD (% rax) (% r10) *)
  0x4b; 0x89; 0x44; 0xc8; 0xf8;
                           (* MOV (Memop Quadword (%%%% (r8,3,r9,-- &8))) (% rax) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x48; 0xff; 0xc9;        (* DEC (% rcx) *)
  0x75; 0xdc;              (* JNE (Imm8 (word 220)) *)
  0x4d; 0x11; 0xf2;        (* ADC (% r10) (% r14) *)
  0x4d; 0x89; 0x54; 0xf8; 0xf8;
                           (* MOV (Memop Quadword (%%%% (r8,3,rdi,-- &8))) (% r10) *)
  0x4d; 0x19; 0xd2;        (* SBB (% r10) (% r10) *)
  0x49; 0xf7; 0xda;        (* NEG (% r10) *)
  0x48; 0x89; 0xf9;        (* MOV (% rcx) (% rdi) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x4b; 0x8b; 0x04; 0xc8;  (* MOV (% rax) (Memop Quadword (%%% (r8,3,r9))) *)
  0x4b; 0x1b; 0x04; 0xcf;  (* SBB (% rax) (Memop Quadword (%%% (r15,3,r9))) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x48; 0xff; 0xc9;        (* DEC (% rcx) *)
  0x75; 0xf0;              (* JNE (Imm8 (word 240)) *)
  0x49; 0x83; 0xda; 0x00;  (* SBB (% r10) (Imm8 (word 0)) *)
  0x4d; 0x19; 0xd2;        (* SBB (% r10) (% r10) *)
  0x49; 0xf7; 0xd2;        (* NOT (% r10) *)
  0x48; 0x31; 0xc9;        (* XOR (% rcx) (% rcx) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x4b; 0x8b; 0x04; 0xc8;  (* MOV (% rax) (Memop Quadword (%%% (r8,3,r9))) *)
  0x4b; 0x8b; 0x1c; 0xcf;  (* MOV (% rbx) (Memop Quadword (%%% (r15,3,r9))) *)
  0x4c; 0x21; 0xd3;        (* AND (% rbx) (% r10) *)
  0x48; 0xf7; 0xd9;        (* NEG (% rcx) *)
  0x48; 0x19; 0xd8;        (* SBB (% rax) (% rbx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4b; 0x89; 0x04; 0xc8;  (* MOV (Memop Quadword (%%% (r8,3,r9))) (% rax) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x49; 0x39; 0xf9;        (* CMP (% r9) (% rdi) *)
  0x72; 0xe0;              (* JB (Imm8 (word 224)) *)
  0x4c; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,64))) *)
  0x49; 0x8b; 0x18;        (* MOV (% rbx) (Memop Quadword (%% (r8,0))) *)
  0x48; 0x8b; 0x6c; 0x24; 0x28;
                           (* MOV (% rbp) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0x0f; 0xaf; 0xeb;  (* IMUL (% rbp) (% rbx) *)
  0x49; 0x8b; 0x07;        (* MOV (% rax) (Memop Quadword (%% (r15,0))) *)
  0x48; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% rbp) *)
  0x48; 0x01; 0xd8;        (* ADD (% rax) (% rbx) *)
  0x49; 0x89; 0xd3;        (* MOV (% r11) (% rdx) *)
  0x41; 0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% r9d) (Imm32 (word 1)) *)
  0x48; 0x89; 0xf9;        (* MOV (% rcx) (% rdi) *)
  0x48; 0xff; 0xc9;        (* DEC (% rcx) *)
  0x74; 0x24;              (* JE (Imm8 (word 36)) *)
  0x4f; 0x13; 0x1c; 0xc8;  (* ADC (% r11) (Memop Quadword (%%% (r8,3,r9))) *)
  0x48; 0x19; 0xdb;        (* SBB (% rbx) (% rbx) *)
  0x4b; 0x8b; 0x04; 0xcf;  (* MOV (% rax) (Memop Quadword (%%% (r15,3,r9))) *)
  0x48; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% rbp) *)
  0x48; 0x29; 0xda;        (* SUB (% rdx) (% rbx) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x4b; 0x89; 0x44; 0xc8; 0xf8;
                           (* MOV (Memop Quadword (%%%% (r8,3,r9,-- &8))) (% rax) *)
  0x49; 0x89; 0xd3;        (* MOV (% r11) (% rdx) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x48; 0xff; 0xc9;        (* DEC (% rcx) *)
  0x75; 0xdc;              (* JNE (Imm8 (word 220)) *)
  0x49; 0x11; 0xf3;        (* ADC (% r11) (% rsi) *)
  0x4d; 0x89; 0x5c; 0xf8; 0xf8;
                           (* MOV (Memop Quadword (%%%% (r8,3,rdi,-- &8))) (% r11) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x49; 0xf7; 0xdb;        (* NEG (% r11) *)
  0x48; 0x89; 0xf9;        (* MOV (% rcx) (% rdi) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x4b; 0x8b; 0x04; 0xc8;  (* MOV (% rax) (Memop Quadword (%%% (r8,3,r9))) *)
  0x4b; 0x1b; 0x04; 0xcf;  (* SBB (% rax) (Memop Quadword (%%% (r15,3,r9))) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x48; 0xff; 0xc9;        (* DEC (% rcx) *)
  0x75; 0xf0;              (* JNE (Imm8 (word 240)) *)
  0x49; 0x83; 0xdb; 0x00;  (* SBB (% r11) (Imm8 (word 0)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x49; 0xf7; 0xd3;        (* NOT (% r11) *)
  0x48; 0x31; 0xc9;        (* XOR (% rcx) (% rcx) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x4b; 0x8b; 0x04; 0xc8;  (* MOV (% rax) (Memop Quadword (%%% (r8,3,r9))) *)
  0x4b; 0x8b; 0x1c; 0xcf;  (* MOV (% rbx) (Memop Quadword (%%% (r15,3,r9))) *)
  0x4c; 0x21; 0xdb;        (* AND (% rbx) (% r11) *)
  0x48; 0xf7; 0xd9;        (* NEG (% rcx) *)
  0x48; 0x19; 0xd8;        (* SBB (% rax) (% rbx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4b; 0x89; 0x04; 0xc8;  (* MOV (Memop Quadword (%%% (r8,3,r9))) (% rax) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x49; 0x39; 0xf9;        (* CMP (% r9) (% rdi) *)
  0x72; 0xe0;              (* JB (Imm8 (word 224)) *)
  0x4c; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,48))) *)
  0x4d; 0x8d; 0x3c; 0xf8;  (* LEA (% r15) (%%% (r8,3,rdi)) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x4d; 0x31; 0xe4;        (* XOR (% r12) (% r12) *)
  0x4d; 0x31; 0xf6;        (* XOR (% r14) (% r14) *)
  0x48; 0x31; 0xed;        (* XOR (% rbp) (% rbp) *)
  0x48; 0x31; 0xf6;        (* XOR (% rsi) (% rsi) *)
  0x4b; 0x8b; 0x0c; 0xc8;  (* MOV (% rcx) (Memop Quadword (%%% (r8,3,r9))) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x48; 0x83; 0xd2; 0x00;  (* ADC (% rdx) (Imm8 (word 0)) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x01; 0xc6;        (* ADD (% rsi) (% rax) *)
  0x48; 0x83; 0xd2; 0x00;  (* ADC (% rdx) (Imm8 (word 0)) *)
  0x49; 0x89; 0xd3;        (* MOV (% r11) (% rdx) *)
  0x4b; 0x8b; 0x0c; 0xcf;  (* MOV (% rcx) (Memop Quadword (%%% (r15,3,r9))) *)
  0x48; 0x8b; 0x44; 0x24; 0x08;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x4c; 0x29; 0xe2;        (* SUB (% rdx) (% r12) *)
  0x49; 0x29; 0xc6;        (* SUB (% r14) (% rax) *)
  0x49; 0x19; 0xd2;        (* SBB (% r10) (% rdx) *)
  0x4d; 0x19; 0xe4;        (* SBB (% r12) (% r12) *)
  0x4f; 0x89; 0x34; 0xc8;  (* MOV (Memop Quadword (%%% (r8,3,r9))) (% r14) *)
  0x4d; 0x89; 0xd6;        (* MOV (% r14) (% r10) *)
  0x48; 0x8b; 0x44; 0x24; 0x18;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x29; 0xea;        (* SUB (% rdx) (% rbp) *)
  0x48; 0x29; 0xc6;        (* SUB (% rsi) (% rax) *)
  0x49; 0x19; 0xd3;        (* SBB (% r11) (% rdx) *)
  0x48; 0x19; 0xed;        (* SBB (% rbp) (% rbp) *)
  0x4b; 0x89; 0x34; 0xcf;  (* MOV (Memop Quadword (%%% (r15,3,r9))) (% rsi) *)
  0x4c; 0x89; 0xde;        (* MOV (% rsi) (% r11) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x4d; 0x39; 0xe9;        (* CMP (% r9) (% r13) *)
  0x72; 0x97;              (* JB (Imm8 (word 151)) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x4d; 0x89; 0xe2;        (* MOV (% r10) (% r12) *)
  0x49; 0x89; 0xeb;        (* MOV (% r11) (% rbp) *)
  0x4d; 0x31; 0xe6;        (* XOR (% r14) (% r12) *)
  0x48; 0x31; 0xee;        (* XOR (% rsi) (% rbp) *)
  0x4b; 0x8b; 0x04; 0xc8;  (* MOV (% rax) (Memop Quadword (%%% (r8,3,r9))) *)
  0x4c; 0x31; 0xe0;        (* XOR (% rax) (% r12) *)
  0x49; 0xf7; 0xda;        (* NEG (% r10) *)
  0x48; 0x83; 0xd0; 0x00;  (* ADC (% rax) (Imm8 (word 0)) *)
  0x4d; 0x19; 0xd2;        (* SBB (% r10) (% r10) *)
  0x4b; 0x89; 0x04; 0xc8;  (* MOV (Memop Quadword (%%% (r8,3,r9))) (% rax) *)
  0x4b; 0x8b; 0x04; 0xcf;  (* MOV (% rax) (Memop Quadword (%%% (r15,3,r9))) *)
  0x48; 0x31; 0xe8;        (* XOR (% rax) (% rbp) *)
  0x49; 0xf7; 0xdb;        (* NEG (% r11) *)
  0x48; 0x83; 0xd0; 0x00;  (* ADC (% rax) (Imm8 (word 0)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x4b; 0x89; 0x04; 0xcf;  (* MOV (Memop Quadword (%%% (r15,3,r9))) (% rax) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x4d; 0x39; 0xe9;        (* CMP (% r9) (% r13) *)
  0x72; 0xce;              (* JB (Imm8 (word 206)) *)
  0x4d; 0x29; 0xd6;        (* SUB (% r14) (% r10) *)
  0x4c; 0x29; 0xde;        (* SUB (% rsi) (% r11) *)
  0x4d; 0x89; 0xe9;        (* MOV (% r9) (% r13) *)
  0x4b; 0x8b; 0x44; 0xc8; 0xf8;
                           (* MOV (% rax) (Memop Quadword (%%%% (r8,3,r9,-- &8))) *)
  0x49; 0x89; 0xc2;        (* MOV (% r10) (% rax) *)
  0x4c; 0x0f; 0xac; 0xf0; 0x3a;
                           (* SHRD (% rax) (% r14) (Imm8 (word 58)) *)
  0x4b; 0x89; 0x44; 0xc8; 0xf8;
                           (* MOV (Memop Quadword (%%%% (r8,3,r9,-- &8))) (% rax) *)
  0x4d; 0x89; 0xd6;        (* MOV (% r14) (% r10) *)
  0x4b; 0x8b; 0x44; 0xcf; 0xf8;
                           (* MOV (% rax) (Memop Quadword (%%%% (r15,3,r9,-- &8))) *)
  0x49; 0x89; 0xc3;        (* MOV (% r11) (% rax) *)
  0x48; 0x0f; 0xac; 0xf0; 0x3a;
                           (* SHRD (% rax) (% rsi) (Imm8 (word 58)) *)
  0x4b; 0x89; 0x44; 0xcf; 0xf8;
                           (* MOV (Memop Quadword (%%%% (r15,3,r9,-- &8))) (% rax) *)
  0x4c; 0x89; 0xde;        (* MOV (% rsi) (% r11) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x75; 0xd1;              (* JNE (Imm8 (word 209)) *)
  0x48; 0xf7; 0xd5;        (* NOT (% rbp) *)
  0x48; 0x8b; 0x4c; 0x24; 0x48;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,72))) *)
  0x4c; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,56))) *)
  0x4c; 0x8b; 0x7c; 0x24; 0x40;
                           (* MOV (% r15) (Memop Quadword (%% (rsp,64))) *)
  0x4d; 0x89; 0xe2;        (* MOV (% r10) (% r12) *)
  0x49; 0x89; 0xeb;        (* MOV (% r11) (% rbp) *)
  0x4d; 0x31; 0xc9;        (* XOR (% r9) (% r9) *)
  0x48; 0x89; 0xea;        (* MOV (% rdx) (% rbp) *)
  0x4a; 0x8b; 0x04; 0xc9;  (* MOV (% rax) (Memop Quadword (%%% (rcx,3,r9))) *)
  0x48; 0x21; 0xc2;        (* AND (% rdx) (% rax) *)
  0x4c; 0x21; 0xe0;        (* AND (% rax) (% r12) *)
  0x4b; 0x8b; 0x1c; 0xc8;  (* MOV (% rbx) (Memop Quadword (%%% (r8,3,r9))) *)
  0x4c; 0x31; 0xe3;        (* XOR (% rbx) (% r12) *)
  0x49; 0xf7; 0xda;        (* NEG (% r10) *)
  0x48; 0x11; 0xd8;        (* ADC (% rax) (% rbx) *)
  0x4d; 0x19; 0xd2;        (* SBB (% r10) (% r10) *)
  0x4b; 0x89; 0x04; 0xc8;  (* MOV (Memop Quadword (%%% (r8,3,r9))) (% rax) *)
  0x4b; 0x8b; 0x1c; 0xcf;  (* MOV (% rbx) (Memop Quadword (%%% (r15,3,r9))) *)
  0x48; 0x31; 0xeb;        (* XOR (% rbx) (% rbp) *)
  0x49; 0xf7; 0xdb;        (* NEG (% r11) *)
  0x48; 0x11; 0xda;        (* ADC (% rdx) (% rbx) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x4b; 0x89; 0x14; 0xcf;  (* MOV (Memop Quadword (%%% (r15,3,r9))) (% rdx) *)
  0x49; 0xff; 0xc1;        (* INC (% r9) *)
  0x49; 0x39; 0xf9;        (* CMP (% r9) (% rdi) *)
  0x72; 0xc3;              (* JB (Imm8 (word 195)) *)
  0x48; 0x83; 0x6c; 0x24; 0x20; 0x3a;
                           (* SUB (Memop Quadword (%% (rsp,32))) (Imm8 (word 58)) *)
  0x0f; 0x87; 0x7c; 0xfb; 0xff; 0xff;
                           (* JA (Imm32 (word 4294966140)) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0x0b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* OR (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0x0b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* OR (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0x0b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* OR (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0x8b; 0x8c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,320))) *)
  0x48; 0x0f; 0x44; 0xc8;  (* CMOVE (% rcx) (% rax) *)
  0x48; 0x89; 0x8c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,320))) (% rcx) *)
  0x48; 0x8b; 0x8c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,328))) *)
  0x48; 0x0f; 0x44; 0xc8;  (* CMOVE (% rcx) (% rax) *)
  0x48; 0x89; 0x8c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,328))) (% rcx) *)
  0x48; 0x8b; 0x8c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,336))) *)
  0x48; 0x0f; 0x44; 0xc8;  (* CMOVE (% rcx) (% rax) *)
  0x48; 0x89; 0x8c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,336))) (% rcx) *)
  0x48; 0x8b; 0x8c; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,344))) *)
  0x48; 0x0f; 0x44; 0xc8;  (* CMOVE (% rcx) (% rax) *)
  0x48; 0x89; 0x8c; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,344))) (% rcx) *)
  0x48; 0x8b; 0xac; 0x24; 0x80; 0x01; 0x00; 0x00;
                           (* MOV (% rbp) (Memop Quadword (%% (rsp,384))) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x60;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,96))) *)
  0xc4; 0x62; 0xbb; 0xf6; 0x8c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MULX4 (% r9,% r8) (% rdx,Memop Quadword (%% (rsp,320))) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x94; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% r10,% rax) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0x9c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MULX4 (% r11,% rax) (% rdx,Memop Quadword (%% (rsp,336))) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xa4; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MULX4 (% r12,% rax) (% rdx,Memop Quadword (%% (rsp,344))) *)
  0x49; 0x11; 0xc3;        (* ADC (% r11) (% rax) *)
  0x49; 0x11; 0xfc;        (* ADC (% r12) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x68;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,104))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,320))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,336))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xac; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MULX4 (% r13,% rax) (% rdx,Memop Quadword (%% (rsp,344))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADOX (% r13) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xef;
                           (* ADCX (% r13) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x70;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,112))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,320))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,336))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xb4; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MULX4 (% r14,% rax) (% rdx,Memop Quadword (%% (rsp,344))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADOX (% r14) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf7;
                           (* ADCX (% r14) (% rdi) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0x48; 0x8b; 0x54; 0x24; 0x78;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,120))) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,320))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe3;
                           (* ADOX (% r12) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,328))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe0;
                           (* ADCX (% r12) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xeb;
                           (* ADOX (% r13) (% rbx) *)
  0xc4; 0xe2; 0xfb; 0xf6; 0x9c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* MULX4 (% rbx,% rax) (% rdx,Memop Quadword (%% (rsp,336))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe8;
                           (* ADCX (% r13) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xf3;
                           (* ADOX (% r14) (% rbx) *)
  0xc4; 0x62; 0xfb; 0xf6; 0xbc; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* MULX4 (% r15,% rax) (% rdx,Memop Quadword (%% (rsp,344))) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xf0;
                           (* ADCX (% r14) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADOX (% r15) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xff;
                           (* ADCX (% r15) (% rdi) *)
  0xba; 0x26; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 38)) *)
  0x31; 0xff;              (* XOR (% edi) (% edi) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdc;
                           (* MULX4 (% rbx,% rax) (% rdx,% r12) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc0;
                           (* ADCX (% r8) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xcb;
                           (* ADOX (% r9) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdd;
                           (* MULX4 (% rbx,% rax) (% rdx,% r13) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xc8;
                           (* ADCX (% r9) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xd3;
                           (* ADOX (% r10) (% rbx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xde;
                           (* MULX4 (% rbx,% rax) (% rdx,% r14) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd0;
                           (* ADCX (% r10) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xdb;
                           (* ADOX (% r11) (% rbx) *)
  0xc4; 0x42; 0xfb; 0xf6; 0xe7;
                           (* MULX4 (% r12,% rax) (% rdx,% r15) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xd8;
                           (* ADCX (% r11) (% rax) *)
  0xf3; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADOX (% r12) (% rdi) *)
  0x66; 0x4c; 0x0f; 0x38; 0xf6; 0xe7;
                           (* ADCX (% r12) (% rdi) *)
  0x4d; 0x0f; 0xa4; 0xdc; 0x01;
                           (* SHLD (% r12) (% r11) (Imm8 (word 1)) *)
  0x48; 0xb9; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x00; 0x80;
                           (* MOV (% rcx) (Imm64 (word 9223372036854775808)) *)
  0xba; 0x13; 0x00; 0x00; 0x00;
                           (* MOV (% edx) (Imm32 (word 19)) *)
  0x49; 0xff; 0xc4;        (* INC (% r12) *)
  0x49; 0x09; 0xcb;        (* OR (% r11) (% rcx) *)
  0xc4; 0xc2; 0xfb; 0xf6; 0xdc;
                           (* MULX4 (% rbx,% rax) (% rdx,% r12) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xd9;        (* ADC (% r9) (% rbx) *)
  0x49; 0x11; 0xfa;        (* ADC (% r10) (% rdi) *)
  0x49; 0x11; 0xfb;        (* ADC (% r11) (% rdi) *)
  0x48; 0x19; 0xc0;        (* SBB (% rax) (% rax) *)
  0x48; 0xf7; 0xd0;        (* NOT (% rax) *)
  0x48; 0x21; 0xd0;        (* AND (% rax) (% rdx) *)
  0x49; 0x29; 0xc0;        (* SUB (% r8) (% rax) *)
  0x49; 0x19; 0xf9;        (* SBB (% r9) (% rdi) *)
  0x49; 0x19; 0xfa;        (* SBB (% r10) (% rdi) *)
  0x49; 0x19; 0xfb;        (* SBB (% r11) (% rdi) *)
  0x48; 0xf7; 0xd1;        (* NOT (% rcx) *)
  0x49; 0x21; 0xcb;        (* AND (% r11) (% rcx) *)
  0x4c; 0x89; 0x45; 0x00;  (* MOV (Memop Quadword (%% (rbp,0))) (% r8) *)
  0x4c; 0x89; 0x4d; 0x08;  (* MOV (Memop Quadword (%% (rbp,8))) (% r9) *)
  0x4c; 0x89; 0x55; 0x10;  (* MOV (Memop Quadword (%% (rbp,16))) (% r10) *)
  0x4c; 0x89; 0x5d; 0x18;  (* MOV (Memop Quadword (%% (rbp,24))) (% r11) *)
  0x48; 0x81; 0xc4; 0xa0; 0x01; 0x00; 0x00;
                           (* ADD (% rsp) (Imm32 (word 416)) *)
  0x41; 0x5f;              (* POP (% r15) *)
  0x41; 0x5e;              (* POP (% r14) *)
  0x41; 0x5d;              (* POP (% r13) *)
  0x41; 0x5c;              (* POP (% r12) *)
  0x5d;                    (* POP (% rbp) *)
  0x5b;                    (* POP (% rbx) *)
  0xc3                     (* RET *)
];;

let CURVE25519_X25519_EXEC =
  X86_MK_CORE_EXEC_RULE curve25519_x25519_mc;;

(* ------------------------------------------------------------------------- *)
(* Abbreviations used to state the specification.                            *)
(* ------------------------------------------------------------------------- *)

let p_25519 = define `p_25519 = 57896044618658097711785492504343953926634992332820282019728792003956564819949`;;

let curve25519x = define
 `curve25519x (f:A ring) = (f,ring_of_num f A_25519,ring_of_num f 1)`;;

let curve25519x_canonically_represents = new_definition
 `curve25519x_canonically_represents (f:A ring) P (X,Z) <=>
        X < p_25519 /\ Z < p_25519 /\
        montgomery_xz f P (ring_of_num f X,ring_of_num f Z)`;;

let CURVE25519X_CANONICALLY_REPRESENTS_BOUND = prove
 (`!(f:A ring) P X Z.
        curve25519x_canonically_represents (f:A ring) P (X,Z)
        ==> X < p_25519 /\ Z < p_25519`,
  SIMP_TAC[curve25519x_canonically_represents]);;

(* ------------------------------------------------------------------------- *)
(* Common lemmas and tactics for the component proofs.                       *)
(* ------------------------------------------------------------------------- *)

let p25519redlemma = prove
 (`!n. n <= (2 EXP 64 - 1) * (p_25519 - 1)
       ==> let q = n DIV 2 EXP 255 + 1 in
           q < 2 EXP 64 /\
           q * p_25519 <= n + p_25519 /\
           n < q * p_25519 + p_25519`,
  CONV_TAC(TOP_DEPTH_CONV let_CONV) THEN REWRITE_TAC[p_25519] THEN ARITH_TAC);;

let p25519weakredlemma = prove
 (`!n. n <= 2 EXP 62 * 2 EXP 256
       ==> let q = n DIV 2 EXP 255 in
           q < 2 EXP 64 /\
           q * p_25519 <= n /\
           n < q * p_25519 + 2 * p_25519`,
  CONV_TAC(TOP_DEPTH_CONV let_CONV) THEN REWRITE_TAC[p_25519] THEN ARITH_TAC);;

let lvs =
 ["resx", [`RBP`;`0`];
  "x", [`RSP`;`32`];
  "dm", [`RSP`;`64`];
  "zm", [`RSP`;`96`];
  "sm", [`RSP`;`96`];
  "dpro", [`RSP`;`96`];
  "sn", [`RSP`;`128`];
  "zn", [`RSP`;`160`];
  "dn", [`RSP`;`160`];
  "e", [`RSP`;`160`];
  "dmsn", [`RSP`;`192`];
  "p", [`RSP`;`192`];
  "xm", [`RSP`;`256`];
  "dnsm", [`RSP`;`256`];
  "spro", [`RSP`;`256`];
  "xn", [`RSP`;`320`];
  "s", [`RSP`;`320`];
  "d", [`RSP`;`352`]];;

(* ------------------------------------------------------------------------- *)
(* Instances of mul_p25519.                                                  *)
(* ------------------------------------------------------------------------- *)

let LOCAL_MUL_P25519_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 93 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1 p2 n2.
      !m. read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) t = m
      ==>
      !n. read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) t = n
      ==>
      nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 4)
      ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                read RIP s = pcin /\
                read RSP s = read RSP t /\
                read RBP s = read RBP t /\
                read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) s = m /\
                read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) s = n)
           (\s. read RIP s = pcout /\
                read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s =
                (m * n) MOD p_25519)
         (MAYCHANGE [RIP; RAX; RBX; RCX; RDX; RDI;
                     R8; R9; R10; R11; R12; R13; R14; R15] ,,
           MAYCHANGE [memory :> bytes(word_add (read p3 t) (word n3),8 * 4)] ,,
           MAYCHANGE SOME_FLAGS)`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s1" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "m_" o lhand o concl) THEN

  (*** The initial multiplication block, similar to bignum_mul_4_8 ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (2--56) (2--56) THEN
  MAP_EVERY ABBREV_TAC
   [`l = bignum_of_wordlist[mullo_s4; sum_s15; sum_s30; sum_s45]`;
    `h = bignum_of_wordlist[sum_s48; sum_s51; sum_s54; sum_s56]`] THEN
  SUBGOAL_THEN `2 EXP 256 * h + l = m * n` (SUBST1_TAC o SYM) THENL
   [MAP_EVERY EXPAND_TAC ["h"; "l"; "m"; "n"] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; bignum_of_wordlist] THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  (*** The initial modular reduction of the high part ***)

  SUBGOAL_THEN
    `(2 EXP 256 * h + l) MOD p_25519 = (38 * h + l) MOD p_25519`
  SUBST1_TAC THENL
   [ONCE_REWRITE_TAC[GSYM MOD_ADD_MOD] THEN
    ONCE_REWRITE_TAC[GSYM MOD_MULT_LMOD] THEN
    REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV;
    ALL_TAC] THEN

  (*** Instantiate the quotient approximation lemma ***)

  MP_TAC(SPEC `38 * h + l` p25519redlemma) THEN ANTS_TAC THENL
   [MAP_EVERY EXPAND_TAC ["h"; "l"] THEN REWRITE_TAC[p_25519] THEN
    CONV_TAC NUM_REDUCE_CONV THEN BOUNDER_TAC[];
    CONV_TAC(TOP_DEPTH_CONV let_CONV) THEN STRIP_TAC] THEN

  (*** Reduction from 8 digits to 5 digits ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (57--71) (57--71) THEN
  ABBREV_TAC
   `ca = bignum_of_wordlist[sum_s60; sum_s63; sum_s66; sum_s69; sum_s71]` THEN
  SUBGOAL_THEN `(38 * h + l) DIV 2 EXP 255 + 1 <= 78`
  ASSUME_TAC THENL
   [REWRITE_TAC[ARITH_RULE `a + 1 <= b <=> a < b`] THEN
    SIMP_TAC[RDIV_LT_EQ; EXP_EQ_0; ARITH_EQ] THEN CONV_TAC NUM_REDUCE_CONV THEN
    MAP_EVERY EXPAND_TAC ["h"; "l"] THEN BOUNDER_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `38 * h + l = ca` SUBST_ALL_TAC THENL
   [MAP_EVERY EXPAND_TAC ["h"; "l"; "ca"] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; bignum_of_wordlist] THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  (*** Quotient estimate computation ***)

  X86_STEPS_TAC CURVE25519_X25519_EXEC (72--76) THEN
  ABBREV_TAC `t = bignum_of_wordlist
   [sum_s60; sum_s63; sum_s66; word_or sum_s69 (word 9223372036854775808)]` THEN
  SUBGOAL_THEN `&ca = &t + &2 pow 255 * (&(ca DIV 2 EXP 255) - &1)`
  ASSUME_TAC THENL
   [REWRITE_TAC[REAL_ARITH
     `c = t + e * (d - &1):real <=> c + e = t + e * d`] THEN
    REWRITE_TAC[REAL_OF_NUM_CLAUSES; ARITH_RULE
    `c + d = t + 2 EXP 255 * c DIV 2 EXP 255 <=> c MOD 2 EXP 255 + d = t`] THEN
    MAP_EVERY EXPAND_TAC ["ca"; "t"] THEN
    REWRITE_TAC[BIGNUM_OF_WORDLIST_SPLIT_RULE(4,1)] THEN
    REWRITE_TAC[MOD_MULT_ADD; ARITH_RULE
     `2 EXP 256 * n = 2 EXP 255 * 2 * n`] THEN
    REWRITE_TAC[MOD_MULT_MOD; ARITH_RULE
     `2 EXP 255 = 2 EXP 192 * 2 EXP 63`] THEN
    REWRITE_TAC[BIGNUM_OF_WORDLIST_SPLIT_RULE(3,1)] THEN
    SIMP_TAC[MOD_MULT_ADD; DIV_MULT_ADD; EXP_EQ_0; ARITH_EQ] THEN
    SUBGOAL_THEN `bignum_of_wordlist [sum_s60; sum_s63; sum_s66] < 2 EXP 192`
    (fun th -> SIMP_TAC[th; MOD_LT; DIV_LT]) THENL
     [BOUNDER_TAC[]; ALL_TAC] THEN
    REWRITE_TAC[ADD_CLAUSES; ARITH_RULE
     `(e * x + a) + e * y:num = a + e * z <=> e * (x + y) = e * z`] THEN
    AP_TERM_TAC THEN REWRITE_TAC[BIGNUM_OF_WORDLIST_SING] THEN
    REWRITE_TAC[GSYM VAL_WORD_AND_MASK_WORD] THEN
    ONCE_REWRITE_TAC[WORD_BITWISE_RULE
     `word_or x m = word_or (word_and x (word_not m)) m`] THEN
    SIMP_TAC[VAL_WORD_OR_DISJOINT; WORD_BITWISE_RULE
     `word_and (word_and x (word_not m)) m = word 0`] THEN
    CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV);
    ALL_TAC] THEN
  ABBREV_TAC `hw:int64 = word_subword
    ((word_join:int64->int64->int128) sum_s71 sum_s69) (63,64)` THEN
  SUBGOAL_THEN `ca DIV 2 EXP 255 = val(hw:int64)` SUBST_ALL_TAC THENL
   [UNDISCH_TAC `ca DIV 2 EXP 255 + 1 <= 78` THEN REWRITE_TAC[ARITH_RULE
     `n DIV 2 EXP 255 = n DIV 2 EXP 192 DIV 2 EXP 63`] THEN
    EXPAND_TAC "ca" THEN
    CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
    DISCH_THEN(fun th ->
     MATCH_MP_TAC CONG_IMP_EQ THEN EXISTS_TAC `2 EXP 64` THEN
     CONJ_TAC THENL [MP_TAC th THEN ARITH_TAC; REWRITE_TAC[VAL_BOUND_64]]) THEN
    EXPAND_TAC "hw" THEN
    SIMP_TAC[VAL_WORD_SUBWORD_JOIN; DIMINDEX_64; ARITH_LE; ARITH_LT] THEN
    REWRITE_TAC[bignum_of_wordlist; MULT_CLAUSES; ADD_CLAUSES] THEN
    REWRITE_TAC[CONG; ADD_SYM; MULT_SYM] THEN
    CONV_TAC MOD_DOWN_CONV THEN REFL_TAC;
    ALL_TAC] THEN
  ABBREV_TAC `q:int64 = word_add hw (word 1)` THEN
  SUBGOAL_THEN `&(val(q:int64)):real = &(val(hw:int64)) + &1` ASSUME_TAC THENL
   [REWRITE_TAC[REAL_OF_NUM_CLAUSES] THEN EXPAND_TAC "q" THEN
    ASM_SIMP_TAC[VAL_WORD_ADD; VAL_WORD_1; DIMINDEX_64; MOD_LT];
    ALL_TAC] THEN

  (*** The rest of the computation ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC
   [77;78;79;80;81;85;86;87;88] (77--94) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  CONV_TAC(LAND_CONV BIGNUM_EXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  CONV_TAC SYM_CONV THEN MATCH_MP_TAC MOD_UNIQ_BALANCED_REAL THEN
  MAP_EVERY EXISTS_TAC [`val(hw:int64) + 1`; `255`] THEN
  ASM_REWRITE_TAC[] THEN
  CONJ_TAC THENL [REWRITE_TAC[p_25519] THEN ARITH_TAC; ALL_TAC] THEN
  CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN

  (*** Comparison computation and then the rest is easy ***)

  SUBGOAL_THEN `ca < (val(hw:int64) + 1) * p_25519 <=> ~carry_s81`
  SUBST1_TAC THENL
   [CONV_TAC SYM_CONV THEN MATCH_MP_TAC FLAG_FROM_CARRY_LT THEN
    EXISTS_TAC `256` THEN ASM_REWRITE_TAC[] THEN EXPAND_TAC "t" THEN
    REWRITE_TAC[p_25519; bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
    REWRITE_TAC[REAL_BITVAL_NOT] THEN CONV_TAC NUM_REDUCE_CONV THEN
    ACCUMULATOR_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN
    ASM_REWRITE_TAC[] THEN BOUNDER_TAC[];
    REWRITE_TAC[REAL_BITVAL_NOT] THEN EXPAND_TAC "t" THEN
    REWRITE_TAC[p_25519; bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
    CONV_TAC NUM_REDUCE_CONV THEN
    RULE_ASSUM_TAC(REWRITE_RULE[WORD_UNMASK_64]) THEN
    REWRITE_TAC[SYM(NUM_REDUCE_CONV `2 EXP 63 - 1`)] THEN
    REWRITE_TAC[VAL_WORD_AND_MASK_WORD] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; REAL_OF_NUM_MOD] THEN
    ACCUMULATOR_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN
    ASM_CASES_TAC `carry_s81:bool` THEN
    ASM_REWRITE_TAC[BITVAL_CLAUSES] THEN CONV_TAC WORD_REDUCE_CONV THEN
    REAL_INTEGER_TAC]);;

(* ------------------------------------------------------------------------- *)
(* Instances of sqr_p25519 (actually there is only one).                     *)
(* ------------------------------------------------------------------------- *)

 let LOCAL_SQR_P25519_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 75 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1.
      !n. read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) t = n
      ==>
        nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 4)
        ==> ensures x86
             (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                  read RIP s = pcin /\
                  read RSP s = read RSP t /\
                  read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) s = n)
             (\s. read RIP s = pcout /\
                  read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s = (n EXP 2) MOD p_25519)
          (MAYCHANGE [RIP; RAX; RBX; RCX; RDX;
                      R8; R9; R10; R11; R12; R13; R14; R15] ,,
           MAYCHANGE [memory :> bytes(word_add (read p3 t) (word n3),8 * 4)] ,,
           MAYCHANGE SOME_FLAGS)`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN

  (*** The initial squaring block, very similar to bignum_sqr_4_8 ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (1--41) (1--41) THEN
  MAP_EVERY ABBREV_TAC
   [`l = bignum_of_wordlist[mullo_s2; sum_s23; sum_s27; sum_s29]`;
    `h = bignum_of_wordlist[sum_s33; sum_s35; sum_s39; sum_s41]`] THEN
  SUBGOAL_THEN `2 EXP 256 * h + l = n EXP 2` (SUBST1_TAC o SYM) THENL
   [MAP_EVERY EXPAND_TAC ["h"; "l"; "n"] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; bignum_of_wordlist] THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  (*** The initial modular reduction of the high part ***)

  SUBGOAL_THEN
    `(2 EXP 256 * h + l) MOD p_25519 = (38 * h + l) MOD p_25519`
  SUBST1_TAC THENL
   [ONCE_REWRITE_TAC[GSYM MOD_ADD_MOD] THEN
    ONCE_REWRITE_TAC[GSYM MOD_MULT_LMOD] THEN
    REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV;
    ALL_TAC] THEN

  (*** Instantiate the quotient approximation lemma ***)

  MP_TAC(SPEC `38 * h + l` p25519redlemma) THEN ANTS_TAC THENL
   [MAP_EVERY EXPAND_TAC ["h"; "l"] THEN REWRITE_TAC[p_25519] THEN
    CONV_TAC NUM_REDUCE_CONV THEN BOUNDER_TAC[];
    CONV_TAC(TOP_DEPTH_CONV let_CONV) THEN STRIP_TAC] THEN

  (*** Reduction from 8 digits to 5 digits ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (42--56) (42--56) THEN
  ABBREV_TAC
   `ca = bignum_of_wordlist[sum_s45; sum_s48; sum_s51; sum_s54; sum_s56]` THEN
  SUBGOAL_THEN `(38 * h + l) DIV 2 EXP 255 + 1 <= 78`
  ASSUME_TAC THENL
   [REWRITE_TAC[ARITH_RULE `a + 1 <= b <=> a < b`] THEN
    SIMP_TAC[RDIV_LT_EQ; EXP_EQ_0; ARITH_EQ] THEN CONV_TAC NUM_REDUCE_CONV THEN
    MAP_EVERY EXPAND_TAC ["h"; "l"] THEN BOUNDER_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `38 * h + l = ca` SUBST_ALL_TAC THENL
   [MAP_EVERY EXPAND_TAC ["h"; "l"; "ca"] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; bignum_of_wordlist] THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  (*** Quotient estimate computation ***)

  X86_STEPS_TAC CURVE25519_X25519_EXEC (57--61) THEN
  ABBREV_TAC `t = bignum_of_wordlist
   [sum_s45; sum_s48; sum_s51; word_or sum_s54 (word 9223372036854775808)]` THEN
  SUBGOAL_THEN `&ca = &t + &2 pow 255 * (&(ca DIV 2 EXP 255) - &1)`
  ASSUME_TAC THENL
   [REWRITE_TAC[REAL_ARITH
     `c = t + e * (d - &1):real <=> c + e = t + e * d`] THEN
    REWRITE_TAC[REAL_OF_NUM_CLAUSES; ARITH_RULE
    `c + d = t + 2 EXP 255 * c DIV 2 EXP 255 <=> c MOD 2 EXP 255 + d = t`] THEN
    MAP_EVERY EXPAND_TAC ["ca"; "t"] THEN
    REWRITE_TAC[BIGNUM_OF_WORDLIST_SPLIT_RULE(4,1)] THEN
    REWRITE_TAC[MOD_MULT_ADD; ARITH_RULE
     `2 EXP 256 * n = 2 EXP 255 * 2 * n`] THEN
    REWRITE_TAC[MOD_MULT_MOD; ARITH_RULE
     `2 EXP 255 = 2 EXP 192 * 2 EXP 63`] THEN
    REWRITE_TAC[BIGNUM_OF_WORDLIST_SPLIT_RULE(3,1)] THEN
    SIMP_TAC[MOD_MULT_ADD; DIV_MULT_ADD; EXP_EQ_0; ARITH_EQ] THEN
    SUBGOAL_THEN `bignum_of_wordlist [sum_s45; sum_s48; sum_s51] < 2 EXP 192`
    (fun th -> SIMP_TAC[th; MOD_LT; DIV_LT]) THENL
     [BOUNDER_TAC[]; ALL_TAC] THEN
    REWRITE_TAC[ADD_CLAUSES; ARITH_RULE
     `(e * x + a) + e * y:num = a + e * z <=> e * (x + y) = e * z`] THEN
    AP_TERM_TAC THEN REWRITE_TAC[BIGNUM_OF_WORDLIST_SING] THEN
    REWRITE_TAC[GSYM VAL_WORD_AND_MASK_WORD] THEN
    ONCE_REWRITE_TAC[WORD_BITWISE_RULE
     `word_or x m = word_or (word_and x (word_not m)) m`] THEN
    SIMP_TAC[VAL_WORD_OR_DISJOINT; WORD_BITWISE_RULE
     `word_and (word_and x (word_not m)) m = word 0`] THEN
    CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV);
    ALL_TAC] THEN
  ABBREV_TAC `hw:int64 = word_subword
    ((word_join:int64->int64->int128) sum_s56 sum_s54) (63,64)` THEN
  SUBGOAL_THEN `ca DIV 2 EXP 255 = val(hw:int64)` SUBST_ALL_TAC THENL
   [UNDISCH_TAC `ca DIV 2 EXP 255 + 1 <= 78` THEN REWRITE_TAC[ARITH_RULE
     `n DIV 2 EXP 255 = n DIV 2 EXP 192 DIV 2 EXP 63`] THEN
    EXPAND_TAC "ca" THEN
    CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
    DISCH_THEN(fun th ->
     MATCH_MP_TAC CONG_IMP_EQ THEN EXISTS_TAC `2 EXP 64` THEN
     CONJ_TAC THENL [MP_TAC th THEN ARITH_TAC; REWRITE_TAC[VAL_BOUND_64]]) THEN
    EXPAND_TAC "hw" THEN
    SIMP_TAC[VAL_WORD_SUBWORD_JOIN; DIMINDEX_64; ARITH_LE; ARITH_LT] THEN
    REWRITE_TAC[bignum_of_wordlist; MULT_CLAUSES; ADD_CLAUSES] THEN
    REWRITE_TAC[CONG; ADD_SYM; MULT_SYM] THEN
    CONV_TAC MOD_DOWN_CONV THEN REFL_TAC;
    ALL_TAC] THEN

  REABBREV_TAC `qm = read RAX s61` THEN
  SUBGOAL_THEN `&(val(qm:int64)):real = &19 * (&(val(hw:int64)) + &1)`
  ASSUME_TAC THENL
   [EXPAND_TAC "qm" THEN
    REWRITE_TAC[VAL_WORD_ADD; VAL_WORD_MUL; DIMINDEX_64] THEN
    REWRITE_TAC[ REAL_OF_NUM_CLAUSES] THEN CONV_TAC MOD_DOWN_CONV THEN
    CONV_TAC WORD_REDUCE_CONV THEN REWRITE_TAC[MULT_SYM] THEN
    MATCH_MP_TAC MOD_LT THEN
    UNDISCH_TAC `val(hw:int64) + 1 <= 78` THEN ARITH_TAC;
    ALL_TAC] THEN

  (*** The rest of the computation ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC
   [62;63;64;65;67;68;69;70] (62--75) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  CONV_TAC(LAND_CONV BIGNUM_EXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  CONV_TAC SYM_CONV THEN MATCH_MP_TAC MOD_UNIQ_BALANCED_REAL THEN
  MAP_EVERY EXISTS_TAC [`val(hw:int64) + 1`; `255`] THEN
  ASM_REWRITE_TAC[] THEN
  CONJ_TAC THENL [REWRITE_TAC[p_25519] THEN ARITH_TAC; ALL_TAC] THEN
  CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN

  (*** Comparison computation and then the rest is easy ***)

  SUBGOAL_THEN `ca < (val(hw:int64) + 1) * p_25519 <=> ~carry_s65`
  SUBST1_TAC THENL
   [CONV_TAC SYM_CONV THEN MATCH_MP_TAC FLAG_FROM_CARRY_LT THEN
    EXISTS_TAC `256` THEN ASM_REWRITE_TAC[] THEN EXPAND_TAC "t" THEN
    REWRITE_TAC[p_25519; bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
    REWRITE_TAC[REAL_BITVAL_NOT] THEN CONV_TAC NUM_REDUCE_CONV THEN
    ACCUMULATOR_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN
    ASM_REWRITE_TAC[] THEN BOUNDER_TAC[];
    REWRITE_TAC[REAL_BITVAL_NOT] THEN EXPAND_TAC "t" THEN
    REWRITE_TAC[p_25519; bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
    CONV_TAC NUM_REDUCE_CONV THEN
    RULE_ASSUM_TAC(REWRITE_RULE[WORD_UNMASK_64]) THEN
    REWRITE_TAC[SYM(NUM_REDUCE_CONV `2 EXP 63 - 1`)] THEN
    REWRITE_TAC[VAL_WORD_AND_MASK_WORD] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; REAL_OF_NUM_MOD] THEN
    ACCUMULATOR_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN
    ASM_CASES_TAC `carry_s65:bool` THEN
    ASM_REWRITE_TAC[BITVAL_CLAUSES] THEN CONV_TAC WORD_REDUCE_CONV THEN
    REAL_INTEGER_TAC]);;

(* ------------------------------------------------------------------------- *)
(* Instance of mul_5                                                         *)
(* ------------------------------------------------------------------------- *)

let LOCAL_MUL_5_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 75 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1 p2 n2.
      !m. read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) t = m
      ==>
      !n. read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) t = n
      ==>
      nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 5)
      ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                read RIP s = pcin /\
                read RSP s = read RSP t /\
                read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) s = m /\
                read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) s = n)
           (\s. read RIP s = pcout /\
                read(memory :> bytes(word_add (read p3 t) (word n3),8 * 5)) s
                < 39 * 2 EXP 256 /\
                (read(memory :> bytes(word_add (read p3 t) (word n3),8 * 5)) s ==
                 m * n) (mod p_25519))
        (MAYCHANGE [RIP; RAX; RBX; RDX; RDI; R8; R9; R10; R11; R12; R13; R14; R15] ,,
         MAYCHANGE [memory :> bytes(word_add (read p3 t) (word n3),8 * 5)] ,,
         MAYCHANGE SOME_FLAGS)`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "m_" o lhand o concl) THEN

  (*** The initial multiply block, very similar to bignum_mul_4_8_alt ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (1--55) (1--55) THEN
  MAP_EVERY ABBREV_TAC
   [`l = bignum_of_wordlist[mullo_s3; sum_s14; sum_s29; sum_s44]`;
    `h = bignum_of_wordlist[sum_s47; sum_s50; sum_s53; sum_s55]`] THEN
  SUBGOAL_THEN `m * n < 2 EXP 512` ASSUME_TAC THENL
   [MAP_EVERY EXPAND_TAC ["m"; "n"] THEN CONV_TAC NUM_REDUCE_CONV THEN
    BOUNDER_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `2 EXP 256 * h + l = m * n` (SUBST_ALL_TAC o SYM) THENL
   [MAP_EVERY EXPAND_TAC ["h"; "l"; "m"; "n"] THEN
    REWRITE_TAC[bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN
  FIRST_X_ASSUM(MP_TAC o MATCH_MP (ARITH_RULE
   `2 EXP 256 * h + l < 2 EXP 512
    ==> l < 2 EXP 256 ==> 38 * h + l < 39 * 2 EXP 256`)) THEN
  ANTS_TAC THENL [EXPAND_TAC "l" THEN BOUNDER_TAC[]; DISCH_TAC] THEN

  (*** Reduction from 8 digits to 5 digits ***)

  REWRITE_TAC[CONG] THEN
  SUBGOAL_THEN
    `(2 EXP 256 * h + l) MOD p_25519 = (38 * h + l) MOD p_25519`
  SUBST1_TAC THENL
   [ONCE_REWRITE_TAC[GSYM MOD_ADD_MOD] THEN
    ONCE_REWRITE_TAC[GSYM MOD_MULT_LMOD] THEN
    REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV;
    ALL_TAC] THEN
  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (56--70) (56--75) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN

  MATCH_MP_TAC(MESON[]`x = y /\ y < n ==> x < n /\ x MOD p = y MOD p`) THEN
  ASM_REWRITE_TAC[] THEN
  RULE_ASSUM_TAC(REWRITE_RULE[COND_SWAP; GSYM WORD_BITVAL]) THEN
  CONV_TAC(LAND_CONV BIGNUM_EXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
    MAP_EVERY EXPAND_TAC ["h"; "l"] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; bignum_of_wordlist] THEN
  ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC);;

(* ------------------------------------------------------------------------- *)
(* Instances of sqr_4.                                                       *)
(* ------------------------------------------------------------------------- *)

let LOCAL_SQR_4_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 68 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1.
      !n.
      read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) t = n
      ==>
      nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 4)
      ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                read RIP s = pcin /\
                read RSP s = read RSP t /\
                read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) s = n)
           (\s. read RIP s = pcout /\
                read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s
                < 2 * p_25519 /\
                (read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s ==
                 n EXP 2)
                (mod p_25519))
        (MAYCHANGE [RIP; RAX; RBX; RCX; RDX;
                    R8; R9; R10; R11; R12; R13; R14; R15] ,,
         MAYCHANGE
          [memory :> bytes(word_add (read p3 t) (word n3),8 * 4)] ,,
         MAYCHANGE SOME_FLAGS)`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN

  (*** The initial squaring block, very similar to bignum_sqr_4_8 ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (1--41) (1--41) THEN
  MAP_EVERY ABBREV_TAC
   [`l = bignum_of_wordlist[mullo_s2; sum_s23; sum_s27; sum_s29]`;
    `h = bignum_of_wordlist[sum_s33; sum_s35; sum_s39; sum_s41]`] THEN
  SUBGOAL_THEN `2 EXP 256 * h + l = n EXP 2` (SUBST1_TAC o SYM) THENL
   [MAP_EVERY EXPAND_TAC ["h"; "l"; "n"] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; bignum_of_wordlist] THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  (*** The initial modular reduction of the high part ***)

  REWRITE_TAC[CONG] THEN
  SUBGOAL_THEN
    `(2 EXP 256 * h + l) MOD p_25519 = (38 * h + l) MOD p_25519`
  SUBST1_TAC THENL
   [ONCE_REWRITE_TAC[GSYM MOD_ADD_MOD] THEN
    ONCE_REWRITE_TAC[GSYM MOD_MULT_LMOD] THEN
    REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV;
    ALL_TAC] THEN

  (*** Instantiate the quotient approximation lemma ***)

  MP_TAC(SPEC `38 * h + l` p25519redlemma) THEN ANTS_TAC THENL
   [MAP_EVERY EXPAND_TAC ["h"; "l"] THEN REWRITE_TAC[p_25519] THEN
    CONV_TAC NUM_REDUCE_CONV THEN BOUNDER_TAC[];
    CONV_TAC(TOP_DEPTH_CONV let_CONV) THEN STRIP_TAC] THEN

  (*** Reduction from 8 digits to 5 digits ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (42--56) (42--56) THEN
  ABBREV_TAC
   `ca = bignum_of_wordlist[sum_s45; sum_s48; sum_s51; sum_s54; sum_s56]` THEN
  SUBGOAL_THEN `(38 * h + l) DIV 2 EXP 255 + 1 <= 78`
  ASSUME_TAC THENL
   [REWRITE_TAC[ARITH_RULE `a + 1 <= b <=> a < b`] THEN
    SIMP_TAC[RDIV_LT_EQ; EXP_EQ_0; ARITH_EQ] THEN CONV_TAC NUM_REDUCE_CONV THEN
    MAP_EVERY EXPAND_TAC ["h"; "l"] THEN BOUNDER_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `38 * h + l = ca` SUBST_ALL_TAC THENL
   [MAP_EVERY EXPAND_TAC ["h"; "l"; "ca"] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; bignum_of_wordlist] THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  (*** Quotient estimate computation ***)

  X86_STEPS_TAC CURVE25519_X25519_EXEC (57--60) THEN
  ABBREV_TAC `hw:int64 = word_subword
    ((word_join:int64->int64->int128) sum_s56 sum_s54) (63,64)` THEN
  SUBGOAL_THEN `ca DIV 2 EXP 255 = val(hw:int64)`
   (fun th -> SUBST_ALL_TAC th THEN ASSUME_TAC th) THENL
   [UNDISCH_TAC `ca DIV 2 EXP 255 + 1 <= 78` THEN REWRITE_TAC[ARITH_RULE
     `n DIV 2 EXP 255 = n DIV 2 EXP 192 DIV 2 EXP 63`] THEN
    EXPAND_TAC "ca" THEN
    CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
    DISCH_THEN(fun th ->
     MATCH_MP_TAC CONG_IMP_EQ THEN EXISTS_TAC `2 EXP 64` THEN
     CONJ_TAC THENL [MP_TAC th THEN ARITH_TAC; REWRITE_TAC[VAL_BOUND_64]]) THEN
    EXPAND_TAC "hw" THEN
    SIMP_TAC[VAL_WORD_SUBWORD_JOIN; DIMINDEX_64; ARITH_LE; ARITH_LT] THEN
    REWRITE_TAC[bignum_of_wordlist; MULT_CLAUSES; ADD_CLAUSES] THEN
    REWRITE_TAC[CONG; ADD_SYM; MULT_SYM] THEN
    CONV_TAC MOD_DOWN_CONV THEN REFL_TAC;
    ALL_TAC] THEN

  ABBREV_TAC `qm:int64 = word_mul (word 19:int64) hw` THEN
  SUBGOAL_THEN `&(val(qm:int64)):real = &19 * &(val(hw:int64))`
  ASSUME_TAC THENL
   [EXPAND_TAC "qm" THEN
    REWRITE_TAC[VAL_WORD_MUL; DIMINDEX_64; REAL_OF_NUM_CLAUSES] THEN
    CONV_TAC WORD_REDUCE_CONV THEN MATCH_MP_TAC MOD_LT THEN
    UNDISCH_TAC `val(hw:int64) + 1 <= 78` THEN
    ASM_REWRITE_TAC[] THEN ARITH_TAC;
    ALL_TAC] THEN

  (*** The rest of the computation ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (61--64) (61--68) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[GSYM CONG; num_congruent] THEN
  REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES] THEN
  MATCH_MP_TAC(MESON[]
   `!q. (ca - q * p == ca) (mod p) /\ ca - q * p < p2 /\ x = ca - q * p
    ==> x:int < p2 /\ (x == ca) (mod p)`) THEN
  EXISTS_TAC `&(val(hw:int64)):int` THEN
  CONJ_TAC THENL [CONV_TAC INTEGER_RULE; ALL_TAC] THEN
  MATCH_MP_TAC(TAUT `p /\ (p ==> q) ==> p /\ q`) THEN CONJ_TAC THENL
   [REWRITE_TAC[INT_ARITH `x - y:int < z <=> x < y + z`] THEN
    REWRITE_TAC[INT_ARITH `h * p + &2 * p:int = (h + &1) * p + p`] THEN
    ASM_REWRITE_TAC[INT_OF_NUM_CLAUSES];
    DISCH_TAC] THEN
  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC INT_CONG_IMP_EQ THEN EXISTS_TAC `(&2:int) pow 256` THEN
  CONJ_TAC THENL
   [FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (INT_ARITH
     `y:int < p ==> &0 <= y /\ &0 <= p /\ p < e /\ &0 <= x /\ x < e
         ==> abs(x - y) < e`)) THEN
    ASM_REWRITE_TAC[INT_SUB_LE; INT_OF_NUM_CLAUSES; LE_0] THEN
    ONCE_REWRITE_TAC[ARITH_RULE
     `h * p <= ca <=> (h + 1) * p <= ca + p`] THEN
    ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
    BOUNDER_TAC[];
    ALL_TAC] THEN
  REWRITE_TAC[INTEGER_RULE
   `(x:int == y - z) (mod p) <=> (x + z == y) (mod p)`] THEN
  REWRITE_TAC[INT_OF_NUM_CLAUSES; GSYM num_congruent] THEN
  REWRITE_TAC[REAL_CONGRUENCE; p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
  EXPAND_TAC "ca" THEN
  REWRITE_TAC[p_25519; bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
  ACCUMULATOR_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[SYM(NUM_REDUCE_CONV `2 EXP 63 - 1`)] THEN
  REWRITE_TAC[VAL_WORD_AND_MASK_WORD] THEN
  UNDISCH_THEN `ca DIV 2 EXP 255 = val(hw:int64)` (SUBST1_TAC o SYM) THEN
  EXPAND_TAC "ca" THEN
  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
  REWRITE_TAC[bignum_of_wordlist; ARITH_RULE
   `(l + 2 EXP 64 * h) DIV 2 EXP 63 = l DIV 2 EXP 63 + 2 * h`] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; REAL_OF_NUM_DIV] THEN
  REAL_INTEGER_TAC);;

(* ------------------------------------------------------------------------- *)
(* Instances of add_4.                                                       *)
(* ------------------------------------------------------------------------- *)

let LOCAL_ADD_4_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 12 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1 p2 n2.
      !m. read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) t = m
      ==>
      !n. read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) t = n
      ==>
      nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 4)
      ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                read RIP s = pcin /\
                read RSP s = read RSP t /\
                read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) s = m /\
                read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) s = n)
           (\s. read RIP s = pcout /\
                (m < p_25519 /\ n < p_25519
                 ==> read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s =
                     m + n))
        (MAYCHANGE [RIP; RAX] ,,
         MAYCHANGE [memory :> bytes(word_add (read p3 t) (word n3),8 * 4)] ,,
         MAYCHANGE SOME_FLAGS)`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "m_" o lhand o concl) THEN
  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC [2;5;8;11] (1--12) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN DISCH_TAC THEN
  CONV_TAC(LAND_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC CONG_IMP_EQ THEN EXISTS_TAC `2 EXP 256` THEN
  REPEAT CONJ_TAC THENL
   [BOUNDER_TAC[];
    FIRST_X_ASSUM(CONJUNCTS_THEN MP_TAC) THEN
    REWRITE_TAC[p_25519] THEN ARITH_TAC;
    REWRITE_TAC[REAL_CONGRUENCE] THEN CONV_TAC NUM_REDUCE_CONV] THEN
  MAP_EVERY EXPAND_TAC ["m"; "n"] THEN
  REWRITE_TAC[bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
  ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC);;

(* ------------------------------------------------------------------------- *)
(* Instances of add5_4 (actually there is only one).                         *)
(* ------------------------------------------------------------------------- *)

let LOCAL_ADD5_4_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 23 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1 p2 n2.
      !m. read(memory :> bytes(word_add (read p1 t) (word n1),8 * 5)) t = m
      ==>
      !n. read(memory :> bytes(word_add (read p2 t) (word n2),8 * 5)) t = n
      ==>
      nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 4)
      ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                read RIP s = pcin /\
                read RSP s = read RSP t /\
                read(memory :> bytes(word_add (read p1 t) (word n1),8 * 5)) s = m /\
                read(memory :> bytes(word_add (read p2 t) (word n2),8 * 5)) s = n)
           (\s. read RIP s = pcout /\
                (m + n < 2 EXP 58 * 2 EXP 256
                 ==> read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s
                     < 2 * p_25519 /\
                     (bignum_from_memory
                       (word_add (read p3 t) (word n3),4) s ==
                      m + n) (mod p_25519)))
        (MAYCHANGE [RIP; RBX; RDX; R8; R9; R10; R11; R12] ,,
         MAYCHANGE [memory :> bytes(word_add (read p3 t) (word n3),8 * 4)] ,,
         MAYCHANGE SOME_FLAGS)`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  ASM_CASES_TAC `m + n < 2 EXP 58 * 2 EXP 256` THENL
   [ASM_REWRITE_TAC[]; X86_SIM_TAC CURVE25519_X25519_EXEC (1--23)] THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "m_" o lhand o concl) THEN

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC [2;4;6;8;10] (1--10) THEN
  ABBREV_TAC
   `ca = bignum_of_wordlist[sum_s2; sum_s4; sum_s6; sum_s8; sum_s10]` THEN
  SUBGOAL_THEN `m + n = ca` SUBST_ALL_TAC THENL
   [EXPAND_TAC "ca" THEN MATCH_MP_TAC CONG_IMP_EQ THEN
    EXISTS_TAC `2 EXP 320` THEN REPEAT CONJ_TAC THENL
     [UNDISCH_TAC `m + n < 2 EXP 58 * 2 EXP 256` THEN ARITH_TAC;
      BOUNDER_TAC[];
      REWRITE_TAC[REAL_CONGRUENCE] THEN CONV_TAC NUM_REDUCE_CONV] THEN
    MAP_EVERY EXPAND_TAC ["m"; "n"] THEN
    REWRITE_TAC[bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  (*** Instantiate the quotient approximation lemma ***)

  MP_TAC(SPEC `ca:num` p25519weakredlemma) THEN ANTS_TAC THENL
   [UNDISCH_TAC `ca < 2 EXP 58 * 2 EXP 256` THEN ARITH_TAC;
    CONV_TAC(TOP_DEPTH_CONV let_CONV) THEN STRIP_TAC] THEN

  (*** Quotient estimate computation ***)

  X86_STEPS_TAC CURVE25519_X25519_EXEC (11--15) THEN
  ABBREV_TAC `hw:int64 = word_subword
    ((word_join:int64->int64->int128) sum_s10 sum_s8) (63,64)` THEN
  SUBGOAL_THEN `ca DIV 2 EXP 255 = val(hw:int64)`
   (fun th -> SUBST_ALL_TAC th THEN ASSUME_TAC th) THENL
   [FIRST_ASSUM(MP_TAC o MATCH_MP (ARITH_RULE
     `ca < 2 EXP 58 * 2 EXP 256
      ==> ca DIV 2 EXP 192 DIV 2 EXP 63 < 2 EXP 59`)) THEN
    EXPAND_TAC "ca" THEN
    CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
    DISCH_THEN(fun th ->
     MATCH_MP_TAC CONG_IMP_EQ THEN EXISTS_TAC `2 EXP 64` THEN
     CONJ_TAC THENL [MP_TAC th THEN ARITH_TAC; REWRITE_TAC[VAL_BOUND_64]]) THEN
    EXPAND_TAC "hw" THEN
    SIMP_TAC[VAL_WORD_SUBWORD_JOIN; DIMINDEX_64; ARITH_LE; ARITH_LT] THEN
    REWRITE_TAC[bignum_of_wordlist; MULT_CLAUSES; ADD_CLAUSES] THEN
    REWRITE_TAC[CONG; ADD_SYM; MULT_SYM] THEN
    CONV_TAC MOD_DOWN_CONV THEN REFL_TAC;
    ALL_TAC] THEN

  ABBREV_TAC `qm:int64 = word_mul (word 19:int64) hw` THEN
  SUBGOAL_THEN `&(val(qm:int64)):real = &19 * &(val(hw:int64))`
  ASSUME_TAC THENL
   [EXPAND_TAC "qm" THEN
    REWRITE_TAC[VAL_WORD_MUL; DIMINDEX_64; REAL_OF_NUM_CLAUSES] THEN
    CONV_TAC WORD_REDUCE_CONV THEN
    MATCH_MP_TAC MOD_LT THEN MAP_EVERY UNDISCH_TAC
     [`val(hw:int64) * p_25519 <= ca`;
      `ca < 2 EXP 58 * 2 EXP 256`] THEN
    REWRITE_TAC[p_25519] THEN ARITH_TAC;
    ALL_TAC] THEN

  (*** The rest of the computation ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (16--19) (16--23) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[GSYM CONG; num_congruent] THEN
  REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES] THEN
  MATCH_MP_TAC(MESON[]
   `!q. (ca - q * p == ca) (mod p) /\ ca - q * p < p2 /\ x = ca - q * p
    ==> x:int < p2 /\ (x == ca) (mod p)`) THEN
  EXISTS_TAC `&(val(hw:int64)):int` THEN
  CONJ_TAC THENL [CONV_TAC INTEGER_RULE; ALL_TAC] THEN
  MATCH_MP_TAC(TAUT `p /\ (p ==> q) ==> p /\ q`) THEN CONJ_TAC THENL
   [REWRITE_TAC[INT_ARITH `x - y:int < z <=> x < y + z`] THEN
    ASM_REWRITE_TAC[INT_OF_NUM_CLAUSES];
    DISCH_TAC] THEN
  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC INT_CONG_IMP_EQ THEN EXISTS_TAC `(&2:int) pow 256` THEN
  CONJ_TAC THENL
   [FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (INT_ARITH
     `y:int < p ==> &0 <= y /\ &0 <= p /\ p < e /\ &0 <= x /\ x < e
         ==> abs(x - y) < e`)) THEN
    ASM_REWRITE_TAC[INT_SUB_LE; INT_OF_NUM_CLAUSES; LE_0] THEN
    ONCE_REWRITE_TAC[ARITH_RULE
     `h * p <= ca <=> (h + 1) * p <= ca + p`] THEN
    ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
    BOUNDER_TAC[];
    ALL_TAC] THEN
  REWRITE_TAC[INTEGER_RULE
   `(x:int == y - z) (mod p) <=> (x + z == y) (mod p)`] THEN
  REWRITE_TAC[INT_OF_NUM_CLAUSES; GSYM num_congruent] THEN
  REWRITE_TAC[REAL_CONGRUENCE; p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
  EXPAND_TAC "ca" THEN
  REWRITE_TAC[p_25519; bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
  ACCUMULATOR_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[SYM(NUM_REDUCE_CONV `2 EXP 63 - 1`)] THEN
  REWRITE_TAC[VAL_WORD_AND_MASK_WORD] THEN
  UNDISCH_THEN `ca DIV 2 EXP 255 = val(hw:int64)` (SUBST1_TAC o SYM) THEN
  EXPAND_TAC "ca" THEN
  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
  REWRITE_TAC[bignum_of_wordlist; ARITH_RULE
   `(l + 2 EXP 64 * h) DIV 2 EXP 63 = l DIV 2 EXP 63 + 2 * h`] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; REAL_OF_NUM_DIV] THEN
  REAL_INTEGER_TAC);;

(* ------------------------------------------------------------------------- *)
(* Instances of sub_4.                                                       *)
(* ------------------------------------------------------------------------- *)

let LOCAL_SUB_4_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 17 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1 p2 n2.
      !m. read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) t = m
      ==>
      !n. read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) t = n
      ==>
      nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 4)
      ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                read RIP s = pcin /\
                read RSP s = read RSP t /\
                read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) s = m /\
                read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) s = n)
           (\s. read RIP s = pcout /\
                (m < p_25519 /\ n < p_25519
                 ==> read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s
                     < 2 * p_25519 /\
                     (&(bignum_from_memory
                         (word_add (read p3 t) (word n3),4) s):int ==
                      &m - &n) (mod (&p_25519))))
        (MAYCHANGE [RIP; RAX; R8; R9; R10] ,,
         MAYCHANGE [memory :> bytes(word_add (read p3 t) (word n3),8 * 4)] ,,
         MAYCHANGE SOME_FLAGS)`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "m_" o lhand o concl) THEN
  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC
   [2;4;6;8;9;11;13;15] (1--17) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN DISCH_TAC THEN
  MATCH_MP_TAC(MESON[INT_OF_NUM_LT]
   `!x':int. (x' == a) (mod p) /\ x' < &e /\ &x = x'
             ==> x < e /\ (&x:int == a) (mod p)`) THEN
  EXISTS_TAC `(&m - &n) + &p_25519:int` THEN REPEAT CONJ_TAC THENL
   [CONV_TAC INTEGER_RULE;
    FIRST_X_ASSUM(CONJUNCTS_THEN MP_TAC) THEN
    REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES] THEN INT_ARITH_TAC;
    ALL_TAC] THEN
  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC INT_CONG_IMP_EQ THEN EXISTS_TAC `(&2:int) pow 256` THEN
  CONJ_TAC THENL
   [MATCH_MP_TAC(INT_ARITH
     `&0 <= x /\ x:int < e /\ &0 <= y /\ y < e ==> abs(x - y) < e`) THEN
    REWRITE_TAC[INT_OF_NUM_CLAUSES; LE_0] THEN
    CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN
    FIRST_X_ASSUM(CONJUNCTS_THEN MP_TAC) THEN
    REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES; p_25519] THEN
    CONV_TAC NUM_REDUCE_CONV THEN INT_ARITH_TAC;
    REWRITE_TAC[INTEGER_RULE
     `(x:int == m - n + c) (mod e) <=> (n + x == m + c) (mod e)`] THEN
    REWRITE_TAC[INT_OF_NUM_CLAUSES; GSYM num_congruent] THEN
    REWRITE_TAC[REAL_CONGRUENCE] THEN CONV_TAC NUM_REDUCE_CONV] THEN
  MAP_EVERY EXPAND_TAC ["m"; "n"] THEN
  REWRITE_TAC[bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES; p_25519] THEN
  REWRITE_TAC[REAL_VAL_WORD_XOR] THEN
  REWRITE_TAC[SYM(NUM_REDUCE_CONV `2 EXP 63`); VAL_WORD_AND_POW2] THEN
  CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV) THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES] THEN
  ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC);;

(* ------------------------------------------------------------------------- *)
(* Instances of sub_twice4 (actually there is only one).                     *)
(* ------------------------------------------------------------------------- *)

let LOCAL_SUB_TWICE4_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 19 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1 p2 n2.
      !m. read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) t = m
      ==>
      !n. read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) t = n
      ==>
      nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 4)
      ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                read RIP s = pcin /\
                read RSP s = read RSP t /\
                read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) s = m /\
                read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) s = n)
           (\s. read RIP s = pcout /\
                (m < 2 * p_25519 /\ n < 2 * p_25519
                 ==> read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s
                     < 2 * p_25519 /\
                     (&(bignum_from_memory
                         (word_add (read p3 t) (word n3),4) s):int ==
                      &m - &n) (mod (&p_25519))))
        (MAYCHANGE [RIP; RAX; RBX; RCX; R8; R9; R10] ,,
         MAYCHANGE [memory :> bytes(word_add (read p3 t) (word n3),8 * 4)] ,,
         MAYCHANGE SOME_FLAGS)`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "m_" o lhand o concl) THEN
  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (1--10) (1--10) THEN
  SUBGOAL_THEN `carry_s10 <=> m < n` SUBST_ALL_TAC THENL
   [MATCH_MP_TAC FLAG_FROM_CARRY_LT THEN EXISTS_TAC `256` THEN
    MAP_EVERY EXPAND_TAC ["m"; "n"] THEN REWRITE_TAC[GSYM REAL_OF_NUM_ADD] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_MUL; GSYM REAL_OF_NUM_POW] THEN
    ACCUMULATOR_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN BOUNDER_TAC[];
    ALL_TAC] THEN
  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (12--15) (11--19) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN DISCH_TAC THEN
  MATCH_MP_TAC(MESON[INT_OF_NUM_LT]
   `!x':int. (x' == a) (mod p) /\ x' < &e /\ &x = x'
             ==> x < e /\ (&x:int == a) (mod p)`) THEN
  EXISTS_TAC `if m < n then &m - &n + &2 * &p_25519:int else &m - &n` THEN
  REPEAT CONJ_TAC THENL
   [COND_CASES_TAC THEN CONV_TAC INTEGER_RULE;
    FIRST_X_ASSUM(CONJUNCTS_THEN MP_TAC) THEN
    REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES] THEN INT_ARITH_TAC;
    ALL_TAC] THEN
  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  ONCE_REWRITE_TAC[int_eq] THEN ONCE_REWRITE_TAC[COND_RAND] THEN
  REWRITE_TAC[int_of_num_th; int_sub_th; int_add_th; int_mul_th] THEN
  MATCH_MP_TAC EQUAL_FROM_CONGRUENT_REAL THEN
  MAP_EVERY EXISTS_TAC [`256`; `&0:real`] THEN
  CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN CONJ_TAC THENL
   [FIRST_X_ASSUM(CONJUNCTS_THEN MP_TAC) THEN
    REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES; p_25519] THEN
    CONV_TAC NUM_REDUCE_CONV THEN INT_ARITH_TAC;
    REWRITE_TAC[INTEGER_CLOSED]] THEN
  RULE_ASSUM_TAC(REWRITE_RULE[GSYM NOT_LT]) THEN
  ABBREV_TAC `bb <=> m:num < n` THEN MAP_EVERY EXPAND_TAC ["m"; "n"] THEN
  REWRITE_TAC[bignum_of_wordlist; p_25519; GSYM REAL_OF_NUM_CLAUSES] THEN
  CONV_TAC NUM_REDUCE_CONV THEN
  ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
  COND_CASES_TAC THEN ASM_REWRITE_TAC[BITVAL_CLAUSES] THEN
  CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC);;

(* ------------------------------------------------------------------------- *)
(* Instances of sub5_4 (actually there is only one).                         *)
(* ------------------------------------------------------------------------- *)

let LOCAL_SUB5_4_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 29 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1 p2 n2.
      !m. read(memory :> bytes(word_add (read p1 t) (word n1),8 * 5)) t = m
      ==>
      !n. read(memory :> bytes(word_add (read p2 t) (word n2),8 * 5)) t = n
      ==>
      nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 4)
      ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                read RIP s = pcin /\
                read RSP s = read RSP t /\
                read(memory :> bytes(word_add (read p1 t) (word n1),8 * 5)) s = m /\
                read(memory :> bytes(word_add (read p2 t) (word n2),8 * 5)) s = n)
           (\s. read RIP s = pcout /\
                (m < 39 * 2 EXP 256 /\ n < 39 * 2 EXP 256
                 ==> read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s
                     < 2 * p_25519 /\
                     (&(bignum_from_memory
                       (word_add (read p3 t) (word n3),4) s):int ==
                      &m - &n) (mod (&p_25519))))
        (MAYCHANGE [RIP; RBX; RDX; R8; R9; R10; R11; R12] ,,
         MAYCHANGE [memory :> bytes(word_add (read p3 t) (word n3),8 * 4)] ,,
         MAYCHANGE SOME_FLAGS)`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  ASM_CASES_TAC `m < 39 * 2 EXP 256 /\ n < 39 * 2 EXP 256` THENL
   [ASM_REWRITE_TAC[]; X86_SIM_TAC CURVE25519_X25519_EXEC (1--29)] THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "m_" o lhand o concl) THEN
  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC
   [2;4;6;8;10;12;13;14;15;16;17] (1--17) THEN
  ABBREV_TAC
   `ca = bignum_of_wordlist[sum_s12; sum_s13; sum_s14; sum_s15; sum_s17]` THEN
  SUBGOAL_THEN `&ca:int = &m - &n + &1000 * &p_25519` ASSUME_TAC THENL
   [EXPAND_TAC "ca" THEN MATCH_MP_TAC INT_CONG_IMP_EQ THEN
    EXISTS_TAC `(&2:int) pow 320` THEN REPEAT CONJ_TAC THENL
     [MATCH_MP_TAC(INT_ARITH
       `&0 <= x /\ x:int < e /\ &0 <= y /\ y < e ==> abs(x - y) < e`) THEN
      REWRITE_TAC[INT_OF_NUM_CLAUSES; LE_0] THEN
      CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN
      MAP_EVERY UNDISCH_TAC
       [`m < 39 * 2 EXP 256`; `n < 39 * 2 EXP 256`] THEN
      REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES; p_25519] THEN
      CONV_TAC NUM_REDUCE_CONV THEN INT_ARITH_TAC;
      REWRITE_TAC[INTEGER_RULE
       `(x:int == m - n + c) (mod e) <=> (n + x == m + c) (mod e)`] THEN
      REWRITE_TAC[INT_OF_NUM_CLAUSES; GSYM num_congruent] THEN
      REWRITE_TAC[REAL_CONGRUENCE] THEN CONV_TAC NUM_REDUCE_CONV] THEN
    MAP_EVERY EXPAND_TAC ["m"; "n"] THEN
    REWRITE_TAC[bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES; p_25519] THEN
    CONV_TAC NUM_REDUCE_CONV THEN
    RULE_ASSUM_TAC(REWRITE_RULE[REAL_BITVAL_NOT]) THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  REWRITE_TAC[GSYM INT_REM_EQ] THEN
  SUBGOAL_THEN `(&m - &n) rem &p_25519 = &ca rem &p_25519` SUBST1_TAC THENL
   [ASM_REWRITE_TAC[INT_REM_MUL_ADD];
    REWRITE_TAC[INT_OF_NUM_CLAUSES; INT_OF_NUM_REM] THEN
    REWRITE_TAC[GSYM CONG]] THEN
  SUBGOAL_THEN `ca < 600 * 2 EXP 256` ASSUME_TAC THENL
   [MAP_EVERY UNDISCH_TAC
     [`m < 39 * 2 EXP 256`; `n < 39 * 2 EXP 256`] THEN
    ASM_REWRITE_TAC[p_25519; GSYM INT_OF_NUM_CLAUSES] THEN
    CONV_TAC NUM_REDUCE_CONV THEN INT_ARITH_TAC;
    ALL_TAC] THEN
  UNDISCH_THEN `&ca:int = &m - &n + &1000 * &p_25519` (K ALL_TAC) THEN

  (*** Instantiate the quotient approximation lemma ***)

  MP_TAC(SPEC `ca:num` p25519weakredlemma) THEN ANTS_TAC THENL
   [UNDISCH_TAC `ca < 600 * 2 EXP 256` THEN ARITH_TAC;
    CONV_TAC(TOP_DEPTH_CONV let_CONV) THEN STRIP_TAC] THEN

  (*** Quotient estimate computation ***)

  X86_STEPS_TAC CURVE25519_X25519_EXEC (18--21) THEN
  ABBREV_TAC `hw:int64 = word_subword
    ((word_join:int64->int64->int128) sum_s17 sum_s15) (63,64)` THEN
  SUBGOAL_THEN `ca DIV 2 EXP 255 = val(hw:int64)`
   (fun th -> SUBST_ALL_TAC th THEN ASSUME_TAC th) THENL
   [FIRST_ASSUM(MP_TAC o MATCH_MP (ARITH_RULE
     `ca < 600 * 2 EXP 256
      ==> ca DIV 2 EXP 192 DIV 2 EXP 63 < 2 EXP 59`)) THEN
    EXPAND_TAC "ca" THEN
    CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
    DISCH_THEN(fun th ->
     MATCH_MP_TAC CONG_IMP_EQ THEN EXISTS_TAC `2 EXP 64` THEN
     CONJ_TAC THENL [MP_TAC th THEN ARITH_TAC; REWRITE_TAC[VAL_BOUND_64]]) THEN
    EXPAND_TAC "hw" THEN
    SIMP_TAC[VAL_WORD_SUBWORD_JOIN; DIMINDEX_64; ARITH_LE; ARITH_LT] THEN
    REWRITE_TAC[bignum_of_wordlist; MULT_CLAUSES; ADD_CLAUSES] THEN
    REWRITE_TAC[CONG; ADD_SYM; MULT_SYM] THEN
    CONV_TAC MOD_DOWN_CONV THEN REFL_TAC;
    ALL_TAC] THEN

  ABBREV_TAC `qm:int64 = word_mul (word 19:int64) hw` THEN
  SUBGOAL_THEN `&(val(qm:int64)):real = &19 * &(val(hw:int64))`
  ASSUME_TAC THENL
   [EXPAND_TAC "qm" THEN
    REWRITE_TAC[VAL_WORD_MUL; DIMINDEX_64; REAL_OF_NUM_CLAUSES] THEN
    CONV_TAC WORD_REDUCE_CONV THEN
    MATCH_MP_TAC MOD_LT THEN MAP_EVERY UNDISCH_TAC
     [`val(hw:int64) * p_25519 <= ca`;
      `ca < 600 * 2 EXP 256`] THEN
    REWRITE_TAC[p_25519] THEN ARITH_TAC;
    ALL_TAC] THEN

  (*** The rest of the computation ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (22--25) (22--29) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[GSYM CONG; num_congruent] THEN
  REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES] THEN
  MATCH_MP_TAC(MESON[]
   `!q. (ca - q * p == ca) (mod p) /\ ca - q * p < p2 /\ x = ca - q * p
    ==> x:int < p2 /\ (x == ca) (mod p)`) THEN
  EXISTS_TAC `&(val(hw:int64)):int` THEN
  CONJ_TAC THENL [CONV_TAC INTEGER_RULE; ALL_TAC] THEN
  MATCH_MP_TAC(TAUT `p /\ (p ==> q) ==> p /\ q`) THEN CONJ_TAC THENL
   [REWRITE_TAC[INT_ARITH `x - y:int < z <=> x < y + z`] THEN
    ASM_REWRITE_TAC[INT_OF_NUM_CLAUSES];
    DISCH_TAC] THEN
  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC INT_CONG_IMP_EQ THEN EXISTS_TAC `(&2:int) pow 256` THEN
  CONJ_TAC THENL
   [FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (INT_ARITH
     `y:int < p ==> &0 <= y /\ &0 <= p /\ p < e /\ &0 <= x /\ x < e
         ==> abs(x - y) < e`)) THEN
    ASM_REWRITE_TAC[INT_SUB_LE; INT_OF_NUM_CLAUSES; LE_0] THEN
    ONCE_REWRITE_TAC[ARITH_RULE
     `h * p <= ca <=> (h + 1) * p <= ca + p`] THEN
    ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
    BOUNDER_TAC[];
    ALL_TAC] THEN
  REWRITE_TAC[INTEGER_RULE
   `(x:int == y - z) (mod p) <=> (x + z == y) (mod p)`] THEN
  REWRITE_TAC[INT_OF_NUM_CLAUSES; GSYM num_congruent] THEN
  REWRITE_TAC[REAL_CONGRUENCE; p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
  EXPAND_TAC "ca" THEN
  REWRITE_TAC[p_25519; bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
  ACCUMULATOR_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[SYM(NUM_REDUCE_CONV `2 EXP 63 - 1`)] THEN
  REWRITE_TAC[VAL_WORD_AND_MASK_WORD] THEN
  UNDISCH_THEN `ca DIV 2 EXP 255 = val(hw:int64)` (SUBST1_TAC o SYM) THEN
  EXPAND_TAC "ca" THEN
  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
  REWRITE_TAC[bignum_of_wordlist; ARITH_RULE
   `(l + 2 EXP 64 * h) DIV 2 EXP 63 = l DIV 2 EXP 63 + 2 * h`] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; REAL_OF_NUM_DIV] THEN
  REAL_INTEGER_TAC);;

(* ------------------------------------------------------------------------- *)
(* Instances of cmadd_4 (actually there is only one, specific constant).     *)
(* ------------------------------------------------------------------------- *)

let LOCAL_CMADD_4_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 31 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1 p2 n2.
     !m. read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) t = m
     ==>
     !n. read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) t = n
     ==>
      nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 4)
      ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                read RIP s = pcin /\
                read RSP s = read RSP t /\
                read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) s = m /\
                read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) s = n)
           (\s. read RIP s = pcout /\
                read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s <
                2 * p_25519 /\
                (read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s ==
                 121666 * m + n) (mod p_25519))
        (MAYCHANGE [RIP; RDI; RAX; RBX; RDX; R8; R9; R10; R11] ,,
         MAYCHANGE [memory :> bytes(word_add (read p3 t) (word n3),8 * 4)] ,,
         MAYCHANGE SOME_FLAGS)`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "m_" o lhand o concl) THEN
  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (1--19) (1--19) THEN
  ABBREV_TAC
   `ca = bignum_of_wordlist[sum_s8; sum_s11; sum_s14; sum_s17; sum_s19]` THEN
  SUBGOAL_THEN `121666 * m + n < 2 EXP 17 * 2 EXP 256` ASSUME_TAC THENL
   [MAP_EVERY EXPAND_TAC ["m"; "n"] THEN CONV_TAC NUM_REDUCE_CONV THEN
    BOUNDER_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `121666 * m + n = ca` SUBST_ALL_TAC THENL
   [MATCH_MP_TAC CONG_IMP_EQ THEN EXISTS_TAC `2 EXP 320` THEN
    REPEAT CONJ_TAC THENL
     [UNDISCH_TAC `121666 * m + n < 2 EXP 17 * 2 EXP 256` THEN ARITH_TAC;
      EXPAND_TAC "ca" THEN BOUNDER_TAC[];
      REWRITE_TAC[REAL_CONGRUENCE] THEN CONV_TAC NUM_REDUCE_CONV] THEN
    MAP_EVERY EXPAND_TAC ["m"; "n"; "ca"] THEN
    REWRITE_TAC[bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES; p_25519] THEN
    CONV_TAC NUM_REDUCE_CONV THEN
    RULE_ASSUM_TAC(REWRITE_RULE[REAL_BITVAL_NOT]) THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  (*** Instantiate the quotient approximation lemma ***)

  MP_TAC(SPEC `ca:num` p25519weakredlemma) THEN ANTS_TAC THENL
   [UNDISCH_TAC `ca < 2 EXP 17 * 2 EXP 256` THEN ARITH_TAC;
    CONV_TAC(TOP_DEPTH_CONV let_CONV) THEN STRIP_TAC] THEN

(*** Quotient estimate computation ***)

  X86_STEPS_TAC CURVE25519_X25519_EXEC (20--23) THEN
  ABBREV_TAC `hw:int64 = word_subword
    ((word_join:int64->int64->int128) sum_s19 sum_s17) (63,64)` THEN
  SUBGOAL_THEN `ca DIV 2 EXP 255 = val(hw:int64)`
   (fun th -> SUBST_ALL_TAC th THEN ASSUME_TAC th) THENL
   [FIRST_ASSUM(MP_TAC o MATCH_MP (ARITH_RULE
     `ca < 2 EXP 17 * 2 EXP 256
      ==> ca DIV 2 EXP 192 DIV 2 EXP 63 < 2 EXP 59`)) THEN
    EXPAND_TAC "ca" THEN
    CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
    DISCH_THEN(fun th ->
     MATCH_MP_TAC CONG_IMP_EQ THEN EXISTS_TAC `2 EXP 64` THEN
     CONJ_TAC THENL [MP_TAC th THEN ARITH_TAC; REWRITE_TAC[VAL_BOUND_64]]) THEN
    EXPAND_TAC "hw" THEN
    SIMP_TAC[VAL_WORD_SUBWORD_JOIN; DIMINDEX_64; ARITH_LE; ARITH_LT] THEN
    REWRITE_TAC[bignum_of_wordlist; MULT_CLAUSES; ADD_CLAUSES] THEN
    REWRITE_TAC[CONG; ADD_SYM; MULT_SYM] THEN
    CONV_TAC MOD_DOWN_CONV THEN REFL_TAC;
    ALL_TAC] THEN

  ABBREV_TAC `qm:int64 = word_mul hw (word 19:int64)` THEN
  SUBGOAL_THEN `&(val(qm:int64)):real = &19 * &(val(hw:int64))`
  ASSUME_TAC THENL
   [EXPAND_TAC "qm" THEN
    REWRITE_TAC[VAL_WORD_MUL; DIMINDEX_64; REAL_OF_NUM_CLAUSES] THEN
    CONV_TAC WORD_REDUCE_CONV THEN REWRITE_TAC[MULT_SYM] THEN
    MATCH_MP_TAC MOD_LT THEN MAP_EVERY UNDISCH_TAC
     [`val(hw:int64) * p_25519 <= ca`;
      `ca < 2 EXP 17 * 2 EXP 256`] THEN
    REWRITE_TAC[p_25519] THEN ARITH_TAC;
    ALL_TAC] THEN

  (*** The rest of the computation ***)

  X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (24--27) (24--31) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[GSYM CONG; num_congruent] THEN
  REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES] THEN
  MATCH_MP_TAC(MESON[]
   `!q. (ca - q * p == ca) (mod p) /\ ca - q * p < p2 /\ x = ca - q * p
    ==> x:int < p2 /\ (x == ca) (mod p)`) THEN
  EXISTS_TAC `&(val(hw:int64)):int` THEN
  CONJ_TAC THENL [CONV_TAC INTEGER_RULE; ALL_TAC] THEN
  MATCH_MP_TAC(TAUT `p /\ (p ==> q) ==> p /\ q`) THEN CONJ_TAC THENL
   [REWRITE_TAC[INT_ARITH `x - y:int < z <=> x < y + z`] THEN
    ASM_REWRITE_TAC[INT_OF_NUM_CLAUSES];
    DISCH_TAC] THEN
  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC INT_CONG_IMP_EQ THEN EXISTS_TAC `(&2:int) pow 256` THEN
  CONJ_TAC THENL
   [FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (INT_ARITH
     `y:int < p ==> &0 <= y /\ &0 <= p /\ p < e /\ &0 <= x /\ x < e
         ==> abs(x - y) < e`)) THEN
    ASM_REWRITE_TAC[INT_SUB_LE; INT_OF_NUM_CLAUSES; LE_0] THEN
    ONCE_REWRITE_TAC[ARITH_RULE
     `h * p <= ca <=> (h + 1) * p <= ca + p`] THEN
    ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
    BOUNDER_TAC[];
    ALL_TAC] THEN
  REWRITE_TAC[INTEGER_RULE
   `(x:int == y - z) (mod p) <=> (x + z == y) (mod p)`] THEN
  REWRITE_TAC[INT_OF_NUM_CLAUSES; GSYM num_congruent] THEN
  REWRITE_TAC[REAL_CONGRUENCE; p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
  EXPAND_TAC "ca" THEN
  REWRITE_TAC[p_25519; bignum_of_wordlist; GSYM REAL_OF_NUM_CLAUSES] THEN
  ACCUMULATOR_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[SYM(NUM_REDUCE_CONV `2 EXP 63 - 1`)] THEN
  REWRITE_TAC[VAL_WORD_AND_MASK_WORD] THEN
  UNDISCH_THEN `ca DIV 2 EXP 255 = val(hw:int64)` (SUBST1_TAC o SYM) THEN
  EXPAND_TAC "ca" THEN
  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
  REWRITE_TAC[bignum_of_wordlist; ARITH_RULE
   `(l + 2 EXP 64 * h) DIV 2 EXP 63 = l DIV 2 EXP 63 + 2 * h`] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; REAL_OF_NUM_DIV] THEN
  REAL_INTEGER_TAC);;

(* ------------------------------------------------------------------------- *)
(* Instances of mux_4.                                                       *)
(* ------------------------------------------------------------------------- *)

let LOCAL_MUX_4_TAC =
  X86_MACRO_SIM_ABBREV_TAC (X86_TRIM_EXEC_RULE curve25519_x25519_mc) 16 lvs
   `!(t:x86state) pcin pcout p3 n3 p1 n1 p2 n2.
     !b. read ZF t = b
     ==>
     !m. read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) t = m
     ==>
     !n. read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) t = n
     ==>
      nonoverlapping (word pc,0x1e90) (word_add (read p3 t) (word n3),8 * 4) /\
      nonoverlapping (stackpointer:int64,416) (res,32)
      ==> ensures x86
           (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
                read RIP s = pcin /\
                read RSP s = read RSP t /\
                read RBP s = read RBP t /\
                read ZF s = b /\
                read(memory :> bytes(word_add (read p1 t) (word n1),8 * 4)) s = m /\
                read(memory :> bytes(word_add (read p2 t) (word n2),8 * 4)) s = n)
           (\s. read RIP s = pcout /\
                read(memory :> bytes(word_add (read p3 t) (word n3),8 * 4)) s =
                (if b then n else m))
        (MAYCHANGE [RIP; RAX; RCX] ,,
         MAYCHANGE [memory :> bytes(word_add (read p3 t) (word n3),8 * 4)])`
 (REWRITE_TAC[C_ARGUMENTS; C_RETURN; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "n_" o lhand o concl) THEN
  FIRST_ASSUM(BIGNUM_LDIGITIZE_TAC "m_" o lhand o concl) THEN
  X86_STEPS_TAC CURVE25519_X25519_EXEC (1--16) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  CONV_TAC(LAND_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[COND_SWAP] THEN
  COND_CASES_TAC THEN ASM_REWRITE_TAC[]);;

(* ------------------------------------------------------------------------- *)
(* Instances of modular inverse inlining                                     *)
(* ------------------------------------------------------------------------- *)

let LOCAL_MODINV_TAC =
  let cth =
     (GEN_REWRITE_CONV RAND_CONV [bignum_modinv_mc] THENC TRIM_LIST_CONV)
     `TRIM_LIST (23,15) bignum_modinv_mc`
  and bth =
    REWRITE_RULE[BUTLAST_CLAUSES]
     (AP_TERM `BUTLAST:byte list->byte list` curve25519_x25519_mc)
  and th = CONV_RULE (DEPTH_CONV WORD_NUM_RED_CONV)
                     (SPEC `word 4:int64` CORE_MODINV_CORRECT) in
  X86_SUBROUTINE_SIM_TAC(bth,CURVE25519_X25519_EXEC,0x16ba,cth,th)
   [`read RSI s`; `read RDX s`;
    `read (memory :> bytes(read RDX s,8 * 4)) s`;
    `read RCX s`;
    `read (memory :> bytes(read RCX s,8 * 4)) s`;
    `read R8 s`;
    `pc + 0x16ba`;
    `stackpointer:int64`];;

(* ------------------------------------------------------------------------- *)
(* Overall point operation proof.                                            *)
(* ------------------------------------------------------------------------- *)

let nintlemma = prove
 (`&(num_of_int(x rem &p_25519)) = x rem &p_25519`,
  MATCH_MP_TAC INT_OF_NUM_OF_INT THEN MATCH_MP_TAC INT_REM_POS THEN
  REWRITE_TAC[INT_OF_NUM_EQ; p_25519] THEN CONV_TAC NUM_REDUCE_CONV);;

let lemma = prove
 (`X = num_of_int(x rem &p_25519) ==> X < p_25519 /\ &X = x rem &p_25519`,
  DISCH_THEN SUBST1_TAC THEN
  REWRITE_TAC[GSYM INT_OF_NUM_LT; nintlemma; INT_LT_REM_EQ] THEN
  REWRITE_TAC[INT_OF_NUM_LT; p_25519] THEN CONV_TAC NUM_REDUCE_CONV);;

let lemma_double = prove
 (`P IN group_carrier (curve25519x_group(f:(int#int) ring)) /\
   montgomery_xz f (group_pow (curve25519x_group f) P n) (x,y)
   ==> field f /\ ring_char f = p_25519
       ==> montgomery_xz f
            (group_pow (curve25519x_group f) P (2 * n))
               (montgomery_xzdouble (curve25519x f) (x,y))`,
  REWRITE_TAC[curve25519x; curve25519x_group] THEN REPEAT STRIP_TAC THEN
  MATCH_MP_TAC MONTGOMERY_XZDOUBLE_GROUP THEN ASM_REWRITE_TAC[] THEN
  ASM_SIMP_TAC[GSYM curve25519x; MONTGOMERY_NONSINGULAR_CURVE25519X] THEN
  REWRITE_TAC[A_25519; p_25519; RING_OF_NUM] THEN
  CONV_TAC NUM_REDUCE_CONV);;

let lemma_diffadd1 = prove
 (`field f /\ ring_char f = p_25519 /\
   ~(x:(int#int) = ring_0 f) /\
   P IN group_carrier (curve25519x_group f) /\
   montgomery_xz f P (x,ring_of_num f 1) /\
   montgomery_xz f
     (group_pow (curve25519x_group f) P (n + 1)) (xn,zn) /\
   montgomery_xz f
     (group_pow (curve25519x_group f) P n) (xm,zm)
   ==> montgomery_xz f
            (group_pow (curve25519x_group f) P (2 * n + 1))
            (montgomery_xzdiffadd (curve25519x f) (x,ring_of_num f 1)
                  (xn,zn) (xm,zm))`,
  REWRITE_TAC[curve25519x; curve25519x_group] THEN REPEAT STRIP_TAC THEN
  MATCH_MP_TAC MONTGOMERY_XZDIFFADD_GROUP THEN ASM_REWRITE_TAC[] THEN
  ASM_SIMP_TAC[GSYM curve25519x; MONTGOMERY_NONSINGULAR_CURVE25519X] THEN
  REWRITE_TAC[A_25519; p_25519; RING_OF_NUM] THEN
  ASM_SIMP_TAC[RING_OF_NUM_1; FIELD_NONTRIVIAL] THEN
  CONV_TAC NUM_REDUCE_CONV);;

let lemma_diffadd2 = prove
 (`field f /\ ring_char f = p_25519 /\
   ~(x:(int#int) = ring_0 f) /\
   P IN group_carrier (curve25519x_group f) /\
   montgomery_xz f P (x,ring_of_num f 1) /\
   montgomery_xz f
     (group_pow (curve25519x_group f) P (n + 1)) (xm,zm) /\
   montgomery_xz f
     (group_pow (curve25519x_group f) P n) (xn,zn)
   ==> montgomery_xz f
            (group_pow (curve25519x_group f) P (2 * n + 1))
            (montgomery_xzdiffadd (curve25519x f) (x,ring_of_num f 1)
                  (xn,zn) (xm,zm))`,
  DISCH_TAC THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP lemma_diffadd1) THEN
  MATCH_MP_TAC EQ_IMP THEN AP_TERM_TAC THEN
  POP_ASSUM STRIP_ASSUME_TAC THEN
  REPEAT(FIRST_X_ASSUM(MP_TAC o MATCH_MP MONTGOMERY_XZ_IN_CARRIER)) THEN
  ASM_SIMP_TAC[montgomery_xzdiffadd; curve25519x; RING_MUL_SYM; PAIR_EQ] THEN
  RING_TAC);;

let CURVE25519_X25519_CORRECT = time prove
 (`!res scalar n point X pc stackpointer.
    ALL (nonoverlapping (stackpointer,416))
        [(word pc,0x1e90); (res,32); (scalar,32); (point,32)] /\
    nonoverlapping (res,32) (word pc,0x1e90)
    ==> ensures x86
         (\s. bytes_loaded s (word pc) (BUTLAST curve25519_x25519_mc) /\
              read RIP s = word(pc + 0x11) /\
              read RSP s = stackpointer /\
              C_ARGUMENTS [res; scalar; point] s /\
              bignum_from_memory (scalar,4) s = n /\
              bignum_from_memory (point,4) s = X)
         (\s. read RIP s = word (pc + 0x1e7e) /\
              bignum_from_memory (res,4) s = rfcx25519(n,X))
         (MAYCHANGE [RIP; RDI; RSI; RAX; RBX; RCX; RDX; RBP;
                     R8; R9; R10; R11; R12; R13; R14; R15] ,,
          MAYCHANGE SOME_FLAGS ,,
          MAYCHANGE [memory :> bytes(res,32);
                     memory :> bytes(stackpointer,416)])`,
  REWRITE_TAC[FORALL_PAIR_THM] THEN
  MAP_EVERY X_GEN_TAC
   [`res:int64`; `scalar:int64`; `n_input:num`; `point:int64`; `X_input:num`;
    `pc:num`; `stackpointer:int64`] THEN
  REWRITE_TAC[ALLPAIRS; ALL; NONOVERLAPPING_CLAUSES] THEN STRIP_TAC THEN
  REWRITE_TAC[C_ARGUMENTS; SOME_FLAGS] THEN

  (*** The modified forms of the inputs that get computed early on  ***)
  (*** The nn' is the computed value without masking of the top bit ***)

  ABBREV_TAC `nn = 2 EXP 254 + n_input MOD 2 EXP 254 - n_input MOD 8` THEN
  ABBREV_TAC `X = (X_input MOD 2 EXP 255) MOD p_25519` THEN
  ABBREV_TAC `nn' = 2 EXP 255 * n_input DIV 2 EXP 255 + nn` THEN
  REWRITE_TAC[rfcx25519] THEN ONCE_REWRITE_TAC[GSYM PUREX25519_MOD] THEN
  ASM_REWRITE_TAC[] THEN

  (*** Setup of the main loop ***)

  ENSURES_WHILE_PDOWN_TAC `255` `pc + 0x134` `pc + 0x1658`
   `\i s.
     (read RSP s = stackpointer /\
      read(memory :> bytes64(word_add stackpointer (word 384))) s = res /\
      read(memory :> bytes64(word_add stackpointer (word 392))) s =
      word_sub (word i) (word 1) /\
      bignum_from_memory (stackpointer,4) s = nn' /\
      bignum_from_memory (word_add stackpointer (word 32),4) s = X /\
      read (memory :> bytes64(word_add stackpointer (word 400))) s =
      word(bitval(ODD(nn DIV 2 EXP i))) /\
      !(f:(int#int) ring) P.
        field f /\ ring_char f = p_25519 /\
        P IN group_carrier(curve25519x_group f) /\
        curve25519x_canonically_represents f P (X,1)
      ==>
      if X = 0 then
        bignum_from_memory(word_add stackpointer (word 96),4) s <= 1 /\
        bignum_from_memory(word_add stackpointer (word 160),4) s = 0 /\
        bignum_from_memory(word_add stackpointer (word 256),4) s = 0 /\
        bignum_from_memory(word_add stackpointer (word 320),4) s <= 1
      else
      curve25519x_canonically_represents f
       (group_pow (curve25519x_group f) P
           (if ODD(nn DIV 2 EXP i)
            then nn DIV 2 EXP i + 1 else nn DIV 2 EXP i))
       (bignum_from_memory(word_add stackpointer (word 320),4) s,
        bignum_from_memory(word_add stackpointer (word 160),4) s) /\
      curve25519x_canonically_represents f
       (group_pow (curve25519x_group f) P
          (if ODD(nn DIV 2 EXP i)
           then nn DIV 2 EXP i else nn DIV 2 EXP i + 1))
       (bignum_from_memory(word_add stackpointer (word 256),4) s,
        bignum_from_memory(word_add stackpointer (word 96),4) s)) /\
     (read CF s <=> i = 0)` THEN
  REPEAT CONJ_TAC THENL
   [ARITH_TAC;

    (*** Initial setup and modification of the inputs ***)

    REWRITE_TAC(!simulation_precanon_thms) THEN ENSURES_INIT_TAC "s0" THEN
    BIGNUM_LDIGITIZE_TAC "n_" `read (memory :> bytes (scalar,8 * 4)) s0` THEN
    BIGNUM_LDIGITIZE_TAC "x_" `read (memory :> bytes (point,8 * 4)) s0` THEN
    X86_ACCSTEPS_TAC CURVE25519_X25519_EXEC (21--24) (1--55) THEN
    ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
    CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN
    ASM_REWRITE_TAC[COND_SWAP] THEN
    CONJ_TAC THENL [CONV_TAC WORD_REDUCE_CONV; ALL_TAC] THEN CONJ_TAC THENL
     [MAP_EVERY EXPAND_TAC ["nn'"; "nn"; "n_input"] THEN
      MATCH_MP_TAC(ARITH_RULE
        `n MOD 8 <= n MOD 2 EXP 254 /\
         2 EXP 254 * n DIV 2 EXP 254 + n MOD 8 + a = b + c + n
         ==> a = b + c + n MOD 2 EXP 254 - n MOD 8`) THEN
      CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
      GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV)
       [ARITH_RULE `x MOD 8 = x MOD 2 EXP (MIN 254 3)`] THEN
      REWRITE_TAC[GSYM MOD_MOD_EXP_MIN; MOD_LE] THEN
      REWRITE_TAC[bignum_of_wordlist] THEN
      ONCE_REWRITE_TAC[ARITH_RULE
       `a + 2 EXP 64 * b = a + 8 * 2 EXP 61 * b`] THEN
      REWRITE_TAC[MOD_MULT_ADD] THEN
      REWRITE_TAC[val_def; ARITH_RULE `8 = 2 EXP 3`; DIMINDEX_64] THEN
      SIMP_TAC[BINARY_DIGITSUM_DIV; BINARY_DIGITSUM_MOD; FINITE_NUMSEG_LT] THEN
      REWRITE_TAC[IN_ELIM_THM; ARITH_RULE
       `i < 64 /\ a <= i <=> a <= i /\ i <= 63`] THEN
      REWRITE_TAC[ARITH_RULE `i < 64 /\ i < 3 <=> i < 3`] THEN
      REWRITE_TAC[NUMSEG_LT; ARITH_EQ; GSYM numseg] THEN
      CONV_TAC NUM_REDUCE_CONV THEN
      CONV_TAC(ONCE_DEPTH_CONV EXPAND_NSUM_CONV) THEN
      REWRITE_TAC[BIT_WORD_OR; BIT_WORD_AND; DIMINDEX_64] THEN
      CONV_TAC(DEPTH_CONV
       (WORD_NUM_RED_CONV ORELSEC
        GEN_REWRITE_CONV I [BITVAL_CLAUSES])) THEN
      ARITH_TAC;
      ALL_TAC] THEN
    MATCH_MP_TAC(TAUT `p /\ (p ==> q) ==> p /\ q`) THEN CONJ_TAC THENL
     [CONV_TAC SYM_CONV THEN EXPAND_TAC "X" THEN
      MATCH_MP_TAC EQUAL_FROM_CONGRUENT_MOD_MOD THEN
      MAP_EVERY EXISTS_TAC
       [`255`;
        `if X_input MOD 2 EXP 255 < p_25519 then &(X_input MOD 2 EXP 255):real
         else &(X_input MOD 2 EXP 255) - &p_25519`] THEN
      REPEAT CONJ_TAC THENL
       [CONV_TAC NUM_REDUCE_CONV THEN
        COND_CASES_TAC THEN ASM_REWRITE_TAC[] THEN BOUNDER_TAC[];
        REWRITE_TAC[p_25519] THEN ARITH_TAC;
        REWRITE_TAC[p_25519] THEN ARITH_TAC;
        ALL_TAC;
        SIMP_TAC[GSYM NOT_LE; COND_SWAP; REAL_OF_NUM_SUB] THEN
        REWRITE_TAC[GSYM COND_RAND; REAL_OF_NUM_EQ] THEN
        REWRITE_TAC[GSYM NOT_LT; COND_SWAP] THEN MATCH_MP_TAC MOD_CASES THEN
        REWRITE_TAC[p_25519] THEN ARITH_TAC] THEN
      SUBGOAL_THEN
       `X_input MOD 2 EXP 255 =
        bignum_of_wordlist [x_0; x_1; x_2; word_and x_3 (word(2 EXP 63 - 1))]`
      SUBST1_TAC THENL
       [EXPAND_TAC "X_input" THEN MATCH_MP_TAC(ARITH_RULE
         `m + 2 EXP 255 * n DIV 2 EXP 255 = n
          ==> n MOD 2 EXP 255 = m`) THEN
        CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
        REWRITE_TAC[bignum_of_wordlist; VAL_WORD_AND_MASK_WORD] THEN
        ARITH_TAC;
        CONV_TAC NUM_REDUCE_CONV] THEN
      SUBGOAL_THEN
       `bignum_of_wordlist
         [x_0; x_1; x_2; word_and x_3 (word 9223372036854775807)] <
        p_25519 <=> ~bit 63 (sum_s24:int64)`
      SUBST1_TAC THENL
       [REWRITE_TAC[GSYM NOT_LE] THEN AP_TERM_TAC THEN CONV_TAC SYM_CONV THEN
        TRANS_TAC EQ_TRANS
         `2 EXP 255 <=
          bignum_of_wordlist[sum_s21; sum_s22; sum_s23; sum_s24]` THEN
        CONJ_TAC THENL
         [REWRITE_TAC[ARITH_RULE
           `2 EXP 255 <= x <=> 2 EXP 63 <= x DIV 2 EXP 192`] THEN
          CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
          REWRITE_TAC[GSYM DIMINDEX_64; ARITH_RULE `63 = 64 - 1`] THEN
          REWRITE_TAC[MSB_VAL];
          ALL_TAC] THEN
        MATCH_MP_TAC(ARITH_RULE
         `19 + p = e /\ 19 + x = s
          ==> (e <= s <=> p <= x)`) THEN
        CONJ_TAC THENL [REWRITE_TAC[p_25519] THEN ARITH_TAC; ALL_TAC] THEN
        REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; bignum_of_wordlist] THEN
        ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
        DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC;
        REWRITE_TAC[COND_SWAP]] THEN
      COND_CASES_TAC THEN ASM_REWRITE_TAC[REAL_SUB_REFL] THENL
       [ALL_TAC; REAL_INTEGER_TAC] THEN
      REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; bignum_of_wordlist] THEN
      ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
      REWRITE_TAC[SYM(NUM_REDUCE_CONV `2 EXP 63 - 1`)] THEN
      REWRITE_TAC[VAL_WORD_AND_MASK_WORD; REAL_OF_NUM_MOD] THEN
      REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; p_25519] THEN
      DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC;
      DISCH_THEN SUBST1_TAC] THEN
    SUBGOAL_THEN `nn < 2 EXP 255` (fun t -> SIMP_TAC[t; DIV_LT; MOD_LT]) THENL
     [EXPAND_TAC "nn" THEN ARITH_TAC; ALL_TAC] THEN
    REWRITE_TAC[bignum_of_wordlist] THEN
    CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV) THEN
    ASM_SIMP_TAC[GROUP_POW_1] THEN REWRITE_TAC[group_pow] THEN
    SIMP_TAC[CURVE25519X_GROUP] THEN
    REWRITE_TAC[curve25519x_canonically_represents; montgomery_xz] THEN
    REWRITE_TAC[RING_OF_NUM] THEN
    REWRITE_TAC[RING_OF_NUM_1; RING_OF_NUM_0; p_25519] THEN
    SIMP_TAC[FIELD_NONTRIVIAL] THEN CONV_TAC NUM_REDUCE_CONV THEN
    REWRITE_TAC[COND_ID];

    (*** The main loop invariant for the Montgomery ladder ***)

    X_GEN_TAC `i:num` THEN STRIP_TAC THEN
    REWRITE_TAC[WORD_BITVAL_EQ_0; EXP; DIV_1] THEN
    GHOST_INTRO_TAC `xn:num`
     `bignum_from_memory (word_add stackpointer (word 320),4)` THEN
    GHOST_INTRO_TAC `zn:num`
     `bignum_from_memory (word_add stackpointer (word 160),4)` THEN
    GHOST_INTRO_TAC `xm:num`
     `bignum_from_memory (word_add stackpointer (word 256),4)` THEN
    GHOST_INTRO_TAC `zm:num`
     `bignum_from_memory(word_add stackpointer (word 96),4)` THEN
    REWRITE_TAC[WORD_RULE `word_sub (word (i + 1)) (word 1) = word i`] THEN

    REWRITE_TAC(!simulation_precanon_thms) THEN ENSURES_INIT_TAC "s0" THEN
    LOCAL_SUB_4_TAC 0 ["dm"; "xm"; "zm"] THEN
    LOCAL_ADD_4_TAC 0 ["sn"; "xn"; "zn"] THEN
    LOCAL_SUB_4_TAC 0 ["dn"; "xn"; "zn"] THEN
    LOCAL_ADD_4_TAC 0 ["sm"; "xm"; "zm"] THEN
    LOCAL_MUL_5_TAC 0 ["dmsn"; "sn"; "dm"] THEN

    SUBGOAL_THEN
     `read(memory :> bytes64
      (word_add stackpointer (word(8 * val(word_ushr (word i:int64) 6))))) s5 =
      word(nn' DIV (2 EXP (64 * i DIV 64)) MOD 2 EXP (64 * 1))`
    ASSUME_TAC THENL
     [EXPAND_TAC "nn'" THEN REWRITE_TAC[GSYM BIGNUM_FROM_MEMORY_BYTES] THEN
      REWRITE_TAC[BIGNUM_FROM_MEMORY_DIV; BIGNUM_FROM_MEMORY_MOD] THEN
      ASM_SIMP_TAC[ARITH_RULE `i < 255 ==> MIN (4 - i DIV 64) 1 = 1`] THEN
      REWRITE_TAC[BIGNUM_FROM_MEMORY_SING; WORD_VAL] THEN
      VAL_INT64_TAC `i:num` THEN ASM_REWRITE_TAC[VAL_WORD_USHR] THEN
      CONV_TAC NUM_REDUCE_CONV THEN REFL_TAC;
      ALL_TAC] THEN
    X86_STEPS_TAC CURVE25519_X25519_EXEC (6--13) THEN
    SUBGOAL_THEN
     `word_and
        (word_ushr (word((nn' DIV 2 EXP (64 * i DIV 64)) MOD 2 EXP 64))
        (val (word(val (word i:int64) MOD 256):byte) MOD 64))
        (word 1:int64) =
      word(bitval(ODD(nn DIV 2 EXP i)))`
    SUBST_ALL_TAC THENL
     [REWRITE_TAC[WORD_AND_1_BITVAL; MOD_64_CLAUSES] THEN
      AP_TERM_TAC THEN AP_TERM_TAC THEN
      REWRITE_TAC[BIT_LSB; VAL_WORD_USHR] THEN
      REWRITE_TAC[VAL_WORD; DIMINDEX_64; MOD_MOD_REFL] THEN
      REWRITE_TAC[DIV_MOD; DIV_DIV; GSYM EXP_ADD] THEN
      REWRITE_TAC[ARITH_RULE `64 * i DIV 64 + i MOD 64 = i`] THEN
      REWRITE_TAC[ARITH_RULE `64 * i DIV 64 + 64 = i + (64 - i MOD 64)`] THEN
      REWRITE_TAC[EXP_ADD; GSYM DIV_MOD; ODD_MOD_POW2] THEN
      MATCH_MP_TAC(TAUT `p /\ (q <=> q')==> (p /\ q <=> q')`) THEN
      CONJ_TAC THENL [ARITH_TAC; ALL_TAC] THEN
      REWRITE_TAC[GSYM CONG_MOD_2_ALT] THEN MATCH_MP_TAC CONG_DIV2 THEN
      REWRITE_TAC[GSYM(ONCE_REWRITE_RULE[MULT_SYM] (CONJUNCT2 EXP))] THEN
      UNDISCH_THEN
       `2 EXP 255 * n_input DIV 2 EXP 255 + nn = nn'`
       (SUBST1_TAC o SYM) THEN
      MATCH_MP_TAC(NUMBER_RULE
       `n divides e ==> (e * x + y:num == y) (mod n)`) THEN
      MATCH_MP_TAC DIVIDES_EXP_LE_IMP THEN ASM_REWRITE_TAC[LE_SUC_LT];
      ALL_TAC] THEN
    RULE_ASSUM_TAC(REWRITE_RULE[VAL_EQ_0; WORD_SUB_EQ_0;
      MESON[VAL_WORD_BITVAL; VAL_EQ; EQ_BITVAL]
       `word(bitval b) = word(bitval c) <=> (b <=> c)`]) THEN

    LOCAL_MUX_4_TAC 0 ["d"; "dm"; "dn"] THEN
    LOCAL_MUX_4_TAC 0 ["s"; "sm"; "sn"] THEN
    LOCAL_MUL_5_TAC 0 ["dnsm"; "sm"; "dn"] THEN
    LOCAL_SQR_4_TAC 0 ["d"; "d"] THEN
    LOCAL_SUB5_4_TAC 0 ["dpro"; "dmsn"; "dnsm"] THEN
    LOCAL_SQR_4_TAC 0 ["s"; "s"] THEN
    LOCAL_ADD5_4_TAC 0 ["spro"; "dmsn"; "dnsm"] THEN
    LOCAL_SQR_4_TAC 0 ["dpro"; "dpro"] THEN
    LOCAL_SUB_TWICE4_TAC 0 ["p"; "s"; "d"] THEN
    LOCAL_SQR_P25519_TAC 0 ["xm"; "spro"] THEN
    LOCAL_CMADD_4_TAC 0 ["e"; "p"; "d"] THEN
    LOCAL_MUL_P25519_TAC 0 ["xn"; "s"; "d"] THEN
    LOCAL_MUL_P25519_TAC 0 ["zm"; "dpro"; "x"] THEN
    LOCAL_MUL_P25519_TAC 0 ["zn"; "p"; "e"] THEN

    X86_STEPS_TAC CURVE25519_X25519_EXEC (28--30) THEN
    FIRST_X_ASSUM(MP_TAC o
     check (can (term_match [] `(MAYCHANGE a ,, b) s s'` o concl))) THEN
    POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o rev) THEN
    DISCH_THEN(fun th -> DISCH_TAC THEN
      ENSURES_FINAL_STATE_TAC THEN MP_TAC th) THEN
    STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
    ASM_SIMP_TAC[VAL_WORD; DIMINDEX_64; MOD_LT;
                 ARITH_RULE `i < 255 ==> i < 2 EXP 64`] THEN
    REWRITE_TAC[ARITH_RULE `i < 1 <=> i = 0`] THEN
    DISCARD_STATE_TAC "s30" THEN
    DISCARD_MATCHING_ASSUMPTIONS
     [`aligned a b`; `val(word i) = i`; `nonoverlapping_modulo a b c`] THEN

    MAP_EVERY X_GEN_TAC
     [`f:(int#int) ring`; `P:((int#int)#(int#int))option`] THEN
    STRIP_TAC THEN FIRST_X_ASSUM(MP_TAC o SPECL
    [`f:(int#int) ring`; `P:((int#int)#(int#int))option`]) THEN
    ASM_REWRITE_TAC[] THEN COND_CASES_TAC THEN ASM_REWRITE_TAC[] THENL
     [FIRST_X_ASSUM SUBST_ALL_TAC THEN
      DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN
       (fun th -> SUBST_ALL_TAC th ORELSE ASSUME_TAC th)) THEN
      REPEAT(FIRST_X_ASSUM(MP_TAC o check (is_imp o concl))) THEN
      REPEAT(ANTS_TAC THENL
       [ASM_REWRITE_TAC[] THEN
        REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
        RULE_ASSUM_TAC(CONV_RULE NUM_REDUCE_CONV o REWRITE_RULE[p_25519]) THEN
        ASM BOUNDER_TAC[];
        STRIP_TAC]) THEN
      POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o rev) THEN
      COND_CASES_TAC THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN
      REWRITE_TAC[GSYM INT_OF_NUM_REM; GSYM INT_OF_NUM_CLAUSES] THEN
      ONCE_REWRITE_TAC[GSYM INT_POW_REM; GSYM INT_MUL_REM] THEN
      RULE_ASSUM_TAC(REWRITE_RULE
       [num_congruent; GSYM INT_OF_NUM_CLAUSES; GSYM INT_OF_NUM_REM]) THEN
      RULE_ASSUM_TAC(REWRITE_RULE[GSYM INT_REM_EQ]) THEN
      RULE_ASSUM_TAC(ONCE_REWRITE_RULE[GSYM INT_SUB_REM; GSYM INT_ADD_REM]) THEN
      RULE_ASSUM_TAC(ONCE_REWRITE_RULE[GSYM INT_POW_REM; GSYM INT_MUL_REM]) THEN
      ASM_REWRITE_TAC[] THEN CONV_TAC INT_REM_DOWN_CONV THEN
      RULE_ASSUM_TAC(REWRITE_RULE[INT_OF_NUM_LE]) THEN
      REPEAT(FIRST_X_ASSUM(DISJ_CASES_THEN SUBST_ALL_TAC o MATCH_MP
       (ARITH_RULE `n <= 1 ==> n = 0 \/ n = 1`))) THEN
      REWRITE_TAC[p_25519] THEN CONV_TAC INT_REDUCE_CONV;
      ALL_TAC] THEN

    RULE_ASSUM_TAC(ONCE_REWRITE_RULE[TAUT
     `(ODD n <=> b) <=> (b <=> ODD n)`]) THEN
    ABBREV_TAC `n = nn DIV 2 EXP (i + 1)` THEN
    ABBREV_TAC `b = ODD(nn DIV 2 EXP i)` THEN
    SUBGOAL_THEN `nn DIV 2 EXP i = 2 * n + bitval b` SUBST1_TAC THENL
     [MAP_EVERY EXPAND_TAC ["b"; "n"] THEN
      REWRITE_TAC[EXP_ADD; GSYM DIV_DIV; BITVAL_ODD] THEN ARITH_TAC;
      SIMP_TAC[BITVAL_CLAUSES; ADD_CLAUSES; COND_ID]] THEN

    DISCH_TAC THEN
    SUBGOAL_THEN
     `(ring_of_num f xm':(int#int),ring_of_num f zm') =
       montgomery_xzdiffadd (curve25519x f)
           (ring_of_num f X,ring_of_num f 1)
           (ring_of_num f xn,ring_of_num f zn)
           (ring_of_num f xm,ring_of_num f zm) /\
      (ring_of_num f xn',ring_of_num f zn') =
       montgomery_xzdouble (curve25519x f)
        (if b <=> ODD n then (ring_of_num f xn,ring_of_num f zn)
         else (ring_of_num f xm,ring_of_num f zm))`
    MP_TAC THENL
     [FIRST_X_ASSUM(CONJUNCTS_THEN (STRIP_ASSUME_TAC o
        MATCH_MP CURVE25519X_CANONICALLY_REPRESENTS_BOUND)) THEN
      FIRST_X_ASSUM(STRIP_ASSUME_TAC o
        MATCH_MP CURVE25519X_CANONICALLY_REPRESENTS_BOUND) THEN
      REPEAT(FIRST_X_ASSUM(MP_TAC o check (is_imp o concl))) THEN
      REPEAT(ANTS_TAC THENL
       [ASM_REWRITE_TAC[] THEN SIMPLE_ARITH_TAC; STRIP_TAC]) THEN
      REPEAT(FIRST_X_ASSUM(K ALL_TAC o GEN_REWRITE_RULE I [GSYM NOT_LE])) THEN
      POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o rev) THEN
      COND_CASES_TAC THEN
      ASM_REWRITE_TAC[montgomery_xzdiffadd; montgomery_xzdouble;
                      curve25519x; PAIR_EQ] THEN
      STRIP_TAC THEN
      REWRITE_TAC[GSYM RING_OF_INT_OF_NUM; RING_OF_INT_CLAUSES] THEN
      ASM_REWRITE_TAC[RING_OF_INT_EQ] THEN
      REWRITE_TAC[GSYM INT_OF_NUM_REM; GSYM INT_REM_EQ;
                  GSYM INT_OF_NUM_CLAUSES] THEN
      CONV_TAC INT_REM_DOWN_CONV THEN
      REWRITE_TAC[PAIR_EQ; GSYM INT_OF_NUM_EQ; nintlemma] THEN
      REWRITE_TAC[GSYM INT_OF_NUM_REM; GSYM INT_OF_NUM_CLAUSES] THEN
      ONCE_REWRITE_TAC[GSYM INT_POW_REM; GSYM INT_MUL_REM] THEN
      RULE_ASSUM_TAC(REWRITE_RULE
       [num_congruent; GSYM INT_OF_NUM_CLAUSES; GSYM INT_OF_NUM_REM]) THEN
      RULE_ASSUM_TAC(REWRITE_RULE[GSYM INT_REM_EQ]) THEN
      RULE_ASSUM_TAC(ONCE_REWRITE_RULE[GSYM INT_SUB_REM; GSYM INT_ADD_REM]) THEN
      RULE_ASSUM_TAC(ONCE_REWRITE_RULE[GSYM INT_POW_REM; GSYM INT_MUL_REM]) THEN
      ASM_REWRITE_TAC[] THEN CONV_TAC INT_REM_DOWN_CONV THEN
      REPEAT CONJ_TAC THEN AP_THM_TAC THEN AP_TERM_TAC THEN
      REWRITE_TAC[A_25519] THEN INT_ARITH_TAC;
      ASM_REWRITE_TAC[] THEN SIMP_TAC[curve25519x_canonically_represents] THEN
      DISCH_THEN(K ALL_TAC) THEN REWRITE_TAC[MOD_LT_EQ; p_25519; ARITH_EQ] THEN
      FIRST_X_ASSUM(CONJUNCTS_THEN(MP_TAC o last o CONJUNCTS o
        GEN_REWRITE_RULE I [curve25519x_canonically_represents])) THEN
      GEN_REWRITE_TAC I [GSYM IMP_CONJ_ALT] THEN
      FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I
       [curve25519x_canonically_represents]) THEN
      DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC (MP_TAC o CONJUNCT2)) THEN
      UNDISCH_TAC
       `P IN group_carrier(curve25519x_group(f:(int#int) ring))`] THEN

    SUBGOAL_THEN `~(ring_of_num (f:(int#int) ring) X = ring_0 f)` MP_TAC THENL
     [ASM_REWRITE_TAC[RING_OF_NUM_EQ_0] THEN
      DISCH_THEN(MP_TAC o MATCH_MP DIVIDES_LE) THEN
      ASM_REWRITE_TAC[NOT_LE];
      MAP_EVERY UNDISCH_TAC
       [`ring_char(f:(int#int) ring) = p_25519`; `field(f:(int#int) ring)`] THEN
      POP_ASSUM_LIST(K ALL_TAC)] THEN

    REPEAT DISCH_TAC THEN CONJ_TAC THENL
     [DISJ_CASES_THEN SUBST_ALL_TAC
       (TAUT `(b <=> ODD n) \/ (b <=> ~ODD n)`) THEN
      REWRITE_TAC[TAUT `~(~p <=> p)`] THENL
       [FIRST_X_ASSUM(MP_TAC o CONJUNCT1);
        FIRST_X_ASSUM(MP_TAC o CONJUNCT2)] THEN
      UNDISCH_TAC `P IN group_carrier(curve25519x_group(f:(int#int) ring))` THEN
      REWRITE_TAC[IMP_IMP] THEN DISCH_THEN(MP_TAC o MATCH_MP lemma_double) THEN
      ASM_REWRITE_TAC[COND_SWAP] THEN COND_CASES_TAC THEN
      REWRITE_TAC[ARITH_RULE `(2 * n + 1) + 1 = 2 * (n + 1)`];

      REPEAT(POP_ASSUM MP_TAC) THEN
      REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC] THEN
      COND_CASES_TAC THEN REWRITE_TAC[lemma_diffadd1] THEN
      GEN_REWRITE_TAC (LAND_CONV o funpow 5 RAND_CONV) [CONJ_SYM] THEN
      REWRITE_TAC[lemma_diffadd2]];

    (*** The trivial loop-back subgoal ***)

    REPEAT STRIP_TAC THEN X86_SIM_TAC CURVE25519_X25519_EXEC [1];

    ALL_TAC] THEN

  (*** Clean up final goal and observe that the modified n is even ***)

  REWRITE_TAC[WORD_BITVAL_EQ_0; EXP; DIV_1] THEN
  GHOST_INTRO_TAC `xn:num`
   `bignum_from_memory (word_add stackpointer (word 320),4)` THEN
  GHOST_INTRO_TAC `zn:num`
   `bignum_from_memory (word_add stackpointer (word 160),4)` THEN
  GHOST_INTRO_TAC `xm:num`
   `bignum_from_memory (word_add stackpointer (word 256),4)` THEN
  GHOST_INTRO_TAC `zm:num`
   `bignum_from_memory(word_add stackpointer (word 96),4)` THEN

  SUBGOAL_THEN `ODD nn <=> F` SUBST1_TAC THENL
   [EXPAND_TAC "nn" THEN REWRITE_TAC[ARITH_RULE `8 = 2 EXP 3`] THEN
    REWRITE_TAC[ODD_ADD; ODD_EXP; ODD_MOD_POW2; ODD_SUB] THEN
    CONV_TAC NUM_REDUCE_CONV;
    REWRITE_TAC[BITVAL_CLAUSES]] THEN

  SUBGOAL_THEN `X < p_25519` ASSUME_TAC THENL
   [EXPAND_TAC "X" THEN REWRITE_TAC[MOD_LT_EQ; p_25519] THEN ARITH_TAC;
    ALL_TAC] THEN
  REPEAT(FIRST_X_ASSUM(K ALL_TAC o
   check (free_in `n_input:num`) o concl)) THEN
  REPEAT(FIRST_X_ASSUM(K ALL_TAC o
   check (free_in `X_input:num`) o concl)) THEN

  (*** The state setup for the modular inverse ***)

  REWRITE_TAC(!simulation_precanon_thms) THEN ENSURES_INIT_TAC "s0" THEN
  X86_STEPS_TAC CURVE25519_X25519_EXEC (1--13) THEN
  SUBGOAL_THEN
   `read (memory :> bytes (word_add stackpointer (word 128),8 * 4)) s13 =
    p_25519`
  ASSUME_TAC THENL
   [CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN
    ASM_REWRITE_TAC[bignum_of_wordlist; p_25519] THEN
    CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV);
    ALL_TAC] THEN

  (*** The inlining of modular inverse ***)

  LOCAL_MODINV_TAC 14 THEN
  ABBREV_TAC
   `zn' =
    read(memory :> bytes(word_add stackpointer (word 96),8 * 4)) s14` THEN

  (*** The tweaking to force xn = 0 whenever zn = 0 ***)

  BIGNUM_LDIGITIZE_TAC "xn_"
   `read(memory :> bytes(word_add stackpointer (word 320),8 * 4)) s14` THEN
  BIGNUM_LDIGITIZE_TAC "zn_"
   `read(memory :> bytes(word_add stackpointer (word 160),8 * 4)) s14` THEN
  X86_STEPS_TAC CURVE25519_X25519_EXEC (15--30) THEN

  SUBGOAL_THEN
   `read(memory :> bytes(word_add stackpointer (word 320),8 * 4)) s30 =
    if zn = 0 then 0 else xn`
  ASSUME_TAC THENL
   [CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN
    ASM_REWRITE_TAC[] THEN MAP_EVERY EXPAND_TAC ["zn"; "xn"] THEN
    REWRITE_TAC[WORD_SUB_0; VAL_EQ_0; WORD_OR_EQ_0] THEN
    REWRITE_TAC[BIGNUM_OF_WORDLIST_EQ_0; ALL] THEN
    REWRITE_TAC[COND_SWAP; CONJ_ACI] THEN
    COND_CASES_TAC THEN ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[bignum_of_wordlist] THEN
    CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV);
    ALL_TAC] THEN

  (*** Final multiplication ***)

  LOCAL_MUL_P25519_TAC 1 ["resx"; "xn"; "zm"] THEN

  (*** Completing the mathematics ***)

  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  CONV_TAC SYM_CONV THEN MATCH_MP_TAC PUREX25519_UNIQUE_IMP THEN
  CONJ_TAC THENL [REWRITE_TAC[MOD_LT_EQ; p_25519] THEN ARITH_TAC; ALL_TAC] THEN
  MAP_EVERY X_GEN_TAC [`f:(int#int)ring`; `P:((int#int)#(int#int))option`] THEN

  ASM_CASES_TAC `X = 0` THEN
  ASM_REWRITE_TAC[RING_OF_NUM_0] THEN STRIP_TAC THENL
   [MP_TAC(ISPECL
     [`f:(int#int)ring`; `ring_of_num f A_25519:int#int`;
      `ring_of_num f 1:int#int`; `P:((int#int)#(int#int))option`;
      `nn:num`] MONTGOMERY_XMAP_EQ_0_POW) THEN
    ASM_REWRITE_TAC[GSYM curve25519x_group; GSYM curve25519x] THEN
    ASM_SIMP_TAC[MONTGOMERY_NONSINGULAR_CURVE25519X; RING_OF_NUM] THEN
    ANTS_TAC THENL [REWRITE_TAC[p_25519] THEN ARITH_TAC; ALL_TAC] THEN
    DISCH_THEN SUBST1_TAC THEN FIRST_X_ASSUM(MP_TAC o SPECL
     [`f:(int#int)ring`; `SOME(ring_0 f:int#int,ring_0 f)`]) THEN
    ASM_REWRITE_TAC[] THEN ANTS_TAC THENL
     [ALL_TAC; SIMP_TAC[MULT_CLAUSES; MOD_0; RING_OF_NUM_0]] THEN
    REWRITE_TAC[curve25519x_canonically_represents] THEN
    ASM_SIMP_TAC[CURVE25519X_GROUP; montgomery_xz] THEN
    GEN_REWRITE_TAC LAND_CONV [IN] THEN
    REWRITE_TAC[montgomery_curve; RING_OF_NUM; curve25519x] THEN
    REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
    ASM_SIMP_TAC[RING_OF_NUM_1; RING_OF_NUM_0; FIELD_NONTRIVIAL; RING_0] THEN
    UNDISCH_TAC `field(f:(int#int)ring)` THEN POP_ASSUM_LIST(K ALL_TAC) THEN
    REPEAT STRIP_TAC THEN FIELD_TAC;
    ALL_TAC] THEN

  FIRST_X_ASSUM(MP_TAC o SPECL
   [`f:(int#int)ring`; `P:((int#int)#(int#int))option`]) THEN
  ASM_REWRITE_TAC[] THEN ANTS_TAC THENL
   [ASM_REWRITE_TAC[curve25519x_canonically_represents] THEN
    REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV THEN
    REWRITE_TAC[RING_OF_NUM_1] THEN
    W(MP_TAC o PART_MATCH (lhand o rand) MONTGOMERY_XZ_XMAP o snd) THEN
    ASM_REWRITE_TAC[RING_OF_NUM] THEN DISCH_THEN MATCH_MP_TAC THEN
    ASM_REWRITE_TAC[RING_OF_NUM_EQ_0; DIVIDES_MOD] THEN
    ASM_SIMP_TAC[MOD_LT];
    DISCH_THEN(MP_TAC o CONJUNCT1)] THEN

  REWRITE_TAC[curve25519x_canonically_represents] THEN
  REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `nn:num` o MATCH_MP GROUP_POW) THEN
  SPEC_TAC(`group_pow (curve25519x_group(f:(int#int)ring)) P nn`,
           `Q:((int#int)#(int#int))option`) THEN
  REWRITE_TAC[FORALL_OPTION_THM] THEN
  GEN_REWRITE_TAC RAND_CONV [FORALL_PAIR_THM] THEN
  REWRITE_TAC[montgomery_xz; montgomery_xmap] THEN
  ASM_SIMP_TAC[RING_OF_NUM_EQ_0; DIVIDES_MOD; MOD_LT] THEN
  REWRITE_TAC[RING_OF_NUM] THEN ONCE_REWRITE_TAC[IN] THEN
  ASM_SIMP_TAC[CURVE25519X_GROUP] THEN
  REWRITE_TAC[montgomery_curve; curve25519x] THEN
  SIMP_TAC[MULT_CLAUSES; MOD_0; RING_OF_NUM_0] THEN
  MAP_EVERY X_GEN_TAC [`u:int#int`; `v:int#int`] THEN
  STRIP_TAC THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC (SUBST1_TAC o SYM)) THEN
  MP_TAC(ISPEC `f:(int#int)ring` RING_OF_NUM_MOD) THEN
  ASM_SIMP_TAC[RING_OF_NUM_MUL] THEN DISCH_THEN(K ALL_TAC) THEN
  REWRITE_TAC[ring_div] THEN AP_TERM_TAC THEN
  MATCH_MP_TAC RING_RINV_UNIQUE THEN
  REWRITE_TAC[RING_OF_NUM; GSYM RING_OF_NUM_MUL] THEN
  REWRITE_TAC[GSYM RING_OF_NUM_1; RING_OF_NUM_EQ] THEN
  FIRST_X_ASSUM(MP_TAC o check (is_imp o concl)) THEN
  ASM_REWRITE_TAC[] THEN
  ANTS_TAC THENL [ALL_TAC; DISCH_THEN(ACCEPT_TAC o CONJUNCT2)] THEN
  ONCE_REWRITE_TAC[COPRIME_SYM] THEN
  SIMP_TAC[PRIME_COPRIME_EQ; PRIME_P25519] THEN
  ASM_SIMP_TAC[DIVIDES_MOD; MOD_LT] THEN
  REWRITE_TAC[p_25519] THEN CONV_TAC NUM_REDUCE_CONV);;

let CURVE25519_X25519_SUBROUTINE_CORRECT = time prove
 (`!res scalar n point X pc stackpointer returnaddress.
    ALL (nonoverlapping (word_sub stackpointer (word 464),464))
        [(word pc,0x1e90); (point,32); (scalar,32)] /\
    nonoverlapping (res,32) (word pc,0x1e90) /\
    nonoverlapping (res,32) (word_sub stackpointer (word 464),472)
    ==> ensures x86
         (\s. bytes_loaded s (word pc) curve25519_x25519_mc /\
              read RIP s = word pc /\
              read RSP s = stackpointer /\
              read (memory :> bytes64 stackpointer) s = returnaddress /\
              C_ARGUMENTS [res; scalar; point] s /\
              bignum_from_memory (scalar,4) s = n /\
              bignum_from_memory (point,4) s = X)
         (\s. read RIP s = returnaddress /\
              read RSP s = word_add stackpointer (word 8) /\
              bignum_from_memory (res,4) s = rfcx25519(n,X))
         (MAYCHANGE [RIP; RSP; RDI; RSI; RAX; RCX; RDX; R8; R9; R10; R11] ,,
          MAYCHANGE SOME_FLAGS ,,
          MAYCHANGE [memory :> bytes(res,32);
                     memory :> bytes(word_sub stackpointer (word 464),464)])`,
  X86_PROMOTE_RETURN_STACK_TAC
    curve25519_x25519_mc CURVE25519_X25519_CORRECT
    `[RBX; RBP; R12; R13; R14; R15]` 464);;

(* ------------------------------------------------------------------------- *)
(* Correctness of Windows ABI version.                                       *)
(* ------------------------------------------------------------------------- *)

let windows_curve25519_x25519_mc = define_from_elf
  "windows_curve25519_x25519_mc"
  "x86/curve25519/curve25519_x25519.obj";;

let WINDOWS_CURVE25519_X25519_SUBROUTINE_CORRECT = time prove
 (`!res scalar n point X pc stackpointer returnaddress.
    ALL (nonoverlapping (word_sub stackpointer (word 480),480))
        [(word pc,0x1e9d); (point,32); (scalar,32)] /\
    nonoverlapping (res,32) (word pc,0x1e9d) /\
    nonoverlapping (res,32) (word_sub stackpointer (word 480),488)
    ==> ensures x86
         (\s. bytes_loaded s (word pc) windows_curve25519_x25519_mc /\
              read RIP s = word pc /\
              read RSP s = stackpointer /\
              read (memory :> bytes64 stackpointer) s = returnaddress /\
              WINDOWS_C_ARGUMENTS [res; scalar; point] s /\
              bignum_from_memory (scalar,4) s = n /\
              bignum_from_memory (point,4) s = X)
         (\s. read RIP s = returnaddress /\
              read RSP s = word_add stackpointer (word 8) /\
              bignum_from_memory (res,4) s = rfcx25519(n,X))
         (MAYCHANGE [RIP; RSP; RAX; RCX; RDX; R8; R9; R10; R11] ,,
          MAYCHANGE SOME_FLAGS ,,
          MAYCHANGE [memory :> bytes(res,32);
                     memory :> bytes(word_sub stackpointer (word 480),480)])`,
  WINDOWS_X86_WRAP_STACK_TAC
   windows_curve25519_x25519_mc curve25519_x25519_mc
   CURVE25519_X25519_CORRECT
    `[RBX; RBP; R12; R13; R14; R15]` 464);;

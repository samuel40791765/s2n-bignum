#############################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#  http://aws.amazon.com/apache2.0
#
# or in the "LICENSE" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
#############################################################################

# The x86 assembly (.S) files are all written for the GNU assembler

OBJ = bignum_add_p25519.o \
      bignum_cmul_p25519.o \
      bignum_cmul_p25519_alt.o \
      bignum_mul_p25519.o \
      bignum_mul_p25519_alt.o \
      bignum_neg_p25519.o \
      bignum_sqr_p25519.o \
      bignum_sqr_p25519_alt.o \
      bignum_sub_p25519.o \
      curve25519_ladderstep.o \
      curve25519_ladderstep_alt.o \
      curve25519_pxscalarmul.o \
      curve25519_pxscalarmul_alt.o \
      curve25519_x25519.o \
      curve25519_x25519_alt.o

%.o : %.S ; $(CC) -E -I../../include $< | as -o $@ -

default: $(OBJ);

clean:; rm -f *.o *.correct

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

OBJ = bignum_add_p384.o \
      bignum_bigendian_6.o \
      bignum_cmul_p384.o \
      bignum_cmul_p384_alt.o \
      bignum_deamont_p384.o \
      bignum_deamont_p384_alt.o \
      bignum_demont_p384.o \
      bignum_demont_p384_alt.o \
      bignum_double_p384.o \
      bignum_half_p384.o \
      bignum_littleendian_6.o \
      bignum_mod_n384.o \
      bignum_mod_n384_alt.o \
      bignum_mod_n384_6.o \
      bignum_mod_p384.o \
      bignum_mod_p384_alt.o \
      bignum_mod_p384_6.o \
      bignum_montmul_p384.o \
      bignum_montmul_p384_alt.o \
      bignum_montsqr_p384.o \
      bignum_montsqr_p384_alt.o \
      bignum_mux_6.o \
      bignum_neg_p384.o \
      bignum_nonzero_6.o \
      bignum_optneg_p384.o \
      bignum_sub_p384.o \
      bignum_tomont_p384.o \
      bignum_tomont_p384_alt.o \
      bignum_triple_p384.o \
      bignum_triple_p384_alt.o \
      p384_montjadd.o \
      p384_montjdouble.o \
      p384_montjmixadd.o

%.o : %.S ; $(CC) -E -I../../include $< | as -o $@ -

default: $(OBJ);

clean:; rm -f *.o *.correct

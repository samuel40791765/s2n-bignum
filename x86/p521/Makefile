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

OBJ = bignum_add_p521.o \
      bignum_cmul_p521.o \
      bignum_cmul_p521_alt.o \
      bignum_deamont_p521.o \
      bignum_demont_p521.o \
      bignum_double_p521.o \
      bignum_fromlebytes_p521.o \
      bignum_half_p521.o \
      bignum_mod_n521_9.o \
      bignum_mod_n521_9_alt.o \
      bignum_mod_p521_9.o \
      bignum_montmul_p521.o \
      bignum_montmul_p521_alt.o \
      bignum_montsqr_p521.o \
      bignum_montsqr_p521_alt.o \
      bignum_mul_p521.o \
      bignum_mul_p521_alt.o \
      bignum_neg_p521.o \
      bignum_optneg_p521.o \
      bignum_sqr_p521.o \
      bignum_sqr_p521_alt.o \
      bignum_sub_p521.o \
      bignum_tolebytes_p521.o \
      bignum_tomont_p521.o \
      bignum_triple_p521.o \
      bignum_triple_p521_alt.o \
      p521_jadd.o \
      p521_jdouble.o \
      p521_jmixadd.o

%.o : %.S ; $(CC) -E -I../../include $< | as -o $@ -

default: $(OBJ);

clean:; rm -f *.o *.correct

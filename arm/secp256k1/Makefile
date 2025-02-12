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

# If actually on an ARM8 machine, just use the GNU assmbler (as). Otherwise
# use a cross-assembling version so that the code can still be assembled
# and the proofs checked against the object files (though you won't be able
# to run code without additional emulation infrastructure). The aarch64
# cross-assembling version can be installed manually by something like:
#
#  sudo apt-get install binutils-aarch64-linux-gnu

UNAME_RESULT=$(shell uname -p)

ifeq ($(UNAME_RESULT),aarch64)
GAS=as
else
GAS=aarch64-linux-gnu-as
endif

# List of object files

OBJ = bignum_add_p256k1.o \
      bignum_cmul_p256k1.o \
      bignum_deamont_p256k1.o \
      bignum_demont_p256k1.o \
      bignum_double_p256k1.o \
      bignum_half_p256k1.o \
      bignum_mod_n256k1_4.o \
      bignum_mod_p256k1_4.o \
      bignum_montmul_p256k1.o \
      bignum_montmul_p256k1_alt.o \
      bignum_montsqr_p256k1.o \
      bignum_montsqr_p256k1_alt.o \
      bignum_mul_p256k1.o \
      bignum_mul_p256k1_alt.o \
      bignum_neg_p256k1.o \
      bignum_optneg_p256k1.o \
      bignum_sqr_p256k1.o \
      bignum_sqr_p256k1_alt.o \
      bignum_sub_p256k1.o \
      bignum_tomont_p256k1.o \
      bignum_triple_p256k1.o \
      secp256k1_jadd.o \
      secp256k1_jdouble.o \
      secp256k1_jmixadd.o

%.o : %.S ; $(CC) -E -I../../include $< | $(GAS) -o $@ -

default: $(OBJ);

clean:; rm -f *.o *.correct

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

OBJ = bignum_add_p25519.o \
      bignum_cmul_p25519.o \
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

%.o : %.S ; $(CC) -E -I../../include $< | $(GAS) -o $@ -

default: $(OBJ);

clean:; rm -f *.o *.correct

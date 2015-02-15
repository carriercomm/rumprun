#!/bin/sh

IFS=' '
BUILDXENMETAL_MKCONF=".if defined(LIB) && \${LIB} == \"pthread\"
.PATH:  $(pwd)/pthread
PTHREAD_MAKELWP=_lwp.c
CPPFLAGS+=      -D_PTHREAD_GETTCB_EXT=_lwp_rumpbaremetal_gettcb
CPPFLAGS._lwp.c= -I$(pwd)/include
.endif  # LIB == pthread"
unset IFS

export BUILDXENMETAL_PCI_P='[ "${MACHINE}" = "amd64" -o "${MACHINE}" = "i386" ]'
export BUILDXENMETAL_PCI_ARGS='RUMP_PCI_IOSPACE=yes'
export BUILDXENMETAL_MKCONF

[ ! -f ./buildrump.sh/subr.sh ] && git submodule update --init buildrump.sh
. ./buildrump.sh/subr.sh
./buildrump.sh/xenbaremetal.sh "$@" || die xenbaremetal.sh failed

# build unwind bits
RUMPMAKE=$(pwd)/rumptools/rumpmake
( cd librumprun_unwind && ${RUMPMAKE} dependall && ${RUMPMAKE} install )

# build the image
make

echo
echo ">> $0 ran successfully"
exit 0

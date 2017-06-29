#!/bin/bash -e
. /etc/profile.d/modules.sh
# We provide the base module which all jobs need to get their environment on the build slaves
module load deploy
module add ncurses
module add libpng
module add gcc/${GCC_VERSION}
module add readline

# We will be running configure and make in this directory
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
make distclean

# Note that $SOFT_DIR is used as the target installation directory.
export LDFLAGS="-L${NCURSES_DIR}/lib"
export CFLAGS="-I${NCURSES_DIR}/include/"
./BUILD_DIR/configure \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION} \
--enable-png \
--with-png=${PNG_DIR} \
--enable-readline
make

make install
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module add ncurses
module add libpng
module add gcc/${GCC_VERSION}

module-whatis   "$NAME $VERSION."
setenv       HEASOFT_VERSION       $VERSION
setenv       HEASOFT_DIR      $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/${VERSION}-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(HEASOFT_DIR)/lib
prepend-path HEASOFT_INCLUDE_DIR   $::env(HEASOFT_DIR)/include
prepend-path CPATH             $::env(HEASOFT_DIR)/include
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}

mkdir -p ${ASTRONOMY}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION} ${ASTRONOMY}/${NAME}

module avail ${NAME}
module add  ${NAME}/${VERSION}-gcc-${GCC_VERSION}

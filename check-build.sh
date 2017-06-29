#!/bin/bash -e
. /etc/profile.d/modules.sh
module load ci
module add ncurses
module add libpng
module add gcc/${GCC_VERSION}
module add readline
echo ""
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}

echo $?

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
setenv       HEASOFT_DIR      /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/${VERSION}-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(HEASOFT_DIR)/lib
prepend-path HEASOFT_INCLUDE_DIR   $::env(HEASOFT_DIR)/include
prepend-path CPATH             $::env(HEASOFT_DIR)/include
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}

mkdir -p ${ASTRONOMY}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION} ${ASTRONOMY}/${NAME}

module avail
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}

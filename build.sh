#!/bin/bash -e
. /etc/profile.d/modules.sh
SOURCE_FILE=${NAME}-${VERSION}src.tar.gz

# We provide the base module which all jobs need to get their environment on the build slaves
module load ci
module add ncurses
module add libpng
module add gcc/${GCC_VERSION}


# Workspace is the "home" directory of jenkins into which the project itself will be created and built.
mkdir -p $WORKSPACE
# SRC_DIR is the local directory to which all of the source code tarballs are downloaded. We cache them locally.
mkdir -p $SRC_DIR
# SOFT_DIR is the directory into which the application will be "installed"
mkdir -p $SOFT_DIR

#  Download the source file if it's not available locally.
#  we were originally using ncurses as the test application
if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  wget http://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release/$SOURCE_FILE -O $SRC_DIR/$SOURCE_FILE
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi

tar xvzf ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files

cd $WORKSPACE/$NAME-$VERSION/build-${BUILD_NUMBER}
# Note that $SOFT_DIR is used as the target installation directory.
export LDFLAGS="-L${NCURSES_DIR}/lib"
export CFLAGS="-I${NCURSES_DIR}/include/"
./configure \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION} \
--enable-png \
--with-png=${PNG_DIR} \
--enable-readline

make

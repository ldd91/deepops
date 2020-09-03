#!/bin/bash 

export BUILD_CUDA=${BUILD_CUDA:-1}
export BUILD_HPCX=${BUILD_HPCX:-1}

export BASEDIR=${BASEDIR:-$(cd $(dirname 0) && pwd)}
export BUILDDIR=${BUILDDIR:-/tmp/build.$$}

APPSDIR=${BASEDIR}/apps

mkdir -p $APPSDIR
mkdir -p $BUILDDIR

CUDA_VERSION=11.0.2
CUDA_HOME=${APPSDIR}/cuda/${CUDA_VERSION}
mkdir -p ${CUDA_HOME}

HPCX_URL="http://www.mellanox.com/downloads/hpc/hpc-x/v2.7/hpcx-v2.7.0-gcc-MLNX_OFED_LINUX-5.0-1.0.0.0-ubuntu18.04-x86_64.tbz"
HPCX_VERSION=$(echo $HPCX_URL | grep -o '[^/]*$' | cut -f5-6 -d-)
HPCX_FN=$(basename ${HPCX_URL})
HPCX_DIR=$(basename ${HPCX_FN} .tbz)

if [ $BUILD_CUDA == 1 ]; then
    cd ${BUILDDIR}
    CUDAPATH=http://developer.download.nvidia.com/compute/cuda/11.0.2/local_installers/cuda_11.0.2_450.51.05_linux.run
    CUDAFN=$(basename ${CUDAPATH})
    rm ${CUDAFN}
    wget http://developer.download.nvidia.com/compute/cuda/11.0.2/local_installers/${CUDAFN}
    sh ${CUDAFN} --installpath=${CUDA_HOME} --silent --toolkit

    if [ $? -ne 0 ]; then
	echo "Install of CUDA failed.  Exiting"
	exit
   fi
fi

if [ $BUILD_HPCX == 1 ]; then
	# First some sanity checking to make sure that the right version
	if [ x"$(which ofed_info)" == x"" ]; then
		echo "Error, unable to find ofed_info.  IB or RoCE is not enabld on this system.  Exiting"
		exit
	fi

	ofed_version=$(ofed_info -n)
	ofed_version_major=$(echo $ofed_version | awk '{print $NF}' | cut -f1 -d-)
	hpcx_version=$(echo $HPCX_URL | grep -o '[^/]*$' | cut -f5-6 -d-)
	hpcx_version_major=$(echo $hpcx_version | grep -o '[^/]*$' | cut -f1 -d-)

	echo "OFED VERSION: ${ofed_version} ${ofed_version_major} ${hpcx_version} ${hpcx_version_major}"
	if [ ${ofed_version_major} != ${hpcx_version_major} ]; then
		echo "Error, the local ofed version ($ofed_version} is not correct for the request HPCX version {$hpcx_version_major}."
		echo "The build script needs to be updated to match the local MOFED version."
		exit
	fi
	
	echo "Downloading file"
	if [ -f $BUILDDIR/$HPCX_FN ]; then
		rm $BUILDDIR/$HPCX_FN
	fi
	wget -q -nc --no-check-certificate -P $BUILDDIR $HPCX_URL
	ls -al
	cd $APPSDIR
	tar -xjf $BUILDDIR/$HPCX_FN
	ls -al
fi

# create setenv.sh script

echo "
export APPSDIR=${APPSDIR}

export HPCX_HOME=\${APPSDIR}/$HPCX_DIR
export CUDA_HOME=\${APPSDIR}/cuda/${CUDA_VERSION}

source \${HPCX_HOME}/hpcx-init.sh
hpcx_load

export PATH=\${CUDA_HOME}/bin:\${PATH}
export LD_LIBRARY_PATH=\${CUDA_HOME}/lib64:\${LD_LIBRARY_PATH}

echo \" Loaded HPCX: \${HPCX_HOME}\"
echo \" UCX Version: \$(ucx_info -v)\"
echo \"OMPI Version: \$(ompi_info --version)\"
" > setenv.sh

echo "Created setenv.sh to setup your environment.  Execute 'source setenv.sh' to enable."
cat setenv.sh



#!/bin/bash -e

# ----------------------------------------------------------------------------
#
# Package               : operator-sdk
# Version               : v0.18.0 
# Source repo           : https://github.com/operator-framework/operator-sdk
# Tested on             : RHEL 8.5,UBI 8.5
# Language              : GO
# Script License        : Apache License, Version 2 or later
# Travis-Check          : True
# Maintainer            : Bhagat Singh<bhagat.singh1@ibm.com>
#
# Disclaimer            : This script has been tested in root mode on given
# ==========              platform using the mentioned version of the package.
#                         It may not work as expected with newer versions of the
#                         package and/or distribution. In such case, please
#                         contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

#Exit immediately if a command exits with a non-zero status.
set -e
yum install git gcc -y

#Set variables 
#PACKAGE_VERSION is configurable can be passed as an argument.
PACKAGE_VERSION=${1:-v0.18.0}
PACKAGE_NAME=github.com/operator-framework/operator-sdk
OS_NAME=$(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)

#Install go package and update go path if not installed 
if ! command -v go &> /dev/null
then
curl -O https://dl.google.com/go/go1.15.6.linux-ppc64le.tar.gz
tar -C /usr/local -xzf go1.15.6.linux-ppc64le.tar.gz
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
export GO111MODULE=auto
fi


#Check if package exists
if [ -d "operator-sdk" ] ; then
  rm -rf operator-sdk
  echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Removed existing package if any"  
 
fi
 

# Download the repos
git clone https://github.com/operator-framework/operator-sdk


# Build and Test
cd operator-sdk
git checkout $PACKAGE_VERSION
ret=$?
if [ $ret -eq 0 ] ; then
 echo "---------------------------$PACKAGE_VERSION found to checkout--------------------- "
else
 echo "---------------------------$PACKAGE_VERSION not found-----------------------------"
 exit
fi 

# Ensure go.mod file exists

  [ ! -f go.mod ] && go mod init

#Build and test
go get -v -t ./...

ret=$?
if [ $ret -ne 0 ] ; then
  echo "Build failed "
    echo "------------------$PACKAGE_NAME:build failed---------------------"
    echo "$PACKAGE_VERSION $PACKAGE_NAME"
    echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  build_Fails"
    exit 1
else
  go test -v ./...
  if [ $ret -ne 0 ] ; then
            echo "------------------$PACKAGE_NAME:test_fails---------------------"
            echo "$PACKAGE_VERSION $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Test_Fails"    
    exit 1
  else
       echo "------------------$PACKAGE_NAME:install_build_and_test_success-------------------------"
       echo "$PACKAGE_VERSION $PACKAGE_NAME"
       echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Pass |  Install_Build_and_Test_Success"
    exit 0 
fi
fi

#Its in parity with intel for test case failure --- FAIL: TestE2E (121.65s).
        #try setting KUBERNETES_MASTER environment variable. Kubernetes setup may be required here.
        #  operator_olm_test.go
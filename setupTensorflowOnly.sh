#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

################################################################################
# Install TensorFlow from git.
################################################################################
export TF_VER=0.11
echo "$GREEN ########################################################## $NC"
echo "$GREEN *** Installing TensorFlow $TF_VER *** $NC"
echo "$GREEN ########################################################## $NC"
export TF_BINARY_URL=https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-$TF_VER.0rc0-cp35-cp35m-linux_x86_64.whl
export VIR_URL=https://pypi.python.org/packages/45/9c/acd0645222dc9f3593e86a33b3e5cae0be841c04807bf0f183625bc5fe85/virtualenv-15.0.3-py2.py3-none-any.whl#md5=75d2e7305967ec368c43152b7c55546e
while true; do
  echo "Which way would you like to install TensorFlow $TF_VER?  \n1) Source code, 2) pip 3) Virtualenv 4) Anaconda 5) Docker 6) skip? [1/2/3/4/5/6]"
  read TF_NUM
  case $TF_NUM in
      1) echo "$GREEN *** Cloning TensorFlow from GitHub *** $NC"
         git clone --recurse-submodules -b r$TF_VER https://github.com/tensorflow/tensorflow.git
         sed -i 's/kDefaultTotalBytesLimit = 64/kDefaultTotalBytesLimit = 128/' tensorflow/google/protobuf/src/google/protobuf/io/coded_stream.h
         ;;
      2) sudo pip3 install --upgrade pip
         sudo pip3 install --upgrade $TF_BINARY_URL
         echo "$GREEN *** Installing Numpy & Matplotlib *** $NC"
         sudo apt-get install python-numpy
         sudo apt-get install python-numpy python-scipy python-matplotlib ipython \
         ipython-notebook python-pandas python-sympy python-nose
         sudo pip3 install numpy --upgrade
         sudo pip3 install matplotlib --upgrade
         ;;
      3) sudo pip3 install --upgrade pip
         sudo apt-get install python-pip python-dev python-virtualenv
         sudo pip3 install --upgrade $VIR_URL
         virtualenv --system-site-packages ~/tensorflow
         sudo pip3 install --upgrade $TF_BINARY_URL
         source ~/tensorflow/bin/activate
         echo "$GREEN *** Installing Numpy & Matplotlib *** $NC"
         sudo apt-get install python-numpy python-scipy python-matplotlib ipython \
         ipython-notebook python-pandas python-sympy python-nose
         sudo pip3 install numpy --upgrade
         sudo pip3 install matplotlib --upgrade
         ;;
      4) wget https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
         chmod +x Anaconda3-4.2.0-Linux-x86_64.sh
         bash ./Anaconda3-4.2.0-Linux-x86_64.sh
         echo 'export PATH=/home/$USER/anaconda3/bin:$PATH' >> .bashrc
         ~/anaconda3/bin/conda create -n tensorflow python=3.5
         source activate tensorflow
         ~/anaconda3/bin/conda install ipython
         ;;
      5) sudo apt-get install apt-transport-https ca-certificates
         sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
         echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' >> docker.list
         sudo cp docker.list /etc/apt/sources.list.d/
         sudo apt-get update
         sudo apt-get purge lxc-docker
         apt-cache policy docker-engine
         sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
         sudo apt-get install docker-engine
         sudo service docker start
         sudo groupadd docker
         sudo usermod -aG docker $USER
         echo "$GREEN *** Installing Numpy & Matplotlib *** $NC"
         sudo apt-get install python-numpy
         sudo apt-get install python-numpy python-scipy python-matplotlib ipython \
         ipython-notebook python-pandas python-sympy python-nose
         sudo pip3 install numpy --upgrade
         sudo pip3 install matplotlib --upgrade
         #reboot to take effect: https://goo.gl/dJDaKY
         #docker run -it -p 8888:8888 -p 6006:6006 --name tensorflow gcr.io/tensorflow/tensorflow
         echo "$GREEN Run 'docker run -it -p 8888:8888 -p 6006:6006 --name tensorflow gcr.io/tensorflow/tensorflow' after system re-login or reboot.$NC"
         read -rsp $'Press any key to continue...\n' -n1 key
         ;;
       6) break;;
       *) echo "Please answer 1) Source code, 2) pip 3) Virtualenv 4) Anaconda 5) Docker 6) skip? [1/2/3/4/5/6]";;
   esac
done

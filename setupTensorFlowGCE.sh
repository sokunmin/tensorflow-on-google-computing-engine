
mkdir tensorflow
cd tensorflow

GREEN='\033[0;32m'
NC='\033[0m'

################################################################################
# Install utils.
################################################################################
echo "$GREEN ########################################################## $NC"
echo "$GREEN *** Installing utilities *** $NC"
echo "$GREEN ########################################################## $NC"
sudo apt-get update
sudo apt-get install unzip git-all pkg-config zip g++ zlib1g-dev
echo 'Press any key to continue installation...\n'
read null

################################################################################
# Install Java deps.
################################################################################
echo "$GREEN ########################################################## $NC"
echo "$GREEN *** Installing Java8. Press ENTER when prompted *** $NC"
echo "$GREEN *** And accept licence *** $NC"
echo "$GREEN ########################################################## $NC"
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer
echo 'Press any key to continue installation...\n'
read null

################################################################################
# Install Bazel dep.
################################################################################
echo "$GREEN ########################################################## $NC"
echo "$GREEN *** Installing Bazel *** $NC"
echo "$GREEN ########################################################## $NC"
wget https://goo.gl/OQ2ZCl -O bazel-installer-linux-x86_64.sh
chmod +x bazel-installer-linux-x86_64.sh
sudo ./bazel-installer-linux-x86_64.sh
rm bazel-installer-linux-x86_64.sh
sudo chown $USER:$USER ~/.cache/bazel/
echo 'Press any key to continue installation...\n'
read null

################################################################################
# Install Swig
################################################################################
echo "$GREEN ########################################################## $NC"
echo "$GREEN *** Installing swig & python deps *** $NC"
echo "$GREEN ########################################################## $NC"
sudo apt-get install swig
sudo apt-get install build-essential python-setuptools python-dev python-pip checkinstall
sudo apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev \
libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
echo 'Press any key to continue installation...\n'
read null


################################################################################
# Install Python 3.5
# Yes/No script example: https://goo.gl/BwVTKI
################################################################################
echo "$GREEN ########################################################## $NC"
echo "$GREEN *** Installing Python 3.5 *** $NC"
echo "$GREEN ########################################################## $NC"
while true; do
  echo "Which way would you like to install Python 3.5?  1)source code or 2) apt-get? [1/2]"
  read NUM
  case $NUM in
    1) echo -e "{GREEN} *** Installing Python 3.5 from source code *** {NC}"
       export PYTHON_VERSION=3.5.2
       wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
       tar -xvf Python-$PYTHON_VERSION.tgz
       cd Python-$PYTHON_VERSION
       ./configure
       make
       sudo make install
       cd ../
       rm Python-$PYTHON_VERSION.tgz
       sudo echo "alias python=python3.5" >> ~/.bashrc
       source ~/.bashrc
       break;;
     2)
       sudo add-apt-repository ppa:fkrull/deadsnakes
       sudo apt-get update
       sudo apt-get install python3.5
       sudo apt-get install libzmq-dev

       # update-alternatives: https://goo.gl/NRvWgY
       sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
       sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.5 2
       wget https://bootstrap.pypa.io/get-pip.py
       sudo python3.5 get-pip.py
       break;;
     *) echo "Please answer 1 or 2";;
  esac
done

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
         break;;
      2) sudo pip3 install --upgrade pip
         sudo pip3 install --upgrade $TF_BINARY_URL
         echo "$GREEN *** Installing Numpy & Matplotlib *** $NC"
         sudo apt-get install python-numpy
         sudo apt-get install python-numpy python-scipy python-matplotlib ipython \
         ipython-notebook python-pandas python-sympy python-nose
         sudo pip3 install numpy --upgrade
         sudo pip3 install matplotlib --upgrade
         break;;
      3) sudo pip3 install --upgrade pip
         sudo apt-get install python-pip python-dev python-virtualenv
         sudo pip3 install --upgrade $VIR_URL
         virtualenv --system-site-packages ~/tensorflow
         sudo pip3 install --upgrade $TF_BINARY_URL
         source ~/tensorflow/bin/activate
         echo "$GREEN *** Installing Numpy & Matplotlib *** $NC"
         sudo apt-get install python-numpy
         sudo apt-get install python-numpy python-scipy python-matplotlib ipython \
         ipython-notebook python-pandas python-sympy python-nose
         sudo pip3 install numpy --upgrade
         sudo pip3 install matplotlib --upgrade
         break;;
      4) wget https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
         chmod +x Anaconda3-4.2.0-Linux-x86_64.sh
         bash ./Anaconda3-4.2.0-Linux-x86_64.sh
         echo 'export PATH=/home/$USER/anaconda3/bin:$PATH' >> .bashrc
         ~/anaconda3/bin/conda create -n tensorflow python=3.5
         source activate tensorflow
         ~/anaconda3/bin/conda install ipython
         break;;
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
         echo "Run 'docker run -it -p 8888:8888 -p 6006:6006 --name tensorflow gcr.io/tensorflow/tensorflow' after system re-login or reboot."
         read -rsp $'Press any key to continue...\n' -n1 key
         break;;
       6) break;;
       *) echo "Please answer 1) Source code, 2) pip 3) Virtualenv 4) Anaconda 5) Docker 6) skip? [1/2/3/4/5/6]";;
   esac
done
################################################################################
# GCE has no swap, prevent trying to use one else out of virtual memory error.
################################################################################
echo 'Press any key to continue installation...\n'
read null


echo "$GREEN ########################################################## $NC"
echo "$GREEN *** Changing swappiness *** $NC"
echo "$GREEN ########################################################## $NC"
sudo sysctl vm.swappiness=0
# Make change persistent even after reboot.
cp /etc/sysctl.conf /tmp/
echo "vm.swappiness=0" >> /tmp/sysctl.conf
sudo cp /tmp/sysctl.conf /etc/

################################################################################
# Make a swap which is used only if RAM not available.
################################################################################
echo "$GREEN ########################################################## $NC"
echo "$GREEN *** Creating swap file *** $NC"
echo "$GREEN ########################################################## $NC"
sudo touch /var/swap.img
sudo chmod 600 /var/swap.img
# Create approx 4GB swap assuming 3.6GB RAM (almost 8GB total space available)
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=4000
sudo mkswap /var/swap.img
sudo swapon /var/swap.img
free
echo "$GREEN Ready to run TensorFlow! $NC"


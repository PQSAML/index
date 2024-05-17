#!/bin/sh

sudo apt install unzip

mkdir temp
cd temp
wget https://corretto.aws/downloads/resources/8.412.08.1/amazon-corretto-8.412.08.1-linux-x64.tar.gz -O corretto8.tar.gz
wget https://corretto.aws/downloads/resources/11.0.23.9.1/amazon-corretto-11.0.23.9.1-linux-x64.tar.gz -O corretto11.tar.gz
wget https://corretto.aws/downloads/resources/17.0.11.9.1/amazon-corretto-17.0.11.9.1-linux-x64.tar.gz -O corretto17.tar.gz
wget https://corretto.aws/downloads/resources/21.0.3.9.1/amazon-corretto-21.0.3.9.1-linux-x64.tar.gz -O corretto21.tar.gz

mkdir $HOME/jdks
mkdir $HOME/jdks/21
mkdir $HOME/jdks/17
mkdir $HOME/jdks/11
mkdir $HOME/jdks/8

tar -xvzf corretto21.tar.gz
rm corretto21.tar.gz
mv amazon-corretto-21.0.3.9.1-linux-x64/* $HOME/jdks/21
rm -rf amazon-corretto-21.0.3.9.1-linux-aarch64

tar -xvzf corretto17.tar.gz
rm corretto17.tar.gz
mv amazon-corretto-17.0.11.9.1-linux-x64/* $HOME/jdks/17
rm -rf amazon-corretto-17.0.11.9.1-linux-aarch64

tar -xvzf corretto11.tar.gz
rm corretto11.tar.gz
mv amazon-corretto-11.0.23.9.1-linux-x64/* $HOME/jdks/11
rm -rf amazon-corretto-11.0.23.9.1-linux-aarch64

tar -xvzf corretto8.tar.gz
rm corretto8.tar.gz
mv amazon-corretto-8.412.08.1-linux-x64/* $HOME/jdks/8
rm -rf amazon-corretto-8.412.08.1-linux-aarch64

BASH_RC=$HOME/.bashrc

echo "export BC_JDK21=\"$HOME/jdks/21\"" >> $BASH_RC
echo "export BC_JDK17=\"$HOME/jdks/17\"" >> $BASH_RC
echo "export BC_JDK11=\"$HOME/jdks/11\"" >> $BASH_RC
echo "export BC_JDK8=\"$HOME/jdks/8\"" >> $BASH_RC
echo "export JAVA_HOME=\"$HOME/jdks/21\"" >> $BASH_RC

wget https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -O maven.tar.gz
wget https://services.gradle.org/distributions/gradle-8.6-bin.zip -O gradle.zip

tar -xvzf maven.tar.gz
rm maven.tar.gz

mkdir $HOME/maven
mv apache-maven-3.9.6/* $HOME/maven
rm -rf apache-maven-3.9.6

unzip gradle.zip
rm gradle.zip
mkdir $HOME/gradle
mv gradle-8.6/* $HOME/gradle
rm -rf gradle-8.6

mkdir $HOME/.m2
wget https://raw.githubusercontent.com/PQSAML/index/main/settings.xml -O $HOME/.m2/settings.xml

echo "export PATH=\"$PATH:$HOME/jdks/21/bin:$HOME/maven/bin:$HOME/gradle/bin\"" >> $BASH_RC

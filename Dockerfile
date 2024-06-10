FROM --platform=linux/arm64 alpine:3.20

LABEL maintainer="PQSAML"

WORKDIR /home
RUN apk update
RUN apk add git
RUN mkdir /opt/jdk
RUN mkdir /opt/jdk/21
RUN mkdir /opt/jdk/17
RUN mkdir /opt/jdk/11
RUN mkdir /opt/jdk/8

ARG VERSION_JDK_21="21.0.3.9.1"
ARG VERSION_JDK_17="17.0.11.9.1"
ARG VERSION_JDK_11="11.0.23.9.1"
ARG VERSION_JDK_8="8.412.08.1"


RUN wget https://corretto.aws/downloads/resources/${VERSION_JDK_8}/amazon-corretto-${VERSION_JDK_8}-alpine-linux-aarch64.tar.gz -O corretto8.tar.gz
RUN wget https://corretto.aws/downloads/resources/${VERSION_JDK_11}/amazon-corretto-${VERSION_JDK_11}-alpine-linux-aarch64.tar.gz -O corretto11.tar.gz
RUN wget https://corretto.aws/downloads/resources/${VERSION_JDK_17}/amazon-corretto-${VERSION_JDK_17}-alpine-linux-aarch64.tar.gz -O corretto17.tar.gz
RUN wget https://corretto.aws/downloads/resources/${VERSION_JDK_21}/amazon-corretto-${VERSION_JDK_21}-alpine-linux-aarch64.tar.gz -O corretto21.tar.gz

RUN tar -xvzf corretto21.tar.gz
RUN rm corretto21.tar.gz
RUN mv amazon-corretto-${VERSION_JDK_21}-alpine-linux-aarch64/* /opt/jdk/21
RUN rm -rf amazon-corretto-${VERSION_JDK_21}-alpine-linux-aarch64

RUN tar -xvzf corretto17.tar.gz
RUN rm corretto17.tar.gz
RUN mv amazon-corretto-${VERSION_JDK_17}-alpine-linux-aarch64/* /opt/jdk/17
RUN rm -rf amazon-corretto-${VERSION_JDK_17}-alpine-linux-aarch64

RUN tar -xvzf corretto11.tar.gz
RUN rm corretto11.tar.gz
RUN mv amazon-corretto-${VERSION_JDK_11}-alpine-linux-aarch64/* /opt/jdk/11
RUN rm -rf amazon-corretto-${VERSION_JDK_11}-alpine-linux-aarch64

RUN tar -xvzf corretto8.tar.gz
RUN rm corretto8.tar.gz
RUN mv amazon-corretto-${VERSION_JDK_8}-alpine-linux-aarch64/* /opt/jdk/8
RUN rm -rf amazon-corretto-${VERSION_JDK_8}-alpine-linux-aarch64

ENV BC_JDK21=/opt/jdk/21
ENV BC_JDK17=/opt/jdk/17
ENV BC_JDK11=/opt/jdk/11
ENV BC_JDK8=/opt/jdk/8
ENV JAVA_HOME=/opt/jdk/21

COPY apache-maven-3.9.6-bin.tar.gz maven.tar.gz

RUN tar -xvzf maven.tar.gz
RUN rm maven.tar.gz

RUN mkdir /opt/maven
RUN mv apache-maven-3.9.6/* /opt/maven
RUN rm -rf apache-maven-3.9.6
ENV PATH="$PATH:/opt/maven/bin"

COPY gradle-8.6-bin.zip gradle.zip

RUN unzip gradle.zip

RUN mkdir /opt/gradle
RUN mv gradle-8.6/* /opt/gradle
RUN rm -rf gradle-8.6
ENV PATH="$PATH:/opt/gradle/bin"

RUN git clone https://github.com/PQSAML/bc-java-pqsaml.git
WORKDIR bc-java-pqsaml
RUN gradle prov:build -x test 
RUN gradle pkix:build -x test
RUN gradle util:build -x test

RUN mvn install:install-file -Dfile="prov/build/libs/bcprov-jdk18on-1.78-PQ.jar" -DgroupId="org.bouncycastle" -DartifactId="bcprov-jdk18on" -Dversion="1.78-PQ" -Dpackaging=jar
RUN mvn install:install-file -Dfile="pkix/build/libs/bcpkix-jdk18on-1.78-PQ.jar" -DgroupId="org.bouncycastle" -DartifactId="bcpkix-jdk18on" -Dversion="1.78-PQ" -Dpackaging=jar
RUN mvn install:install-file -Dfile="util/build/libs/bcutil-jdk18on-1.78-PQ.jar" -DgroupId="org.bouncycastle" -DartifactId="bcutil-jdk18on" -Dversion="1.78-PQ" -Dpackaging=jar

WORKDIR /home
RUN git clone https://github.com/PQSAML/santuario-xml-security-java-pqsaml
WORKDIR santuario-xml-security-java-pqsaml
RUN mvn install -DskipTests

COPY settings.xml /root/.m2/settings.xml

WORKDIR /home
RUN git clone https://github.com/PQSAML/java-opensaml-pq
WORKDIR java-opensaml-pq
RUN git checkout 4.3.0-pq
WORKDIR opensaml-parent
RUN mvn -Prelease -DskipTests -D no-check-m2 -Dmaven.javadoc.skip=true install

WORKDIR /home
RUN git clone https://github.com/PQSAML/benchmarks.git
WORKDIR benchmarks
RUN mvn -PbuildSignaturesBenchmark package
RUN mvn -PbuildKEMsBenchmark package
RUN mvn -PbuildSAMLBenchmark package

ENV PATH="$PATH:/opt/jdk/21/bin"



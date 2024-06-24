# Post-quantum XML/SAML
This repository serves as an index of repositories used in the post-quantum SAML paper.

In total, we have 5 repositories:
- This index repository https://github.com/PQSAML/index.
- BouncyCastle fork repository https://github.com/PQSAML/bc-java-pqsaml.
- Apache Santuario fork repository https://github.com/PQSAML/santuario-xml-security-java-pqsaml.
- OpenSAML fork repository https://github.com/PQSAML/java-opensaml-pq/tree/4.3.0-pq.
- A repository containing our benchmark scripts https://github.com/PQSAML/benchmarks.

Note that forked repositories contain their own build instructions but we provide a complete guide how to build the benchmark scripts from scratch here. Alternately, we provide pre-built executable JARs.

# Overview 
Everything is in Java. We tested everything on MacOS (tested on version 14.3.1, MacBook Pro M1) with Java JDK 21. Similar build process should be reproducible on other UNIX-based systems.

Because the build process is fairly complex due to the amount of dependencies, we also provide pre-built JARs at https://github.com/PQSAML/index/tree/main/prebuilt. 

Each library subfolder (BouncyCastle, Apache Santuario, OpenSAML) contains a bash script which installs the JARs into the local Maven repository in case you want to skip building certain libraries and use the pre-built ones. 

Note that the folder `benchmarks` https://github.com/PQSAML/index/tree/main/prebuilt/benchmarks contains the final executable benchmark scripts which can be run using instructions below https://github.com/PQSAML/index?tab=readme-ov-file#running-benchmark-scripts. For those, you only need Java 17 (we tested it on JDK 20 and JDK 21).

If you want to build it all from scratch, follow all the steps at https://github.com/PQSAML/index?tab=readme-ov-file#complete-build-process or use Docker described at https://github.com/PQSAML/index?tab=readme-ov-file#docker-build-and-execution.

# Docker build and execution
We also provide a Dockerfile which sets up the build environment, builds everything and can be used to run benchmarks. 

Note that running benchmarks inside a docker container may result in decreased performance compared to running it natively.

## Building Docker image
This will run the whole build process.
``` 
docker build -t pqsamlbenchmarks -f Dockerfile-[arch] .
```

Where `[arch]` is `x86` if you are running docker on an x86 system and `arm` if you are on an ARM64 system.

Alternatively, you could run, e.g., `Dockerfile-arm` on an x86 system but you need to have installed an emulation layer together with Docker.

 For example, on Ubuntu 22.04 it is necessary to install QEMU:
```
sudo apt install qemu-user-static
```

## Running benchmarks inside Docker
To run benchmarks inside the Docker container we have prepared a helped bash script at https://github.com/PQSAML/index/blob/main/dockerRunBenchmark.sh. The result files are going to be placed inside the current working directory (from which the bash script is run).

To run each benchmark simply run
```
./dockerRunBenchmark.sh [type]
```
where `[type]` can be these values:
- `sig:purely` - Runs the purely post-quantum XML signatures benchmark.
- `sig:composite` - Runs the composite hybrid post-quantum XML signatures benchmark.
- `sig:separate` - Runs the separate hybrid post-quantum XML signatures benchmark.
- `pke:purely` - Runs the purely post-quantum XML PKE benchmark.
- `pke:hybrid` - Runs the hybrid post-quantum XML PKE benchmark.
- `saml:purely` - Runs the purely post-quantum SAML SSO benchmark.
- `saml:back` - Runs the backward compatible hybrid post-quantum SAML SSO benchmark.
- `saml:nonback` - Runs the non-backward compatible hybrid post-quantum SAML SSO benchmark.

## Alternative Docker option
Alternatively, you can simply build the docker image and extract the JARs from the running container and run them natively using instructions at https://github.com/PQSAML/index?tab=readme-ov-file#running-benchmark-scripts.

To extract the JARs from the docker container simply run:
```
docker run -it --net=none --mount type=bind,source=$PWD,target=/workdir pqsamlbenchmarks /bin/sh -c "cp /home/benchmarks/target/BenchmarkSignatures.jar /workdir/BenchmarkSignatures.jar"
docker run -it --net=none --mount type=bind,source=$PWD,target=/workdir pqsamlbenchmarks /bin/sh -c "cp /home/benchmarks/target/BenchmarkKEMs.jar /workdir/BenchmarkKEMs.jar"
docker run -it --net=none --mount type=bind,source=$PWD,target=/workdir pqsamlbenchmarks /bin/sh -c "cp /home/benchmarks/target/BenchmarkSAML.jar /workdir/BenchmarkSAML.jar"
```

# Complete build process
The dependency chain is as follows: 
- our benchmark scripts depend on OpenSAML and BouncyCastle. 
- OpenSAML depends on Apache Santuario and BouncyCastle. 

Therefore, the recommended build order is
1. Build and install BouncyCastle
2. Build and install Apache Santuario
3. Build and install OpenSAML
4. Build and run benchmark scripts.

## Build preliminaries
We need these build tools:
- JDK 8, 11, 17 and 21 (without BouncyCastle only version 21)
- Maven 3.9
- Gradle 8.6
- Git

Note that the [`setupEnv.sh`](https://github.com/PQSAML/index/blob/main/setupEnv.sh) provides an automated way to setup the JDKs, Maven and Gradle (tested on Ubuntu 22.04). It is an aggregation of the commands described below.

### JDK
If you choose to built BouncyCastle from scratch, note that BouncyCastle requires to have 4 versions of JDK installed. 

We use the Amazon Corretto JDK available at https://aws.amazon.com/corretto/.

- JDK 8 https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/downloads-list.html
- JDK 11 https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/downloads-list.html
- JDK 17 https://docs.aws.amazon.com/corretto/latest/corretto-17-ug/downloads-list.html
- JDK 21 https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/downloads-list.html

Also, BouncyCastle requires to set these environment variables to run the build process.

```
export BC_JDK8=/path/to/java8
export BC_JDK11=/path/to/java11
export BC_JDK17=/path/to/java17
export BC_JDK21=/path/to/java21
```

### Maven
Maven (https://maven.apache.org/index.html) is used to build Apache Santuario, OpenSAML and our benchmark scripts.

On MacOS Maven can be installed using Homebrew as follows:
```
brew install maven@3.9
``` 

### Gradle
Gradle (https://gradle.org/) is used to build BouncyCastle.

On MacOS Gradle can be installed using Homebrew as follows:
```
brew install gradle@8
```

### Git 
To download the code from Github the most convenient way is to use git. We refer the reader to https://github.com/git-guides/install-git for installation instructions.

## Bulding BouncyCastle
First, we need to build our modified BouncyCastle library with support for composite hybrid post-quantum signatures. 

BouncyCastle actually consists of multiple libraries and for our purposes we need the provider (folder `prov`), the PKI library (folder `pkix`) and the ASN.1 utility library (folder `util`).

Detailed BouncyCastle build instructions can be found in its repository but we provide the necessary steps below. 

Assuming preliminaries are installed. We need to clone the repository and then navigate into the root directory
```
git clone https://github.com/PQSAML/bc-java-pqsaml.git
cd bc-java-pqsaml
```
Then, the three libraries can be built by calling the script `build-jars.sh` script in the root directory (note that you might need to enable executing the script with `chmod +x build-jars.sh`):
```
./build-jars.sh
```

Alternatively, you can use following commands (option `-x test` skips tests for faster build):

```
gradle prov:build -x test
gradle pkix:build -x test
gradle util:build -x test
```

The built libraries will be in each library subfolder in `build/libs`. E.g., the provider JAR will be in `bc-java-pqsaml/prov/build/libs/bcprov-jdk18on-1.78-PQ.jar`.

### Installing built JARs into the local Maven repository.
We need to install the compiled libraries to our local Maven repository so it can be used to build OpenSAML and our benchmark scripts.

> Note that the official version of BouncyCastle is published on the global Maven mvnrepository.com but we need our forked version with support for composite signatures. 


Assuming we are in the BouncyCastle root directory `bc-java-pqsaml`. We can install the three JARs by calling the script `install-jars.sh` (note that you might need to enable executing the script with `chmod +x install-jars.sh`).
```
./install-jars.sh
```
Alternatively, you can use the commands below (which is the content of the script):
```
mvn install:install-file -Dfile="prov/build/libs/bcprov-jdk18on-1.78-PQ.jar" -DgroupId="org.bouncycastle" -DartifactId="bcprov-jdk18on" -Dversion="1.78-PQ" -Dpackaging=jar
mvn install:install-file -Dfile="pkix/build/libs/bcpkix-jdk18on-1.78-PQ.jar" -DgroupId="org.bouncycastle" -DartifactId="bcpkix-jdk18on" -Dversion="1.78-PQ" -Dpackaging=jar
mvn install:install-file -Dfile="util/build/libs/bcutil-jdk18on-1.78-PQ.jar" -DgroupId="org.bouncycastle" -DartifactId="bcutil-jdk18on" -Dversion="1.78-PQ" -Dpackaging=jar

```

Our PQ BouncyCastle fork is now installed into the local Maven repository.

## Apache Santuario
Building Apache Santurio is simpler than BouncyCastle. Assuming you have Maven already installed, download the code and navigate to the library root directory (e.g., `santuario-xml-security-java-pqsaml`) and run `mvn install -DskipTests`

In total:
```
git clone https://github.com/PQSAML/santuario-xml-security-java-pqsaml
cd santuario-xml-security-java-pqsaml
mvn install -DskipTests
```

This automatically builds and installs Apache Santuario into the local Maven repository.

## OpenSAML
Note that the official OpenSAML is not hosted on Github (https://shibboleth.atlassian.net/wiki/spaces/DEV/pages/1118699532/Source+Code+Access) but it can be found at https://git.shibboleth.net/view/. 

Our version is a fork of the unnofficial Github mirror https://github.com/unofficial-shibboleth-mirror/java-opensaml as Github allows to view the diff easily.

Note that OpenSAML latest version is 5+ but we developed our solutions for 4.3.0. We presume our modifications should be compatible with the newest version but we have not tested it. 

Before we can initiate the build. We need to modify Maven settings and add dependency repositories as noted here https://shibboleth.atlassian.net/wiki/spaces/DEV/pages/2891317253/MavenRepositories. On MacOS, we need to create a file name `settings.xml` in folder the `~/.m2/` with the contents available at https://github.com/PQSAML/index/blob/main/settings.xml or https://shibboleth.atlassian.net/wiki/spaces/DEV/pages/2891317253/MavenRepositories 

To build OpenSAML, we need to download the code, checkout to the correct branch and install using maven. In total:
```
git clone https://github.com/PQSAML/java-opensaml-pq
cd java-opensaml-pq
git checkout 4.3.0-pq
cd opensaml-parent
mvn -Prelease -DskipTests -D no-check-m2 -Dmaven.javadoc.skip=true install
```

This builds and installs OpenSAML into the local Maven repository.

## Benchmark scripts
Assuming BouncyCastle and OpenSAML are installed in the local Maven repository, we can download the code:
```
git clone https://github.com/PQSAML/benchmarks.git
cd benchmarks
```
and then we can build each benchmark script using the commands:

- Builds the XML signatures benchmark. 
```
mvn -PbuildSignaturesBenchmark package
```
- Builds the XML PKE benchmark. 
```
mvn -PbuildKEMsBenchmark package
```
- Builds the SAML benchmark. 
```
mvn -PbuildSAMLBenchmark package
```

Each build creates a JAR file located in the `target/` subfolder, e.g., the XML PKE benchmark can be found at  `benchmarks/target/BenchmarkKEMs.jar`.

# Running benchmark scripts

Each benchmark produces a sample file and a results file in the execution directory.

## XML signatures benchmark
The benchmark can be executed using the command
```
java -jar BenchmarkSignatures.jar [number of repetitions] [is hybrid] [primary alg list] <secondary alg list>
```
where
- `[number of repetitions]` is a number indicating the number of loops in the benchmark. We used 10000 in our paper.
- `[is hybrid]` is a string "true" or "false" indicating if we want to benchmark the separate hybrid PQ XML signatures (backward compatible).  If "true" then `<secondary alg list>` must be included.
- `[primary alg list]` is a string of signature algorithms to be benchmarked separated by space.
- `<secondary alg list>` is to be included only if `[is hybrid]="true"` it is a string of signature algorithms that are used as the second signature placed inside the Extensions.

Available algorithms are
`RSA3072 RSA15360 ECDSAP256 ECDSAP521 DILITHIUM2 DILITHIUM5 FALCON512 FALCON1024 SPHINCS128 SPHINCS256 MLDSA44andECDSAP256 MLDSA87andECDSAP384 MLDSA87andECDSAP521 Falcon512andECDSAP256 Falcon1024andECDSAP521`. Note that composite signature names use MLDSA instead of Dilithium as we named it according to the IETF draft.

The commands we used to get the results for the paper are:
- Purely post-quantum XML signatures
```
java -jar BenchmarkSignatures.jar 10000 false "RSA3072 RSA15360 ECDSAP256 ECDSAP521 DILITHIUM2 DILITHIUM5 FALCON512 FALCON1024 SPHINCS128 SPHINCS256"
```
- Composite hybrid post-quantum XML signatures
```
java -jar BenchmarkSignatures.jar 10000 false "MLDSA44andECDSAP256 MLDSA87andECDSAP521 Falcon512andECDSAP256 Falcon1024andECDSAP521"
```
- Separate hybrid post-quantum XML signatures
```
java -jar BenchmarkSignatures.jar 10000 true "ECDSAP256" "DILITHIUM2 DILITHIUM5 FALCON512 FALCON1024"
```

## XML PKE benchmark
The benchmark can be executed using the command
```
java -jar BenchmarkKEMs.jar [number of repetitions] [is hybrid] [primary alg list] <secondary alg list>
```
where
- `[number of repetitions]` is a number indicating the number of loops in the benchmark. We used 10000 in our paper.
- `[is hybrid]` is a string "true" or "false" indicating if we want to benchmark hybrid XMK PKE. If "true" then `<secondary alg list>` must be included.
- `[primary alg list]` is a string of PKE algorithms to be benchmarked separated by space.
- `<secondary alg list>` is to be included only if `[is hybrid]="true"` it is a string of PKE algorithms that are used in the outer layer if hybrid PQ PKE encryption is used.

Available algorithms are
`RSA3072 KYBER512 KYBER1024 CMCE1 CMCE5 BIKE1 BIKE5 HQC1 HQC5`. Note that, as mentioned in the paper, the BouncyCastle's HQC implementation causes decryption errors and therefore is to not recommended to use it as the benchamrk will fail.

The commands we used to get the results for the paper are:
- Purely post-quantum XML PKE
```
java -jar BenchmarkKEMs.jar 10000 false "RSA3072 KYBER512 KYBER1024 BIKE1 BIKE5 CMCE1 CMCE5"
```
- Hybrid post-quantum XML PKE
```
java -jar BenchmarkKEMs.jar 10000 true "RSA3072" "KYBER512 KYBER1024 BIKE1 BIKE5 CMCE1 CMCE5"
```

## SAML benchmark
For simplicity of the CLI arguments, we include predefined signature + PKE combination in the source code. From the CLI we can select only between modes (purely/separate hybrid/composite hybrid). The benchmark can be executed using the command
```
java -jar BenchmarkSAML.jar [number of repetitions] [is backward compatible hybrid] [is non-backward compatible hybrid]
```
where
- `[number of repetitions]` is a number indicating the number of loops in the benchmark. We used 10000 in our paper.
- `[is backward compatible hybrid]` is a string "true" or "false" indicating if we want to benchmark the backward compatible hybrid PQ SAML.
- `[is non-backward compatible hybrid]` is a string "true" or "false" indicating if we want to benchmark the non-backward compatible hybrid PQ SAML.

If both boolean arguments are false, we benchmark the purely post-quantum SAML.

The commands we used to get the results for the paper are:
- Purely post-quantum SAML SSO
```
java -jar BenchmarkSAML.jar 10000 false false
```
- Backward compatible hybrid post-quantum SAML SSO
```
java -jar BenchmarkSAML.jar 10000 true false
```
- Non-backward compatible hybrid post-quantum SAML SSO
```
java -jar BenchmarkSAML.jar 10000 false true
```
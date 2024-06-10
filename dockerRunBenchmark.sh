ITERATIONS=10000

if [ "$1" = "sig:purely" ]; then
	COMMAND="cd /workdir; java -jar /home/benchmarks/target/BenchmarkSignatures.jar $ITERATIONS false \"RSA3072 RSA15360 ECDSAP256 ECDSAP521 DILITHIUM2 DILITHIUM5 FALCON512 FALCON1024 SPHINCS128 SPHINCS256\""
elif [ "$1" = "sig:composite" ]; then
	COMMAND="cd /workdir; java -jar /home/benchmarks/target/BenchmarkSignatures.jar $ITERATIONS false \"MLDSA44andECDSAP256 MLDSA87andECDSAP521 Falcon512andECDSAP256 Falcon1024andECDSAP521\""
elif [ "$1" = "sig:separate" ]; then
	COMMAND="cd /workdir; java -jar /home/benchmarks/target/BenchmarkSignatures.jar $ITERATIONS true \"ECDSAP256\" \"DILITHIUM2 DILITHIUM5 FALCON512 FALCON1024\""
elif [ "$1" = "pke:purely" ]; then
	COMMAND="cd /workdir; java -jar /home/benchmarks/target/BenchmarkKEMs.jar $ITERATIONS false \"RSA3072 KYBER512 KYBER1024 BIKE1 BIKE5 CMCE1 CMCE5\""
elif [ "$1" = "pke:hybrid" ]; then
	COMMAND="cd /workdir; java -jar /home/benchmarks/target/BenchmarkKEMs.jar $ITERATIONS true \"RSA3072\" \"KYBER512 KYBER1024 BIKE1 BIKE5 CMCE1 CMCE5\""
elif [ "$1" = "saml:purely" ]; then
	COMMAND="cd /workdir; java -jar /home/benchmarks/target/BenchmarkSAML.jar $ITERATIONS false false"
elif [ "$1" = "saml:back" ]; then
	COMMAND="cd /workdir; java -jar /home/benchmarks/target/BenchmarkSAML.jar $ITERATIONS true false"
elif [ "$1" = "saml:nonback" ]; then
	COMMAND="cd /workdir; java -jar /home/benchmarks/target/BenchmarkSAML.jar $ITERATIONS false true"
else
echo "Invalid argument"
exit 1
fi

docker run -it --net=none --mount type=bind,source=.,target=/workdir pqsamlbenchmarks /bin/sh -c "$COMMAND"




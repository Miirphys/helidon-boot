# Helidon && GraalVM on Amazon Linux 2023 for Arm 

GraalVM is a giant leap for Java applications in the cloud. It has completely revamped the ecosystem and reignited my interest for Java in today's internet world. In this example, I implement Oracle's Helidon SE, which is a high-performance framework in the style of Node.js, on an Amazon Linux 2023 image.

This sample specifically targets Amazon Graviton , and build a docker image based on Amazon Linux 2023.

## Environment

This example requires:

Graalvm-jdk-21

Maven-3.9.5

Docker 4.25.0

## Build and run

```bash
mvn package
java -jar target/helidon-boot.jar
```

## Exercise the application

Basic:
```
curl -X GET http://localhost:8080/simple-greet
Hello World!
```


JSON:
```
curl -X GET http://localhost:8080/greet
{"message":"Hello World!"}

curl -X GET http://localhost:8080/greet/Joe
{"message":"Hello Joe!"}

curl -X PUT -H "Content-Type: application/json" -d '{"greeting" : "Hola"}' http://localhost:8080/greet/greeting

curl -X GET http://localhost:8080/greet/Jose
{"message":"Hola Jose!"}
```

## Try metrics

```
# Prometheus Format
curl -s -X GET http://localhost:8080/metrics
# TYPE base:gc_g1_young_generation_count gauge
. . .

# JSON Format
curl -H 'Accept: application/json' -X GET http://localhost:8080/metrics
{"base":...
. . .
```

## Try health

This example shows the basics of using Helidon SE Health. It uses the
set of built-in health checks that Helidon provides plus defines a
custom health check.

Note the port number reported by the application.

Probe the health endpoints:

```bash
curl -X GET http://localhost:8080/observe/health
curl -X GET http://localhost:8080/observe/health/ready
```



## Building a Native Image

The generation of native binaries requires an installation of Graalvm-jdk-21+

You can build a native binary using Maven as follows:

```
mvn -Pnative-image install -DskipTests
```

The generation of the executable binary may take a few minutes to complete depending on
your hardware and operating system. When completed, the executable file will be available
under the `target` directory and be named after the artifact ID you have chosen during the
project generation phase.

Make sure you have GraalVM locally installed:

```
$GRAALVM_HOME/bin/native-image --version
```

Build the native image using the native image profile:

```
mvn package -Pnative-image
```

This uses the helidon-maven-plugin to perform the native compilation using your installed copy of GraalVM. It might take a while to complete.
Once it completes start the application using the native executable (no JVM!):

```
./target/helidon-boot
```

Yep, it starts fast. You can exercise the application’s endpoints as before.


## Building the Docker Image

```
docker build -t helidon-boot .
```

## Running the Docker Image

```
docker run --rm -p 8080:8080 helidon-boot:latest
```

Exercise the application as described above.
      
                                

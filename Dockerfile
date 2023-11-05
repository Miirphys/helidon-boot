FROM public.ecr.aws/amazonlinux/amazonlinux:2023 as build

WORKDIR /usr/share

#####################################################################################################################

RUN echo "1 - Installing wget && tar && gzip && gcc build tools"

RUN yum update

RUN yum install -y wget && yum -y install tar && yum -y install gzip && yum -y  groupinstall "Development Tools"

#####################################################################################################################

RUN echo "2 - Installing graalvm-jdk-21.0.1+12.1"

RUN wget https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_linux-aarch64_bin.tar.gz

RUN tar -xvf graalvm-jdk-21_linux-aarch64_bin.tar.gz && rm -f -R graalvm-jdk-21_linux-aarch64_bin.tar.gz

RUN ln -s /usr/share/graalvm-jdk-21.0.1+12.1/bin/java /usr/bin/java

#####################################################################################################################

RUN echo "3 - Installing maven-3.9.5"

RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz

RUN tar -xvf apache-maven-3.9.5-bin.tar.gz && rm -f -R apache-maven-3.9.5-bin.tar.gz

RUN ln -s /usr/share/apache-maven-3.9.5/bin/mvn /usr/bin/mvn

ENV JAVA_HOME=/usr/share/graalvm-jdk-21.0.1+12.1

RUN export JAVA_HOME

#####################################################################################################################

RUN echo "4 - Creating distribution"

WORKDIR /helidon-boot

ADD src src

ADD pom.xml .

#####################################################################################################################

RUN echo "5 - Creating native image"

RUN mvn package -Pnative-image -Dnative.image.skip -Dmaven.test.skip -Declipselink.weave.skip

# 2nd stage, build the runtime image
FROM public.ecr.aws/amazonlinux/amazonlinux:2023
WORKDIR /helidon-boot

# Copy the binary built in the 1st stage
COPY --from=build /helidon-boot/target/helidon-boot .

ENTRYPOINT ["./helidon-boot"]

EXPOSE 8080

# JDK8 Builder
FROM edwardlukeiw/mvn:openjdk8 as build-openjdk8
WORKDIR /app
COPY pom.xml /app
RUN mvn clean package
COPY src /app/src
RUN mvn clean install

# JRE8 Runtime
FROM edwardlukeiw/jvm:openjdk8-jre as runtime-openjdk8-jre
ENV filename=hello-java-app-1.0-SNAPSHOT.jar
COPY --from=build-openjdk8 /app/target/${filename} /usr/local/bin/${filename}
CMD ["sh", "-c", "java -cp /usr/local/bin/${filename} uk.co.edwardlukeiw.Main"]

# JRE11 Builder
FROM edwardlukeiw/mvn:openjdk11 as build-openjdk11
WORKDIR /app
COPY pom.xml /app
RUN mvn clean package
COPY src /app/src
RUN mvn clean install

# JRE11 Runtime
FROM edwardlukeiw/jvm:openjdk11-jre as runtime-openjdk11-jre
ENV filename=hello-java-app-1.0-SNAPSHOT.jar
COPY --from=build-openjdk11 /app/target/${filename} /usr/local/bin/${filename}
CMD ["sh", "-c", "java -cp /usr/local/bin/${filename} uk.co.edwardlukeiw.Main"]

# GraalVM Builder
FROM edwardlukeiw/mvn:graaljdk11 as build-graaljdk11
WORKDIR /app
COPY pom.xml /app
RUN mvn clean package
COPY src /app/src
RUN mvn clean install -Pnative-image

# GraalVM Runtime
FROM scratch as runtime-graal
ENV filename=uk.co.edwardlukeiw.main
COPY --from=build-graaljdk11 /app/target/${filename} /usr/local/bin/${filename}


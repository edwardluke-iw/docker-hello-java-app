# docker-hello-java-app
An example of a docker multi-stage build to generate a hello world java application. For the `builder` stages it leverages the images produced with:

https://github.com/edwardluke-iw/docker-mvn-base

Which in turn leverage the base JDK images from:

https://github.com/edwardluke-iw/docker-jvm-base.

Additionally, the base JVM images that are used to generate the `runtime` containers which are also produced from:

https://github.com/edwardluke-iw/docker-jvm-base.


## Stages and Java Versions
The project can use three different `builder` images to execute the maven build:
* `edwardlukeiw/mvn:openjdk8`
* `edwardlukeiw/mvn:openjdk11`
* `edwardlukeiw/mvn:graaljdk11`

And the project can generate three different `runtime` images to execute the application:
* `edwardlukeiw/jvm:openjdk8-jre`
* `edwardlukeiw/jvm:openjdk11-jre`
* `scratch` with GraalVM static binary

## Dockerfile

To achieve the cross-version and minimal runtime image setup the Dockerfile contains a number of named stages using the `AS` command which allows images to be built from images created within previous build stages. Witin this project, the multi-stage feature is used for two purposes.

1. Creating a `builder` container which contains all of the nessecary tooling to compile the sources
2. Creating a `runtime` image which has the minimal amount of dependencies to execute the project

### `build-openjdk8`
**This stage enables the project sources to be compiled using version 8 of the JDK.**
This stage is based from the `edwardlukeiw/mvn:openjdk8` image. The project sources are copied to this image an then built using the `maven install` commmand. The `maven pacakge` command is first executed against the `pom.xml` which downloads the project dependencies and creates a layer. The sources are then copied and the `mvn install` command is executed with the sources. This ensures that the dependencies (that do not change as often as the source code) are kept in a seperate layer within the image.

### `runtime-openjdk8-jre`
**This stage enables the application to be executed using version 8 of the JRE.**
This stage is based from the `edwardlukeiw/jvm:openjdk8-jre` image. The artifacts produced by the `build-openjdk8` stage are copied to this image using the `COPY --from=build-openjdk` flag. The image only contains the JRE Runtime and the compiled project code and is the image that will run the application in production. This process ensures the production image is as small as possible and contains only the nessecary tooling.

### `build-openjdk11`
**This stage enables the project sources to be compiled using version 11 of the JDK.**
This stage is based from the `edwardlukeiw/mvn:openjdk11` image. The project sources are copied to this image an then built using the `maven install` commmand. The `maven pacakge` command is first executed against the `pom.xml` which downloads the project dependencies and creates a layer. The sources are then copied and the `mvn install` command is executed with the sources. This ensures that the dependencies (that do not change as often as the source code) are kept in a seperate layer within the image.

### `runtime-openjdk11-jre`
**This stage enables the application to be executed using version 11 of the JRE.**
This stage is based from the `edwardlukeiw/jvm:openjdk11-jre` image. The artifacts produced by the `build-openjdk8` stage are copied to this image using the `COPY --from=build-openjdk` flag. The image only contains the JRE Runtime and the compiled project code and is the image that will run the application in production. This process ensures the production image is as small as possible and contains only the nessecary tooling.

### Docker Commands
The Makefile targets are simply wrappers for running the appropriate docker `build` command. For example the difference between the JRE8, JRE11 and GraalVM builds are shown below:

The only difference between the two commands below is the `--target` parameter and the final image name.

#### Build

	docker build --file Dockerfile --target runtime-openjdk8-jre --tag edwardlukeiw/hello-java-app:openjdk8-jre .

	docker build --file Dockerfile --target runtime-openjdk11-jre --tag edwardlukeiw/hello-java-app:openjdk11-jre .

    docker build --file Dockerfile --target runtime-graal --tag edwardlukeiw/hello-java-app:graal .

Note the `--target` parameter which specifies which `stage` within the Dockerfile should be used to produce the final image.

#### Run

To run the image produced by the `JDK8` build above in the `JRE8` runtime:

    docker run -it edwardlukeiw/hello-java-app:openjdk8-jre

To run the image produced by the `JDK11` build above in the `JRE11` runtime:

    docker run -it edwardlukeiw/hello-java-app:openjdk11-jre

To run the image produced by the GraalVM build above within the `FROM scratch` runtime:

	docker run -it edwardlukeiw/hello-java-app:graal /usr/local/bin/uk.co.edwardlukeiw.main

### Makefile

To build all runtime images for JRE8, JRE11 and GraalVM

    make build_all

To build just the OpenJRE11 image:

    make build_8

To build just the OpenJRE11 image:

    make build_11

To build just the GraalVM image:

    make build_graal

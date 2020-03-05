.PHONY: clean run build maven docker compose
build_all:
	make build_8
	make build_11
	make build_graal
	make run_8
	make run_11
	make run_graal

build_8:
	docker build --file Dockerfile --target runtime-openjdk8-jre --tag edwardlukeiw/hello-java-app:openjdk8-jre .
	# docker push edwardlukeiw/hello-java-app:openjdk8-jre

build_11:
	docker build --file Dockerfile --target runtime-openjdk11-jre --tag edwardlukeiw/hello-java-app:openjdk11-jre .
	# docker push edwardlukeiw/hello-java-app:openjdk11 -jre

build_graal:
	docker build --file Dockerfile --target runtime-graal --tag edwardlukeiw/hello-java-app:graal .
	# docker push edwardlukeiw/hello-java-app:graal

run_8:
	docker run -it edwardlukeiw/hello-java-app:openjdk8-jre

run_11:
	docker run -it edwardlukeiw/hello-java-app:openjdk11-jre

run_graal:
	docker run -it edwardlukeiw/hello-java-app:graal /usr/local/bin/uk.co.edwardlukeiw.main

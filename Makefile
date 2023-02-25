build-go:
	docker build . -t surenpi/jenkins-agent-go --build-arg TOOL=golang
	docker push surenpi/jenkins-agent-go
build-maven:
	docker build . -t surenpi/jenkins-agent-maven --build-arg TOOL=maven
	docker push surenpi/jenkins-agent-maven

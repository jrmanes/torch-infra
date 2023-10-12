PROJECT_NAME := $(shell basename `pwd`)
REPOSITORY_NAME := $(shell basename `pwd`)
REGISTRY_NAME=ghcr.io/jrmanes
LOCAL_DEV=local

# Docker
docker_build:
	docker build -f Dockerfile -t ${PROJECT_NAME} -t ${PROJECT_NAME}:latest .
.PHYONY: docker_build

docker_build_local_push:
	docker build  -f Dockerfile -t ${PROJECT_NAME} .
	docker tag ${PROJECT_NAME}:latest localhost:5000/${REPOSITORY_NAME}:latest
	docker push localhost:5000/${REPOSITORY_NAME}:latest
.PHYONY: docker_build_local_push

docker_build_local_push_gh: clean_bin
	GOOS=linux GOARCH=amd64 go build -o ./${PROJECT_NAME} ./cmd/main.go &&\
	docker build -f Dockerfile_local -t ${REGISTRY_NAME}/${PROJECT_NAME}:latest .
	docker push ${REGISTRY_NAME}/${PROJECT_NAME}:latest
.PHYONY: docker_build_local_push_gh

docker_run:
	docker run -p 8080:8080 ${PROJECT_NAME}:latest
.PHYONY: docker_run

kubectl_apply:
	kubectl delete -f ./deployment/deployment.yaml ;\
	kubectl apply -f ./deployment/deployment.yaml
.PHYONY: kubectl_apply

kubectl_kustomize:
	kubectl delete -k ./deployment/overlays/${LOCAL_DEV} ;\
	kubectl apply -k ./deployment/overlays/${LOCAL_DEV}
.PHYONY: kubectl_kustomize

kubectl_kustomize_delete:
	kubectl delete -k ./deployment/overlays/${LOCAL_DEV}
.PHYONY: kubectl_kustomize_delete

kubectl_deploy: docker_build_local_push kubectl_apply
.PHYONY: kubectl_deploy

kubectl_remote_kustomize_deploy: kubectl_kustomize
.PHYONY: kubectl_remote_kustomize_deploy

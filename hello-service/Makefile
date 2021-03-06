ACCOUNT_ID:=$(shell aws sts get-caller-identity --profile $(AWS_PROFILE) --region $(AWS_REGION) --output text --query 'Account')

# Service stack parameters
SUB_SYSTEM:=wis
ENV_TYPE:=nonproduction
SERVICE_NAME:=hello-service
APP_PORT:=3000
HEALTH_CHECK_PATH:=/service-status
URL_PATTERN:=/hello
PRIORITY:=10
DESIRED_COUNT:=2

# CodePipeline parameters
GIT_USER:=rohitrox
GIT_REPO:=ecs-sub-system-from-scaffold
GIT_BRANCH:=master
SOURCE_PATH:=./

# Latest service version
# Should be removed
SERVICE_VERSION=0.0.0

STACK_NAME:=$(ENV_LABEL)-$(SUB_SYSTEM)-$(SERVICE_NAME)
IMAGE_NAME:=$(SUB_SYSTEM)-$(SERVICE_NAME)
ECR_ADDR:=$(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME)

build:
	docker build -t $(SERVICE_NAME) .
run:
	docker run -it -p $(APP_PORT):$(APP_PORT) $(SERVICE_NAME):latest
test:
	# Replace with some test

	docker build -t $(SERVICE_NAME) .
ecr-create:
	aws ecr create-repository --repository-name $(IMAGE_NAME) --profile $(AWS_PROFILE) --region $(AWS_REGION)
ecr-delete:
	aws ecr delete-repository --repository-name $(IMAGE_NAME) --profile $(AWS_PROFILE) --region $(AWS_REGION)
ecr-push:
	make build
	eval `aws ecr get-login --no-include-email --region $(AWS_REGION) --profile $(AWS_PROFILE)`
	docker tag $(SERVICE_NAME):latest $(ECR_ADDR):$(SERVICE_VERSION)
	docker push $(ECR_ADDR):$(SERVICE_VERSION)
create-resources:
	aws cloudformation create-stack --stack-name $(STACK_NAME)-resources --template-body file://Infrastructure/resources.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --parameters ParameterKey=EnvLabel,ParameterValue=$(ENV_LABEL) ParameterKey=EnvType,ParameterValue=$(ENV_TYPE) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=ServiceName,ParameterValue=$(SERVICE_NAME)
update-resources:
	aws cloudformation update-stack --stack-name $(STACK_NAME)-resources --template-body file://Infrastructure/resources.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --parameters ParameterKey=EnvLabel,UsePreviousValue=true ParameterKey=EnvType,UsePreviousValue=true ParameterKey=SubSystem,UsePreviousValue=true ParameterKey=ServiceName,UsePreviousValue=true
create-service:
	aws cloudformation create-stack --stack-name $(STACK_NAME) --template-body file://Infrastructure/service.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --capabilities CAPABILITY_IAM --parameters ParameterKey=EnvLabel,ParameterValue=$(ENV_LABEL) ParameterKey=EnvType,ParameterValue=$(ENV_TYPE) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=ServiceName,ParameterValue=$(SERVICE_NAME) ParameterKey=ServiceVersion,ParameterValue=$(SERVICE_VERSION) ParameterKey=DockerRepoUrl,ParameterValue=$(ECR_ADDR) ParameterKey=AppPort,ParameterValue=$(APP_PORT) ParameterKey=UrlPattern,ParameterValue=$(URL_PATTERN) ParameterKey=Priority,ParameterValue=$(PRIORITY) ParameterKey=DesiredCount,ParameterValue=$(DESIRED_COUNT) ParameterKey=HealthCheckPath,ParameterValue=$(HEALTH_CHECK_PATH)
update-service:
	aws cloudformation update-stack --stack-name $(STACK_NAME) --template-body file://Infrastructure/service.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --capabilities CAPABILITY_IAM --parameters ParameterKey=EnvLabel,UsePreviousValue=true ParameterKey=EnvType,UsePreviousValue=true ParameterKey=SubSystem,UsePreviousValue=true ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=ServiceVersion,ParameterValue=$(SERVICE_VERSION) ParameterKey=DockerRepoUrl,UsePreviousValue=true ParameterKey=AppPort,ParameterValue=$(APP_PORT) ParameterKey=UrlPattern,ParameterValue=$(URL_PATTERN) ParameterKey=Priority,ParameterValue=$(PRIORITY) ParameterKey=DesiredCount,ParameterValue=$(DESIRED_COUNT) ParameterKey=HealthCheckPath,ParameterValue=$(HEALTH_CHECK_PATH)
create-pipeline:
	aws cloudformation create-stack --stack-name $(STACK_NAME)-pipeline --template-body file://Infrastructure/pipeline.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=EnvLabel,ParameterValue=$(ENV_LABEL) ParameterKey=EnvType,ParameterValue=$(ENV_TYPE) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=ServiceName,ParameterValue=$(SERVICE_NAME) ParameterKey=GitUser,ParameterValue=$(GIT_USER) ParameterKey=GitRepo,ParameterValue=$(GIT_REPO) ParameterKey=GitBranch,ParameterValue=$(GIT_BRANCH) ParameterKey=GitOauthToken,ParameterValue=$(GIT_OAUTH_TOKEN) ParameterKey=DockerRepoUrl,ParameterValue=$(ECR_ADDR) ParameterKey=SourcePath,ParameterValue=$(SOURCE_PATH) ParameterKey=StackName,ParameterValue=$(STACK_NAME)
update-pipeline:
	aws cloudformation update-stack --stack-name $(STACK_NAME)-pipeline --template-body file://Infrastructure/pipeline.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=EnvLabel,UsePreviousValue=true ParameterKey=EnvType,UsePreviousValue=true ParameterKey=SubSystem,UsePreviousValue=true ParameterKey=ServiceName,UsePreviousValue=true ParameterKey=GitUser,ParameterValue=$(GIT_USER) ParameterKey=GitRepo,ParameterValue=$(GIT_REPO) ParameterKey=GitBranch,ParameterValue=$(GIT_BRANCH) ParameterKey=GitOauthToken,UsePreviousValue=true ParameterKey=DockerRepoUrl,ParameterValue=$(ECR_ADDR) ParameterKey=SourcePath,UsePreviousValue=true ParameterKey=StackName,ParameterValue=$(STACK_NAME)
version:
	echo $(SERVICE_VERSION)
parameters:
	@echo '{ "Parameters": {"EnvLabel": "$(ENV_LABEL)","EnvType": "$(ENV_TYPE)","SubSystem": "$(SUB_SYSTEM)","ServiceName": "$(SERVICE_NAME)","ServiceVersion": "$(SERVICE_VERSION)","DockerRepoUrl": "$(ECR_ADDR)","AppPort": "$(APP_PORT)","UrlPattern": "$(URL_PATTERN)","Priority": "$(PRIORITY)","DesiredCount": "$(DESIRED_COUNT)","HealthCheckPath": "$(HEALTH_CHECK_PATH)" } }' > parameters.json

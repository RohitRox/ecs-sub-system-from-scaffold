ENV_TYPE:=nonproduction
SUB_SYSTEM:=wis
SUB_SYSTEM_ENDPOINT:=wis.cloudfactory.local
GIT_USER:=RohitRox
GIT_REPO:=ecs-sub-system-from-scaffold

STACK_NAME:=$(SUB_SYSTEM)-subsystem

CLUSTER_STACK:=$(ENV_LABEL)-$(STACK_NAME)-cluster
RESOURCES_STACK:=$(ENV_LABEL)-$(STACK_NAME)-resources

install-tools:
	@which aws || pip install awscli
	@which jq || ( which brew && brew install jq || which apt-get && apt-get install jq || which yum && yum install jq || which choco && choco install jq)

create-cluster:
	aws cloudformation create-stack --stack-name $(CLUSTER_STACK) --template-body file://Infrastructure/cluster.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --capabilities CAPABILITY_IAM --parameters ParameterKey=EnvironmentName,ParameterValue=$(ENV_LABEL) ParameterKey=EnvironmentType,ParameterValue=$(ENV_TYPE) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=DomainName,ParameterValue=$(SUB_SYSTEM_ENDPOINT)
update-cluster:
	aws cloudformation update-stack --stack-name $(CLUSTER_STACK) --template-body file://Infrastructure/cluster.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --capabilities CAPABILITY_IAM --parameters ParameterKey=EnvironmentName,UsePreviousValue=true ParameterKey=EnvironmentType,UsePreviousValue=true ParameterKey=SubSystem,UsePreviousValue=true ParameterKey=DomainName,UsePreviousValue=true
describe-cluster:
	aws cloudformation describe-stacks --stack-name $(CLUSTER_STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION) | jq -r '.Stacks[].Outputs'
delete-cluster:
	aws cloudformation delete-stack --stack-name $(CLUSTER_STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION)

create-resources:
	aws cloudformation create-stack --stack-name $(RESOURCES_STACK) --template-body file://Infrastructure/resources.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --parameters ParameterKey=EnvironmentName,ParameterValue=$(ENV_LABEL) ParameterKey=EnvironmentType,ParameterValue=$(ENV_TYPE) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM)
update-resources:
	aws cloudformation update-stack --stack-name $(RESOURCES_STACK) --template-body file://Infrastructure/resources.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --parameters ParameterKey=EnvironmentName,UsePreviousValue=true ParameterKey=EnvironmentType,UsePreviousValue=true ParameterKey=SubSystem,UsePreviousValue=true
describe-resources:
	aws cloudformation describe-stacks --stack-name $(RESOURCES_STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION) | jq -r '.Stacks[].Outputs'
delete-resources:
	aws cloudformation delete-stack --stack-name $(RESOURCES_STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION)

test:
	echo "Command to test whole sub system. Not implemented yet. In master"

create-pr-code-build:
	aws cloudformation create-stack --stack-name $(STACK_NAME)-pr-code-build --template-body file://Infrastructure/pr.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=GitUser,ParameterValue=$(GIT_USER) ParameterKey=GitRepo,ParameterValue=$(GIT_REPO)

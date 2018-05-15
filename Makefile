.DEFAULT_GOAL := help
.PHONY: help create-stack delete-stack status get-profile get-region get-email

project.name := aws-root-login
project.repo := github.com/unbounce/$(project.name)

stack.name := root-login-alerts
stack.owner := security
stack.lifetime := long

help: ## show this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create-stack: get-profile get-region get-email ## launch the stack into AWS
	@aws cloudformation create-stack --stack-name $(stack.name) --template-body file://template.cft --parameters ParameterKey=RecipientEmailAddress,ParameterValue=$(RECIPIENT_EMAIL) --tags Key=project,Value=$(project.name) Key=owner,Value=$(stack.owner) Key=repository,Value=$(project.repo) Key=lifetime,Value=$(stack.lifetime) --enable-termination-protection --region $(AWS_REGION) --profile $(AWS_PROFILE) --stack-policy-body file://policy.json

# You must first remove stack termination protection before
# deleting the stack, to prevent accidents.
delete-stack: get-profile get-region ## remove the stack from AWS
	@aws cloudformation delete-stack --stack-name $(stack.name) --region $(AWS_REGION) --profile $(AWS_PROFILE)

status: get-profile get-region ## display the latest status of the stack
	@aws cloudformation describe-stack-events --profile $(AWS_PROFILE) --region $(AWS_REGION) --stack-name $(stack.name) --query 'StackEvents[?ResourceType == `AWS::CloudFormation::Stack`] | [0].ResourceStatus'

get-profile:
ifndef AWS_PROFILE
	@echo "Provide a AWS_PROFILE to continue."; exit 1
endif

get-region:
ifndef AWS_REGION
	@echo "Provide a AWS_REGION to continue."; exit 1
endif

get-email:
ifndef RECIPIENT_EMAIL
	@echo "Provide a RECIPIENT_EMAIL to continue."; exit 1
endif


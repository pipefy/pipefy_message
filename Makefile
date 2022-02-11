
build-app-infra:
	@docker-compose up -d
	@echo "Checking if the localstack SNS and SQS resources are created"
	@sleep 10
	docker logs aws-cli;

recreate-app-infra: delete-app-infra build-app-infra

delete-app-infra:
	@docker-compose down -v --remove-orphans

build-app:
	bundle install
	gem build pipefy_message.gemspec
	gem install pipefy_message-[0-9].[0-9].[0-9].gem
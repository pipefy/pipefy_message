.PHONY: help
help:
	@echo "Targets:"
	@echo "    build-app             Build and install pipefy-message gem"
	@echo "    build-app-infra       Run docker-compose with localstack infra"
	@echo "    delete-app-infra      Delete docker-compose localstack infra"
	@echo "    recreate-app-infra    Rebuild docker-compose localstack infra"
	@echo "    run-dev-env           Run a developer container environment"
	@echo "    run-lint              Run linter"
	@echo "    run-lint-fix          Fix linter issues"
	@echo "    test                  Run rspec tests"

.PHONY: build-app-infra
build-app:
	bundle install
	gem build pipefy_message.gemspec
	gem install pipefy_message-[0-9].[0-9].[0-9].gem

.PHONY: build-app-infra
build-app-infra:
	@docker-compose up -d
	@echo "Checking if the localstack SNS and SQS resources are created"
	@sleep 10
	docker logs aws-cli;

.PHONY: delete-app-infra
delete-app-infra:
	@docker-compose down -v --remove-orphans

.PHONY: recreate-app-infra
recreate-app-infra: delete-app-infra build-app-infra

.PHONY: run-dev-env
run-dev-env:
	docker run                           \
	-it                                  \
	--rm                                 \
	--net=host                           \
	-v $(shell pwd):/home/pipefy_message \
	-w /home/pipefy_message              \
	-e ENABLE_AWS_CLIENT_CONFIG="true"   \
	-e ASYNC_APP_ENV="development"       \
	ruby:2.7.6                           \
	bash

.PHONY: run-lint
run-lint:
	bundle exec rubocop

.PHONY: run-lint-fix
run-lint-fix:
	bundle exec rubocop -A

.PHONY: test
test:
	bundle exec rspec

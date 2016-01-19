APP_NAME = ruby
MAINTAINER = dcrbsltd
NAME = $(MAINTAINER)/$(APP_NAME)
VERSION = 2.2.4
DATE = $(shell date)
.PHONY: all build clean test tag_latest release ssl

all: build

build:
	docker build -f Dockerfile -t $(NAME):$(VERSION) .

clean:
	@eval `docker-machine env default` ||:
	@docker kill `docker ps -a -q` ||:
	@docker rm -f `docker ps -a -q` ||:
	@docker rmi -f `docker images -q` ||:

test:
	env NAME=$(NAME) VERSION=$(VERSION) ./test

tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

docker_release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"

push:
	docker push $(NAME)

release:
	@echo "Enter commit message:"
	@read REPLY; \
	echo "${DATE} - $$REPLY" >> CHANGELOG; \
	git add --all; \
	git commit -m "$$REPLY"; \
	git push

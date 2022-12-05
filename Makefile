PACKAGE=openapi_client
OPENAPI_GENERATOR_VERSION=6.2.1

.PHONY: generate-config
generate-config:
	printf "packageName: ${PACKAGE}\npackageVersion: 1.0.0\n" > config.yml
	cat ./templates/python/config.yml >> config.yml
	sed 's/{{packageName}}/${PACKAGE}/g' -i config.yml

.PHONY: generate-openapi-client
generate-openapi-client: generate-config
	mkdir -p ${PACKAGE}/test

	docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli:v${OPENAPI_GENERATOR_VERSION} generate \
    -t /local/templates/python \
    --ignore-file-override /local/templates/python/.openapi-generator-ignore \
    -i /local/reference/sdk_test.yaml \
    -g python \
    -c /local/config.yml \
    -o /local/${PACKAGE}

.PHONY: test
test :
	PYTHONPATH=${PACKAGE} poetry run python -m unittest discover ${PACKAGE}/test

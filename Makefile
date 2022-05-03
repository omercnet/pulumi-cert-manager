.PHONY: clean
.DEFAULT_GOAL := all
package: CERT_MANAGER_VERSION = `gh -R cert-manager/cert-manager release view --json name -q .name`
package: TEMP_FILE := $(shell mktemp)

clean:
	rm -rf $(TEMP_FILE)
	rm -rf cert-manager.crds.yaml

install-crd2pulumi:
	go install github.com/pulumi/crd2pulumi@latest

download:
	gh release download --pattern "*.crds.yaml" -R cert-manager/cert-manager

generate:
	crd2pulumi --nodejsPath . --force cert-manager.crds.yaml

package:
	jq --arg VER ${CERT_MANAGER_VERSION} '.version = $$VER | .license = "MIT" | .name = "@omercnet/cert-manager"' package.json > ${TEMP_FILE}
	mv ${TEMP_FILE} package.json

all: clean download generate package

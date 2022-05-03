.PHONY: clean
.DEFAULT_GOAL := all
ifndef CERT_MANAGER_VERSION
package: CERT_MANAGER_VERSION = `gh -R cert-manager/cert-manager release view --json name -q .name`
CERT_MANAGER_VERSION = `jq -r '.version|ltrimstr("v")' package.json`
endif

clean:
	rm -rf cert-manager.crds.yaml *.json || true
	git checkout main
	git clean -fd
	git tag -d `git tag -l`

branch:
	git branch -D $(CERT_MANAGER_VERSION) || true
	git checkout -b $(CERT_MANAGER_VERSION)

install-crd2pulumi:
	go install github.com/pulumi/crd2pulumi@latest

download:
	gh release download --pattern "*.crds.yaml" -R cert-manager/cert-manager v${CERT_MANAGER_VERSION}

generate:
	crd2pulumi --nodejsPath . --force cert-manager.crds.yaml
	npm pkg set name="pulumi-crds-cert-manager"

commit:
	git add -A
	git commit -am ${CERT_MANAGER_VERSION}
	npm version ${CERT_MANAGER_VERSION}

publish:
	npm publish --access public

publish-dry:
	npm publish --access public --dry-run

push:
	git push --tags -u origin $(CERT_MANAGER_VERSION)

all: clean branch download generate commit



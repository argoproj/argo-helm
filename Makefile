SRC_ROOT = $(shell git rev-parse --show-toplevel)

helm-docs: HELMDOCS_VERSION := v1.9.1
helm-docs: has-docker
	@docker run -v "$(SRC_ROOT):/helm-docs" jnorwood/helm-docs:$(HELMDOCS_VERSION) --chart-search-root /helm-docs

ct-lint: CT_VERSION := v3.3.1
ct-lint: has-docker
	@docker run -v "$(SRC_ROOT):/workdir" --entrypoint /bin/sh quay.io/helmpack/chart-testing:$(CT_VERSION) -c cd /workdir && ct lint --config .github/configs/ct-lint.yaml --lint-conf .github/configs/lintconf.yaml --all --debug

kind-up: has-kind
	@kind create cluster --name argo-helm --config "$(SRC_ROOT)/.github/configs/kind-config.yaml"

kind-down: has-kind
	@kind delete cluster --name argo-helm

has-kind:
	@hash kind 2>/dev/null || {\
		echo "You need KinD" &&\
		exit 1;\
	}

has-docker:
	@hash docker 2>/dev/null || {\
		echo "You need docker" &&\
		exit 1;\
	}

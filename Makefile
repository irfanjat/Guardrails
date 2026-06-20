CONFTEST_VERSION ?= v0.58.0
KYVERNO_VERSION ?= v1.13.3
CONFTEST ?= conftest
KYVERNO ?= kyverno

.PHONY: all install-tools test-terraform test-kubernetes test-full clean

all: test-full

install-tools:
	@echo "=== Installing Conftest ==="
	curl -sSLfo /tmp/conftest.tar.gz \
		https://github.com/open-policy-agent/conftest/releases/download/$(CONFTEST_VERSION)/conftest_$(CONFTEST_VERSION)_Linux_x86_64.tar.gz
	tar xzf /tmp/conftest.tar.gz -C /tmp
	cp /tmp/conftest /usr/local/bin/conftest && chmod +x /usr/local/bin/conftest || \
		cp /tmp/conftest ~/conftest && chmod +x ~/conftest
	$(CONFTEST) --version

	@echo "=== Installing Kyverno CLI ==="
	curl -sSLfo /tmp/kyverno.tar.gz \
		https://github.com/kyverno/kyverno/releases/download/$(KYVERNO_VERSION)/kyverno-cli_$(KYVERNO_VERSION)_linux_x86_64.tar.gz
	tar xzf /tmp/kyverno.tar.gz -C /tmp
	cp /tmp/kyverno /usr/local/bin/kyverno && chmod +x /usr/local/bin/kyverno || \
		cp /tmp/kyverno ~/kyverno && chmod +x ~/kyverno
	$(KYVERNO) version

test-terraform: test-terraform-bad test-terraform-clean

test-terraform-bad:
	@echo "=== Conftest: Bad Terraform fixtures (expect FAIL) ==="
	-$(CONFTEST) test --policy policies/terraform/ test-fixtures/bad/terraform/tfplan.json
	@echo ""

test-terraform-clean:
	@echo "=== Conftest: Clean Terraform fixtures (expect PASS) ==="
	$(CONFTEST) test --policy policies/terraform/ test-fixtures/clean/terraform/tfplan.json
	@echo ""

test-kubernetes: test-kubernetes-bad test-kubernetes-clean

test-kubernetes-bad:
	@echo "=== Kyverno: Bad K8s fixtures (expect FAIL) ==="
	-$(KYVERNO) apply policies/kubernetes/ --resource=test-fixtures/bad/kubernetes/deployment-bad.yaml
	@echo ""

test-kubernetes-clean:
	@echo "=== Kyverno: Clean K8s fixtures (expect PASS) ==="
	$(KYVERNO) apply policies/kubernetes/ --resource=test-fixtures/clean/kubernetes/deployment-clean.yaml
	@echo ""

test-kubernetes-suite:
	@echo "=== Kyverno: Test suite ==="
	$(KYVERNO) test tests/kyverno-test.yaml
	@echo ""

test-full: test-terraform test-kubernetes

clean:
	rm -f /tmp/conftest.tar.gz /tmp/kyverno.tar.gz

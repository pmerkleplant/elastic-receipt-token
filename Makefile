.PHONY: clean
clean: ## Remove build artifacts
	@forge clean

.PHONY: build
build: ## Build project
	forge build

.PHONY: test
test: ## Run whole testsuite
	forge test -vvv

.PHONY: testToken
testToken: ## Run ERC20 tests
	forge test -vvv --match-contract "ERC20"

.PHONY: testRebase
testRebase: ## Run rebase tests
	forge test -vvv --match-contract "Rebase"

.PHONY: simulation
simulation: ## Run simulation
	forge test -vvv --match-contract "Simulate"

.PHONY: testDeployment
testDeployment: ## Run deployment tests
	forge test -vvv --match-contract "Deployment"

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Run Debugger with:
# forge run ./src/test/<Contract>.t.sol --sig "<function>()" --debug

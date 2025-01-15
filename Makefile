# Makefile for project setup and execution

# Define the output file for the bundled Lua
OUTPUT_FILE=process.lua


setup:
	@echo "Setting up the environment..."
	@if [ "$(shell uname)" = "Darwin" ]; then \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		brew install lua@5.3; \
		brew link --force lua@5.3; \
		brew install luarocks; \
		luarocks config lua_version 5.3; \
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash; \
		export NVM_DIR="$$HOME/.nvm"; \
		[ -s "$$NVM_DIR/nvm.sh" ] && . "$$NVM_DIR/nvm.sh"; \
		nvm install; \
		nvm use; \
	elif [ "$(shell uname)" = "Linux" ]; then \
		sudo apt-get update; \
		sudo apt-get install -y lua5.3 lua5.3-dev; \
		sudo apt-get install -y luarocks; \
		sudo luarocks config lua_version 5.3; \
		rm -rf luarocks-3.11.1/; \
		rm -f luarocks.tar.gz; \
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash; \
		export NVM_DIR="$$HOME/.nvm"; \
		[ -s "$$NVM_DIR/nvm.sh" ] && . "$$NVM_DIR/nvm.sh"; \
		nvm install; \
		nvm use; \
	else \
		echo "Please follow the instructions in docs/misc/install_npm.md and docs/misc/install_luarocks.md for your OS."; \
	fi

# Define the target for installing dependencies
# Installing Lua dependencies to lib & global.
# Installing Node dependencies to node_modules.
# Intalling AO
install:
	sudo luarocks install --tree=lib --only-deps arcao-process-template-1.0-1.rockspec
	sudo luarocks install --only-deps arcao-process-template-1.0-1.rockspec
	sudo npm install
	sudo npm i -g https://get_ao.g8way.io

# Define the target for setting up the environment

# Define the target for running the node script
build:
	node bundle.js $(OUTPUT_FILE)

# Define the target for running tests
test:
	sudo busted --verbose

deploy:
	bash deploy.sh

.PHONY: build install test setup deploy

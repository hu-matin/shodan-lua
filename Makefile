.PHONY: test setup docs

LUA ?= lua
BUSTED ?= busted

test:
	$(BUSTED) --verbose tests/

setup:
	luarocks install busted
	luarocks install dkjson
	luarocks install luatime
	luarocks make

docs:
	@echo "Documentation:"
	@echo "  - README.md   : Getting started"
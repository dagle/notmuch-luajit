.PHONY: test lint
THIS_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

pr-ready: fmt test lint

lint:
	luacheck lua/

stylua:
	stylua lua/

test/testdir:
	test/init.sh

test: test/testdir
	NOTMUCH_CONFIG=${THIS_DIR}/test/testdir/notmuch/notmuch-config nvim --headless --clean \
	-u test/minimal.vim \
	-c "PlenaryBustedDirectory test/test {minimal_init = 'test/minimal.vim'}"

testclean:
	rm -rf test/testdir

emmy:
	lemmy-help lua/notmuch/init.lua

docker-build:
	docker build --no-cache . -t notmuch

ready-docker:
	docker run -v $(shell pwd):/code/refactoring.nvim -t refactoring

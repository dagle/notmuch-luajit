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
	NOTMUCH_CONFIG=test/testdir/notmuch/notmuch-config nvim --headless --clean \
	-u test/minimal.vim \
	-c "PlenaryBustedDirectory test/test {minimal_init = 'test/minimal.vim'}"

testclean:
	rm -rf test/testdir

emmy:
	lemmy-help lua/notmuch/init.lua > doc/notmuch.txt

pod-build:
	podman build --no-cache . -t notmuch

ready-pod:
	podman run -v $(shell pwd):/code/notmuch-lua -t notmuch

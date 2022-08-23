all: hello-world.prg

hello-world.prg:
	cl65 --verbose --target nes -o hello-world.prg hello-world.s

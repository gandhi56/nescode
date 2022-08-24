all: hello-world.prg draw-sprite.prg

hello-world.prg:
	cl65 --verbose --target nes -o hello-world.prg hello-world.s

draw-sprite.prg:
	cl65 --verbose --target nes -o draw-sprite.prg draw-sprite.s

clean:
	rm -rf *.o *.prg

all: hellomario.nes spaceship.nes cart.nes bouncing-toad.nes
hellomario.nes: hellomario.s
	ca65 hellomario.s -o hellomario.o -t nes
	ld65 hellomario.o -o hellomario.nes -t nes hellomario.dbg

spaceship.nes: spaceship.s
	ca65 spaceship.s -o spaceship.o -t nes
	ld65 spaceship.o -o spaceship.nes -t nes

cart.nes: cart.s
	ca65 cart.s -o cart.o -t nes
	ld65 cart.o -o cart.nes -t nes

bouncing-toad.nes: bouncing-toad.s
	ca65 bouncing-toad.s -o bouncing-toad.o -t nes
	ld65 bouncing-toad.o -o bouncing-toad.nes -t nes

clean:
	rm *.o *.nes
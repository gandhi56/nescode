all: hellomario.nes spaceship.nes cart.nes
hellomario.nes: hellomario.s
	ca65 hellomario.s -o hellomario.o --debug-info
	ld65 hellomario.o -o hellomario.nes -t nes --dbgfile hellomario.dbg

spaceship.nes: spaceship.s
	ca65 spaceship.s -o spaceship.o
	ld65 spaceship.o -o spaceship.nes -t nes

cart.nes: cart.s
	ca65 cart.s -o cart.o
	ld65 cart.o -o cart.nes -t nes

clean:
	rm *.o *.nes
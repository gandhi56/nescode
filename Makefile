
all: hellomario.nes spaceship.nes
hellomario.nes: hellomario.asm
	ca65 hellomario.asm -o hellomario.o --debug-info
	ld65 hellomario.o -o hellomario.nes -t nes --dbgfile hellomario.dbg

spaceship.nes: spaceship.asm
	ca65 spaceship.asm -o spaceship.o
	ld65 spaceship.o -o spaceship.nes -t nes

clean:
	del *.o *.nes
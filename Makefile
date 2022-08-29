SRC := hello-world.s hello-world2.s
NES := $(SRC:.s=.nes)

all: $(NES)
hello-world.nes: hello-world.s
	ca65 -o hello-world.o $<
	ld65 -t nes -o $@ hello-world.o

hello-world2.nes: hello-world2.s
	ca65 -o hello-world2.o $<
	ld65 -t nes -o $@ hello-world2.o

clean:
	rm -rf *.o *.nes

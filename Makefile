#######################################################################
# General variables. Twiddle as you see fit.
#######################################################################

LIBTI99?=/range/share/software/ti994a/libti99
PATH := $(PATH):/range/share/software/ti994a/tms9900gcc/bin

#######################################################################

GAS=tms9900-as
LD=tms9900-ld
CC=tms9900-gcc
OBJCOPY=tms9900-objcopy
OBJDUMP=tms9900-objdump

SFNAME=helloworl
FNAME=helloworld
UCFNAME=$(shell echo -n $(FNAME) | tr 'a-z' 'A-Z')
UCSFNAME=$(shell echo -n $(SFNAME) | tr 'a-z' 'A-Z')

LDFLAGS=\
  --script=linkfile -L$(LIBTI99) -lti99

CFLAGS=\
  -std=gnu99 -O2 -Werror --save-temp -I$(LIBTI99) -DBANK_STACK_SIZE=10

SRCS:=$(sort $(wildcard *.c) $(wildcard *.asm))

OBJECT_LIST:=$(SRCS:.c=.o)
OBJECT_LIST:=$(OBJECT_LIST:.asm=.o)

LINK_OBJECTS:=$(addprefix objects/,$(OBJECT_LIST))

all: $(UCFNAME).DSK

$(FNAME).elf: $(LINK_OBJECTS)
	$(LD) $(LINK_OBJECTS) $(LDFLAGS) -o $(FNAME).elf -Map=mapfile

$(UCFNAME): $(FNAME).elf
	rm -f upper.bin lower.bin objects/$(UCSFNAME)? $(SFNAME)?.tfi
	$(OBJCOPY) -O binary -j .text $< upper.bin
	$(OBJCOPY) -O binary -j .data $< lower.bin
	python ./ea5split.py A000:upper.bin 2000:lower.bin objects/$(UCFNAME)
	xdm99.py -T objects/$(UCSFNAME)? -f PROGRAM
	for i in $(SFNAME)?.tfi; do cp $$i `basename $$i .tfi`; done

$(UCFNAME).DSK: $(UCFNAME)
	rm -f $(UCSNAME).DSK
	xdm99.py $(UCFNAME).DSK --initialize DSDD40T
	xdm99.py $(UCFNAME).DSK -t -a $(SFNAME)?
	xdm99.py $(UCFNAME).DSK

.phony clean:
	rm -fr objects
	rm -f *.elf
	rm -f *.bin
	rm -f mapfile
	rm -f *.DSK
	rm -f *.tfi
	rm -f $(SFNAME)?


objects/%.o: %.asm
	mkdir -p objects
	$(GAS) $< -o $@

objects/%.o: %.c
	mkdir -p objects
	$(CC) -c $< $(CFLAGS) -o $@
	mv *.i *.s objects/


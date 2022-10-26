PROG= krt

.SUFFIXES: .sh
.PHONY: clean

.sh:
	cp $< $@
	chmod +x $@

all: ${PROG}

perfect_squares.txt: perfect_squares.sh
	perfect_squares.sh > perfect_squares.txt

${PROG}: perfect_squares.txt ${PROG}.sh

clean:
	rm -f -- perfect_squares.txt ${PROG} *.ppm

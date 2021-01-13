SCRIPT= krt.sh
PROG= ${SCRIPT:R}

all: ${PROG}

perfect_squares.txt: perfect_squares.sh
	perfect_squares.sh > perfect_squares.txt

${PROG}: perfect_squares.txt ${SCRIPT}
	cp ${SCRIPT} ${PROG}

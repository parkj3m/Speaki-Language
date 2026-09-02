CFLAGS=-g -Og -Wall -Wno-unused-variable -Wno-unused-function -std=c99
CC=gcc

spki: spki.lex.yy.c spki.tab.c
	$(CC) -o $@ $^ $(CFLAGS)

spki.lex.yy.c: spki.l
	flex -o $@ $<

spki.tab.c: spki.y
	bison -o $@ -dv $<

clean:
	rm -f spki spki.lex.yy.c spki.tab.* spki.output spki.py

all: build/demo

.PHONY:
clean:
	rm -r build/*

build/demo:
	mkdir -p build
	$(CC) -g -O -c -Isrc -o build/testfilea.o src/demo/testfilea.cpp
	$(CC) -g -O -c -Isrc -DUNIT_TEST_UNIQUE_ID=$$(date +%015s%09N) -o build/testfilec.o src/demo/testfilec.cpp
	cp src/unittest.sh build/unittest
	cp src/unittest.h build/unittest.h
	build/unittest -f 2 build/testfilea.o build/testfilec.o
	$(CC) build/testfilea.o build/testfilec.o -o build/testfile


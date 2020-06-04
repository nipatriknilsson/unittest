# unittest
Unit testing of applications are one essential step for getting all programming done correctly. The concept used by this unit-testing script is to find all functions with the correct signature and call them one by one from a main function. It is done in C++, but I'm sure it can easily be adopted by all programming languages supported by gcc.

~~~
$ unittest --help
Copyright (c) 2020 Patrik Nilsson, MIT License

unittest [-p] [-f max_count] [object-files...] [-- options to the compiler]
options:
-p        print only failed unit tests
-f N      stop processing, when N units failed. Default 5.
-h        this help
--help    this help

This is a script to perform unit testing of gcc-compiled files.
Create a function with prototype
int unit_test_*(). This function will be called from the test script.
You return 0 on success. Anything else is an error and is printed.

The unit function must be accessable from main().Example:
int unit_test_addition_1_plus_1_eq_2 ()
{
    return 1+1==2 ? 0 : 1;
}

Compile the source file(s) to object files with debug symbols:
gcc -g -O -c -o build/testfilea.o src/demo/testfilea.cpp

You can provide a define to make all unit_test-functions unique:
-DUNIT_TEST_UNIQUE_ID=$$(date +%015s%09N) (makefile syntax)
and define your unit-test function with:

#include "unittest.h"
UNIT_TEST(usingmacro)
{
    return 0;
}

Run unit test:
unittest build/testfilea.o

Output:
Started testing of 2 units.
/[...]/test/src/demo/testfilea.cpp:1:unit_test_returning_pass ... OK
/[...]/test/src/demo/testfilea.cpp:6:unit_test_addition_1_plus_1_eq_2 ... OK
Finished testing of 2 units in 0.000004s.

Requires nm and gcc to work.

Example of a command line including options to the compiler:
unittest -p -f 2 build/testfilea.o build/testfilec.o -- -pthread -ldl

Further examples, see the demo files.
~~~


#!/bin/bash

set -e
#set -x

arg_temp=$(tempfile)

arg_output=${arg_temp}
arg_help=0
arg_max=5
arg_single=
arg_linker=
arg_nomoreoptions=0
arg_printonlyfailed=0

while [ $# -gt 0 ]; do
    case "$1" in
    -f)
        shift
        arg_max=$1
        shift
        ;;
    
    -o)
        shift
        arg_output=$1
        shift
        ;;
    
    -h)
        arg_help=1
        break
        ;;
    
    -p)
        arg_printonlyfailed=1
        shift
        ;;
    
    --help)
        arg_help=1
        break
        ;;
    
    --)
        arg_nomoreoptions=1
        shift
        ;;
    
    -*)
        if [ "$arg_nomoreoptions" == "0" ] ; then
            arg_single="${arg_single} $1"
        else
            arg_linker="${arg_linker} $1"
        fi

        shift
        ;;

    *)
        echo >> ${arg_output}.objs "$1"
        shift
        ;;

    esac
done

touch ${arg_output}.objs

if [ "${arg_help}" == "1" ] ; then
    echo "Copyright (c) 2021 Patrik Nilsson, MIT License"

    echo ""

    echo "unittest [-p] [-o executable_unit_file  ] [-f max_count] [object-files...] [-- options to the compiler]"

    echo "options:"
    echo "-p        print only failed unit tests"
    echo "-f N      stop processing, when N units failed. Default 5."
    echo "-o        executable output file (which can be used with i.e. gdb)"
    echo "          otherwise a temporary file is used"
    echo "-h        this help"
    echo "--help    this help"
    
    echo ""
    
    echo "This is a script to perform unit testing of gcc-compiled files."
    echo "Create a function with prototype \"int unittest_*()\"."
    echo "The function will be called from a main loop."
    echo "Return 0 on success. Anything else is an error and it is printed."
    
    echo ""
    
    echo "The unit function must be accessable from main(). Example:"
    
    echo "int unittest_addition_1_plus_1_eq_2 ()"
    echo "{"
    echo "    return 1+1==2 ? 0 : 1;"
    echo "}"
    
    echo ""
    echo "Compile the source file(s) to object files with debug symbols:"
    
    echo "gcc -g -O -c -o build/testfilea.o src/demo/testfilea.cpp"
    echo ""
    echo "You can provide a define to make all unit_test-functions unique:"
    echo "-DUNIT_TEST_UNIQUE_ID=\$\$(date +%015s%09N) (makefile syntax)"
    echo "and define your unit-test function with:"
    echo ""
    echo "#include \"unittest.h\""
    echo "UNITTEST(usingmacro)"
    echo "{"
    echo "    return 0;"
    echo "}"
    
    echo ""
    echo "Run unit test:"
    
    echo "unittest build/testfilea.o"
    
    echo ""
    echo "Example Output:"
    echo "Started testing of 2 units."
    echo "/[...]/test/src/demo/testfilea.cpp:1:unittest_returning_pass ... OK"
    echo "/[...]/test/src/demo/testfilea.cpp:6:unittest_addition_1_plus_1_eq_2 ... OK"
    echo "Finished testing of 2 units in 0.000004s."
    
    echo ""
    echo "Requires nm, gcc and strip to work."
    echo ""
    
    echo "Example of a command line including options to the compiler:"
    echo "unittest -p -f 2 build/testfilea.o build/testfilec.o -- -pthread -ldl"
    
    echo ""
    
    echo "For further examples, see the demo files."
    
    exit 1
fi

if ! which nm >/dev/null 2>&1 ; then
    echo "Error: \"nm\" must be installed"
    exit 1
fi

if ! which gcc >/dev/null 2>&1 ; then
    echo "Error: \"nm\" must be installed"
    exit 1
fi

if ! which strip >/dev/null 2>&1 ; then
    echo "Error: \"strip\" must be installed"
    exit 1
fi

cat ${arg_output}.objs | xargs -I '{}' -- nm -n --demangle -l -f POSIX '{}' | grep -E '^(unit_test|unittest)_' | awk '{fu=substr($1,1,length($1)-2); pos=index($0,"\t") ; if(pos!=0) { fi=substr($0,pos+1) } print "\"" fi "\", \"" fu "\", " fu }' | sort --field-separator=':' -k1,1 -k2,2g  > ${arg_output}.funcs

#echo -e "\n### cat ${arg_output}.objs ###\n" ; cat ${arg_output}.objs

#echo -e "\n### cat ${arg_output}.funcs ###\n" ; cat ${arg_output}.funcs

cat > ${arg_output}.cpp <<EOF
#include <stdio.h>
#include <chrono>
#include <unistd.h>
#include <stdlib.h>

#include <signal.h>
#include <execinfo.h>

$(cat ${arg_output}.funcs | awk -F ',' '{print "extern const int " $NF "();"}')

struct struct_unit
{
    const char *filenameline;
    const char *funcname;
    const int (*funccall)();
};

struct_unit units [] =
{
    $(cat ${arg_output}.funcs | awk '{print "{" $0 "},"}')
};

//https://stackoverflow.com/questions/77005/how-to-automatically-generate-a-stacktrace-when-my-program-crashes
void exception_handler ( int sig )
{
    void *array[10];
    size_t size;
    
    // get void*'s for all entries on the stack
    size = backtrace ( array, 10 );
    
    // print out all the frames to stderr
    fprintf ( stderr, "Error: signal %d:\n", sig );
    backtrace_symbols_fd ( array, size, STDERR_FILENO );
    
    exit ( 255 );
}

int main ( int argc, char **argv )
{
    signal ( SIGSEGV, exception_handler );
    
    setbuf ( stdout, NULL );
    
    unsigned long maxfailed = 5;
    int printonlyfailed = 0;
    
    int opt = 0;
    
    while ( ( opt = getopt ( argc, argv, "pf:" ) ) != -1 )
    {
        switch (opt)
        {
            case 'p':
                printonlyfailed = 1;
                break;
            
            case 'f':
                maxfailed = atol ( optarg );
                break;
            
            default: /* '?' */
                fprintf ( stderr, "Usage: %s [-m maxfailed=5 ]\n", argv [ 0 ] );
                exit ( EXIT_FAILURE );
        }
    }
    
    unsigned long countunits = sizeof ( units ) / sizeof ( struct_unit );
    unsigned long countfailed = 0;
    
    printf ( "Started testing of %ld units.\n", countunits );
    
    std::chrono::steady_clock::time_point start = std::chrono::steady_clock::now();
    
    for ( unsigned long processingunit = 0 ; processingunit < countunits ; processingunit ++ )
    {
        if ( printonlyfailed == 0 )
        {
            printf ( "%s:%s ... ", units [ processingunit ].filenameline, units [ processingunit ].funcname );
        }
        
        int ret = units [ processingunit ].funccall ();
        
        if ( ret == 0 )
        {
            if ( printonlyfailed == 0 )
            {
                printf ( "OK\n" );
            }
        }
        else
        {
            if ( printonlyfailed == 1 )
            {
                printf ( "%s:%s ... ", units [ processingunit ].filenameline, units [ processingunit ].funcname );
            }
            
            printf ( "FAILED (%d)\n", ret );
            countfailed ++;
            
            if ( maxfailed != 0 && countfailed >= maxfailed )
            {
                break;
            }
        }
    }
    
    std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
    std::chrono::duration<double> elapsed_seconds = end-start;
    
    if ( countfailed == 0 )
    {
        printf ( "Successfully finished testing of %ld units in %fs.\n", countunits, elapsed_seconds.count () );
        exit ( EXIT_SUCCESS );
    }
    else
    {
        printf ( "Failed testing %ld out of %ld units in %fs.\n", countfailed, countunits, elapsed_seconds.count () );
        if ( maxfailed != 0 && countfailed >= maxfailed )
        {
            printf ( "Exited due to max failed reached.\n" );
        }
    }
    
    exit ( EXIT_FAILURE );
}
EOF

#echo -e "\n### cat ${arg_output}.cpp ###\n" ; cat ${arg_output}.cpp

cat ${arg_output}.objs | sed 's/\.o//' > ${arg_output}.objsnoext
cat ${arg_output}.objsnoext | xargs -I '{}' -- cp -a '{}.o' '{}_unittest.o'
cat ${arg_output}.objsnoext | xargs -I '{}' -- strip -w -K '!main' -K '*' '{}_unittest.o'

gcc -rdynamic -g -o ${arg_output} ${arg_output}.cpp $(cat ${arg_output}.objsnoext | xargs -I '{}' -- echo '{}_unittest.o' | tr '\n' ' ') -lstdc++ ${arg_linker}

argtestfile=

if [ "$arg_printonlyfailed" == "1" ] ; then
    argtestfile="-p"
fi

${arg_output} ${arg_single} -f ${arg_max} $argtestfile

rm ${arg_temp}*

exit 0


#include "unittest.h"

int unit_test_returning_pass_1 ()
{
    return 0;
}

/*
int unit_test_fail_1 ()
{
    return 1;
}
*/

int unit_test_addition_1_plus_1_eq_2_abc ()
{
    return 1+1==2 ? 0 : 1;
}

UNIT_TEST(unit_test_addition_1_plus_1_eq_2)
{
    return 1+1==2 ? 0 : 1;
}

UNIT_TEST(usingmacro)
{
    return 0;
}

UNIT_TEST(secondmacro)
{
    return 0;
}


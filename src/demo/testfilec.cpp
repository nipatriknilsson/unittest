#include "unittest.h"

int unittest_returning_pass_1 ()
{
    return 0;
}

/*
int unittest_fail_1 ()
{
    return 1;
}
*/

int unittest_addition_1_plus_1_eq_2_abc ()
{
    return 1+1==2 ? 0 : 1;
}

UNITTEST(addition_1_plus_1_eq_2)
{
    return 1+1==2 ? 0 : 1;
}

UNIT_TEST(addition_1_plus_1_eq_2)
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


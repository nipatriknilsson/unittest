#define CONCAT_IMPL( a, b, c, d, e ) a##b##c##d##e
#define MACRO_CONCAT( a, b, c, d, e ) CONCAT_IMPL( a, b, c, d, e )

#ifndef UNIT_TEST_UNIQUE_ID
#define UNIT_TEST_UNIQUE_ID __COUNTER__
#endif

#define UNIT_TEST(x) MACRO_CONCAT ( int unit_test_, x, _, UNIT_TEST_UNIQUE_ID, __LINE__ ) ()



int unit_test_returning_pass ()
{
    return 0;
}

int unit_test_not_fail ()
{
    return 0;
}

/*
int unit_test_multiple_fail ()
{
    dosomething1;

    if ( canfail1 )
    {
        return 1;
    }

    dosomething2;

    if ( canfail2 )
    {
        return 2;
    }
    
    return 0;
}
*/

int unittest_addition_1_plus_1_eq_2 ()
{
    return 1+1==2 ? 0 : 1;
}

class myclass
{
public:
    myclass ()
    {
    }

    ~myclass ()
    {
    }

protected:
    int myprotectedfunction ()
    {
        return 0;
    }

    friend int unit_test_of_protected_class_function ();
};

int unit_test_of_protected_class_function ()
{
    myclass my;

    return my.myprotectedfunction ();

}

//#include <stdio.h>
//int main(int argc, char **argv)
//{
    //// must not interfere the built of test
    //printf ( "Must not run!!!\n" );
    //return 255;
//}


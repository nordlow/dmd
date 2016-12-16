/*
PERMUTE_ARGS:
TEST_OUTPUT:
---
fail_compilation/retscope.d(22): Error: scope variable p may not be returned
fail_compilation/retscope.d(32): Error: escaping reference to local variable j
fail_compilation/retscope.d(45): Error: scope variable p assigned to non-scope q
fail_compilation/retscope.d(47): Error: cannot take address of local i in @safe function test2
fail_compilation/retscope.d(47): Error: reference to local variable i assigned to non-scope q
fail_compilation/retscope.d(48): Error: variadic variable a assigned to non-scope b
fail_compilation/retscope.d(49): Error: reference to stack allocated value returned by (*fp2)() assigned to non-scope q
---
*/



int* foo1(return scope int* p) { return p; } // ok

int* foo2()(scope int* p) { return p; }  // ok, 'return' is inferred
alias foo2a = foo2!();

int* foo3(scope int* p) { return p; }   // error

int* foo4(bool b)
{
    int i;
    int j;

    int* nested1(scope int* p) { return null; }
    int* nested2(return scope int* p) { return p; }

    return b ? nested1(&i) : nested2(&j);
}

/************************************************/

struct S2 { int a,b,c,d; }

@safe S2 function() fp2;

void test2(scope int* p, int[] a ...) @safe
{
    static int* q;
    static int[] b;
    q = p;
    int i;
    q = &i;
    b = a;
    q = &fp2().d;
}



/*
PERMUTE_ARGS:
EXTRA_FILES: imports/a9546.d

Windows linker may write something like:
---
Creating library {{RESULTS_DIR}}/runnable/traits_0.lib and object {{RESULTS_DIR}}/runnable/traits_0.exp
---

TRANSFORM_OUTPUT: remove_lines("Creating library")
TEST_OUTPUT:
---
__lambda1
---
*/

module traits;

import core.stdc.stdio;

alias int myint;
struct S { void bar() { } void tbar()() { } int x = 4; static int z = 5; }
class C { void bar() { } void tbar()() { } final void foo() { } static void abc() { } void delegate() del; }
abstract class AC { }
class AC2 { abstract void foo(); }
class AC3 : AC2 { }
final class FC { void foo() { } }
enum E { EMEM }
struct D1 { @disable void true_(); void false_(){} }
union U {}
interface I {}

private alias AliasSeq(T...) = T;
private alias UnsignedTypes = AliasSeq!(ubyte, ushort, uint, ulong,
                                        char, wchar, dchar);
private alias SignedTypes = AliasSeq!(byte, short, int, long);
private alias IntegralTypes = AliasSeq!(byte, ubyte, short, ushort, int, uint, long, ulong,
                                        char, wchar, dchar);
private alias FloatingTypes = AliasSeq!(float, double, real);
private alias ScalarTypes = AliasSeq!(byte, ubyte, short, ushort, int, uint, long, ulong,
                                      float, double, real,
                                      char, wchar, dchar,
                                      char*, void*);
private alias ArithmeticTypes = AliasSeq!(byte, ubyte, short, ushort, int, uint, long, ulong,
                                          float, double, real,
                                          char, wchar, dchar);

/********************************************************/

void test_isArithmetic()
{
    auto t = __traits(isArithmetic, int);
    assert(t == true);

    static assert(__traits(isArithmetic) == false);
    static assert(__traits(isArithmetic, myint) == true);
    static assert(__traits(isArithmetic, S) == false);
    static assert(__traits(isArithmetic, C) == false);
    static assert(__traits(isArithmetic, E) == true);
    static assert(__traits(isArithmetic, void*) == false);
    static assert(__traits(isArithmetic, void[]) == false);
    static assert(__traits(isArithmetic, void[3]) == false);
    static assert(__traits(isArithmetic, int[char]) == false);
    static assert(__traits(isArithmetic, int, int) == true);
    static assert(__traits(isArithmetic, int, S) == false);
    static assert(__traits(isArithmetic, void) == false);
    static foreach (T; ArithmeticTypes)
        static assert(__traits(isArithmetic, T) == true);
    int i;
    static assert(__traits(isArithmetic, i, i+1, int) == true);
    static assert(__traits(isArithmetic) == false);
}

/********************************************************/

void test_isScalar()
{
    auto t = __traits(isScalar, int);
    assert(t == true);

    static assert(__traits(isScalar) == false);
    static assert(__traits(isScalar, myint) == true);
    static assert(__traits(isScalar, S) == false);
    static assert(__traits(isScalar, C) == false);
    static assert(__traits(isScalar, E) == true);
    static assert(__traits(isScalar, void[]) == false);
    static assert(__traits(isScalar, void[3]) == false);
    static assert(__traits(isScalar, int[char]) == false);
    static assert(__traits(isScalar, int, int) == true);
    static assert(__traits(isScalar, int, S) == false);
    static assert(__traits(isScalar, void) == false);
    static foreach (T; ScalarTypes)
        static assert(__traits(isScalar, T) == true);
}

/********************************************************/

void test_isIntegral()
{
    static assert(__traits(isIntegral) == false);
    static assert(__traits(isIntegral, myint) == true);
    static assert(__traits(isIntegral, S) == false);
    static assert(__traits(isIntegral, C) == false);
    static assert(__traits(isIntegral, E) == true);
    static assert(__traits(isIntegral, void*) == false);
    static assert(__traits(isIntegral, void[]) == false);
    static assert(__traits(isIntegral, void[3]) == false);
    static assert(__traits(isIntegral, int[char]) == false);
    static assert(__traits(isIntegral, int, int) == true);
    static assert(__traits(isIntegral, short, int) == true);
    static assert(__traits(isIntegral, int, S) == false);
    static assert(__traits(isIntegral, S, int) == false);
    static assert(__traits(isIntegral, void) == false);
    static foreach (T; IntegralTypes)
        static assert(__traits(isIntegral, T) == true);
}

/********************************************************/

void test_isFloating()
{
    static assert(__traits(isFloating) == false);
    static assert(__traits(isFloating, S) == false);
    static assert(__traits(isFloating, C) == false);
    static assert(__traits(isFloating, E) == false);
    static assert(__traits(isFloating, void*) == false);
    static assert(__traits(isFloating, void[]) == false);
    static assert(__traits(isFloating, void[3]) == false);
    static assert(__traits(isFloating, int[char]) == false);
    static assert(__traits(isFloating, FloatingTypes[0], FloatingTypes[0]) == true);
    static assert(__traits(isFloating, float, S) == false);
    static assert(__traits(isFloating, S, float) == false);
    static assert(__traits(isFloating, void) == false);
    static foreach (T; IntegralTypes)
        static assert(__traits(isFloating, T) == false);
    static foreach (T; FloatingTypes)
        static assert(__traits(isFloating, T) == true);
}

/********************************************************/

void test_isUnsigned()
{
    static assert(__traits(isUnsigned) == false);
    static assert(__traits(isUnsigned, S) == false);
    static assert(__traits(isUnsigned, C) == false);
    static assert(__traits(isUnsigned, E) == false);
    static assert(__traits(isUnsigned, void*) == false);
    static assert(__traits(isUnsigned, void[]) == false);
    static assert(__traits(isUnsigned, void[3]) == false);
    static assert(__traits(isUnsigned, int[char]) == false);
    static assert(__traits(isUnsigned, FloatingTypes[0], FloatingTypes[0]) == false);
    static assert(__traits(isUnsigned, UnsignedTypes[0], UnsignedTypes[0]) == true);
    static assert(__traits(isUnsigned, float, S) == false);
    static assert(__traits(isUnsigned, S, float) == false);
    static assert(__traits(isUnsigned, void) == false);
    static assert(__traits(isUnsigned, byte) == false);
    static assert(__traits(isUnsigned, ubyte) == true);
    static assert(__traits(isUnsigned, short) == false);
    static assert(__traits(isUnsigned, ushort) == true);
    static assert(__traits(isUnsigned, int) == false);
    static assert(__traits(isUnsigned, uint) == true);
    static assert(__traits(isUnsigned, long) == false);
    static assert(__traits(isUnsigned, ulong) == true);
    static assert(__traits(isUnsigned, char) == true);
    static assert(__traits(isUnsigned, wchar) == true);
    static assert(__traits(isUnsigned, dchar) == true);
    static foreach (T; FloatingTypes)
        static assert(__traits(isUnsigned, T) == false);
    static foreach (T; UnsignedTypes)
        static assert(__traits(isUnsigned, T) == true);
}

void test_isSigned()
{
    static assert(__traits(isSigned) == false);
    static assert(__traits(isSigned, S) == false);
    static assert(__traits(isSigned, C) == false);
    static assert(__traits(isSigned, E) == true);
    static assert(__traits(isSigned, void*) == false);
    static assert(__traits(isSigned, void[]) == false);
    static assert(__traits(isSigned, void[3]) == false);
    static assert(__traits(isSigned, int[char]) == false);
    static assert(__traits(isSigned, FloatingTypes[0], FloatingTypes[0]) == false);
    static assert(__traits(isSigned, SignedTypes[0], SignedTypes[0]) == true);
    static assert(__traits(isSigned, float, S) == false);
    static assert(__traits(isSigned, S, float) == false);
    static assert(__traits(isSigned, void) == false);
    static assert(__traits(isSigned, byte) == true);
    static assert(__traits(isSigned, ubyte) == false);
    static assert(__traits(isSigned, short) == true);
    static assert(__traits(isSigned, ushort) == false);
    static assert(__traits(isSigned, int) == true);
    static assert(__traits(isSigned, uint) == false);
    static assert(__traits(isSigned, long) == true);
    static assert(__traits(isSigned, ulong) == false);
    static assert(__traits(isSigned, char) == false);
    static assert(__traits(isSigned, wchar) == false);
    static assert(__traits(isSigned, dchar) == false);
    static foreach (T; FloatingTypes)
        static assert(__traits(isSigned, T) == false);
    static foreach (T; SignedTypes)
        static assert(__traits(isSigned, T) == true);
}

/********************************************************/

void test_isAssociativeArray()
{
    static assert(__traits(isAssociativeArray) == false);
    static assert(__traits(isAssociativeArray, S) == false);
    static assert(__traits(isAssociativeArray, C) == false);
    static assert(__traits(isAssociativeArray, E) == false);
    static assert(__traits(isAssociativeArray, void*) == false);
    static assert(__traits(isAssociativeArray, void[]) == false);
    static assert(__traits(isAssociativeArray, void[3]) == false);
    static assert(__traits(isAssociativeArray, int[char]) == true);
    static assert(__traits(isAssociativeArray, int[char]) == true);
    static assert(__traits(isAssociativeArray, int[char], int[int]) == true);
    static assert(__traits(isAssociativeArray, float, float) == false);
    static assert(__traits(isAssociativeArray, float, S) == false);
    static assert(__traits(isAssociativeArray, S, float) == false);
    static assert(__traits(isAssociativeArray, void) == false);
    static assert(__traits(isAssociativeArray, byte) == false);
    static assert(__traits(isAssociativeArray, ubyte) == false);
    static assert(__traits(isAssociativeArray, short) == false);
    static assert(__traits(isAssociativeArray, ushort) == false);
    static assert(__traits(isAssociativeArray, int) == false);
    static assert(__traits(isAssociativeArray, uint) == false);
    static assert(__traits(isAssociativeArray, long) == false);
    static assert(__traits(isAssociativeArray, ulong) == false);
    static assert(__traits(isAssociativeArray, float) == false);
    static assert(__traits(isAssociativeArray, double) == false);
    static assert(__traits(isAssociativeArray, real) == false);
    static assert(__traits(isAssociativeArray, char) == false);
    static assert(__traits(isAssociativeArray, wchar) == false);
    static assert(__traits(isAssociativeArray, dchar) == false);
}

/********************************************************/

void test_isStaticArray()
{
    static assert(__traits(isStaticArray) == false);
    static assert(__traits(isStaticArray, S) == false);
    static assert(__traits(isStaticArray, C) == false);
    static assert(__traits(isStaticArray, E) == false);
    static assert(__traits(isStaticArray, void*) == false);
    static assert(__traits(isStaticArray, void[]) == false);
    static assert(__traits(isStaticArray, void[3]) == true);
    static assert(__traits(isStaticArray, void[3], void[3]) == true);
    static assert(__traits(isStaticArray, int[char]) == false);
    static assert(__traits(isStaticArray, float, float) == false);
    static assert(__traits(isStaticArray, float, S) == false);
    static assert(__traits(isStaticArray, S, float) == false);
    static assert(__traits(isStaticArray, void) == false);
    static foreach (T; ScalarTypes)
        static assert(__traits(isStaticArray, T) == false);
}

void test_isDynamicArray()
{
    static assert(__traits(isDynamicArray) == false);
    static assert(__traits(isDynamicArray, S) == false);
    static assert(__traits(isDynamicArray, C) == false);
    static assert(__traits(isDynamicArray, E) == false);
    static assert(__traits(isDynamicArray, void*) == false);
    static assert(__traits(isDynamicArray, void[]) == true);
    static assert(__traits(isDynamicArray, void[], void[]) == true);
    static assert(__traits(isDynamicArray, void[], float) == false);
    static assert(__traits(isDynamicArray, void[3]) == false);
    static assert(__traits(isDynamicArray, int[char]) == false);
    static assert(__traits(isDynamicArray, float, float) == false);
    static assert(__traits(isDynamicArray, float, S) == false);
    static assert(__traits(isDynamicArray, void) == false);
    static foreach (T; ScalarTypes)
        static assert(__traits(isDynamicArray, T) == false);
}

void test_isArray()
{
    static assert(__traits(isArray) == false);
    static assert(__traits(isArray, S) == false);
    static assert(__traits(isArray, C) == false);
    static assert(__traits(isArray, E) == false);
    static assert(__traits(isArray, void*) == false);
    static assert(__traits(isArray, void[]) == true);
    static assert(__traits(isArray, void[3]) == true);
    static assert(__traits(isArray, void[3], void[3]) == true);
    static assert(__traits(isArray, void[3], S) == false);
    static assert(__traits(isArray, S, void[3]) == false);
    static assert(__traits(isArray, float, float) == false);
    static assert(__traits(isArray, float, S) == false);
    static assert(__traits(isArray, void) == false);
    static foreach (T; ScalarTypes)
        static assert(__traits(isArray, T) == false);
}

void test_isAggregate()
{
    static assert(__traits(isAggregate) == false);
    static assert(__traits(isAggregate, S) == true);
    static assert(__traits(isAggregate, C) == true);
    static assert(__traits(isAggregate, U) == true);
    static assert(__traits(isAggregate, I) == true);
    static assert(__traits(isAggregate, E) == false);
    static assert(__traits(isAggregate, void*) == false);
    static assert(__traits(isAggregate, float, float) == false);
    static assert(__traits(isAggregate, float, S) == false);
    static assert(__traits(isAggregate, S, float) == false);
    static assert(__traits(isAggregate, S, S) == true);
    static assert(__traits(isAggregate, void) == false);
    static foreach (T; ScalarTypes)
        static assert(__traits(isAggregate, T) == false);
}

/********************************************************/

void test_isAbstractClass()
{
    static assert(__traits(isAbstractClass) == false);
    static assert(__traits(isAbstractClass, S) == false);
    static assert(__traits(isAbstractClass, C) == false);
    static assert(__traits(isAbstractClass, AC) == true);
    static assert(__traits(isAbstractClass, AC, AC) == true);
    static assert(__traits(isAbstractClass, E) == false);
    static assert(__traits(isAbstractClass, void*) == false);
    static assert(__traits(isAbstractClass, void[]) == false);
    static assert(__traits(isAbstractClass, void[3]) == false);
    static assert(__traits(isAbstractClass, int[char]) == false);
    static assert(__traits(isAbstractClass, float, float) == false);
    static assert(__traits(isAbstractClass, float, S) == false);
    static assert(__traits(isAbstractClass, S, float) == false);
    static assert(__traits(isAbstractClass, void) == false);
    static assert(__traits(isAbstractClass, AC2) == true);
    static assert(__traits(isAbstractClass, AC3) == true);
    static foreach (T; ScalarTypes)
        static assert(__traits(isAbstractClass, T) == false);
}

/********************************************************/

void test_isFinalClass()
{
    static assert(__traits(isFinalClass) == false);
    static assert(__traits(isFinalClass, C) == false);
    static assert(__traits(isFinalClass, FC) == true);
    static assert(__traits(isFinalClass, FC, FC) == true);
    static assert(__traits(isFinalClass, C, FC) == false);
    static assert(__traits(isFinalClass, FC, C) == false);
}

/********************************************************/

void test_isAbstractFunction()
{
    static assert(__traits(isAbstractFunction) == false);
    static assert(__traits(isAbstractFunction, C.bar) == false);
    static assert(__traits(isAbstractFunction, C.tbar) == false);
    static assert(__traits(isAbstractFunction, C.tbar!()) == false);
    static assert(__traits(isAbstractFunction, S.bar) == false);
    static assert(__traits(isAbstractFunction, S.tbar) == false);
    static assert(__traits(isAbstractFunction, S.tbar!()) == false);
    static assert(__traits(isAbstractFunction, AC2.foo) == true);
    static assert(__traits(isAbstractFunction, AC2.foo, AC2.foo) == true);
    static assert(__traits(isAbstractFunction, C.bar, AC2.foo) == false);
    static assert(__traits(isAbstractFunction, AC2.foo, C.bar) == false);
}

/********************************************************/

void test_isFinalFunction()
{
    static assert(__traits(isFinalFunction) == false);
    static assert(__traits(isFinalFunction, C.bar) == false);
    static assert(__traits(isFinalFunction, C.tbar) == false);
    static assert(__traits(isFinalFunction, S.bar) == false);
    static assert(__traits(isFinalFunction, S.tbar) == false);
    static assert(__traits(isFinalFunction, AC2.foo) == false);
    static assert(__traits(isFinalFunction, FC.foo) == true);
    static assert(__traits(isFinalFunction, FC.foo, FC.foo) == true);
    static assert(__traits(isFinalFunction, C.foo) == true);
    static assert(__traits(isFinalFunction, C.foo, C.foo) == true);
    static assert(__traits(isFinalFunction, S.bar, C.foo) == false);
    static assert(__traits(isFinalFunction, C.foo, S.bar) == false);
}

void test_isNormalFunction() // mimics `std.traits.isFunction`
{
    static assert(__traits(isNormalFunction) == false);
    static assert(__traits(isNormalFunction, C.bar) == true);
    static assert(__traits(isNormalFunction, C.tbar) == false);
    static assert(__traits(isNormalFunction, C.tbar!()) == true);
    static assert(__traits(isNormalFunction, C.foo) == true);
    static assert(__traits(isNormalFunction, C.del) == false);
    static assert(__traits(isNormalFunction, S.bar) == true);
    static assert(__traits(isNormalFunction, S.tbar) == false);
    static assert(__traits(isNormalFunction, S.tbar!()) == true);
    static assert(__traits(isNormalFunction, AC2.foo) == true);
    static assert(__traits(isNormalFunction, FC.foo) == true);
    static assert(__traits(isNormalFunction, FC.foo, FC.foo) == true);
    static assert(__traits(isNormalFunction, C.foo) == true);
    static assert(__traits(isNormalFunction, C.foo, C.foo) == true);
    static assert(__traits(isNormalFunction, S.bar, C.foo) == true);
    static assert(__traits(isNormalFunction, C.foo, S.bar) == true);
    static assert(__traits(isNormalFunction, C.bar) == true);
    static assert(__traits(isNormalFunction, S.bar) == true);
    static assert(__traits(isNormalFunction, AC2.foo) == true);
    static assert(__traits(isNormalFunction, AC2.foo, AC2.foo) == true);
    static assert(__traits(isNormalFunction, C.bar, AC2.foo) == true);
    static assert(__traits(isNormalFunction, AC2.foo, C.bar) == true);
}

void test_isTemplate()
{
    struct S {}
    struct C {}
    struct St() {}
    class Ct() {}
    static assert(__traits(isTemplate) == false);
    static assert(__traits(isTemplate, St) == true);
    static assert(__traits(isTemplate, St, Ct) == true);
    static assert(__traits(isTemplate, St, St) == true);
    static assert(__traits(isTemplate, Ct, Ct) == true);
    static assert(__traits(isTemplate, St, S) == false);
    static assert(__traits(isTemplate, S, S) == false);
    static foreach (T; ArithmeticTypes)
        static assert(__traits(isTemplate, T) == false);
}

/********************************************************/

void test_getMember()
{
    S s;
    __traits(getMember, s, "x") = 7;
    auto i = __traits(getMember, s, "x");
    assert(i == 7);
    auto j = __traits(getMember, S, "z");
    assert(j == 5);
}

void test_hasMember()
{
    S s;
    static assert(__traits(hasMember, s, "x") == true);
    static assert(__traits(hasMember, S, "z") == true);
    static assert(__traits(hasMember, S, "aaa") == false);
}

void test_classInstanceSize()
{
    S s;
    auto k = __traits(classInstanceSize, C);
    assert(k == C.classinfo.initializer.length);
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=7123

private struct DelegateFaker7123(F)
{
    template GeneratingPolicy() {}
    enum WITH_BASE_CLASS = __traits(hasMember, GeneratingPolicy!(), "x");
}

auto toDelegate7123(F)(F fp)
{
    alias DelegateFaker7123!F Faker;
}


void test_toDelegate7123()
{
    static assert(is(typeof(toDelegate7123(&main))));
}

/********************************************************/

class D14
{
    this() { }
    ~this() { }
    void foo() { }
    int foo(int) { return 0; }
}

void test_derivedMembers()
{
    auto a = [__traits(derivedMembers, D14)];
    assert(a == ["__ctor","__dtor","foo", "__xdtor"]);
}

/********************************************************/

class D15
{
    this() { }
    ~this() { }
    void foo() { }
    int foo(int) { return 2; }
}

/********************************************************/

struct S16 { }

int foo16();
int bar16();

void test_isSame()
{
    static assert(__traits(isSame, foo16, foo16) == true);
    static assert(__traits(isSame, foo16, bar16) == false);
    static assert(__traits(isSame, foo16, S16) == false);
    static assert(__traits(isSame, S16, S16) == true);
    static assert(__traits(isSame, core, S16) == false);
    static assert(__traits(isSame, core, core) == true);
    static assert(__traits(isSame, core, core) == true);
}

/********************************************************/

struct S17
{
    static int s1;
    int s2;
}

int foo17();

void test_compiles()
{
    static assert(__traits(compiles) == false);
    static assert(__traits(compiles, foo17) == true);
    static assert(__traits(compiles, foo17 + 1) == true);
    static assert(__traits(compiles, &foo17 + 1) == false);
    static assert(__traits(compiles, typeof(1)) == true);
    static assert(__traits(compiles, S17.s1) == true);
    static assert(__traits(compiles, S17.s3) == false);
    static assert(__traits(compiles, 1,2,3,int,long,core) == true);
    static assert(__traits(compiles, 3[1]) == false);
    static assert(__traits(compiles, 1,2,3,int,long,3[1]) == false);
}

/********************************************************/

interface D18
{
  extern(Windows):
    void foo();
    int foo(int);
}

void test_allMembers_D18()
{
    auto a = __traits(allMembers, D18);
    assert(a.length == 1);
}


/********************************************************/

class C19
{
    void mutating_method(){}

    const void const_method(){}

    void bastard_method(){}
    const void bastard_method(int){}
}


void test_allMembers_C19()
{
    auto a = __traits(allMembers, C19);
    assert(a.length == 9);

    foreach( m; __traits(allMembers, C19) )
        printf("%.*s\n", cast(int)m.length, m.ptr);
}


/********************************************************/

void test_isRef_isOut_isLazy()
{
    void fooref(ref int x)
    {
        static assert(__traits(isRef, x));
        static assert(__traits(isRef, x, x));
        static assert(!__traits(isOut, x));
        static assert(!__traits(isOut, x, x));
        static assert(!__traits(isLazy, x));
        static assert(!__traits(isLazy, x, x));
    }

    void fooout(out int x)
    {
        static assert(!__traits(isRef, x));
        static assert(!__traits(isRef, x, x));
        static assert(__traits(isOut, x));
        static assert(__traits(isOut, x, x));
        static assert(!__traits(isLazy, x));
        static assert(!__traits(isLazy, x, x));
    }

    void foolazy(lazy int x)
    {
        static assert(!__traits(isRef, x));
        static assert(!__traits(isRef, x, x));
        static assert(!__traits(isOut, x));
        static assert(!__traits(isOut, x, x));
        static assert(__traits(isLazy, x));
        static assert(__traits(isLazy, x, x));
    }
}

/********************************************************/

void test_isStaticFunction()
{
    static assert(__traits(isStaticFunction, C.bar) == false);
    static assert(__traits(isStaticFunction, C.bar, C.bar) == false);
    static assert(__traits(isStaticFunction, C.abc) == true);
    static assert(__traits(isStaticFunction, C.abc, C.abc) == true);
    static assert(__traits(isStaticFunction, S.bar) == false);
    static assert(__traits(isStaticFunction, C.abc, S.bar) == false);
    static assert(__traits(isStaticFunction, S.bar, C.abc) == false);
}

/********************************************************/

class D22
{
    this() { }
    ~this() { }
    void foo() { }
    int foo(int) { return 2; }
}

void test_getOverloads()
{
    D22 d = new D22();

    assert(typeid(typeof(__traits(getOverloads, D22, "foo")[0])).toString()
           == "void function()");
    assert(typeid(typeof(__traits(getOverloads, D22, "foo")[1])).toString()
           == "int function(int)");

    alias typeof(__traits(getOverloads, D22, "foo")) b;
    assert(typeid(b[0]).toString() == "void function()");
    assert(typeid(b[1]).toString() == "int function(int)");

    auto i = __traits(getOverloads, d, "foo")[1](1);
    assert(i == 2);
}

/********************************************************/

string toString23(E)(E value) if (is(E == enum)) {
   foreach (s; __traits(allMembers, E)) {
      if (value == mixin("E." ~ s)) return s;
   }
   return null;
}

enum OddWord { acini, alembicated, prolegomena, aprosexia }

void test_allMembers_toString23()
{
   auto w = OddWord.alembicated;
   assert(toString23(w) == "alembicated");
}

/********************************************************/

struct Test24
{
    public void test24(int){}
    private void test24(int, int){}
}

static assert(__traits(getVisibility, __traits(getOverloads, Test24, "test24")[1]) == "private");

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=1369

void test_getMember_issue1369()
{
    class C1
    {
        static int count;
        void func() { count++; }
    }

    // variable symbol
    C1 c1 = new C1;
    __traits(getMember, c1, "func")();      // TypeIdentifier -> VarExp
    __traits(getMember, mixin("c1"), "func")(); // Expression -> VarExp
    assert(C1.count == 2);

    // nested function symbol
    @property C1 get() { return c1; }
    __traits(getMember, get, "func")();
    __traits(getMember, mixin("get"), "func")();
    assert(C1.count == 4);

    class C2
    {
        C1 c1;
        this() { c1 = new C1; }
        void test()
        {
            // variable symbol (this.outer.c1)
            __traits(getMember, c1, "func")();      // TypeIdentifier -> VarExp -> DotVarExp
            __traits(getMember, mixin("c1"), "func")(); // Expression -> VarExp -> DotVarExp
            assert(C1.count == 6);

            // nested function symbol (this.outer.get)
            __traits(getMember, get, "func")();
            __traits(getMember, mixin("get"), "func")();
            assert(C1.count == 8);
        }
    }
    C2 c2 = new C2;
    c2.test();
}

/********************************************************/

template Foo2234(){ int x; }

struct S2234a{ mixin Foo2234; }
struct S2234b{ mixin Foo2234; mixin Foo2234; }
struct S2234c{ alias Foo2234!() foo; }

static assert([__traits(allMembers, S2234a)] == ["x"]);
static assert([__traits(allMembers, S2234b)] == ["x"]);
static assert([__traits(allMembers, S2234c)] == ["foo"]);

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=5878

template J5878(A)
{
    static if (is(A P == super))
        alias P J5878;
}

alias J5878!(A5878) Z5878;

class X5878 {}
class A5878 : X5878 {}

/********************************************************/

mixin template Members6674()
{
    static int i1;
    static int i2;
    static int i3;  //comment out to make func2 visible
    static int i4;  //comment out to make func1 visible
}

class Test6674
{
    mixin Members6674;

    alias void function() func1;
    alias bool function() func2;
}

static assert([__traits(allMembers,Test6674)] == [
    "i1","i2","i3","i4",
    "func1","func2",
    "toString","toHash","opCmp","opEquals","Monitor","factory"]);

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=6073

struct S6073 {}

template T6073(M...) {
    //alias int T;
}
alias T6073!traits V6073;                       // ok
alias T6073!(__traits(parent, S6073)) U6073;    // error
static assert(__traits(isSame, V6073, U6073));  // same instantiation == same arguemnts

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=7027

struct Foo7027 { int a; }
static assert(!__traits(compiles, { return Foo7027.a; }));

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=9213

class Foo9213 { int a; }
static assert(!__traits(compiles, { return Foo9213.a; }));

/********************************************************/

interface AA
{
     int YYY();
}

class DD
{
    final int YYY() { return 4; }
}

static assert(__traits(isVirtualMethod, DD.YYY) == false);
static assert(__traits(isVirtualMethod, DD.YYY, DD.YYY) == false);
static assert(__traits(getVirtualMethods, DD, "YYY").length == 0);

class EE
{
     int YYY() { return 0; }
}

class FF : EE
{
    final override int YYY() { return 4; }
}

static assert(__traits(isVirtualMethod, FF.YYY));
static assert(__traits(isVirtualMethod, FF.YYY, FF.YYY));
static assert(__traits(getVirtualMethods, FF, "YYY").length == 1);

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=7608

struct S7608a(bool T)
{
    static if (T) { int x; }
    int y;
}
struct S7608b
{
    version(none) { int x; }
    int y;
}
template TypeTuple7608(T...){ alias T TypeTuple7608; }
void test_issue7608()
{
    alias TypeTuple7608!(__traits(allMembers, S7608a!false)) MembersA;
    static assert(MembersA.length == 1);
    static assert(MembersA[0] == "y");

    alias TypeTuple7608!(__traits(allMembers, S7608b)) MembersB;
    static assert(MembersB.length == 1);
    static assert(MembersB[0] == "y");
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=7858

void test_issue7858()
{
    class C
    {
        final void ffunc(){}
        final void ffunc(int){}

        void vfunc(){}
        void vfunc(int){}

        abstract void afunc();
        abstract void afunc(int);

        static void sfunc(){}
        static void sfunc(int){}
    }

    static assert(__traits(isFinalFunction, C.ffunc) ==
                  __traits(isFinalFunction, __traits(getOverloads, C, "ffunc")[0]));    // NG
    static assert(__traits(isVirtualMethod, C.vfunc) ==
                  __traits(isVirtualMethod, __traits(getOverloads, C, "vfunc")[0]));    // NG
    static assert(__traits(isAbstractFunction, C.afunc) ==
                  __traits(isAbstractFunction, __traits(getOverloads, C, "afunc")[0])); // OK
    static assert(__traits(isStaticFunction, C.sfunc) ==
                  __traits(isStaticFunction, __traits(getOverloads, C, "sfunc")[0]));   // OK

    static assert(__traits(isSame, C.ffunc, __traits(getOverloads, C, "ffunc")[0]));    // NG
    static assert(__traits(isSame, C.vfunc, __traits(getOverloads, C, "vfunc")[0]));    // NG
    static assert(__traits(isSame, C.afunc, __traits(getOverloads, C, "afunc")[0]));    // NG
    static assert(__traits(isSame, C.sfunc, __traits(getOverloads, C, "sfunc")[0]));    // NG
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=8971

template Tuple8971(TL...){ alias TL Tuple8971; }

class A8971
{
    void bar() {}

    void connect()
    {
        alias Tuple8971!(__traits(getOverloads, typeof(this), "bar")) overloads;
        static assert(__traits(isSame, overloads[0], bar));
    }
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=8972

struct A8972
{
    void foo() {}

    void connect()
    {
        alias Tuple8971!(__traits(getOverloads, typeof(this), "foo")) overloads;
        static assert(__traits(isSame, overloads[0], foo));
    }
}

/********************************************************/

private   struct TestProt1 {}
package   struct TestProt2 {}
protected struct TestProt3 {}
public    struct TestProt4 {}
export    struct TestProt5 {}

void getVisibility()
{
    class Test
    {
        private   { int va; void fa(){} }
        package   { int vb; void fb(){} }
        protected { int vc; void fc(){} }
        public    { int vd; void fd(){} }
        export    { int ve; void fe(){} }
    }
    Test t;

    // TOKvar and VarDeclaration
    static assert(__traits(getVisibility, Test.va) == "private");
    static assert(__traits(getVisibility, Test.vb) == "package");
    static assert(__traits(getVisibility, Test.vc) == "protected");
    static assert(__traits(getVisibility, Test.vd) == "public");
    static assert(__traits(getVisibility, Test.ve) == "export");

    // TOKdotvar and VarDeclaration
    static assert(__traits(getVisibility, t.va) == "private");
    static assert(__traits(getVisibility, t.vb) == "package");
    static assert(__traits(getVisibility, t.vc) == "protected");
    static assert(__traits(getVisibility, t.vd) == "public");
    static assert(__traits(getVisibility, t.ve) == "export");

    // TOKvar and FuncDeclaration
    static assert(__traits(getVisibility, Test.fa) == "private");
    static assert(__traits(getVisibility, Test.fb) == "package");
    static assert(__traits(getVisibility, Test.fc) == "protected");
    static assert(__traits(getVisibility, Test.fd) == "public");
    static assert(__traits(getVisibility, Test.fe) == "export");

    // TOKdotvar and FuncDeclaration
    static assert(__traits(getVisibility, t.fa) == "private");
    static assert(__traits(getVisibility, t.fb) == "package");
    static assert(__traits(getVisibility, t.fc) == "protected");
    static assert(__traits(getVisibility, t.fd) == "public");
    static assert(__traits(getVisibility, t.fe) == "export");

    // TOKtype
    static assert(__traits(getVisibility, TestProt1) == "private");
    static assert(__traits(getVisibility, TestProt2) == "package");
    static assert(__traits(getVisibility, TestProt3) == "protected");
    static assert(__traits(getVisibility, TestProt4) == "public");
    static assert(__traits(getVisibility, TestProt5) == "export");

    // This specific pattern is important to ensure it always works
    // through reflection, however that becomes implemented
    static assert(__traits(getVisibility, __traits(getMember, t, "va")) == "private");
    static assert(__traits(getVisibility, __traits(getMember, t, "vb")) == "package");
    static assert(__traits(getVisibility, __traits(getMember, t, "vc")) == "protected");
    static assert(__traits(getVisibility, __traits(getMember, t, "vd")) == "public");
    static assert(__traits(getVisibility, __traits(getMember, t, "ve")) == "export");
    static assert(__traits(getVisibility, __traits(getMember, t, "fa")) == "private");
    static assert(__traits(getVisibility, __traits(getMember, t, "fb")) == "package");
    static assert(__traits(getVisibility, __traits(getMember, t, "fc")) == "protected");
    static assert(__traits(getVisibility, __traits(getMember, t, "fd")) == "public");
    static assert(__traits(getVisibility, __traits(getMember, t, "fe")) == "export");
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=9546

void test9546()
{
    import imports.a9546 : S;

    S s;
    static assert(__traits(getVisibility, s.privA) == "private");
    static assert(__traits(getVisibility, s.protA) == "protected");
    static assert(__traits(getVisibility, s.packA) == "package");
    static assert(__traits(getVisibility, S.privA) == "private");
    static assert(__traits(getVisibility, S.protA) == "protected");
    static assert(__traits(getVisibility, S.packA) == "package");

    static assert(__traits(getVisibility, mixin("s.privA")) == "private");
    static assert(__traits(getVisibility, mixin("s.protA")) == "protected");
    static assert(__traits(getVisibility, mixin("s.packA")) == "package");
    static assert(__traits(getVisibility, mixin("S.privA")) == "private");
    static assert(__traits(getVisibility, mixin("S.protA")) == "protected");
    static assert(__traits(getVisibility, mixin("S.packA")) == "package");

    static assert(__traits(getVisibility, __traits(getMember, s, "privA")) == "private");
    static assert(__traits(getVisibility, __traits(getMember, s, "protA")) == "protected");
    static assert(__traits(getVisibility, __traits(getMember, s, "packA")) == "package");
    static assert(__traits(getVisibility, __traits(getMember, S, "privA")) == "private");
    static assert(__traits(getVisibility, __traits(getMember, S, "protA")) == "protected");
    static assert(__traits(getVisibility, __traits(getMember, S, "packA")) == "package");

    static assert(__traits(getVisibility, s.privF) == "private");
    static assert(__traits(getVisibility, s.protF) == "protected");
    static assert(__traits(getVisibility, s.packF) == "package");
    static assert(__traits(getVisibility, S.privF) == "private");
    static assert(__traits(getVisibility, S.protF) == "protected");
    static assert(__traits(getVisibility, S.packF) == "package");

    static assert(__traits(getVisibility, mixin("s.privF")) == "private");
    static assert(__traits(getVisibility, mixin("s.protF")) == "protected");
    static assert(__traits(getVisibility, mixin("s.packF")) == "package");
    static assert(__traits(getVisibility, mixin("S.privF")) == "private");
    static assert(__traits(getVisibility, mixin("S.protF")) == "protected");
    static assert(__traits(getVisibility, mixin("S.packF")) == "package");

    static assert(__traits(getVisibility, __traits(getMember, s, "privF")) == "private");
    static assert(__traits(getVisibility, __traits(getMember, s, "protF")) == "protected");
    static assert(__traits(getVisibility, __traits(getMember, s, "packF")) == "package");
    static assert(__traits(getVisibility, __traits(getMember, S, "privF")) == "private");
    static assert(__traits(getVisibility, __traits(getMember, S, "protF")) == "protected");
    static assert(__traits(getVisibility, __traits(getMember, S, "packF")) == "package");
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=9091

template isVariable9091(X...) if (X.length == 1)
{
    enum isVariable9091 = true;
}
class C9091
{
    int x;  // some class members
    void func(int n){ this.x = n; }

    void test()
    {
        alias T = C9091;
        enum is_x = isVariable9091!(__traits(getMember, T, "x"));

        foreach (i, m; __traits(allMembers, T))
        {
            enum x = isVariable9091!(__traits(getMember, T, m));
            static if (i == 0)  // x
            {
                __traits(getMember, T, m) = 10;
                assert(this.x == 10);
            }
            static if (i == 1)  // func
            {
                __traits(getMember, T, m)(20);
                assert(this.x == 20);
            }
        }
    }
}
struct S9091
{
    int x;  // some struct members
    void func(int n){ this.x = n; }

    void test()
    {
        alias T = S9091;
        enum is_x = isVariable9091!(__traits(getMember, T, "x"));

        foreach (i, m; __traits(allMembers, T))
        {
            enum x = isVariable9091!(__traits(getMember, T, m));
            static if (i == 0)  // x
            {
                __traits(getMember, T, m) = 10;
                assert(this.x == 10);
            }
            static if (i == 1)  // func
            {
                __traits(getMember, T, m)(20);
                assert(this.x == 20);
            }
        }
    }
}

void test_issue9091()
{
    auto c = new C9091();
    c.test();

    auto s = S9091();
    s.test();
}

/********************************************************/

struct CtorS_9237 { this(int x) { } }       // ctor -> POD
struct DtorS_9237 { ~this() { } }           // dtor -> nonPOD
struct PostblitS_9237 { this(this) { } }    // cpctor -> nonPOD

struct NonPOD1_9237
{
    DtorS_9237 field;  // nonPOD -> ng
}

struct NonPOD2_9237
{
    DtorS_9237[2] field;  // static array of nonPOD -> ng
}

struct POD1_9237
{
    DtorS_9237* field;  // pointer to nonPOD -> ok
}

struct POD2_9237
{
    DtorS_9237[] field;  // dynamic array of nonPOD -> ok
}

struct POD3_9237
{
    int x = 123;
}

class C_9273 { }

void test9237()
{
    int x;
    struct NS_9237  // acceses .outer -> nested
    {
        void foo() { x++; }
    }

    struct NonNS_9237 { }  // doesn't access .outer -> non-nested
    static struct StatNS_9237 { }  // can't access .outer -> non-nested

    static assert(!__traits(isPOD, NS_9237));
    static assert(__traits(isPOD, NonNS_9237));
    static assert(__traits(isPOD, StatNS_9237));
    static assert(__traits(isPOD, CtorS_9237));
    static assert(!__traits(isPOD, DtorS_9237));
    static assert(!__traits(isPOD, PostblitS_9237));
    static assert(!__traits(isPOD, NonPOD1_9237));
    static assert(!__traits(isPOD, NonPOD2_9237));
    static assert(__traits(isPOD, POD1_9237));
    static assert(__traits(isPOD, POD2_9237));
    static assert(__traits(isPOD, POD3_9237));

    // static array of POD/non-POD types
    static assert(!__traits(isPOD, NS_9237[2]));
    static assert(__traits(isPOD, NonNS_9237[2]));
    static assert(__traits(isPOD, StatNS_9237[2]));
    static assert(__traits(isPOD, CtorS_9237[2]));
    static assert(!__traits(isPOD, DtorS_9237[2]));
    static assert(!__traits(isPOD, PostblitS_9237[2]));
    static assert(!__traits(isPOD, NonPOD1_9237[2]));
    static assert(!__traits(isPOD, NonPOD2_9237[2]));
    static assert(__traits(isPOD, POD1_9237[2]));
    static assert(__traits(isPOD, POD2_9237[2]));
    static assert(__traits(isPOD, POD3_9237[2]));

    // non-structs are POD types
    static assert(__traits(isPOD, C_9273));
    static assert(__traits(isPOD, int));
    static assert(__traits(isPOD, int*));
    static assert(__traits(isPOD, int[]));
    static assert(!__traits(compiles, __traits(isPOD, 123) ));
}

/*************************************************************/
// https://issues.dlang.org/show_bug.cgi?id=5978

void test_issue5978()
{
    () {
        int x;
        pragma(msg, __traits(identifier, __traits(parent, x)));
    } ();
}

/*************************************************************/

template T7408() { }

void test_issue7408()
{
    auto x = T7408!().stringof;
    auto y = T7408!().mangleof;
    static assert(__traits(compiles, T7408!().stringof));
    static assert(__traits(compiles, T7408!().mangleof));
    static assert(!__traits(compiles, T7408!().init));
    static assert(!__traits(compiles, T7408!().offsetof));
}

/*************************************************************/
// https://issues.dlang.org/show_bug.cgi?id=9552

class C9552
{
    int f() { return 10; }
    int f(int n) { return n * 2; }
}

void test_issue9552()
{
    auto c = new C9552;
    auto dg1 = &(__traits(getOverloads, c, "f")[0]); // DMD crashes
    assert(dg1() == 10);
    auto dg2 = &(__traits(getOverloads, c, "f")[1]);
    assert(dg2(10) == 20);
}

/*************************************************************/

void test_issue9136()
{
    int x;
    struct S1 { void f() { x++; } }
    struct U1 { void f() { x++; } }
    static struct S2 { }
    static struct S3 { S1 s; }
    static struct U2 { }
    void f1() { x++; }
    static void f2() { }

    static assert(__traits(isNested, S1));
    static assert(__traits(isNested, U1));
    static assert(!__traits(isNested, S2));
    static assert(!__traits(isNested, S3));
    static assert(!__traits(isNested, U2));
    static assert(!__traits(compiles, __traits(isNested, int) ));
    static assert(!__traits(compiles, __traits(isNested, f1, f2) ));
    static assert(__traits(isNested, f1));
    static assert(!__traits(isNested, f2));

    static class A { static class SC { } class NC { } }
    static assert(!__traits(isNested, A));
    static assert(!__traits(isNested, A.SC));
    static assert(__traits(isNested, A.NC));
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=9939

struct Test9939
{
    int f;
    enum /*Anonymous enum*/
    {
        A,
        B
    }
    enum NamedEnum
    {
        C,
        D
    }
}

static assert([__traits(allMembers, Test9939)] == ["f", "A", "B", "NamedEnum"]);

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=10043

void test10043()
{
    struct X {}
    X d1;
    static assert(!__traits(compiles, d1.structuralCast!Refleshable));
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=10096

struct S10096X
{
    string str;

    invariant() {}
    invariant() {}
    unittest {}
    unittest {}

    this(int) {}
    this(this) {}
    ~this() {}

    string getStr() in(str) out(r; r == str) { return str; }
}
static assert(
    [__traits(allMembers, S10096X)] ==
    ["str", "__ctor", "__postblit", "__dtor", "getStr", "__xdtor", "__xpostblit", "opAssign"]);

class C10096X
{
    string str;

    invariant() {}
    invariant() {}
    unittest {}
    unittest {}

    this(int) {}
    ~this() {}

    string getStr() in(str) out(r; r == str) { return str; }
}
static assert(
    [__traits(allMembers, C10096X)] ==
    ["str", "__ctor", "__dtor", "getStr", "__xdtor", "toString", "toHash", "opCmp", "opEquals", "Monitor", "factory"]);

// --------

string foo10096(alias var, T = typeof(var))()
{
    foreach (idx, member; __traits(allMembers, T))
    {
        auto x = var.tupleof[idx];
    }

    return "";
}

string foo10096(T)(T var)
{
    return "";
}

struct S10096
{
    int i;
    string s;
}

void test_issue10096()
{
    S10096 s = S10096(1, "");
    auto x = foo10096!s;
}

/********************************************************/

unittest { }

struct GetUnitTests
{
    unittest { }
}

void test_getUnitTests ()
{
    // Always returns empty tuple if the -unittest flag isn't used
    static assert(__traits(getUnitTests, mixin(__MODULE__)).length == 0);
    static assert(__traits(getUnitTests, GetUnitTests).length == 0);
}

/********************************************************/

class TestIsOverrideFunctionBase
{
    void bar () {}
}

class TestIsOverrideFunctionPass : TestIsOverrideFunctionBase
{
    override void bar () {}
}

void test_isOverrideFunction ()
{
    static assert(__traits(isOverrideFunction, TestIsOverrideFunctionPass.bar) == true);
    static assert(__traits(isOverrideFunction, TestIsOverrideFunctionPass.bar, TestIsOverrideFunctionPass.bar) == true);
    static assert(__traits(isOverrideFunction, TestIsOverrideFunctionBase.bar, TestIsOverrideFunctionBase.bar) == false);
    static assert(__traits(isOverrideFunction, TestIsOverrideFunctionPass.bar, TestIsOverrideFunctionBase.bar) == false);
    static assert(__traits(isOverrideFunction, TestIsOverrideFunctionBase.bar, TestIsOverrideFunctionPass.bar) == false);
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=11711
// Add __traits(getAliasThis)

alias TypeTuple(T...) = T;

void test11711()
{
    struct S1
    {
        string var;
        alias var this;
    }
    static assert(__traits(getAliasThis, S1) == TypeTuple!("var"));
    static assert(is(typeof(__traits(getMember, S1.init, __traits(getAliasThis, S1)[0]))
                == string));

    struct S2
    {
        TypeTuple!(int, string) var;
        alias var this;
    }
    static assert(__traits(getAliasThis, S2) == TypeTuple!("var"));
    static assert(is(typeof(__traits(getMember, S2.init, __traits(getAliasThis, S2)[0]))
                == TypeTuple!(int, string)));

    // https://issues.dlang.org/show_bug.cgi?id=19439
    // Return empty tuple for non-aggregate types.
    static assert(__traits(getAliasThis, int).length == 0);
}


/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=12278

class Foo12278
{
    InPlace12278!Bar12278 inside;
}

class Bar12278 { }

struct InPlace12278(T)
{
    static assert(__traits(classInstanceSize, T) != 0);
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=12571

mixin template getScopeName12571()
{
    enum string scopeName = __traits(identifier, __traits(parent, scopeName));
}

void test12571()
{
    mixin getScopeName12571;
    static assert(scopeName == "test12571");
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=12237

auto f12237(T)(T a)
{
    static if (is(typeof(a) == int))
        return f12237("");
    else
        return 10;
}

void test_issue12237()
{
    assert(f12237(1) == 10);

    assert((a){
        static if (is(typeof(a) == int))
        {
            int x;
            return __traits(parent, x)("");
        }
        else
            return 10;
    }(1) == 10);
}

/********************************************************/

void async(ARGS...)(ARGS)
{
        static void compute(ARGS)
        {
        }

        auto x = __traits(getParameterStorageClasses, compute, 1);
}

alias test17495 = async!(int, int);

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=15094

void test_issue15094()
{
    static struct Foo { int i; }
    static struct Bar { Foo foo; }

    Bar bar;
    auto n = __traits(getMember, bar.foo, "i");
    assert(n == bar.foo.i);
}

/********************************************************/

void test_isDisabled()
{
    static assert(__traits(isDisabled, D1.true_));
    static assert(__traits(isDisabled, D1.true_, D1.true_));
    static assert(!__traits(isDisabled, D1.true_, D1.false_));
    static assert(!__traits(isDisabled, D1.false_));
    static assert(!__traits(isDisabled, D1));
    static assert(!__traits(isDisabled, D1, D1));
}

/********************************************************/
// https://issues.dlang.org/show_bug.cgi?id=10100

enum E10100
{
    value,
    _value,
    __value,
    ___value,
    ____value,
}
static assert(
    [__traits(allMembers, E10100)] ==
    ["value", "_value", "__value", "___value", "____value"]);

/********************************************************/

int main()
{
    test_isArithmetic();
    test_isScalar();
    test_isIntegral();
    test_isFloating();
    test_isUnsigned();
    test_isSigned();
    test_isAssociativeArray();
    test_isStaticArray();
    test_isDynamicArray();
    test_isArray();
    test_isAbstractClass();
    test_isFinalClass();
    test_isAbstractFunction();
    test_isFinalFunction();
    test_isNormalFunction();
    test_isTemplate();
    test_getMember();
    test_hasMember();
    test_classInstanceSize();
    test_toDelegate7123();
    test_derivedMembers();
    test_isSame();
    test_compiles();
    test_allMembers_D18();
    test_allMembers_C19();
    test_isRef_isOut_isLazy();
    test_isStaticFunction();
    test_getOverloads();
    test_allMembers_toString23();
    test_getMember_issue1369();
    test_issue7608();
    test_issue7858();
    test_issue9091();
    test_issue5978();
    test_issue7408();
    test_issue9552();
    test_issue9136();
    test_issue10096();
    test_getUnitTests();
    test_isOverrideFunction();
    test_issue12237();
    test_issue15094();
    test_isDisabled();

    printf("Success\n");
    return 0;
}

module traits_hasAliasing;

@safe pure nothrow @nogc:

/** Verify behavior of `__traits(hasAliasing, void*)` being same as `std.traits.hasAliasing`.
 *
 * Copied from Phobos `std.traits` and extended.
 */
private static void test1()
{
    static assert(__traits(hasAliasing, void*));
    static assert(!__traits(hasAliasing, void function()));

    class C { int a; }
    static assert(__traits(hasAliasing, C));

    struct S1 { int a; Object b; }
    struct S2 { string a; }
    struct S3 { int a; immutable Object b; }
    struct S4 { float[3] vals; }
    struct S41 { int*[3] vals; }
    struct S42 { immutable(int)*[3] vals; }
    struct S5 { int[int] vals; } // not in std.traits
    struct S6 { const int[int] vals; } // not in std.traits
    struct S7 { immutable int[int] vals; } // not in std.traits

    static assert( __traits(hasAliasing, S1));
    static assert(!__traits(hasAliasing, S2));
    static assert(!__traits(hasAliasing, S3));
    static assert(!__traits(hasAliasing, S4));
    static assert( __traits(hasAliasing, S41));
    static assert(!__traits(hasAliasing, S42));
    static assert( __traits(hasAliasing, S5));
    static assert( __traits(hasAliasing, S6));
    static assert(!__traits(hasAliasing, S7));

    static assert( __traits(hasAliasing, S1, S41)); // multiple arguments, all have aliasing
    static assert( __traits(hasAliasing, S1, S2)); // multiple arguments, some have aliasing
    static assert( __traits(hasAliasing, S2, S1)); // multiple arguments, some have aliasing
    static assert(!__traits(hasAliasing, S2, S4)); // multiple arguments, none have aliasing

    static assert( __traits(hasAliasing, uint[uint]));
    static assert(!__traits(hasAliasing, immutable(uint[uint])));
    static assert( __traits(hasAliasing, void delegate()));
    static assert( __traits(hasAliasing, void delegate() const));
    static assert(!__traits(hasAliasing, void delegate() immutable));
    static assert( __traits(hasAliasing, void delegate() shared));
    static assert( __traits(hasAliasing, void delegate() shared const));
    static assert( __traits(hasAliasing, const(void delegate())));
    static assert( __traits(hasAliasing, const(void delegate() const)));
    static assert(!__traits(hasAliasing, const(void delegate() immutable)));
    static assert( __traits(hasAliasing, const(void delegate() shared)));
    static assert( __traits(hasAliasing, const(void delegate() shared const)));
    static assert(!__traits(hasAliasing, immutable(void delegate())));
    static assert(!__traits(hasAliasing, immutable(void delegate() const)));
    static assert(!__traits(hasAliasing, immutable(void delegate() immutable)));
    static assert(!__traits(hasAliasing, immutable(void delegate() shared)));
    static assert(!__traits(hasAliasing, immutable(void delegate() shared const)));
    static assert( __traits(hasAliasing, shared(const(void delegate()))));
    static assert( __traits(hasAliasing, shared(const(void delegate() const))));
    static assert(!__traits(hasAliasing, shared(const(void delegate() immutable))));
    static assert( __traits(hasAliasing, shared(const(void delegate() shared))));
    static assert( __traits(hasAliasing, shared(const(void delegate() shared const))));
    static assert(!__traits(hasAliasing, void function()));

    interface I;
    static assert( __traits(hasAliasing, I));
    struct T1 { int a; I b; }
    struct T2 { int a; immutable I b; }

    static assert( __traits(hasAliasing, T1));
    static assert(!__traits(hasAliasing, T2));

    struct ST(T) { T a; }
    class CT(T) { T a; }
    static assert( __traits(hasAliasing, ST!C));
    static assert( __traits(hasAliasing, ST!I));
    static assert(!__traits(hasAliasing, ST!int));
    static assert( __traits(hasAliasing, CT!C));
    static assert( __traits(hasAliasing, CT!I));
    static assert( __traits(hasAliasing, CT!int));

    import std.typecons : Rebindable;
    static assert( __traits(hasAliasing, Rebindable!(const Object)));
    static assert(!__traits(hasAliasing, Rebindable!(immutable Object)));
    static assert( __traits(hasAliasing, Rebindable!(shared Object)));
    static assert( __traits(hasAliasing, Rebindable!Object));
}

private static test2()
{
    struct S5
    {
        void delegate() immutable b;
        shared(void delegate() immutable) f;
        immutable(void delegate() immutable) j;
        shared(const(void delegate() immutable)) n;
    }
    struct S6 { typeof(S5.tupleof) a; void delegate() p; }
    static assert(!__traits(hasAliasing, S5));
    static assert( __traits(hasAliasing, S6));

    struct S7 { void delegate() a; int b; Object c; }
    class S8 { int a; int b; }
    class S9 { typeof(S8.tupleof) a; }
    class S10 { typeof(S8.tupleof) a; int* b; }
    static assert( __traits(hasAliasing, S7));
    static assert( __traits(hasAliasing, S8));
    static assert( __traits(hasAliasing, S9));
    static assert( __traits(hasAliasing, S10));
    struct S11 {}
    class S12 {}
    interface S13 {}
    union S14 {}
    static assert(!__traits(hasAliasing, S11));
    static assert( __traits(hasAliasing, S12));
    static assert( __traits(hasAliasing, S13));
    static assert(!__traits(hasAliasing, S14));

    class S15 { S15[1] a; }
    static assert( __traits(hasAliasing, S15));
    static assert(!__traits(hasAliasing, immutable(S15)));
}

private static test3()
{
    enum Ei : string { a = "a", b = "b" }
    enum Ec : const(char)[] { a = "a", b = "b" }
    enum Em : char[] { a = null, b = null }

    static assert(!__traits(hasAliasing, Ei));
    static assert( __traits(hasAliasing, Ec));
    static assert( __traits(hasAliasing, Em));
}

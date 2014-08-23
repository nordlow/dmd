import std.traits : Unqual;
alias Tuple(T...) = T;

void test(T,int Q)(bool unknown)
{
    static if (Q)
    {
      Unqual!T ii = unknown ? 33 : -1;
      T i = ii;
    }
    else
    {
      T i = unknown ? -1 : 33;
    }

    if (i)
      static assert(Q || __traits(valueRange, i) == Tuple!(-1, 33));
    else
    {
      static assert(i == 0);
      static assert(__traits(valueRange, i) == Tuple!(0, 0));
    }

    if (i == 33)
    {
      static assert(i == 33);
      static assert(__traits(valueRange, i) == Tuple!(33, 33));
    }
    else
      static assert(Q || __traits(valueRange, i) == Tuple!(-1, 32));

    if (i != 33)
      static assert(Q || __traits(valueRange, i) == Tuple!(-1, 32));
    else
    {
      static assert(i == 33);
      static assert(__traits(valueRange, i) == Tuple!(33, 33));
    }

    if (10 <= i)
      static assert(__traits(valueRange, i) == Tuple!(10, Q?T.max:33));
    else
      static assert(__traits(valueRange, i) == Tuple!(Q?T.min:-1, 9));

    if (i > 10)
      static assert(__traits(valueRange, i) == Tuple!(11, Q?T.max:33));
    else
      static assert(__traits(valueRange, i) == Tuple!(Q?T.min:-1, 10));

    if (!i)
    {
      static assert(i == 0);
      static assert(__traits(valueRange, i) == Tuple!(0, 0));
    }
    else
      static assert(Q || __traits(valueRange, i) == Tuple!(-1, 33));
}

void main(string[] args)
{
    test!(immutable int, 0)(args.length < 1);
    test!(const int, 0)(args.length < 1);
    test!(immutable(int), 0)(args.length < 1);
    test!(const(int), 0)(args.length < 1);

    test!(immutable int, 1)(args.length < 1);
    test!(const int, 1)(args.length < 1);
    test!(immutable(int), 1)(args.length < 1);
    test!(const(int), 1)(args.length < 1);
}

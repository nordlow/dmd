/**
 * Hash functions for arbitrary binary data.
 *
 * Copyright: Copyright (C) 1999-2025 by The D Language Foundation, All Rights Reserved
 * Authors:   Martin Nowak, Walter Bright, https://www.digitalmars.com
 * License:   $(LINK2 https://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Source:    $(LINK2 https://github.com/dlang/dmd/blob/master/compiler/src/dmd/root/hash.d, root/_hash.d)
 * Documentation:  https://dlang.org/phobos/dmd_root_hash.html
 * Coverage:    https://codecov.io/gh/dlang/dmd/src/master/compiler/src/dmd/root/hash.d
 */

module dmd.root.hash;

// MurmurHash2 was written by Austin Appleby, and is placed in the public
// domain. The author hereby disclaims copyright to this source code.
// https://github.com/aappleby/smhasher/
uint calcHash(scope const(char)[] data) @nogc nothrow pure @safe
{
    return calcHash(cast(const(ubyte)[])data);
}

alias calcHash = calcHash_xxHash32;

/// ditto
uint calcHash_murmur2(scope const(ubyte)[] data) @nogc nothrow pure @safe
{
    // 'm' and 'r' are mixing constants generated offline.
    // They're not really 'magic', they just happen to work well.
    enum uint m = 0x5bd1e995;
    enum int r = 24;
    // Initialize the hash to a 'random' value
    uint h = cast(uint) data.length;
    // Mix 4 bytes at a time into the hash
    while (data.length >= 4)
    {
        uint k = data[3] << 24 | data[2] << 16 | data[1] << 8 | data[0];
        k *= m;
        k ^= k >> r;
        h = (h * m) ^ (k * m);
        data = data[4..$];
    }
    // Handle the last few bytes of the input array
    switch (data.length & 3)
    {
    case 3:
        h ^= data[2] << 16;
        goto case;
    case 2:
        h ^= data[1] << 8;
        goto case;
    case 1:
        h ^= data[0];
        h *= m;
        goto default;
    default:
        break;
    }
    // Do a few final mixes of the hash to ensure the last few
    // bytes are well-incorporated.
    h ^= h >> 13;
    h *= m;
    h ^= h >> 15;
    return h;
}

unittest
{
    char[10] data = "0123456789";
    assert(calcHash_murmur2(data[0..$]) ==   439_272_720);
    assert(calcHash_murmur2(data[1..$]) == 3_704_291_687);
    assert(calcHash_murmur2(data[2..$]) == 2_125_368_748);
    assert(calcHash_murmur2(data[3..$]) == 3_631_432_225);
}

// combine and mix two words (boost::hash_combine)
size_t mixHash(size_t h, size_t k) @nogc nothrow pure @safe
{
    return h ^ (k + 0x9e3779b9 + (h << 6) + (h >> 2));
}

unittest
{
    // & uint.max because mixHash output is truncated on 32-bit targets
    assert((mixHash(0xDE00_1540, 0xF571_1A47) & uint.max) == 0x952D_FC10);
}

uint calcHash_xxHash32(scope const(ubyte)[] data) @nogc nothrow pure @trusted
{
    // xxHash32 constants
    enum uint PRIME32_1 = 0x9E3779B1;
    enum uint PRIME32_2 = 0x85EBCA77;
    enum uint PRIME32_3 = 0xC2B2AE3D;
    enum uint PRIME32_4 = 0x27D4EB2F;
    enum uint PRIME32_5 = 0x165667B1;

    const(ubyte)* p = data.ptr;
    const(ubyte)* end = p + data.length;
    uint h32;

    // Process 16-byte chunks
    if (data.length >= 16) {
        const(ubyte)* limit = end - 16;
        uint v1 = PRIME32_1 + PRIME32_2;  // seed = 0
        uint v2 = PRIME32_2;
        uint v3 = 0;
        uint v4 = cast(uint)(0 - PRIME32_1);

        do {
            v1 = rotleft(v1 + read32(p) * PRIME32_2, 13) * PRIME32_1;
            p += 4;
            v2 = rotleft(v2 + read32(p) * PRIME32_2, 13) * PRIME32_1;
            p += 4;
            v3 = rotleft(v3 + read32(p) * PRIME32_2, 13) * PRIME32_1;
            p += 4;
            v4 = rotleft(v4 + read32(p) * PRIME32_2, 13) * PRIME32_1;
            p += 4;
        } while (p <= limit);

        h32 = rotleft(v1, 1) + rotleft(v2, 7) + rotleft(v3, 12) + rotleft(v4, 18);
    } else {
        h32 = PRIME32_5;  // seed + PRIME32_5, seed = 0
    }

    h32 += cast(uint)data.length;

    // Process remaining 4-byte chunks
    while (p + 4 <= end) {
        h32 += read32(p) * PRIME32_3;
        h32 = rotleft(h32, 17) * PRIME32_4;
        p += 4;
    }

    // Process remaining bytes
    while (p < end) {
        h32 += (*p) * PRIME32_5;
        h32 = rotleft(h32, 11) * PRIME32_1;
        p++;
    }

    // Final avalanche
    h32 ^= h32 >> 15;
    h32 *= PRIME32_2;
    h32 ^= h32 >> 13;
    h32 *= PRIME32_3;
    h32 ^= h32 >> 16;

    return h32;
}

pragma(inline, true)
private uint read32(const(ubyte)* p) @nogc nothrow pure @trusted
{
    return p[0] | (cast(uint)p[1] << 8) | (cast(uint)p[2] << 16) | (cast(uint)p[3] << 24);
}

pragma(inline, true)
private uint rotleft(uint value, int shift) @nogc nothrow pure @safe
{
    return (value << shift) | (value >> (32 - shift));
}

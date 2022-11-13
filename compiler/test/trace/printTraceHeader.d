import std.stdio : writeln, writefln, stderr;
import std.file;
import dmd.trace_file;

enum separator = " | ";

private bool argOneToN(uint arg, uint N) @safe
{
    if (!arg || arg > N)
    {
        writeln("ArgumentError: RangeError: Expected Range [1, ", N, "] (inclusive)");
        return false;
    }
    return true;
}

/// Output mode.
enum Mode
{
    Tree,
    MemToplist,
    TimeToplist,
    Header,
    PhaseHist,
    KindHist,
    Symbol,
    Kind,
    Phase,
    RandSample,
    OutputSelfStats,
    OutputParentTable,
    Parent,
    TemplateInstances,
}

void main(string[] args) /* TODO: @safe */
{
    import std.conv : to;
    import std.traits : EnumMembers;
    enum modes = EnumMembers!Mode; // TODO: create array of strings

    if (args.length < 3)
    {
        writeln("Too few arguments: ", args);
        writeln("Usage: ", __FILE__, " TRACEFILE MODE {args depending on mode}");
        writeln("Modes: ", modes);
        return;
    }
    const modeArg = args[2];

    import std.path : setExtension;

    auto originalFile = args[1];
    auto traceFile = originalFile.setExtension(traceExtension);
    auto symbolFile = originalFile.setExtension(symbolExtension);

    Mode mode;
    try {
        mode = modeArg.to!Mode;
    } catch (Exception e) {
        writeln("Unknown mode", args[2]);
        writeln("Supported modes are ", modes);
    }

    if (mode != Mode.Header && !exists(traceFile))
    {
        writeln(`Trace file "`, traceFile, `" is missing`);
        return;
    }

    TraceFileHeader header;
    const void[] fileBytes = read(originalFile);
    if (fileBytes.length < header.sizeof)
    {
        writeln("Trace file was truncated from size ", header.sizeof, " ", fileBytes.length, " bytes");
    }
    (cast(void*)&header)[0 .. header.sizeof] = fileBytes[0 .. header.sizeof];

    if (header.magic_number != (*cast(ulong*) &"DMDTRACE"[0]))
    {
        writeln(`Trace file "`, traceFile, `" contains incorrect magic number`);
        return;
    }

    const kinds = readStrings(fileBytes, header.offset_kinds, header.n_kinds);
    const phases = readStrings(fileBytes, header.offset_phases, header.n_phases);

    // writeln("phases:\n    ", phases);
    // writeln("kinds:\n    ", kinds);

    ProbeRecord[] records = readRecords(fileBytes);

    static ulong hashRecord(ProbeRecord r) pure
    {
        ulong hash;
        hash ^= r.begin_mem;
        hash ^= (r.end_mem << 8);
        hash ^= (r.end_ticks << 16);
        hash ^= (r.begin_ticks << 24);
        hash ^= (ulong(r.symbol_id) << 32);
        return hash;
    }

    uint strange_record_count;
    ulong lastBeginTicks;

    if (mode == Mode.Header)
    {
        import std.array : join;
        writeln(structToString(header));
        writeln("kinds=", kinds.join("#"));
        writeln("phases=", phases.join("#"));
        // a file with a correct header might not have a symbol table and we
        // don't want to scan for strange records just to show the header
        return ;
    }

    foreach (const r; records)
    {
        if (r.begin_ticks <= lastBeginTicks)
        {
            strange_record_count++;
            writeln("Symbol: ", getSymbolName(fileBytes, r), "is proucing a strange record");
        }
        lastBeginTicks = r.begin_ticks;
    }

    if (strange_record_count)
    {
        writeln(strange_record_count, " strange records encounterd");
        return;
    }
    // if we get here records are sorted by begin_ticks as they should be

    // writeln("records are sorted that's good n_records: ", records.length);

    // now can start establishing parent child relationships;
    import core.stdc.stdlib;

    uint[] parents = (cast(uint*) calloc(records.length, uint.sizeof))[0 .. records.length];
    uint[] depths = (cast(uint*) calloc(records.length, uint.sizeof))[0 .. records.length];
    uint[2][] selfTime = (cast(uint[2]*) calloc(records.length, uint.sizeof * 2))[0 .. records.length];
    uint[2][] selfMem = (cast(uint[2]*) calloc(records.length, uint.sizeof * 2))[0 .. records.length];

    {
        ulong parentsFound = 0;
        uint currentDepth = 1;
        stderr.writeln("Looking for parents");
        foreach (const i; 0 .. records.length)
        {
            const r = records[i];
            const time = cast(uint)(r.end_ticks - r.begin_ticks);
            const mem = cast(uint)(r.end_mem - r.begin_mem);

            selfTime[i][0] = cast(uint) i;
            selfTime[i][1] = time;
            selfMem[i][0] = cast(uint) i;
            selfMem[i][1] = mem;

            // either our parent is right above us
            if (i && records[i - 1].end_ticks > r.end_ticks)
            {
                parents[i] = cast(uint)(i - 1);
                depths[i] = currentDepth++;
                selfTime[i-1][1] -= time;
                selfMem[i-1][1] -= mem;
                parentsFound++;
            }
            else if (i) // or it's the parent of our parent
            {
                // the indent does not increase now we have to check if we have to pull back or not
                // our indent level is the one of the first record that ended after we ended

                uint currentParent = parents[i - 1];
                while (currentParent)
                {
                    auto p = records[currentParent];
                    if (p.end_ticks > r.end_ticks)
                    {
                        selfTime[currentParent][1] -= time;
                        selfMem[currentParent][1] -= mem;

                        assert(selfTime[currentParent][1] > 1);
                        currentDepth = depths[currentParent] + 1;
                        depths[i] = currentDepth;
                        parents[i] = currentParent;
                        parentsFound++;
                        break;
                    }
                    currentParent = parents[currentParent];
                }

                //assert(currentParent);
            }
        }
        stderr.writeln("parentsFound: ", parentsFound, " out of ", header.n_records, " tracepoints");
        if (!parentsFound && header.n_records)
        {
            stderr.writeln("No Parents? Something is fishy!");
            return ;
        }
    }

    if (mode == Mode.Tree)
    {
        const char[4096 * 4] indent = '-';
        foreach (const i; 0 .. records.length)
        {
            const r = records[i];
            writeln(indent[0 .. depths[i]], ' ', r.end_ticks - r.begin_ticks, separator,
                    selfTime[i], separator, phases[r.phase_id - 1], separator, getSymbolName(fileBytes,
                        r), separator, getSymbolLocation(fileBytes, r), separator,);

        }
        import std.algorithm.sorting : sort;
        const sorted_selfTimes = selfTime.sort!((a, b) => a[1] > b[1]).release;
        writeln("SelfTimes");
        writeln("selftime, kind, symbol_id");
        foreach (const st; sorted_selfTimes[0 .. (header.n_records > 2000 ? 2000 : header.n_records)])
        {
            const r = records[st[0]];
            writeln(st[1], separator, kinds[r.kind_id - 1], separator, /*getSymbolLocation(fileBytes, r)*/r.symbol_id);
        }
    }
    else if (mode == Mode.MemToplist)
    {
        import std.algorithm.sorting : sort;
        const sorted_records = records.sort!((a, b) => (a.end_mem - a.begin_mem > b.end_mem - b.begin_mem)).release;
        writeln("Toplist");
        writeln("Memory (in Bytes),kind,phase,file(line),ident_or_code");
        foreach (const r; sorted_records)
        {
            writeln(r.end_mem - r.begin_mem, separator, kinds[r.kind_id - 1], separator, phases[r.phase_id - 1], separator,
                    getSymbolLocation(fileBytes, r), getSymbolName(fileBytes, r));
        }
    }
    else if (mode == Mode.TimeToplist)
    {
        import std.algorithm.sorting : sort;
        const auto sorted_records = records.sort!((a, b) => (a.end_ticks - a.begin_ticks > b.end_ticks - b.begin_ticks)).release;
        writeln("Toplist");
        writeln("Time [cy],kind,phase,file(line),ident_or_code");
        foreach (const r; sorted_records)
        {
            writeln(r.end_ticks - r.begin_ticks, separator, kinds[r.kind_id - 1], separator, phases[r.phase_id - 1], separator,
                    getSymbolLocation(fileBytes, r), separator, getSymbolName(fileBytes, r));
        }
    }
    else if (mode == Mode.PhaseHist)
    {
        static struct SortRecord
        {
            uint phaseId;
            uint freq;
            float absTime = 0;
            float avgTime = 0;
        }

        SortRecord[] sortRecords;
        sortRecords.length = phases.length;

        foreach (const i, const r; records)
        {
            sortRecords[r.phase_id - 1].absTime += selfTime[i][1];
            sortRecords[r.phase_id - 1].freq++;
        }
        foreach (const i; 0 .. header.n_phases)
        {
            sortRecords[i].phaseId = i + 1;
            sortRecords[i].avgTime = sortRecords[i].absTime / double(sortRecords[i].freq);
        }
        import std.algorithm.sorting : sort;

        sortRecords.sort!((a, b) => a.absTime > b.absTime);
        writeln(" === Phase Time Distribution : ===");
        writefln(" %-90s %-10s %-13s %-7s ", "phase", "avg [cy]", "abs [cy]", "count");
        foreach (const sr; sortRecords)
        {
            writefln(" %-90s %-10.2f %-13.0f %-7d ", phases[sr.phaseId - 1],
                    sr.avgTime, sr.absTime, sr.freq);
        }
    }
    else if (mode == Mode.KindHist)
    {
        static struct SortRecord_Kind
        {
            uint kindId;
            uint freq;
            float absTime = 0;
            float avgTime = 0;
        }

        SortRecord_Kind[] sortRecords;
        sortRecords.length = kinds.length;

        foreach (const i, const r; records)
        {
            sortRecords[r.kind_id - 1].absTime += selfTime[i][1];
            sortRecords[r.kind_id - 1].freq++;
        }
        foreach (const i; 0 .. header.n_kinds)
        {
            sortRecords[i].kindId = i + 1;
            sortRecords[i].avgTime = sortRecords[i].absTime / double(sortRecords[i].freq);
        }
        import std.algorithm.sorting : sort;

        sortRecords.sort!((a, b) => a.absTime > b.absTime);
        writeln(" === Kind Time Distribution ===");
        writefln(" %-90s %-10s %-13s %-7s ", "kind", "avg [cy]", "abs [cy]", "count");
        foreach (const sr; sortRecords)
        {
            writefln(" %-90s %-10.2f %-13.0f %-7d ", kinds[sr.kindId - 1],
                    sr.avgTime, sr.absTime, sr.freq);
        }
    }
    else if (mode == Mode.Symbol)
    {
        import std.conv : to;
        uint sNumber = to!uint(args[3]);
        if (sNumber.argOneToN(header.n_symbols))
        {
            writeln("{name: ", getSymbolName(fileBytes, sNumber),
                "\nlocation: " ~ getSymbolLocation(fileBytes, sNumber) ~ "}");
        }
    }
    else if (mode == Mode.Parent)
    {
        import std.conv : to;
        uint sNumber = to!uint(args[3]);
        if (sNumber.argOneToN(header.n_records))
        {
            writeln("{parentId: ", parents[sNumber - 1], "}");
        }
    }
    else if (mode == Mode.Phase)
    {
        import std.conv : to;
        uint sNumber = to!uint(args[3]);
        if (sNumber.argOneToN(header.n_phases))
        {
            writeln("{phase: " ~ phases[sNumber - 1] ~ "}");
        }
    }
    else if (mode == Mode.Kind)
    {
        import std.conv : to;
        uint sNumber = to!uint(args[3]);
        if (sNumber.argOneToN(header.n_kinds))
        {
            writeln("{kind: " ~ kinds[sNumber - 1] ~ "}");
        }
    }
    else if (mode == Mode.RandSample)
    {
        import std.random : randomSample;
        import std.algorithm : map, each;
        randomSample(records, 24).map!(r => structToString(r)).each!writeln;
    }
    else if (mode == Mode.OutputSelfStats)
    {
        const void[] selfTimeMem = (cast(void*)selfTime)[0 .. (selfTime.length * selfTime[0].sizeof)];
        std.file.write(traceFile ~ ".st", selfTimeMem);
        const void[] selfMemMem = (cast(void*)selfMem)[0 .. (selfMem.length * selfMem[0].sizeof)];
        std.file.write(traceFile ~ ".sm", selfMemMem);
    }
    else if (mode == Mode.OutputParentTable)
    {
        void [] parentsMem = (cast(void*)parents)[0 .. (parents.length * parents[0].sizeof)];
        std.file.write(traceFile ~ ".pt", parentsMem);
    }
    else if (mode == Mode.TemplateInstances)
    {
        import std.algorithm.iteration : filter;
        import std.algorithm.searching : countUntil;
        import std.algorithm.sorting : sort;
        import std.array : array;
        auto template_instance_kind_idx = kinds.countUntil("TemplateInstance") + 1;
        foreach (const rec; records.filter!((r) => r.kind_id == template_instance_kind_idx)
                                   .array()
                                   .sort!((a, b) => a.end_ticks - a.begin_ticks > b.end_ticks - b.begin_ticks))
        {
            writeln(rec.end_ticks - rec.begin_ticks, separator, phases[rec.phase_id - 1], separator,
                    getSymbolLocation(fileBytes, rec), separator, getSymbolName(fileBytes, rec));
        }
    }
    else
        writeln("Mode unsupported: ", mode, "\nsupported modes are: ", modes);
}

struct NoPrint
{
}

string structToString(T)(auto ref T _struct, int indent = 1)
{
    char[] result;

    result ~= T.stringof ~ " (\n";

    foreach (const i, e; _struct.tupleof)
    {
        bool skip = false;

        foreach (const attrib; __traits(getAttributes, _struct.tupleof[i]))
        {
            static if (is(attrib == NoPrint))
                skip = true;
        }

        if (!skip)
        {
            foreach (const _; 0 .. indent)
            {
                result ~= "\t";
            }
            alias type = typeof(_struct.tupleof[i]);
            const fieldName = _struct.tupleof[i].stringof["_struct.".length .. $];

            result ~= "" ~ fieldName ~ " : ";

            static if (is(type == enum))
            {
                result ~= enumToString(e);
            }
            else static if (is(type : ulong))
            {
                result ~= itos64(e);
            }
            else
            {
                pragma(msg, type);
                import std.conv : to;
                result ~= to!string(e);
            }
            result ~= ",\n";
        }
    }

    result[$ - 2] = '\n';
    result[$ - 1] = ')';
    return cast(string) result;
}

const(uint) fastLog10(const uint val) pure nothrow @nogc @safe
{
    return (val < 10) ? 0 : (val < 100) ? 1 : (val < 1000) ? 2 : (val < 10000)
        ? 3 : (val < 100000) ? 4 : (val < 1000000) ? 5 : (val < 10000000)
        ? 6 : (val < 100000000) ? 7 : (val < 1000000000) ? 8 : 9;
}

/*@unique*/
static immutable fastPow10tbl = [
    1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000,
];

string itos(const uint val) pure @trusted nothrow
{
    immutable length = fastLog10(val) + 1;
    char[] result;
    result.length = length;

    foreach (const i; 0 .. length)
    {
        immutable _val = val / fastPow10tbl[i];
        result[length - i - 1] = cast(char)((_val % 10) + '0');
    }

    return cast(string) result;
}

static assert(mixin(uint.max.itos) == uint.max);

string itos64(const ulong val) pure @trusted nothrow
{
    if (val <= uint.max)
        return itos(val & uint.max);

    uint lw = val & uint.max;
    uint hi = val >> 32;

    auto lwString = itos(lw);
    auto hiString = itos(hi);

    return cast(string) "((" ~ hiString ~ "<< 32)" ~ separator ~ lwString ~ ")";
}

string enumToString(E)(E v)
{
    static assert(is(E == enum), "emumToString is only meant for enums");
    string result;

Switch:
    switch (v)
    {
        foreach (const m; __traits(allMembers, E))
        {
    case mixin("E." ~ m):
            result = m;
            break Switch;
        }

    default:
        {
            result = "cast(" ~ E.stringof ~ ")";
            uint val = v;
            enum headLength = cast(uint)(E.stringof.length + "cast()".length);
            uint log10Val = (val < 10) ? 0 : (val < 100) ? 1 : (val < 1000)
                ? 2 : (val < 10000) ? 3 : (val < 100000) ? 4 : (val < 1000000)
                ? 5 : (val < 10000000) ? 6 : (val < 100000000) ? 7 : (val < 1000000000) ? 8 : 9;
            result.length += log10Val + 1;
            for (uint i; i != log10Val + 1; i++)
            {
                cast(char) result[headLength + log10Val - i] = cast(char)('0' + (val % 10));
                val /= 10;
            }
        }
    }

    return result;
}

version(none)                   // disabled currently unused
private enum hexString = (ulong value) {
    const wasZero = !value;
    static immutable NibbleRep = "0123456789abcdef";
    char[] resultBuffer;
    resultBuffer.length = 18; // ulong.sizeof * 2 + "0x".length
    resultBuffer[] = '0';
    int p;
    for (ubyte currentNibble = value & 0xF; value; currentNibble = ((value >>>= 4) & 0xF))
    {
        resultBuffer[17 - p++] = NibbleRep[currentNibble];
    }
    resultBuffer[17 - wasZero - p++] = 'x';
    return cast(string) resultBuffer[17 - p - wasZero .. 18];
};

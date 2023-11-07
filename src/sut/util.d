module sut.util;

static import sut.wrapper;
static import sut.mixins;

debug import std.stdio;



/**
 * Determine whether the `needle` is found in the `haystack` using the
 * specified predicate, `pred`, on how to find the `needle`.
 */
bool
isIn (alias pred)(
    const string[] haystack,
    const string needle
) @safe
{
    import std.algorithm: canFind;
    import std.uni: toLower;
    if (haystack.length == 0) {
        return false;
    }
    if (needle.length == 0) {
        return false;
    }
    return canFind!(pred)(haystack, needle);
}



/**
 * Determine whether the needle is an exact match or begins with one of
 * the items in the haystack.
 *
 * Returns: `true` if the needle is an exact match or begins with one of
 *          the items in the haystack.
 */
bool
beginsWith (
    const string[] haystack,
    const string needle
) @safe
{
    import std.algorithm: startsWith;
    import std.uni: toLower;
    return isIn!(
        (string a, string b) => b.startsWith(a.toLower))
        (haystack, needle.toLower);
}
@("beginsWith: empty")
unittest {
    mixin (sut.wrapper.prologue);
    const string[] arr;
    assert (!arr.beginsWith(__MODULE__));
}
@("beginsWith: exact")
unittest {
    mixin (sut.wrapper.prologue);
    const string[] arr = ["aaa", "bbb", "ccc"];
    assert (arr.beginsWith("aaa"));
    assert (arr.beginsWith("bbb"));
    assert (arr.beginsWith("ccc"));
    assert (!arr.beginsWith(""));
    assert (!arr.beginsWith("any"));
}
@("beginsWith: begins with")
unittest {
    mixin (sut.wrapper.prologue);
    const string[] arr = ["aaa", "bbb", "ccc"];
    assert (arr.beginsWith("aaa111"));
    assert (arr.beginsWith("bbb222"));
    assert (arr.beginsWith("ccc333"));
    assert (!arr.beginsWith("111aaa"));
}



/**
 * Determine whether one of the items in the haystack is an exact match
 * or a substring of the needle.
 *
 * Returns: `true` if one of the items in the haystack is an exact match
 *          or a substring of the needle.
 */
//bool
//isFound (
//    const string[] haystack,
//    const string needle
//) @safe
//{
//    import std.algorithm: canFind;
//    import std.uni: toLower;
//    return isIn!(
//        (string a, string b) => b.canFind(a.toLower))
//        (haystack, needle.toLower);
//}
//@("isFound: empty")
//unittest {
//    mixin (sut.wrapper.prologue);
//    const string[] arr;
//    assert (!arr.isFound("aaa"));
//}
//@("isFound: exact")
//unittest {
//    mixin (sut.wrapper.prologue);
//    const string[] arr = ["aaa", "bbb", "ccc"];
//    assert (arr.isFound("aaa"));
//    assert (!arr.isFound(""));
//    assert (!arr.isFound("ddd"));
//}
//@("isFound: substring")
//unittest {
//    mixin (sut.wrapper.prologue);
//    const string[] arr = ["aaa", "bbb", "ccc"];
//    assert (arr.isFound("aaa111"));
//    assert (arr.isFound("111aaa"));
//    assert (!arr.isFound(""));
//    assert (!arr.isFound("ddd"));
//    assert (arr.isFound("ddd"));                // Will FAIL!
//}



/**
 * Convert string argument into array of string, stripped of whitespaces, and
 * duplicates removed.
 *
 * The function looks for '\r', '\n', '\v', '\f', "\r\n", std.uni.lineSep,
 * std.uni.paraSep and '\u0085' (NEL) as delimiters.
 *
 * Returns: `string[]`
 */
string[]
toArray (const string arg) @safe
{
    import std.algorithm: map, remove, sort, uniq;
    import std.array: array;
    import std.string: strip, splitLines;
    import std.uni: toLower;

    if (arg.length == 0) {
        return (string[]).init;
    }
    return arg.splitLines()
        .map!(a => a.strip()).array()
        .sort!("toLower(a) < toLower(b)").release()
        .uniq().array()
        .remove!("a.length == 0").array();
}
@("toArray: empty array")
unittest {
    mixin (sut.wrapper.prologue);
    assert ("".toArray() == []);
}
@("toArray: with empty array element")
unittest {
    mixin (sut.wrapper.prologue);
    const arr = " one\n \n two ";
    assert (arr.toArray() == ["one", "two"]);
}
@("toArray")
unittest {
    mixin (sut.wrapper.prologue);
    const arr = " utb:one\n utb:two \n utm:three \nutm:four\nutb:one\nutb:two ";
    assert (arr.toArray() == ["utb:one", "utb:two", "utm:four", "utm:three"]);
}



/**
 * Sort (case insensitive) and remove duplicates.
 */
//string[]
//dedup (const string[] arg) @safe
//{
//    import std.algorithm:
//        sort,
//        uniq;
//    import std.array: array;
//    import std.uni: toLower;
//    return (arg.dup).sort!("toLower(a) < toLower(b)")
//        .release()
//        .uniq()
//        .array();
//}
//@("dedup")
//unittest {
//    // mixin (sut.wrapper.prologue);
//    auto arr = ["one", "four", "two", "three", "two", "four", "three"];
//    assert (arr.dedup() == ["four", "one", "three", "two"]);
//}



/**
 * Remove needles from haystack.
 */
//string[]
//remove (
//    const string[] haystack,
//    const string[] needles
//) nothrow @safe
//{
//    import std.algorithm:
//        canFind,
//        remove;
//    return (haystack.dup).remove!(a => needles.canFind(a))();
//}
//@("remove")
//unittest {
//    // mixin (sut.wrapper.prologue);
//    auto arr = ["one", "two", "three", "four"];
//    assert (arr.remove(["one"])   == ["two", "three", "four"]);
//    assert (arr.remove(["two"])   == ["one", "three", "four"]);
//    assert (arr.remove(["three"]) == ["one", "two", "four"]);
//    assert (arr.remove(["four"])  == ["one", "two", "three"]);
//}



/**
 * Remove the prefix string and separator character from the string argument.
 */
string
unprefix (
    const string arg,
    const string prefix,
    const size_t separatorLength = 0
) nothrow @safe
{
    import std.string: strip;
    return (arg[prefix.length + separatorLength..$]).strip();
}
@("unprefix")
unittest {
    mixin (sut.wrapper.prologue);
    assert (unprefix("aaabbb", "aaa") == "bbb");
    assert (unprefix("aaa:bbb", "aaa", 0) == ":bbb");
    assert (unprefix("aaa:bbb", "aaa", 1) == "bbb");
}



/**
 * Wrap the string argument breaking at whitespace characters and respecting
 * newline characters.
 */
string
wrapnl (
    const string input,
    const size_t columns = 80,
    const string firstIndent = string.init,
    const string indent = string.init,
    const size_t tabsize = 8
) @safe
{
    import std.array: split;
    import std.string:
        chomp,
        KeepTerminator,
        splitLines;
    import std.ascii: isWhite, newline;
    import std.algorithm: endsWith;

    enum NEWLINE = newline;
    enum SPACE = ' ';

    string appendLine (
        const string res,
        const string line
    ) {
        if (res.length == 0) {
            return res ~ firstIndent ~ line;
        } else {
            return res ~ NEWLINE ~ indent ~ line;
        }
    }

    if (input.length == 0) {
        return input;
    }
    if (input.length + firstIndent.length < columns) {
        return firstIndent ~ input;
    }

    string res;
    string line;
    foreach (chunk; input.split(" ")) {
        auto words = chunk.splitLines(KeepTerminator.yes);
        foreach (word; words) {
            // Always check whether appending the current word exceeds
            // the first or succeeding line limit.
            bool exceedsLine = false;
            if (res.length == 0) {
                if (firstIndent.length + line.length + word.length >= columns) {
                    exceedsLine = true;
                }
            } else {
                if (indent.length + line.length + word.length >= columns) {
                    exceedsLine = true;
                }
            }
            // If the possible new line exceeds the line limit, append the
            // current line now.
            if (exceedsLine) {
                res = appendLine(res, line);
                line = word;
                if (word.endsWith!isWhite) {
                    res = appendLine(res, line.chomp);
                    line = string.init;
                }
                continue;
            }
            if (line.length == 0) {
                line = word;
                if (word.endsWith!isWhite) {
                    res = appendLine(res, line.chomp);
                    line = string.init;
                }
            } else {
                if (word.endsWith!isWhite) {
                    line ~= SPACE ~ word;
                    res = appendLine(res, line.chomp);
                    line = string.init;
                } else {
                    line ~= SPACE ~ word;
                }
            }
        }
    }
    //debug (verbose) writefln("'%s'", line);
    if (line.length > 0) {
        res ~= NEWLINE ~ indent ~ line;
    }
    return res;
}
version (unittest) {
    import std.array: join;

    enum RulerOnes = "123456789012345678901234567890123456789012345";
    enum RulerTens = "         1         2         3         4     ";
}
@("wrapnl: exceeds line then append")
unittest {
    // mixin (sut.wrapper.prologue);

    import std.ascii: newline;
    import std.array: join;
    enum NEWLINE = newline;

    immutable input = "create archive file (tar.bz2) suffixed with the "
        ~ "specified version string; default version string is date and "
        ~ "time as\n'yyyymmdd-hhmmss'";
    enum Result = [
        "  create archive file (tar.bz2) suffixed",
        "  with the specified version string;",
        "  default version string is date and time",
        "  as",
        "  'yyyymmdd-hhmmss'"
    ];
    debug (verbose) writeln("Wrapping at column: ", 43);
    debug (verbose) writefln("%s\n%s", RulerOnes, RulerTens);
    const result = wrapnl(input, 43, "  ", "  ");
    debug (verbose) writeln(result);
    assert (result == Result.join(NEWLINE));
}
@("wrapnl: append to line")
unittest {
    mixin (sut.wrapper.prologue);

    import std.ascii: newline;
    import std.array: join;
    enum NEWLINE = newline;

    immutable input = "create archive file (tar.bz2)\nsuffixed with the "
        ~ "specified version string; default version string is date and "
        ~ "time as 'yyyymmdd-hhmmss'";
    enum Result = [
        "  create archive file (tar.bz2)",
        "  suffixed with the specified version",
        "  string; default version string is date",
        "  and time as 'yyyymmdd-hhmmss'"
    ];
    debug (verbose) writeln("Wrapping at column: ", 43);
    debug (verbose) writefln("%s\n%s", RulerOnes, RulerTens);
    const result = wrapnl(input, 43, "  ", "  ");
    debug (verbose) writeln(result);
    assert (result == Result.join(NEWLINE));
}
@("wrapnl: first word")
unittest {
    mixin (sut.wrapper.prologue);

    import std.ascii: newline;
    import std.array: join;
    enum NEWLINE = newline;

    immutable input = "create\narchive file (tar.bz2) suffixed with the "
        ~ "specified version string; default version string is date and "
        ~ "time as 'yyyymmdd-hhmmss'";
    enum Result = [
        "  create",
        "  archive file (tar.bz2) suffixed with the",
        "  specified version string; default version",
        "  string is date and time as",
        "  'yyyymmdd-hhmmss'"
    ];
    debug (verbose) writeln("Wrapping at column: ", 43);
    debug (verbose) writefln("%s\n%s", RulerOnes, RulerTens);
    const result = wrapnl(input, 43, "  ", "  ");
    debug (verbose) writeln(result);
    assert (result == Result.join(NEWLINE));
}
@("wrapnl: last word")
unittest {
    mixin (sut.wrapper.prologue);

    import std.ascii: newline;
    import std.array: join;
    enum NEWLINE = newline;

    immutable input = "create archive file (tar.bz2) suffixed with the "
        ~ "specified version string; default version string is date and "
        ~ "time as 'yyyymmdd-hhmmss'\n";
    enum Result = [
        "  create archive file (tar.bz2) suffixed",
        "  with the specified version string;",
        "  default version string is date and time",
        "  as 'yyyymmdd-hhmmss'"
    ];
    debug (verbose) writeln("Wrapping at column: ", 43);
    debug (verbose) writefln("%s\n%s", RulerOnes, RulerTens);
    const result = wrapnl(input, 43, "  ", "  ");
    debug (verbose) writeln(result);
    assert (result == Result.join(NEWLINE));
}
@("wrapnl: multiple new lines")
unittest {
    mixin (sut.wrapper.prologue);

    import std.ascii: newline;
    import std.array: join;
    enum NEWLINE = newline;

    immutable input = "first line\n\nThis is the rest of the text. It "
        ~ "must be long so it should wrap to the next line.";
    enum Result = [
        "first line",
        "  ",
        "  This is the rest of the text. It must be",
        "  long so it should wrap to the next line."
    ];
    debug (verbose) writeln("Wrapping at column: ", 43);
    debug (verbose) writefln("%s\n%s", RulerOnes, RulerTens);
    const result = wrapnl(input, 43, string.init, "  ");
    debug (verbose) writeln(result);
    debug (verbose) writeln(Result.join(NEWLINE));
    assert (result == Result.join(NEWLINE));
}

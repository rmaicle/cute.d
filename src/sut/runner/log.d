module sut.runner.log;

import sut.util:
    beginsWith,
    wrapnl;

import std.string: tosz = toStringz;
import std.traits: ReturnType;
import std.stdio: print = printf;
import core.time: MonoTime;
import sut.log;



/**
 * Display assertion information.
 */
void
printAssertion (
    const string moduleName,
    const Throwable throwable
) @trusted
{
    import std.conv: to;
    import std.string: leftJustify;
    import std.stdio;
    enum ASSERT_MSG_FMTS = `
%s%s Assertion Failed!%s
%s Message: %s
%s Module:  %s
%s File:    %s (%llu)
`;

    const indent = Label.AssertionDetail.length + " Message: ".length;
    const message = wrapnl(
        to!string(throwable.message),
        80,
        leftJustify("", indent, ' '),
        leftJustify("", indent, ' '))[indent..$];
    print(ASSERT_MSG_FMTS,
        // Heading
        Color.IRed.tosz,
        Label.AssertionFailed.tosz,
        Color.Reset.tosz,
        // Message
        Label.AssertionDetail.tosz,
        message.tosz,
        // Module
        Label.AssertionDetail.tosz,
        moduleName.tosz,
        // File
        Label.AssertionDetail.tosz,
        throwable.file.tosz,
        throwable.line);
}



/**
 * Display trace information.
 */
void
printTrace (const Throwable throwable)
{
    import std.conv: to;
    import std.algorithm:
        canFind,
        startsWith;

    enum COLUMN_MAX = 70;
    enum SEPARATOR = 1;
    enum INDENT = 5;
    enum SPACE_CHAR = ' ';

    enum PREFIX = "??:?";
    enum UNIT_TEST_FUNC = ".__unittest_L";

   // Ignore custom unit test runner internals.

    enum IGNORE_START = "sut.runner.customUnitTestRunner().";
    enum IGNORE_END = "sut.runner.customUnitTestRunner()";

    // Performance consideration we do not want to call canFind everytime
    // so we use boolean flags for checking.
    bool isIgnoreStartFound = false;
    bool isIgnoreEndFound = false;

    string line;
    // Display stack trace; indent for alignment only
    foreach (i, item; throwable.info) {
        if (i == 0) {
            continue;
        }
        line = to!string(item);
        if (line.startsWith(PREFIX)) {
            line = line[PREFIX.length + 1 .. $];
        }
        if (line.canFind(UNIT_TEST_FUNC)) {
            print("%s %s%s%s\n",
                Label.Trace.tosz,
                Color.Yellow.tosz,
                line.tosz,
                Color.Reset.tosz);
            continue;
        }
        // Do not output stack trace items beyond the call to the
        // custom unit test runner.
        if (!isIgnoreStartFound && line.canFind(IGNORE_START)) {
            print("%s ...  (skipping)\n", Label.Trace.tosz);
            isIgnoreStartFound = true;
            continue;
        }
        if (!isIgnoreEndFound && line.canFind(IGNORE_END)) {
            isIgnoreEndFound = true;
            continue;
        }
        if (isIgnoreStartFound ^ isIgnoreEndFound) {
            continue;
        }
        print("%s %s\n", Label.Trace.tosz, line.tosz);
    }
    print("\n");
}

module sut.output;

import sut.config:
    Config,
    Unknown;
import sut.counter: UnitTestCounter;
import sut.execution: executionList;
import sut.util:
    beginsWith,
    wrapnl;

import std.traits: ReturnType;
import std.stdio;
import core.time: MonoTime;


/**
 * Dummy for toStringz in case we need to revert later.
 * This is temporary only.
 */
string
tosz (const string arg) pure nothrow @nogc @safe
{
    return arg;
}



void
printIntro () @safe
{
    static import std.compiler;

    printDateTime(Label.Start);
    writef("%s %s version %d.%d\n",
        Label.Blank.tosz,
        std.compiler.name.tosz,
        std.compiler.version_major,
        std.compiler.version_minor);
    writef("%s D specification version %d\n",
        Label.Blank.tosz,
        std.compiler.D_major);
    auto mode = getExecutionMode();
    writef("%s %s\n", Label.Mode.tosz, mode.tosz);
    if (mode != ExecutionMode.Selection) {
        return;
    }
    printSelections();
}



void
printUnknownSelections (const Config arg) @safe
{
    enum UNKNOWN_FMTS = "%s   x:      %s (%s)\n";
    const label = Label.Blank.tosz;
    if (!arg.hasUnknowns()) {
        return;
    }
    foreach (file; arg.unknown) {
        const filename = file.filename.tosz;
        foreach (item; file.content) {
            writef(UNKNOWN_FMTS, label, item.tosz, filename);
        }
    }
}



void
printUnitTestInfo (
    const string moduleName,
    const string unitTestName,
    const size_t line,
    const UnitTestCounter counter
) @safe
{
    version (sut) {
        string label;
        if (counter.current.total == 1) {
            label = Label.Module;
        } else {
            label = Label.Blank;
        }

        writef("%s %s %4zd %s%s%s\n",
            label.tosz,
            moduleName.tosz,
            line,
            Color.Green.tosz,
            unitTestName.tosz,
            Color.Reset.tosz);
    }
}



void
printModuleSummary (
    const string moduleName,
    const UnitTestCounter counter,
    const MonoTime from,
    const MonoTime to
) @safe
{
    const passColor = counter.current.isAllPassing() ? Color.IGreen : Color.Yellow;
    const failingColor = counter.current.isNoneFailing() ? Color.IGreen : Color.IRed;

    writef("%s %s - %s%d passed%s, %s%d failed%s, %d found - %s\n",
        Label.Blank.tosz,
        moduleName.tosz,
        passColor.tosz,
        counter.current.passing,
        Color.Reset.tosz,
        failingColor.tosz,
        counter.current.failing,
        Color.Reset.tosz,
        counter.current.total,
        elapseTimeString(from, to).tosz);
}



void
printSummary (
    const UnitTestCounter counter,
    const string[] excludeList,
    const MonoTime from,
    const MonoTime to
) @safe
{
    import std.string: leftJustify;
    import std.uni: toLower;
    import std.format: format;

    const passColor = counter.all.isAllPassing() ? Color.IGreen : Color.Yellow ;
    const failColor = counter.all.isNoneFailing() ? Color.IGreen: Color.IRed ;

    enum BarLine = leftJustify(string.init, 50, '=');
    enum SummaryStart = format!"%s %s"(cast (string) Label.Blank, BarLine);

    if (getExecutionMode() == ExecutionMode.All) {
        writef("%s\n", SummaryStart.tosz);
        printSummaryWithUnitTests(counter.modulesWith, counter.modulesWithPrologue);
        printSummaryWithoutUnitTests(counter.modulesWithout);
        printSummaryExcludedUnitTests(excludeList);
    }

    writef("%s\n", SummaryStart.tosz);

    writef("%s %d found: %s%d passed%s, %s%d failed%s\n",
        Label.Summary.tosz,
        counter.all.total,
        passColor.tosz, counter.all.passing, Color.Reset.tosz,
        failColor.tosz, counter.all.failing, Color.Reset.tosz);
    auto blank = Label.Blank.tosz;
    writef("%s %d %s\n",
        blank,
        counter.modulesWith.length,
        Module.WithUnitTest.toLower.tosz);
    writef("%s %d %s\n",
        blank,
        counter.modulesWithout.length,
        Module.WithoutUnitTest.toLower.tosz);
    writef("%s %d %s\n",
        blank,
        excludeList.length,
        Module.Excluded.toLower.tosz);

    writef("%s %s\n", Label.Elapsed.tosz, elapseTimeString(from, to).tosz);
    printDateTime(Label.End);
}



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
%s File:    %s (%d)
`;

    const indent = Label.AssertionDetail.length + " Message: ".length;
    const message = wrapnl(
        to!string(throwable.message),
        80,
        leftJustify("", indent, ' '),
        leftJustify("", indent, ' '))[indent..$];
    writef(ASSERT_MSG_FMTS,
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
printTrace (const Throwable throwable) @trusted
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
            writef("%s %s%s%s\n",
                Label.Trace.tosz,
                Color.Yellow.tosz,
                line.tosz,
                Color.Reset.tosz);
            continue;
        }
        // Do not output stack trace items beyond the call to the
        // custom unit test runner.
        if (!isIgnoreStartFound && line.canFind(IGNORE_START)) {
            writef("%s ...  (skipping)\n", Label.Trace.tosz);
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
        writef("%s %s\n", Label.Trace.tosz, line.tosz);
    }
    writef("\n");
}



private:



/**
 * Execution mode is the context in which the unit test is running.
 */
enum ExecutionMode: string {
    All = "All",
    Selection = "Selection"
}



/**
 * Output label enumeration.
 */
enum Label: string {
    Blank               = "[unittest]         ",
    Start               = "[unittest] Start:  ",
    Mode                = "[unittest] Mode:   ",
    Module              = "[unittest] Module: ",
    Summary             = "[unittest] Summary:",
    List                = "[unittest] List:   ",
    Elapsed             = "[unittest] Elapsed:",
    End                 = "[unittest] End:    ",
    AssertionFailed     = "[unittest]",
    AssertionDetail     = "          ",
    Trace               = "   [trace]"
}



/**
 * Labels for the summary lists.
 */
enum Module: string {
    WithUnitTest = "Module(s) with unit test",
    WithoutUnitTest = "Module(s) without unit test",
    Excluded = "Module(s) excluded"
}



/**
 * Color enumeration.
 */
enum Color: string {
    Reset   = "\033[0;;m",
    Red     = "\033[0;31m",
    IRed    = "\033[38;5;196m",
    Green   = "\033[0;32m",
    IGreen  = "\033[38;5;46m",
    Yellow  = "\033[0;93m",
    White   = "\033[0;97m"
}



void
printDateTime (const string arg) @safe
{
    writef("%s %s\n", arg.tosz, getCurrentTimeString().tosz);
}



string
getCurrentTimeString () @safe
{
    import std.datetime: Clock;
    return Clock.currTime().toSimpleString();
}



string
elapseTimeString (
    const MonoTime from,
    const MonoTime to
) @safe
{
    import core.time: Duration;
    Duration elapsedTime = to - from;
    return elapsedTime.toString();
}



/**
 * Determine the `ExecutionMode` based on the execution list status.
 * The `ExecutionMode` is `Selective` if the execution list is not
 * empty. Otherwise, `ExecutionMode` is `All`.
 */
ExecutionMode
getExecutionMode () @safe
{
    if (executionList.isEmpty()) {
        return ExecutionMode.All;
    } else {
        return ExecutionMode.Selection;
    }
}



void
printSummaryWithUnitTests (
    const string[] modulesWithUnitTests,
    const string[] modulesWithPrologue
) @safe
{
    import std.algorithm: sort;

    alias GoodColor = Color.IGreen;
    alias BadColor = Color.IRed;
    const AttentionColor = Color.Yellow.tosz;
    const ResetColor = Color.Reset.tosz;
    const color = modulesWithUnitTests.length == 0 ? BadColor : GoodColor;

    writef("%s %s%s (%d)%s\n",
        Label.List.tosz,
        color.tosz,
        Module.WithUnitTest.tosz,
        modulesWithUnitTests.length,
        Color.Reset.tosz);
    writef("%s Module(s) without prologue code have asterisk (*)\n",
        Label.Blank.tosz);

    if (modulesWithUnitTests.length == 0) {
        return;
    }

    foreach (item; (modulesWithUnitTests.dup).sort.release()) {
        if (modulesWithPrologue.beginsWith(item)) {
            writef("%s     %s\n", Label.Blank.tosz, item.tosz);
        } else {
            writef("%s     %s%s *%s\n",
                Label.Blank.tosz,
                AttentionColor,
                item.tosz,
                ResetColor);
        }
    }
}



void
printSummaryWithoutUnitTests (const string[] arg) @safe
{
    printSummaryCategory(arg, Module.WithoutUnitTest, Color.Yellow, Color.IGreen);
}



void
printSummaryExcludedUnitTests (const string[] arg) @safe
{
    // Note the reversed color arguments
    printSummaryCategory(arg, Module.Excluded, Color.Reset, Color.Reset);
}



void
printSummaryCategory (
    const string[] list,
    const string label,
    const string goodColor,
    const string badColor
) @safe
{
    import std.algorithm: sort;
    const color = list.length == 0 ? badColor : goodColor;
    writef("%s %s%s (%d)%s\n",
        Label.List.tosz,
        color.tosz,
        label.tosz,
        list.length,
        Color.Reset.tosz);
    if (list.length == 0) {
        return;
    }
    foreach (e; (list.dup).sort.release()) {
        writef("%s     %s\n", Label.Blank.tosz, e.tosz);
    }
}



void
printSelections () @safe
{
    const label = Label.Blank.tosz;
    foreach (entry; executionList.modules) {
        writef("%s   module: %s\n", label, entry.tosz);
    }
    foreach (entry; executionList.unittests) {
        writef("%s   block:  %s\n", label, entry.tosz);
    }
}

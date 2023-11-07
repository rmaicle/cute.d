module sut.log;

import core.time: Duration;
import std.stdio: printf;
import std.string: tosz = toStringz;
import sut.list: execList;
import sut.stats: ExecutionStatusCounter;



void
printIntro ()
{
    static import std.compiler;

    printDateTime(Label.Start);
    printf("%s %s version %u.%u\n",
        Label.Compiler.tosz,
        std.compiler.name.tosz,
        std.compiler.version_major,
        std.compiler.version_minor);
    auto mode = getExecutionMode();
    printf("%s %s\n", Label.Mode.tosz, mode.tosz);
    if (mode != ExecutionMode.Selection) {
        return;
    }
    printSelections();
}



void
printUnitTestSummary (
    const string moduleName,
    const string unitTestName,
    const ulong lineNumber,
    const bool status
) {
    const color = status ? Color.IGreen : Color.IRed;
    printf("%s %s %s%s%s (%llu)\n",
        Label.Blank.tosz,
        moduleName.tosz,
        color.tosz,
        unitTestName.tosz,
        Color.Reset.tosz,
        lineNumber);
}



void
printModuleSummary (
    const string moduleName,
    const ExecutionStatusCounter esc,
    const Duration duration
) {
    const passingColor = esc.total == esc.passing ? Color.IGreen : Color.Yellow;
    const failingColor = esc.failing == 0 ? Color.IGreen : Color.IRed;

    printf("%s %s - %s%llu passed%s, %s%llu failed%s, %llu found - %s\n",
        Label.Module.tosz,
        moduleName.tosz,
        passingColor.tosz,
        esc.passing,
        Color.Reset.tosz,
        failingColor.tosz,
        esc.failing,
        Color.Reset.tosz,
        esc.total,
        duration.toString().tosz);
}



void
printSummary (
    const ExecutionStatusCounter esc,
    const Duration duration,
    const ulong withUnitTestCounter,
    const ulong withoutUnitTestCounter
) {
    import std.string: leftJustify;
    //import std.uni: toLower;
    import std.format: format;

    const unitTestColor = withoutUnitTestCounter == 0 ? Color.IGreen : Color.IRed;
    const passingColor = esc.total == esc.passing ? Color.IGreen : Color.Yellow;
    const failingColor = esc.failing == 0 ? Color.IGreen : Color.IRed;

    enum BarLine = leftJustify(string.init, 50, '=');
    enum SummaryStart = format!"%s %s"(cast (string) Label.Blank, BarLine);
    printf("%s\n", SummaryStart.tosz);

    //if (getExecutionMode() == ExecutionMode.All) {
    //}

    if (withoutUnitTestCounter == 0) {
        printf("%s Modules:  %s%llu%s\n", Label.Summary.tosz, unitTestColor.tosz, withUnitTestCounter, Color.Reset.tosz);
    } else {
        printf("%s Modules:  %llu %s(%llu)%s\n", Label.Summary.tosz, withUnitTestCounter, unitTestColor.tosz, withoutUnitTestCounter, Color.Reset.tosz);
    }
    printf("%s %sPassed:   %llu%s\n", Label.Blank.tosz, passingColor.tosz, esc.passing, Color.Reset.tosz);
    printf("%s %sFailed:   %llu%s\n", Label.Blank.tosz, failingColor.tosz, esc.failing, Color.Reset.tosz);
    printf("%s Total:    %llu\n", Label.Blank.tosz, esc.total);
    printf("%s Duration: %s\n", Label.Blank.tosz, duration.toString().tosz);
    printDateTime(Label.End);
}



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
    Blank               = "[unittest]           ",
    Start               = "[unittest] Start:    ",
    Compiler            = "[unittest] Compiler: ",
    Mode                = "[unittest] Mode:     ",
    Module              = "[unittest] Module:   ",
    Summary             = "[unittest] Summary:  ",
    //List                = "[unittest] List:     ",
    //Duration            = "[unittest] Duration: ",
    End                 = "[unittest] End:      ",
    AssertionFailed     = "[unittest]",
    AssertionDetail     = "          ",
    Trace               = "   [trace]"
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



private:



/**
 * Determine the `ExecutionMode` based on the execution list status.
 * The `ExecutionMode` is `Selective` if the execution list is not
 * empty. Otherwise, `ExecutionMode` is `All`.
 */
ExecutionMode
getExecutionMode ()
{
    if (execList.isEmpty()) {
        return ExecutionMode.All;
    } else {
        return ExecutionMode.Selection;
    }
}



void
printSelections ()
{
    const label = Label.Blank.tosz;
    foreach (entry; execList.modules) {
        printf("%s   module: %s\n", label, entry.tosz);
    }
    foreach (entry; execList.unittests) {
        printf("%s   block:  %s\n", label, entry.tosz);
    }
}



void
printDateTime (const string arg)
{
    string
    getCurrentTimeString ()
    {
        import std.datetime: Clock;
        return Clock.currTime().toSimpleString();
    }

    printf("%s %s\n", arg.tosz, getCurrentTimeString().tosz);
}

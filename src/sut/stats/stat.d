module sut.stats.stat;

import sut.stats.exec_stat_counter: ExecutionStatusCounter;
import sut.stats.module_stat: ModuleStat;
import sut.stats.unittest_stat: UnitTestStat;
static import sut.log;

import std.algorithm:
    canFind,
    find;
import core.time: Duration;



/**
 * Generic structure that holds a list of module names and statistics
 * about it like
 */
struct Stat
{
    ModuleStat[] modules;



    /**
     * Set to empty.
     */
    void
    reset ()
    {
        modules = (ModuleStat[]).init;
    }



    /**
     * Determine whether the unit test and module arrays are empty.
     */
    bool
    isEmpty () const nothrow @safe
    {
        return modules.length == 0;
    }



    /**
     * Determine whether the string argument is a prefix string of any of the
     * strings in the `modules` array.
     *
     * Returns: `true` if a match is found.
     */
    bool
    isModulePrefixFound (const string arg) const @safe
    {
        return modules.canFind!("a.name == b")(arg);
    }



    /**
     * Append an item to the module list if it does not exist yet.
     */
    void
    addModuleIfNotFound (
        const string arg,
        const bool withUnitTestFlag
    ) {
        if (!modules.canFind!("a.name == b")(arg)) {
            modules ~= ModuleStat(arg, withUnitTestFlag);
        }
    }



    void
    startModuleExecutionTimer (const string m) @safe
    {
        getModule(m).startTimer();
    }



    void
    stopModuleExecutionTimer (const string m) @safe
    {
        getModule(m).stopTimer();
    }



    void
    beginExecution (
        const string m,
        const string ut
    ) @safe
    {
        addUnitTest(m, ut);
        getUnitTest(m, ut).execute();
    }



    void endExecution (
        const string m,
        const string ut
    ) @safe
    {
        // TODO: Log
        import std.stdio;
    }



    void endExecutionSuccessful (
        const string m,
        const string ut,
        const ulong ln
    ) @trusted
    {
        getUnitTest(m, ut).pass();
        printUnitTestSummary(m, ut, ln);
    }



    void endExecutionFailure (
        const string m,
        const string ut,
        const ulong ln
    ) @trusted
    {
        getUnitTest(m, ut).fail();
        printUnitTestSummary(m, ut, ln);
    }



    void
    printModuleSummary (const string m)
    {
        scope ModuleStat fm = getModule(m);
        scope ExecutionStatusCounter esc = fm.getExecutionStatus();
        scope Duration d = fm.getExecutionDuration();
        sut.log.printModuleSummary(fm.name, esc, d);
    }



    void
    printSummary ()
    {
        ExecutionStatusCounter escTotal;
        Duration durationTotal;
        ModuleStat fm;
        ExecutionStatusCounter esc;
        Duration d;
        ulong withUnitTestCounter;
        ulong withOutUnitTestCounter;
        foreach (m; modules) {
            esc = m.getExecutionStatus();
            escTotal.add(esc);
            d = fm.getExecutionDuration();
            durationTotal += d;
            if (m.withUnitTest) {
                withUnitTestCounter++;
            } else {
                withOutUnitTestCounter++;
            }
        }
        sut.log.printSummary(escTotal, durationTotal, withUnitTestCounter, withOutUnitTestCounter);
    }



    private:



    void
    printUnitTestSummary (
        const string m,
        const string ut,
        const ulong ln
    ) @trusted
    {
        scope ModuleStat fm = getModule(m);
        scope bool status = fm.getUnitTestStatus(ut);
        sut.log.printUnitTestSummary(fm.name, ut, ln, status);
    }



    ModuleStat
    getModule (const string m) @trusted
    {
        auto fm = modules.find!("a.name == b")(m);
        assert (fm.length > 0);
        return fm[0];
    }



    /**
     * Append an item to the unit test list.
     */
    void
    addUnitTest (
        const string m,
        const string ut
    ) @safe
    {
        auto fm = modules.find!("a.name == b")(m);
        if (fm.length == 0) {
            return;
        }
        fm[0].unittests ~= UnitTestStat(ut);
    }



    ref UnitTestStat
    getUnitTest (
        const string m,
        const string ut
    ) @safe
    {
        auto fm = modules.find!("a.name == b")(m);
        assert (fm.length > 0);
        auto fut = (fm[0].unittests).find!("a.name == b")(ut);
        return fut[0];
    }
}

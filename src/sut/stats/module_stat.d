module sut.stats.module_stat;

import core.time:
    Duration,
    MonoTime;
import std.algorithm: find;
debug import std.stdio;
import sut.stats.unittest_stat: UnitTestStat;
import sut.stats.exec_stat_counter: ExecutionStatusCounter;



struct ModuleStat
{
    /**
     * Module name
     */
    string name;

    /**
     * With unit test flag. Set to `true` if module has a unit test.
     * Otherwise, this is set to `false`.
     */
    bool withUnitTest;

    /**
     * With unit test prologue flag. Set to `true` if at least one
     * module unit test contains a prologue.
     */
    bool withUnitTestPrologue;

    /**
     * Collection of unit tests with unit test prologue.
     *
     * Note: This library could only check for unit tests with prologue.
     */
    UnitTestStat[] unittests;



    MonoTime timeStart;
    MonoTime timeStop;



    this (
        const string arg,
        const bool withUnitTestFlag
    ) @safe
    {
        name = arg;
        withUnitTest = withUnitTestFlag;
    }



    ExecutionStatusCounter
    getExecutionStatus () @trusted
    {
        ExecutionStatusCounter es;
        foreach (ut; unittests) {
            if (!ut.executed) {
                continue;
            }
            es.total++;
            if (ut.passing) {
                es.passing++;
            } else {
                es.failing++;
            }
        }
        return es;
    }




    bool
    getUnitTestStatus (const string ut) @trusted
    {
        auto fut = unittests.find!("a.name == b")(ut);
        assert (fut.length > 0);
        return fut[0].passing;
    }



    Duration
    getExecutionDuration ()
    {
        return timeStop - timeStart;
    }



    void
    startTimer () @trusted
    {
        timeStart = MonoTime.currTime;
    }




    void
    stopTimer () @trusted
    {
        timeStop = MonoTime.currTime;
    }
}

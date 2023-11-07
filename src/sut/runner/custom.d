module sut.runner.custom;

import core.exception:
    AssertError,
    assertHandler;
import core.runtime: UnitTestResult;
import core.time: Duration;

import sut.list:
    isModuleExcluded,
    execList,
    skipList;
import sut.log: printIntro;
import sut.stats: stat;
import sut.runner.log:
    printAssertion,
    printTrace;
import sut.runner.runtime: Runtime;

debug import std.stdio;
debug import std.string: tosz = toStringz;



/**
 * Custom module unit test runner.
 *
 * Code snippet from runtime.d.runModuleUnitTests
 * Ref: druntime/src/core/runtime.d
 */
UnitTestResult
sutRunner ()
{
    import std.string: join, toStringz;
    import core.stdc.stdio:
        fflush,
        printf,
        stdout;



    UnitTestResult result;
    result.passed = 0;
    result.executed = 0;
    if (Runtime.exitFlag) {
        return result;
    }

    printIntro();
    assertHandler(&customAssertHandler);
    foreach (m; ModuleInfo) {
        debug (variable) writeln("Module: ", m.name);
        if (!m) {
            continue;
        }
        if (isModuleExcluded(m.name)) {
            continue;
        }
        if (!execList.isEmpty() && !execList.isModuleFound(m.name)) {
            continue;
        }
        auto fp = m.unitTest();
        // MODULE AND UNIT TEST CHECKING NOTE:
        // Do not test here whether a module is in the execution list
        // because unit tests are needed to be checked too whether it
        // is in the execution list. Checking for unit tests here is
        // not possible because there is no way to do it.
        stat.addModuleIfNotFound(m.name, fp != null);
        if (!fp) {
            continue;
        }
        stat.startModuleExecutionTimer(m.name);
        try {
            fp();
        } catch (Throwable e) {
            // If assertion is from this module, do nothing
            if (typeid(e) == typeid(AssertError)) {
                if (isInternalAssertion(m.name, e.file)) {
                    continue;
                }
            }
            // When an assertion is caught inside assertThrown(), the message
            // string defaults to null. This can be used to check if an
            // assertion inside assertThrown() was caught. If the assertion
            // was caught, do not report the assertion failure.
            //
            // See std.exception.assertThrown definition.
            if (e.message.length > 0) {
                printAssertion(m.name, e);
                printTrace(e);
            }
        }
        stat.stopModuleExecutionTimer(m.name);
        stat.printModuleSummary(m.name);
    }
    assertHandler(null);
    stat.printSummary();

    // OPTION -unittest NOTE:
    // DMD 2.090.0 changed -unittest behavior and now defaults to
    // running unit tests only. If old behavior is desired (run tests
    // then main), use --DRT-testmode=run-main.

    // Do not print summary, we handle it here.
    result.summarize = false;
    // Do not run main()
    result.runMain = false;

    return result;
    // End of code snippet from runtime.d.runModuleUnitTests
}



bool
isInternalAssertion (
    const string moduleName,
    const string filename
) {
    import std.string: toStringz, tr;

    string mName = moduleName ~ ".d";
    string fName = filename;
    debug (verbose) {
        printf("Module:   %s\n", mName.toStringz);
        printf("Filename: %s\n", fName.toStringz);
    }
    if (filename.length == moduleName.length) {
        // Convert module filename to module name
        fName = filename.tr("/", ".")[$ - moduleName.length..$];
    } else if (filename.length < moduleName.length) {
        enum SEPARATOR = ".";
    }
    return mName == fName;
}



private:



/**
 * Custom assert handler for unit tests only.
 * The default assert handler must be restored.
 */
@safe
nothrow
void
customAssertHandler (
    string file = __FILE__,
    ulong line = __LINE__,
    string msg = string.init
) {
    import core.exception: AssertError;
    throw new AssertError(msg, file, line);
}

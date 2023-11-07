/**
 * Selective Unit Testing (SUT) Module
 *
 * Unit testing library for selective unit test execution of D programs.
 * It allows per module and per unit test block execution.
 *
 * Copyright (c) 2020-2021 Ricardo I. Maicle
 * Distributed under MIT license.
 * See LICENSE file for detail.
 *
 *
 *
 * Self unit testing:
 *
 * Requires that the current directory is at <project>/build and
 * executes compile.sh to build and run the binary file. The output
 * binary file is created in <project>/bin.
 *
 *    <project-root>
 *    ├── bin
 *    ├── build
 *    └── src
 *        ├── sut
 *        │   ├── list
 *        │   ├── runner
 *        │   └── stats
 *        └── test
 *            ├── failing
 *            ├── no_wrapper
 *            ├── selective_block
 *            ├── selective_module
 *            └── with_wrapper
 *
 *    dmd                                     \
 *        -I=<project>/src                    \
 *        -i                                  \
 *        -main                               \
 *        -debug | -release                   \
 *        -unittest                           \
 *        -version=sut                        \
 *        -version=sut_internal_unittest      \
 *        -od=<project>/bin                   \
 *        <project>/src/sut/<source-file>
 *
 *
 *
 * Unit testing other source code using SUT:
 */



module sut;

public import sut.mixins:
    prologueBlock,
    getUnitTestName,
    executeBlock;
public import sut.stats: stat;



version (sut_internal_unittest) {
    version (sut) { } else {
        enum ERR_MSG = `Compiling with version identifier 'sut_internal_unittest'
    requires 'sut' version definition.`;
        static assert (false, ERR_MSG);
    }
}



version (sut) {
    version (D_ModuleInfo) {
        version = sut_execution_enabled;
    } else {
        enum ERR_MSG = `Compiling with version identifier 'sut' requires D_ModuleInfo`;
        static assert (false, ERR_MSG);
    }
}



version (sut_execution_enabled) {

    shared static this () {
        static import sut.runner;
        import core.runtime: Runtime;
        if (!handleArguments(Runtime.args())) {
            sut.runner.Runtime.exitFlag = true;
        }
        // When Runtime.exitFlag is true, we exit from the custom unit test
        // runner because we cannot exit here.
        Runtime.extendedModuleUnitTester = &sut.runner.sutRunner;
    }



    /**
     * Handle run-time arguments. Arguments are passed to the program
     * at compile-time.
     *
     * The function is called statically during module initialization.
     */
    bool
    handleArguments (const string[] arg)
    {
        import sut.list: collect;
        import std.getopt:
            getoptConfig = config,
            defaultGetoptPrinter,
            getopt;
        debug import std.stdio;

        // Necessary to declare a local array variable because
        // getopt function accepts only reference arrays.
        string[] arguments = arg.dup;
        string[] files;
        auto helpInfo = getopt(
            arguments,
            getoptConfig.passThrough,
            "config|c", "configuration file (../bin/unittest.conf)", &files);
        if (helpInfo.helpWanted) {
            defaultGetoptPrinter("SUT command-line options:", helpInfo.options);
            return false;
        }
        debug writeln("Files: ", files);
        auto filesProcessed = collect(files);
        return true;
    }
}

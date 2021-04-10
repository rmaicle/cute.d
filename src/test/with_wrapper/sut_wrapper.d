/**
 * Module that encapsulates the inclusion of the selective unit test
 * module at compile-time. It allows client code to be compiled with
 * or without using the selective unit test module.
 */
module test.with_wrapper.sut_wrapper;

version (sut) { } else {
    pragma (msg, "Using default unit test runner.");
    enum prologue="";
    enum skip="";
}

static if (!__traits(compiles, { import sut; })) {
    pragma (msg, "Version identifier 'sut' defined but 'sut' module not found.");
    enum prologue="";
    enum skip="";
}

/**
 * Conditionally compile-in the `sut` module if it is visible in
 * the client code. Otherwise, it does nothing.
 */
pragma (msg, "Using selective unit testing module.");
public import sut;

/**
 * Unit test block prologue code mixed-in from unit test blocks.
 */
enum prologue=`mixin (test.with_wrapper.sut_wrapper.unitTestBlockPrologue);`;
enum skip=`mixin (test.with_wrapper.sut_wrapper.skipModule);`;

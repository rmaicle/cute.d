module sut.runner.runtime;



/**
 * Runtime flag whether to exit the custom unit test before executing
 * unit tests.
 *
 * Design:
 * This is necessary in handling test program arguments, like --help, that
 * skips the unit test execution.
 */
struct Runtime
{
    static
    bool exitFlag = false;
}

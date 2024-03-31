/**
 * Excluded module.
 */
module test.with_wrapper.excluded;

import sut;
version (unittest) {
    static import test.with_wrapper.sut_wrapper;        // import
}

int div (const int arg, const int n) {
    return arg / n;
}
@("div")
unittest {
    mixin (test.with_wrapper.sut_wrapper.prologue);     // prologue code
    assert (div(10, 1) == 10);                          // never executed
}

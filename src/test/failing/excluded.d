/**
 * Excluded module.
 */
module test.failing.excluded;

import sut;
version (unittest) {
    static import test.failing.sut_wrapper;
    //mixin (test.failing.sut_wrapper.exclude);
}

int div (const int arg, const int n) {
    return arg / n;
}
@("div")
unittest {
    mixin (test.failing.sut_wrapper.prologue);
    assert (div(10, 1) == 10);
}

module test.with_wrapper.mul;

import sut;
version (unittest) {
    static import test.with_wrapper.sut_wrapper;        // import
}

size_t mul (const int arg, const int n) {
    return arg * n;
}
@("mul")
unittest {
    mixin (test.with_wrapper.sut_wrapper.prologue);     // prologue code
    assert (mul(10, 2) == 20);
}

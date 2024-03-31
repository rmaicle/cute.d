module test.with_wrapper.test;

import sut;
import test.with_wrapper.mul;
import test.with_wrapper.no_prologue;
import test.with_wrapper.no_unittest;
import test.with_wrapper.excluded;
version (unittest) {
    static import test.with_wrapper.sut_wrapper;        // import
}

int add (const int arg, const int n) {
    return arg + n;
}
@("add")
unittest {
    mixin (test.with_wrapper.sut_wrapper.prologue);     // prologue code
    assert (add(10, 1) == 11);
}

int sub (const int arg, const int n) {
    return arg - n;
}
@("sub")
unittest {
    mixin (test.with_wrapper.sut_wrapper.prologue);     // prologue code
    assert (sub(10, 1) == 9);
}

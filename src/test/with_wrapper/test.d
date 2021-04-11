module test.with_wrapper.test;

import test.with_wrapper.excluded;
import test.with_wrapper.no_unittest;
import test.with_wrapper.mul;
version (unittest) {
    static import test.with_wrapper.sut_wrapper;        // changed
}

int add (const int arg, const int n) {
    return arg + n;
}
@("add")
unittest {
    mixin (test.with_wrapper.sut_wrapper.prologue);     // changed
    assert (add(10, 1) == 11);
}

int sub (const int arg, const int n) {
    return arg - n;
}
@("sub")
unittest {
    mixin (test.with_wrapper.sut_wrapper.prologue);     // changed
    assert (sub(10, 1) == 9);
}

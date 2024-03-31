module test.failing.test;

import sut;
import test.failing.mul;
import test.failing.no_prologue;
import test.failing.no_unittest;
import test.failing.excluded;

version (unittest) {
    static import test.failing.sut_wrapper;         // changed
}

int add (const int arg, const int n) {
    return arg + n;
}
@("add")
unittest {
    mixin (test.failing.sut_wrapper.prologue);      // changed
    assert (add(10, 1) == 11);
}

int sub (const int arg, const int n) {
    return arg - n;
}
@("subtract")
unittest {
    mixin (test.failing.sut_wrapper.prologue);      // changed
    assert (sub(10, 1) == 0);                       // failing
}

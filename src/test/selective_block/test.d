module test.selective_block.test;

import sut;
import test.selective_block.mul;
import test.selective_block.no_prologue;
import test.selective_block.no_unittest;
import test.selective_block.excluded;
version (unittest) {
    static import test.selective_block.sut_wrapper;        // changed
}

int add (const int arg, const int n) {
    return arg + n;
}
@("add")
unittest {
    mixin (test.selective_block.sut_wrapper.prologue);     // changed
    assert (add(10, 1) == 11);
}

int sub (const int arg, const int n) {
    return arg - n;
}
@("subtract")
unittest {
    mixin (test.selective_block.sut_wrapper.prologue);     // changed
    assert (sub(10, 1) == 9);
}

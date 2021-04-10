module test.selective_block.test;

import test.selective_block.empty;
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

module test.selective_block.mul;

import sut;
version (unittest) {
    static import test.selective_block.sut_wrapper;         // changed
}

size_t mul (const int arg, const int n) {
    return arg * n;
}
@("mul")
unittest {
    mixin (test.selective_block.sut_wrapper.prologue);      // changed
    assert (mul(10, 2) == 20);
}

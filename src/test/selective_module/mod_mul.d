module test.selective_module.mod_mul;

import sut;
version (unittest) {
    static import test.selective_module.sut_wrapper;        // changed
}

size_t mul (const int arg, const int n) {
    return arg * n;
}
@("mul")
unittest {
    mixin (test.selective_module.sut_wrapper.prologue);     // changed
    assert (mul(10, 2) == 20);
}

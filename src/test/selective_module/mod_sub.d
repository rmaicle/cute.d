module test.selective_module.mod_sub;

import sut;
version (unittest) {
    static import test.selective_module.sut_wrapper;        // changed
}

int sub (const int arg, const int n) {
    return arg - n;
}
@("sub")
unittest {
    mixin (test.selective_module.sut_wrapper.prologue);     // changed
    assert (sub(10, 1) == 9);
}

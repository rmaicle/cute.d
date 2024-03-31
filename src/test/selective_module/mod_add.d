module test.selective_module.mod_add;

import sut;
version (unittest) {
    static import test.selective_module.sut_wrapper;        // changed
}

int add (const int arg, const int n) {
    return arg + n;
}
@("add")
unittest {
    mixin (test.selective_module.sut_wrapper.prologue);     // changed
    assert (add(10, 1) == 11);
}

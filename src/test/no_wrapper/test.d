module test.no_wrapper.test;

import sut;                                 // SUT module
import test.no_wrapper.mul;
import test.no_wrapper.no_prologue;
import test.no_wrapper.no_unittest;
import test.no_wrapper.excluded;

int add (const int arg, const int n) {
    return arg + n;
}
@("add")                                    // unit test block name
unittest {
    mixin (sut.mixins.prologueBlock);       // necessary code
    assert (add(10, 1) == 11);
}

int sub (const int arg, const int n) {
    return arg - n;
}
@("subtract")                               // unit test block name
unittest {
    mixin (sut.mixins.prologueBlock);       // necessary code
    assert (sub(10, 1) == 9);
}

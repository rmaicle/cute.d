module test.no_wrapper.mul;

import sut;                                 // SUT module

size_t mul (const int arg, const int n) {
    return arg * n;
}
@("mul")                                    // unit test block name
unittest {
    mixin (sut.mixins.prologueBlock);       // necessary code
    assert (mul(10, 2) == 20);
}

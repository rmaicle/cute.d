module test.selective_module.test;

import sut;
import test.selective_module.mod_add;
import test.selective_module.mod_sub;
import test.selective_module.mod_mul;
import test.selective_module.no_prologue;
import test.selective_module.no_unittest;
import test.selective_module.excluded;

version (unittest) {
    static import test.selective_module.sut_wrapper;
}

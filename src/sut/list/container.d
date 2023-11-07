module sut.list.container;

import std.algorithm:
    canFind,
    find;
static import sut.wrapper;
static import sut.mixins;



static List execList;
static List skipList;



/**
 * Determine whether the module specified by the string argument is excluded
 * from execution.
 *
 * Returns: `true` if the argument is a module name excluded from execution.
 */
bool
isModuleExcluded (const string arg)
{
    version (sut_internal_unittest) {
        return isLanguageModule(arg)
            || skipList.isModuleFound(arg);
    } else {
        return isLanguageModule(arg)
            || isInternalModule(arg)
            || skipList.isModuleFound(arg);
    }
}



private:



struct List
{
    /**
     * Module list
     */
    string[] modules;

    /**
     * Unit test list
     */
    string[] unittests;



    /**
     * Set lists to empty.
     */
    void
    reset ()
    {
        modules = (string[]).init;
        unittests = (string[]).init;
    }



    /**
     * Determine if the lists are empty.
     */
    bool
    isEmpty () const @safe
    {
        return modules.length == 0 && unittests.length == 0;
    }



    /**
     * Determine whether the string argument is one of the strings in the unit
     * test list.
     *
     * Returns: `true` if a match is found.
     */
    bool
    isUnitTestFound (const string arg) const @safe
    {
        return unittests.canFind(arg);
    }



    /**
     * Determine whether the unit test strings can be found in the
     * string argument.
     */
    bool
    doesUnitTestStringsAppearIn (const string arg)
    {
        return unittests.canFind!(
            (string a, string b) => b.canFind(a))(arg);
    }
    @("doesUnitTestStringsAppearIn")
    unittest {
        mixin (sut.wrapper.prologue);
        List list;
        list.unittests ~= "one";
        list.unittests ~= "two";
        list.unittests ~= "three";
        assert (list.doesUnitTestStringsAppearIn("one thousand"));
        assert (list.doesUnitTestStringsAppearIn("twenty two"));
        assert (!list.doesUnitTestStringsAppearIn("thousand"));
    }



    /**
     * Determine whether the string argument is one of the strings in the
     * module list.
     *
     * Returns: `true` if a match is found.
     */
    bool
    isModuleFound (const string arg) const @safe
    {
        return modules.canFind(arg);
    }



    /**
     * Append an item to the unit test list only if it does not
     * already exists.
     */
    void
    addUnitTestIfNotFound (const string arg) @safe
    {
        if (!unittests.canFind(arg)) {
            addUnitTest(arg);
        }
    }



    /**
     * Append an item to the `modules` list only if it does not
     * already exists.
     */
    void
    addModuleIfNotFound (const string arg)
    {
        if (!modules.canFind(arg)) {
            addModule(arg);
        }
    }



private:



    /**
     * Append an item to the unit test list.
     */
    void
    addUnitTest (const string arg) @safe
    {
        unittests ~= arg;
    }



    /**
     * Append an item to the `modules` list.
     */
    void
    addModule (const string arg)
    {
        modules ~= arg;
    }
}



/**
 * Determine whether the string argument corresponds to any D language module
 * name.
 *
 * Returns: `true` if the argument is a D language module.
 */
bool
isLanguageModule (const string mod)
{
    import sut.util: beginsWith;
    static immutable string[] langModules = [
        "__main",
        "core",
        "etc",
        "invariant",
        "gc",
        "ldc",
        "object",
        "rt",
        "std"
    ];

    // Module invariant has been added since it keeps on appearing when
    // reporting the total number of modules processed even though
    // there is no invariant module present. What is it really?

    return langModules.beginsWith(mod);
}
@("isLanguageModule")
unittest {
    mixin (sut.wrapper.prologue);
    assert (isLanguageModule("__main"));
    assert (isLanguageModule("core.submodule"));
    assert (isLanguageModule("etc.submodule"));
    assert (isLanguageModule("gc.submodule"));
    assert (isLanguageModule("gc.submodule"));
    assert (isLanguageModule("object.submodule"));
    assert (isLanguageModule("rt.submodule"));
    assert (isLanguageModule("std.submodule"));
}



/**
 * Determine whether the string argument is equal to the package name `sut`.
 * This check is only performed when unit testing is enabled and the
 * version identifier `sut` is not defined.
 *
 * Returns: `true` if the string argument is equivalent to this module's name.
 */
bool
isInternalModule (const string arg)
{
    version (sut_internal_unittest) {
        version (sut) {
            // We are testing the `sut` package so we explicitly
            // tell the calling routine that the string argument
            // is not an internal module whatever its value may be.
            return false;
        } else {
            assert (false, "This should be unreachable.\n"
                ~ "Compiling with version identifier 'sut_internal_unittest' "
                ~ "requires 'sut' version definition.");
        }
    } else {
        if (arg.canFind(".")) {
            return arg.canFind("sut.") || arg.canFind(".sut");
        } else {
            return arg.canFind("sut");
        }
    }
}
@("isInternalModule")
unittest {
    mixin (sut.wrapper.prologue);
    version (sut_internal_unittest) {
        version (sut) {
            assert (!isInternalModule(__MODULE__));
        } else {
            assert (isInternalModule(__MODULE__));
        }
    } else {
        assert (isInternalModule(__MODULE__));
    }
    assert (!isInternalModule("__main"));
    assert (!isInternalModule("core.submodule"));
    assert (!isInternalModule("etc.submodule"));
    assert (!isInternalModule("gc.submodule"));
    assert (!isInternalModule("gc.submodule"));
    assert (!isInternalModule("object.submodule"));
    assert (!isInternalModule("rt.submodule"));
    assert (!isInternalModule("std.submodule"));
}

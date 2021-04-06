module sut.prologue;

import sut.color;
import sut.counter;
import sut.output;
import sut.execlist:
    isExecutionListEmpty,
    isInModuleExecList,
    isInUnitTestExecList,
    isUnitTestBlockExecuted;

debug import std.stdio;



/**
 * Generate a compile-time string used in a mixed-in to:
 *   - get the unit test block name whether it is a user-supplied name using
 *     a user-defined string attribute (UDA) or the default unit test name.
 *   - call the actual function that displays the unit test block info and
 *     execution status.
 *
 * Params:
 *   skipFlag - pass `false` to skip execution of the rest of the unit test
 *              block.
 *
 * Returns: string
 *
 * Example:
 *
 * ~~~~~~~~~~
 * static import sut;
 * ...
 * unittest {
 *     mixin (sut.unitTestBlockPrologue());
 * }
 * ~~~~~~~~~~
 *
 * TODO: Use moduleName!moduleName instead
 */
string
unitTestBlockPrologue (size_t LN = __LINE__)()
{
    import std.format: format;

    // Because this function is intended to be called from the first line
    // of unit test blocks, we hard code the line number.
    //
    // NOTE:
    //
    // The result of this function is passed to a mixin statement.
    //
    //   @("unittest label or identifier string")
    //   unittest {                                 <-- LN - 1
    //     mixin (???.unitTestBlockPrologue());     <-- LN
    //   }
    //
    enum UTLineNumber = LN - 1;
    // Create possible non-conflicting identifiers for module name and unit
    // test name which are used only within the calling unit test block.
    enum ModuleName = format!("module_name_L%d__")(UTLineNumber);
    enum UnitTestName = format!("unit_test_name_L%d__")(UTLineNumber);

    return `static import sut;
import std.traits: moduleName;
struct dummyXYZ { }` ~
format!("\nenum %s = sut.getUnitTestName!dummyXYZ;")(UnitTestName) ~
format!("\nenum %s = moduleName!dummyXYZ;")(ModuleName) ~
format!("\nif (sut.executeBlock!(%s, %s, %d)() == false) { return; }")(
    ModuleName,
    UnitTestName,
    UTLineNumber);
}



/**
 * Get unit test name.
 *
 * Unit test name is the first user-defined string attribute or the
 * compiler-generated name.
 *
 * Returns: string
 */
string
getUnitTestName (alias T)() pure nothrow
{
    enum udaName = firstStringUDA!(__traits(parent, T));
    static if (udaName == string.init) {
        return __traits(identifier, __traits(parent, T));
    } else {
        return udaName;
    }
}



/**
 * Execute unit test block.
 *
 * To skip execution of a unit test block, pass `false` or an expression that
 * evaluates to `false`.
 *
 * Returns: `true` by default. When `sut` version identifier is defined, the
 *          return value is the boolean argument.
 */
bool
executeBlock (
    const string ModuleName,
    const string UnitTestName,
    const size_t LineNo
)()
{
    import std.string: toStringz;
    import core.stdc.stdio: printf, fflush, stdout;

    bool
    proceedToExecute (const bool flag) {
        // Assume it passed first
        // If an assertion occurs, subtract 1 in the exception handler code
        moduleCounter.pass++;

        printf("%s %s %4zd %s%s%s\n",
            Label.NoGroupLabel.toStringz,
            ModuleName.toStringz,
            LineNo,
            Color.Green.toStringz,
            UnitTestName.toStringz,
            Color.Reset.toStringz);
        fflush(stdout);
        return flag;
    }

    moduleCounter.found++;
    version (sut) {
        // Filter if a selection is present. Otherwise, execute all.
        if (isExecutionListEmpty()) {
            isUnitTestBlockExecuted = true;
            return proceedToExecute(true);
        }
        if (isInModuleExecList(ModuleName)) {
            if (!isUnitTestBlockExecuted) {
                isUnitTestBlockExecuted = true;
                printModuleStart(ModuleName);
            }
            return proceedToExecute(true);
        } else {
            if (isInUnitTestExecList(UnitTestName)) {
                if (!isUnitTestBlockExecuted) {
                    isUnitTestBlockExecuted = true;
                    printModuleStart(ModuleName);
                }
                return proceedToExecute(true);
            }
        }
        moduleCounter.skip++;
        return false;
    } else {
        //return proceedToExecute(true);
        return true;
    }
}



private:



/**
 * Determine whether the template argument is some string.
 */
template
isStringUDA (alias T)
{
    import std.traits: isSomeString;
    static if (__traits(compiles, isSomeString!(typeof(T)))) {
        enum isStringUDA = isSomeString!(typeof(T));
    } else {
        enum isStringUDA = false;
    }
}
@("isStringUDA: string")
unittest {
    //mixin (unitTestBlockPrologue());
    @("string variable")
    string stringVar;
    static assert (isStringUDA!(__traits(getAttributes, stringVar)));
}
@("isStringUDA: not a string")
unittest {
    //mixin (unitTestBlockPrologue());
    @(123)
    int intVar;
    static assert (isStringUDA!(__traits(getAttributes, intVar)) == false);
}



/**
 * Get the first string user-defined attribute (UDA) of the alias argument
 * if one is present. Otherwise, an empty string.
 */
template
firstStringUDA (alias T)
{
    import std.traits: hasUDA, getUDAs;
    import std.meta: Filter;
    enum attributes = Filter!(isStringUDA, __traits(getAttributes, T));
    static if (attributes.length > 0) {
        enum firstStringUDA = attributes[0];
    } else {
        enum firstStringUDA = "";
    }
}
@("firstStringUDA: string")
unittest {
    //mixin (unitTestBlockPrologue());
    @("123")
    int intVar;
    static assert (firstStringUDA!intVar == "123");
}
@("firstStringUDA: integer")
unittest {
    //mixin (unitTestBlockPrologue());
    @(123)
    int intVar;
    static assert (firstStringUDA!intVar == string.init);
}
@("firstStringUDA: empty")
unittest {
    //mixin (unitTestBlockPrologue());
    int intVar;
    static assert (firstStringUDA!intVar == string.init);
}



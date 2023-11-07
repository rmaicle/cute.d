module sut.mixins;

debug import std.stdio;



string
prologueBlock (const size_t LineNumber = __LINE__)()
{
    // Because this string is intended and assumed to be passed to a mixin
    // expression at the first line of the unit test block, the line number
    // of the unit test entry block point is calculated to be less than.
    //
    // This is the solution for now until a more reliable way is found on how
    // to get the actual line number of the unit test block entry point.
    //
    //   @("unittest label or identifier string")
    //   unittest {                                 <-- prologue - 1
    //     mixin (???.unitTestBlockPrologue());     <-- prologue
    //   }

    import std.format: format;
    return format!`
    static import sut;
    import std.traits: moduleName;

    // Dummy struct to be used to identify the module and unit test block
    // this block is in.
    struct dummyXYZ { }
    static unitTestName = sut.mixins.getUnitTestName!dummyXYZ();

    // Unit test block flag is set when execution enters the unit test block.
    // When execution leaves the unit test block, the flag is unset.
    // This flag is used to determine whether execution is happening inside
    // a unit test block with prologue code.

    scope (success) sut.stat.endExecutionSuccessful(moduleName!dummyXYZ, unitTestName, %1$s);
    scope (failure) sut.stat.endExecutionFailure(moduleName!dummyXYZ, unitTestName, %1$s);

    bool executeBlockFlag = sut.mixins.executeBlock!(
        moduleName!dummyXYZ,
        sut.mixins.getUnitTestName!dummyXYZ(),
        %1$s);
    if (executeBlockFlag == false) {
        return;
    }`(LineNumber - 1);
}



/**
 * Execute unit test block.
 */
public
bool
executeBlock (
    const string ModuleName,
    const string UnitTestName,
    const size_t Line
)() @trusted
{
    import sut.list:
        execList,
        skipList;
    import sut.stats: stat;



    bool
    execute ()
    {
        sut.stat.beginExecution(ModuleName, UnitTestName);
        return true;
    }



    // If execution list is empty then all unit tests are to be executed
    // except, of course, those modules that are in the skip list.
    if (execList.isEmpty()) {
        return execute();
    }
    // Checking whether the module is in the execution list happens here.
    // If the module is not in the execution list, the unit test can then
    // be checked next.
    // See: MODULE CHECK NOTE in the unit test custom runner module.
    if (execList.isModuleFound(ModuleName)) {
            return execute();
    } else {
        if (execList.doesUnitTestStringsAppearIn(UnitTestName)) {
            return execute();
        }
    }
    return false;
}



/**
 * Get unit test name of template argument.
 *
 * Unit test name is the first user-defined string attribute or the
 * compiler-generated name of the parent symbol of the template argument.
 *
 * Returns: string
 */
public
string
getUnitTestName (alias T)() pure nothrow
{
    import std.traits: isSomeString;
    enum attributes = __traits (getAttributes, __traits (parent, T));
    static if (attributes.length > 0) {
        if (isSomeString!(typeof (attributes[0]))) {
            return attributes[0];
        } else {
            return string.init;
        }
    } else {
        return string.init;
    }
}

module sut.stats.unittest_stat;



struct UnitTestStat
{
    /**
     * Unit test "name".
     */
    string name;


    /**
     * State whether it has been executed or not.
     */
    bool executed;

    /**
     * Execution passing flag. Set to `true` if unit tests passes. Otherwise,
     * this is set to `false`.
     */
    bool passing;



    /**
     * Constructor
     */
    this (const string arg) @safe
    {
        name = arg;
        executed = false;
        passing = false;
    }



    /**
     * Determine whether the instance is valid or not.
     */
    bool
    isValid () const @safe
    {
        return name.length > 0;
    }


    /**
     * Set executed state to `true`.
     */
    void
    execute () @safe
    {
        executed = true;
    }



    /**
     * Set passing state to `true`.
     */
    void
    pass () @safe
    {
        passing = true;
    }



    /**
     * Set passing state to `false`.
     */
    void
    fail () @safe
    {
        passing = false;
    }
}

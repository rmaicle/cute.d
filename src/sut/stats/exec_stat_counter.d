module sut.stats.exec_stat_counter;


/**
 * Unit test execution status counter.
 */
struct ExecutionStatusCounter
{
    ulong passing;
    ulong failing;
    ulong total;



    void
    add (ExecutionStatusCounter esc)
    {
        passing += esc.passing;
        failing += esc.failing;
        total += esc.total;
    }
}

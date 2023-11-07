module sut.list.config;

import sut.list.container;
import sut.util:
    toArray,
    unprefix;

debug import std.stdio;



/**
 * Collect unit test and module strings from unit test configuration files
 * specified in the string array argument. The collected strings are kept
 * in the `static` variable `sut.unittestlist.execList`.
 *
 * Returns: Number of non-empty files.
 */
size_t
collect (const string[] files)
{
    import std.exception: enforce;
    import std.file: exists;
    import std.format: format;

    enum FILE_NOT_FOUND = "File not found: %s";

    size_t withContent = 0;
    if (files.length == 0) {
        debug (state) writeln("No files to collect from.");
        return withContent;
    }
    foreach (f; files) {
        enforce(f.exists(), format(FILE_NOT_FOUND, f));
        auto file = readFile(f);
        debug (variable) writefln("File: %s contains %s", f, file);
        if (file.isEmpty()) {
            continue;
        }
        withContent++;
        filter(file);
    }
    return withContent;
}



private:



/**
 * Read the contents of the file specified by the string argument.
 */
File
readFile (const string arg)
{
    import std.file: readText;
    return File(arg, arg.readText().toArray());
}



/**
 * Segregate file contents into their corresponding containers.
 */
bool
filter (const File arg)
{
    import std.algorithm: startsWith;

    enum BLOCK_PREFIX = "utb";
    enum MODULE_PREFIX = "utm";
    enum EXBLOCK_PREFIX = "xutb";
    enum EXMODULE_PREFIX = "xutm";
    enum SEPARATOR = ":";

    string tmp;
    foreach (item; arg.content) {
        if (item.startsWith(BLOCK_PREFIX)) {
            tmp = item.unprefix(BLOCK_PREFIX, SEPARATOR.length);
            execList.addUnitTestIfNotFound(tmp);
        } else if (item.startsWith(MODULE_PREFIX)) {
            tmp = item.unprefix(MODULE_PREFIX, SEPARATOR.length);
            execList.addModuleIfNotFound(tmp);
        } else if (item.startsWith(EXBLOCK_PREFIX)) {
            tmp = item.unprefix(EXBLOCK_PREFIX, SEPARATOR.length);
            skipList.addUnitTestIfNotFound(tmp);
        } else if (item.startsWith(EXMODULE_PREFIX)) {
            tmp = item.unprefix(EXMODULE_PREFIX, SEPARATOR.length);
            skipList.addModuleIfNotFound(tmp);
        }
    }
    debug (variables) {
        writeln("Execution list: ", execList.modules);
        writeln("Execution list: ", execList.unittests);
        writeln("Execution list: ", skipList.modules);
        writeln("Execution list: ", skipList.unittests);
    }
    return true;
}



/**
 * Container for the unit test configuration file and its content.
 */
struct File
{
    string filename;
    string[] content;



    /**
     * Constructor.
     */
    this (
        const string arg,
        const string[] args
    ) {
        filename = arg;
        content = args.dup;
    }



    /**
     * Determine whether the container is empty.
     *
     * Returns: `true` if the container is empty.
     */
    bool
    isEmpty () const
    {
        return content.length == 0;
    }
}

# Selective Unit Testing

A library for selective unit test execution; allows per unit test block and per
module execution.



## Rationale

The default unit testing behaviour implemented in D compilers is to execute all
unit tests.
It is designed to ensure that all unit tests pass; it is all or nothing.

Although it is possible to isolate a piece of code for testing, I feel that it
is sometimes a bit of an extra work specially when in the middle of
enhancements, refactorings or reimplementations of portions of code.

This library allows a piece of code to be tested in-place without being
concerned with non-related parts of the code base.



## Features

The library provides the following and still allows the programmer to opt-out
and revert to the default unit test execution behavior.

* __Unit Test Block Execution__

  Execute only a specific unit test block or a group of unit test blocks.

* __Module Unit Test Execution and Exclusion__

  Execute all unit test blocks in a module or exclude all unit test blocks
  in a module.



## Usage



### Incorporating the SUT Module

Use the `-I` compiler option and pass the path to the `sut` source code.

The following directory diagram is an example showing where the `sut`
module may be located.

~~~
...
`-- project
    |-- ...
    |-- build
    |   +-- sut.conf        // selective unit testing configuraiton file
    |-- extern
    |   |-- sut             // <----- this module
    |   `-- ...             // other external dependencies
    `-- src                 // <----- we are here
        |-- main.d
        |-- module_a.d
        |-- module_b.d
        |-- sut_wrapper.d   // sut wrapper module
        `-- ...
~~~



### Version Identifier

The _version identifier_ `sut` must be passed to the compiler.

~~~
$ dmd -version=sut
$ ldc --d-version=sut
$ ldmd2 -version=sut
~~~

Here is a command-line example of how the above may be compiled.

~~~
dmd                                 \
    -I=../../                       \  # Look for imports in project/
    -i                              \
    -main                           \
    -debug                          \
    -unittest                       \
    -version=sut                    \  # Version identifier for using this module
    -run                            \
    test.d
~~~



### Code Changes

The wrapper module must be imported.

~~~{escapechar=!}
...
version (unittest) {                // unit test conditional compilation block
    static import <your-module>.sut_wrapper;
}
...
~~~

Additionally, unit test blocks are required to be _named_ using
[`user-defined attribute`](https://dlang.org/spec/attribute.html#uda) (UDA).
The first UDA string will be used as the name for the unit test block.
This name can be used later to _filter_ execution.
See the _Unit Test Configuration File_ section below on how unit test UDA can
be used to filter unit test execution.

~~~{escapechar=!}
@("some name")                                      // unit test block names
unittest {
    mixin (<your-module>.sut_wrapper.prologue);     // unit test prologue
    ...
}
~~~



### Unit Test Configuration File

The _unit test configuration file_ contains the list of unit test blocks and modules
to be executed and those that are to be skipped.

The _unit test configuration file_ must follow these formatting rules:

* one item per line;
* empty lines and duplicates are ignored;
* unit test block names to be executed are prefixed with `utb:`;
* unit test block names to be skipped are prefixed with `xutb:`;
* module names to be executed are prefixed with `utm:`;
* module names to be skipped are prefixed with `xutm:`;



~~~
utb: <unit_test_block_name>
xutb: <unit_test_block_name>
utm: <module_name>
xutm: <module_name>
~~~

One or more _unit test configuration files_ may be passed using the command-line
option `--config` or `-c`:

~~~
-c<file>
-c <file>
--config=<file>
--config <file>
~~~



### Create the SUT Wrapper Module

The _wrapper module_ conditionally enables or disables the use of the library.
The library is enabled by the use of the version identifier `sut`.
See the _Version Identifier_ section below.

It is possible to use the library without using a _wrapper module_.
But using a _wrapper module_ makes it seemless to revert to the default unit
test execution.

~~~d
module sut_wrapper;

version (sut) {
    static if (__traits(compiles, { import sut; })) {
        /**
         * Conditionally compile-in the 'sut' module if it is visible in
         * the client code. Otherwise, it does nothing.
         */
        pragma (msg, "Using selective unit testing module.");

        /**
         * Unit test block prologue code mixed-in from unit test blocks.
         */
        enum prologue='mixin (sut_wrapper.unitTestBlockPrologue);';
    } else {
        pragma (msg, "Version identifier 'sut' defined but 'sut' module not found.");
        enum prologue="";
    }
} else {
    pragma (msg, "Using default unit test runner.");
    enum prologue="";
}
~~~



## Basic Usage Example

Let us begin with the _with_wrapper_ test program to demonstrate the basic use
of the library without unit test filtering and show the console output.
This test program has four D source files:

* `test.d` - main module with a couple of unit tests.
* `mul.d` - a module with a unit test to show per module and summary reporting
            output for such modules.
* `excluded.d` - a module with a unit test to show how to exclude a module from
                 unit test execution.
* `no_unittest.d` - a module without a unit test to show summary reporting
                    output for such modules.
* `no_prologue.d` - a module with a unit test but does not use the prologue code.
* `sut.conf` - unit test configuration file for this test program is empty
               which means there will be no filtering of unit tests.

The following are the contents of each file starting with the main module.

* __test.d__

  ~~~{escapechar=!}
  module test.with_wrapper.test;

  import sut;
  import test.with_wrapper.mul;
  import test.with_wrapper.no_prologue;
  import test.with_wrapper.no_unittest;
  import test.with_wrapper.excluded;
  version (unittest) {
      static import test.with_wrapper.sut_wrapper;        // import
  }

  int add (const int arg, const int n) {
      return arg + n;
  }
  @("add")
  unittest {
      mixin (test.with_wrapper.sut_wrapper.prologue);     // prologue code
      assert (add(10, 1) == 11);
  }

  int sub (const int arg, const int n) {
      return arg - n;
  }
  @("sub")
  unittest {
      mixin (test.with_wrapper.sut_wrapper.prologue);     // prologue code
      assert (sub(10, 1) == 9);
  }
  ~~~

* __mul.d__

  ~~~{escapechar=!}
  module test.with_wrapper.mul;

  import sut;
  version (unittest) {
      static import test.with_wrapper.sut_wrapper;        // import
  }

  size_t mul (const int arg, const int n) {
      return arg * n;
  }
  @("mul")
  unittest {
      mixin (test.with_wrapper.sut_wrapper.prologue);     // prologue code
      assert (mul(10, 2) == 20);
  }
  ~~~

* __excluded.d__

  ~~~{escapechar=!}
  module test.with_wrapper.excluded;

  import sut;
  version (unittest) {
      static import test.with_wrapper.sut_wrapper;        // import
  }

  int div (const int arg, const int n) {
      return arg / n;
  }
  @("div")
  unittest {
      mixin (test.with_wrapper.sut_wrapper.prologue);     // prologue code
      assert (div(10, 1) == 10);                          // never executed
  }
  ~~~

* __no_unittest.d__

  ~~~
  /**
   * Module without unit test.
   */
  module test.with_wrapper.no_unittest;
  ~~~

* __no_prologue.d__

  ~~~
  module test.with_wrapper.no_prologue;

  size_t square (const uint arg) {
      return arg * arg;
  }
  unittest {
      assert (square(10) == 100);
  }
  ~~~

Compile the source files using the following command:

~~~
$ dmd                               \
    -I=../..                        \
    -i                              \
    -main                           \
    -debug                          \
    -unittest                       \
    -version=sut                    \
    -run                            \
    test.d                          \
    --config=unittest.conf
~~~

Note that using the `ldc2` compiler, you may replace `dmd` with `ldmd2` which is
a wrapper that accepts dmd-style argument formats.


~~~
$ dmd                                 \
>     -I=../../                       \
>     -i                              \
>     -main                           \
>     -debug                          \
>     -unittest                       \
>     -version=sut                    \
>     -run                            \
>     test.d --config=unittest.conf
Using selective unit testing module.
[unittest] Start    2021-Apr-23 18:00:07.226723
[unittest]          Digital Mars D version 2.96
[unittest]          D specification version 2
[unittest] Mode:    All
[unittest] Module:  test.with_wrapper.test   15 add
[unittest]          test.with_wrapper.test   24 sub
[unittest]          test.with_wrapper.test - 2 passed, 0 failed, 2 found - 0.000s
[unittest] Module:  test.with_wrapper.mul   11 mul
[unittest]          test.with_wrapper.mul - 1 passed, 0 failed, 1 found - 0.000s
[unittest]          ========================================
[unittest] Summary: 3 passed, 0 failed, 3 found
[unittest]          3 module(s) with unit test
[unittest]          1 module(s) without unit test
[unittest]          1 module(s) excluded
[unittest] List:    Module(s) with unit test (3)
[unittest]          Module(s) without prologue code have asterisk (*)
[unittest]              test.with_wrapper.mul
[unittest]              test.with_wrapper.no_prologue *
[unittest]              test.with_wrapper.test
[unittest] List:    Module(s) without unit test (1)
[unittest]              test.with_wrapper.no_unittest
[unittest] List:    Module(s) excluded (1)
[unittest]              test.with_wrapper.excluded
[unittest] End      2021-Apr-23 18:00:07.2269942
~~~



## Selective Unit Test Block Execution Example

This example will be using the same _with_wrapper_ test program above.

Choose one of the unit test blocks names you wanted to execute.
Edit the _unit test configuration file_ and add an entry.

* `utb:add`
* `utb:sub`
* `utb:mul`

The _unit test configuration file_ should look something like:

~~~
utb:add
~~~

Compile the source files using the following command:

~~~
$ dmd                               \
    -I=../..                        \
    -i                              \
    -main                           \
    -debug                          \
    -unittest                       \
    -version=sut                    \
    -run                            \
    test.d                          \
    --config=unittest.conf
~~~

Choosing `utb:add` shows the following output:

~~~
Using selective unit testing module.
[unittest] Start    2021-Apr-23 18:02:56.9533576
[unittest]          Digital Mars D version 2.96
[unittest]          D specification version 2
[unittest] Mode:    Selection
[unittest]            block:  add
[unittest] Module:  test.with_wrapper.test   15 add
[unittest]          test.with_wrapper.test - 1 passed, 0 failed, 2 found - 0.000s
[unittest]          ========================================
[unittest] Summary: 1 passed, 0 failed, 3 found
[unittest]          3 module(s) with unit test
[unittest]          1 module(s) without unit test
[unittest]          1 module(s) excluded
[unittest] List:    Module(s) with unit test (3)
[unittest]          Module(s) without prologue code have asterisk (*)
[unittest]              test.with_wrapper.mul
[unittest]              test.with_wrapper.no_prologue *
[unittest]              test.with_wrapper.test
[unittest] List:    Module(s) without unit test (1)
[unittest]              test.with_wrapper.no_unittest
[unittest] List:    Module(s) excluded (1)
[unittest]              test.with_wrapper.excluded
[unittest] End      2021-Apr-23 18:02:56.9535918
~~~



## Selective Module Execution Example

This example will be using the same _with_wrapper_ test program above.

Choose one of the modules you wanted to execute.
Edit the _unit test configuration file_ and add an entry.

* `utm:test.with_wrapper.mul`
* `utm:test.with_wrapper.test`

The _unit test configuration file_ should look something like:

~~~
utm:test.with_wrapper.mul
~~~

Compile the source files using the following command:

~~~
$ dmd                               \
    -I=../..                        \
    -i                              \
    -main                           \
    -debug                          \
    -unittest                       \
    -version=sut                    \
    -run                            \
    test.d                          \
    --config=unittest.conf
~~~

Choosing `utm:test.with_wrapper.mul` shows the following output:

~~~
Using selective unit testing module.
[unittest] Start    2021-Apr-23 18:06:47.0770861
[unittest]          Digital Mars D version 2.96
[unittest]          D specification version 2
[unittest] Mode:    Selection
[unittest]            module: test.with_wrapper.mul
[unittest] Module:  test.with_wrapper.mul   11 mul
[unittest]          test.with_wrapper.mul - 1 passed, 0 failed, 1 found - 0.000s
[unittest]          ========================================
[unittest] Summary: 1 passed, 0 failed, 3 found
[unittest]          3 module(s) with unit test
[unittest]          1 module(s) without unit test
[unittest]          1 module(s) excluded
[unittest] List:    Module(s) with unit test (3)
[unittest]          Module(s) without prologue code have asterisk (*)
[unittest]              test.with_wrapper.mul
[unittest]              test.with_wrapper.no_prologue *
[unittest]              test.with_wrapper.test
[unittest] List:    Module(s) without unit test (1)
[unittest]              test.with_wrapper.no_unittest
[unittest] List:    Module(s) excluded (1)
[unittest]              test.with_wrapper.excluded
[unittest] End      2021-Apr-23 18:06:47.0774876
~~~



## Test Programs

The repository contains different test programs that are good enough to
demonstrate how to use this module.
The directory structure below shows where they can be found.
You can download or clone the repository and run the tests with the command
`../compile.sh test.d -- [-c<file>...]`.

~~~
...
`-- src
    |-- sut                     // this module
    |   ...
    `-- test                    // we are here
        |-- failing             // test with failed assertion
        |-- no_wrapper          // test of not using a 'wrapper' module
        |-- selective_block     // test of selective unit test block execution
        |-- selective_module    // test of selective module execution
        |-- with_wrapper        // test of using a 'wrapper' module
        `-- compile.sh          // compile script
~~~



## Compiler Compatibility

The following compilers have been tested under GNU/Linux only.
I do not currently have a Microsoft Windows machine to test it.

The oldest compiler used to execute the unit tests in this library is version
2.090.0.
It is not known what earlier versions can successfully compile and use the
library.

Latest versions of compilers to successfully compile and use the library are:
* [DMD 2.105.3](https://dlang.org/download.html#dmd)
* [LDC 1.33.0](https://github.com/ldc-developers/ldc/releases/tag/v1.33.0)



## Limitations

* Cannot be used with `-betterC`.
  The library cannot be used if D source is compiled without `ModuleInfo`.
  That includes source codes being compiled with the `-betterC` flag since the
  flag disables the use of `ModuleInfo`.
* Cannot be used with `@nogc`.
* Cannot be used with `nothrow`.
* Cannot be used with `pure`.



## Change Log

The detailed log of changes can be seen on [CHANGELOG.md](CHANGELOG.md) file.



## License

See the [LICENSE](LICENSE) file for license rights and limitations (MIT).

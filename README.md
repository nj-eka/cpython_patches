# CPython internals
Series of the experiments with **CPython** extensions for educational purposes.
___
## Preparing environment:
Based on the following references and articles:
- https://devguide.python.org
- https://realpython.com/cpython-source-code-guide/
- https://tenthousandmeters.com/blog/python-behind-the-scenes-4-how-python-bytecode-is-executed/
- https://www.devroom.io/2009/10/26/how-to-create-and-apply-a-patch-with-git/

**Host version**

1. Make fork of https://github.com/python/cpython
2. Make shallow clone of some stable branch from that fork (here v3.9.5 is used)
    > $ git clone --branch v3.9.5 --single-branch --depth 1 https://github.com/[user-id]/cpython cpy395 
3. Set current directory:
    > $ cd cpy395

    *The CPython source directory behaves like a virtual environment.
    When compiling CPython or modifying the source or the standard library, this all stays within the sandbox of the source directory.*

4. Compile **CPython** (on Linux):
    - first need to download and install (*make* , *gcc* , *configure*, and *pkgconfig*) with some additional dependencies:
        - **APT**-based systems:
        ```
        $ sudo apt-get update
        $ sudo apt-get build-dep python3.9 
        ```
        - **YUM**-based:
        ```
        $ sudo yum install yum-utils
        $ sudo yum-builddep python3
        ```

    - run configuration script, optionally enabling the debug hooks using *--with-pydebug* (and specifing install directory *--prefix=path/to/python* if needed - note: *make install* isn't used here)
        > $ ./configure [--with-pydebug]
    - build **CPython** binary by running the generated *Makefile*:
        > $ make -j -s
    - run tests:
        > $ ./python -m test -j
5. Apply patches:
    > $ git clone https://github.com/nj-eka/cpython_patches.git patches

    > $ git apply patches/cpy395/[patch-name].patch

    > $ make patchcheck

    > $ ./python -m test -j


**Docker version**
 - perform the above steps in docker:
    > $ git clone https://github.com/nj-eka/cpython_patches.git
    
    > $ cd cpython_patches

    > $ docker build --rm -t dicpy395 .
    
    > $ docker run -it --name dcpy395 -v $PWD/cpy395:/opt/cpy395/patches dicpy395
    
    >> root@02dfd15d5a61:/opt/cpy395# git apply patches/[patch-name].patch

    >> root@02dfd15d5a61:/opt/cpy395# make patchcheck

    >> root@02dfd15d5a61:/opt/cpy395# ./python
 ___
 ## Making patch
## + **Until**
Add new **until** statement.

Steps:
1) Add `until` stmt to Grammar in:
    - *Grammar/Grammar* (deprecated)
    - *Grammar/python.gram*
2) Make regen:
    > $ make regen-pegen
3) Modify func `compiler_until` to implement until's specifics in:
    - *Python/compile.c*
4) Check and make patch:
    > $ make patchcheck
    
    Run tests: 
    > $ ./python -m test -j

5) Build patch file:    
    > $ git diff --binary > cpy395_update_stmt.patch 

6) Use `until` statment in **python** interpreter:
    - Examples:
        ```
        $ ./python
        >>> until False:
        ...     print('Done')
        ...     break
        ... 
        Done
        >>> i = 0
        >>> until i > 2:
        ...     print(i)
        ...     i += 1
        ... 
        0
        1
        2
        ```
Usefull links:
- https://eli.thegreenplace.net/2010/06/30/python-internals-adding-a-new-statement-to-python/
- https://devguide.python.org/grammar/
___

## + **Increment / Decrement**
Add new `++` and `--` operators.

Steps:
1) Update Grammar: 
    - add new `incr_stmt` and `decr_stmt` to `expr_stmt` into:
        - *Grammar/Grammar* (deprecated)
    - add new tokens `++` and `--` into:
        - *Grammar/Tokens*

2) Make regens:
    > $ make regen-token

    > $ make regen-grammar

3) Update func `ast_for_expr_stmt` in:
    - *Python/ast.c*

4) Check, make, test and build patch:
    > $ make patchcheck
    
    > $ ./python -m test -j

    > $ git diff --binary > cpy395_indecrement_expr_stmt.patch     

5) Use `++`/`--`:
    - Run python with setting `oldparser` flag up
        > $ ./python -X oldparser
    - Examples:
        ```
        >>> i = 0
        >>> i++
        >>> i
        1
        >>> i--; i
        0
        ```


Usefull links:
- https://hackernoon.com/modifying-the-python-language-in-7-minutes-b94b0a99ce14
___
## + Opcode
Add new opcode for `LOAD_FAST` and `LOAD_CONST` combination.

Note: this patch works on previous versions of **python** as described below:
- https://blog.quarkslab.com/building-an-obfuscated-python-interpreter-we-need-more-opcodes.html
___


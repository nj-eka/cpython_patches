# CPython internals
A series of experiments with CPython extensions for educational purposes.
___
## Preparing environment:
Based on the following references:
- https://devguide.python.org
- https://realpython.com/cpython-source-code-guide/
- https://tenthousandmeters.com/blog/python-behind-the-scenes-4-how-python-bytecode-is-executed/
- https://www.devroom.io/2009/10/26/how-to-create-and-apply-a-patch-with-git/

**Host version**

1. Make fork for https://github.com/python/cpython
2. Make shallow clone of some stable branch from that fork (below v3.9.5 used)
    > git clone --branch v3.9.5 --single-branch --depth 1 https://github.com/nj-eka/cpython cpy395 
3. Set current directory:
    > cd cpy395

    *The CPython source directory behaves like a virtual environment.
    When compiling CPython or modifying the source or the standard library, this all stays within the sandbox of the source directory.*

4. Compile CPython (on Linux):
    - first need to download and install (*make* , *gcc* , *configure*, and *pkgconfig*) and some addtional dependencies:
        - APT-based systems:
        ```
        sudo apt install build-essential
        # sudo apt install build-dep python3.9 ->  E: Unable to locate package build-dep ...
        sudo apt-get update
        sudo apt-get build-dep python3.9 
        # sudo apt install libssl-dev zlib1g-dev libncurses5-dev \
        # libncursesw5-dev libreadline-dev libsqlite3-dev libgdbm-dev \
        # libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev libffi-dev
        ```
        - YUM-based systems
        ```
        sudo yum install yum-utils
        sudo yum-builddep python3
        ```

    - run configure script, optionally enabling the debug hooks using --with-pydebug
        > ./configure --with-pydebug
    - build CPython binary by running the generated Makefile:
        > make -j -s
    - tests:
        > ./python -m test -j
5. Apply patches:
    - Download these patches:
        > git clone https://github.com/nj-eka/cpython_patches.git patches
    - Apply patch:
        > git apply patches/[patch-name].patch
    - Run checks and tests
        > make patchcheck

        > ./python -m test -j
    - Have fun using patch

**Docker version**
 - perform the above steps in docker:
 > docker
 
 ___
 ## Making patch
## + Until
Add new `until` statement.

Steps:
1) Add `until` stmt to Grammar:
    - Grammar/Grammar (deprecated)
    - Grammar/python.gram
2) Make regen
    > make regen-pegen
3) Modify func `compiler_until` to implement until's specifics
    - Python/compile.c
4) Check and make patch
    > make patchcheck
    
    > git diff --binary > cpy395_update_stmt.patch 
5) Use `until`
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

## + Increment / Decrement
Add new `++` and `--` operators.

Steps:
1) Update Grammar: 
    - add new `incr_stmt` and `decr_stmt` to `expr_stmt`
        - Grammar/Grammar (deprecated)
    - add new tokens `++` and `--`:
        - Grammar/Tokens
2) Make regens:
    > make regen-token

    > make regen-grammar
3) Update func `ast_for_expr_stmt`:
    - Python/ast.c
4) Check and make patch
    > make patchcheck
    
    > git diff --binary > cpy395_indecrement_expr_stmt.patch     
4) Use ++/--:
    - Run python with setting `oldparser` flag up
        > ./python -X oldparser
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
Add new opcode (`LOAD_FAST` and `LOAD_CONST` combination).

Usefull links:
- https://blog.quarkslab.com/building-an-obfuscated-python-interpreter-we-need-more-opcodes.html
___


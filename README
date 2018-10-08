Quick start:

1. Edit the configuration defs at the top of wren.c and in wren.h

2. make

3. ./check-examples

5. ./build
   (This makes a stripped executable optimized for size.)

4. ./benchmark
   Notice how much faster it is than Python! Gee whiz.

6. Look over the examples file to get an idea what you can do.
   (It was mainly written as a basic test suite though.)

7. Look over (Todd's) TODO to see all the stuff not done.

8. Look over (Doug's) e_notes.txt for bugs and planned tasks.

One thing that's probably not obvious is that you can define arrays
or other dynamic data structures in a Wren program. The thing is, you
have to use peek and poke. But you can allocate the space for it so
the interpreter doesn't step all over it, by incrementing the 'cp'
variable (short for compiler_ptr, its name at the C level). Same 
basic idea as ALLOT in Forth: get the current value of cp as the 
starting address for your data structure, then increment cp by its
size.

Have fun!

Note:

Some of the examples, such as boot.wren and disasm.wren are written
assuming a little-endian machine. This should be fixed soon.

tinyelf
=======
This is an example of how to create a very minimal (but still valid) ELF
executable using nothing but an assembler (NASM). No system linker required.

Technical Details
-----------------
In a typical ELF file there are several data structures: the ELF header,
program headers, section headers, and multiple sections containing data (.text
for code, .data for data, string tables, etc.).

For just executing code, most of these data structures are not necessary. In
this example, there is just the ELF header (52 bytes); a single program header
(32 bytes), which identifies the offset of the code, how big the code is, and
where it should be loaded to in virtual memory; and of course, the code
itself. Combined, the headers only take 84 bytes of space in the resulting
executable.

Even more extreme reductions in size can be achieved by re-purposing parts of
the headers that are unchecked by the OS program loader. For instance, it is
possible to store code inside the ELF header padding and some other fields.


# y86-64 processor in Verilog

We implement a pipelined version of the x86-64 processor with multiple features such as countering data dependencies using data forwarding and bubble/stall methods. The pipelined version of this processor consist of the following files:-
* `fetch.v` consisting of fetch module 
* `decode.v` consisting of decode and writeback modules 
* `execute.v` consisting of execute module
* `memory.v` consisting of memory module and the main memory as well
* `pipe_control.v` consisting of logic for handling stalls and bubbles


# How to use?

Write in the Machine code for the program you want to run in the `instr_mem`  array of the fetch module. Note that the machine code should follow x-86-64 Instruction set Architecture only. Then, run `processor.v` using the following commands in terminal :-
> iverilog -o run processor.v
> vvp run


## To view GTKWave
The testbench also generates a GTKwave showing pulse diagram of all the signals. To view it, run the following commands after running the above command on the terminal in the main (pipeline) directory.
> gtkwave processor.vcd


# y86 64-bit Processor in Verilog

The project involves the implementation of Y86-64 processor architecture design using Verilog. The final goal is to achieve a 5 state pipelined implementation of the processor. This report includes the sequential and the pipelined implementation of the Y86-64 processor which contains the fetch, decode - write back , execute, memory and the PC update blocks, their testbenches and the combined testbench along with data forwarding and support for eliminating pipeline hazards. The following 2 designs are implemented :-

 1. **Sequential :** The sequential implementation of the Y86-64 processor works with fetch, decode, execute, memory, writeback and PC update. In this implementation, only one instruction will be there in whole architecture in one clock cycle. 
 2. **5-stage Pipelined :** The pipelined implementation of the Y86-64 works the same way as that of the sequential implementation with the modules being same but with inclusion of the pipelined registers, slight change in the fetch and decode blocks, addition of support for data forwarding and PC prediction for improving the performance and the addition of the pipeline control logic for eliminating pipeline hazards. This type implementation increases throughput but increases latency which is a trade-off.

## Pipeline Stages
The 5 pipeline stages used in the pipelined implementation of the processor are :-

 1. **Fetch** involves fetching the instruction along with the data and register values from the `instr_mem` according to the current Program Counter
 2. **Decode** decrypts the recieved instruction data according to the instruction type
 3. **Memory** performs operations that require writing into the Main Memory
 4. **WriteBack** performs operations that require writing into the register array
 5. **PC Update** updates the Program counter according to the instruction and some other conditions.

Based on the above stages and the clock frequency used in the code, the throughput can be calculated as :- 
$$throughput\ =\frac{1}{T_{cycle}}=\frac{1}{20ns}=5\cdot10^{7}ips=50Mips$$

## Additional Features
1. **Data Dependencies :** We might need some register value in an instruction even before write back writes the data into the instruction. To handle this, we use the fact that the data is still somewhere in the pipeline. Therefore, we directly forward the data from that stage to the decode stage of the instruction to use it directly. 

2. **Load Use Hazard :** If a data is written to a register in some instruction, and then, later used by some other instruction even before the 1st instruction writes the data into the register, we might end up using the old data in the register and mess up the program. To handle these type of situations a bubble is introduced in the appropriate stage while stalling the previous stages, thereby, waiting for the data to arrive after which we can forward it. 
3. **Jump Mis-Prediction :** We are assuming that the conditional jump is taken. This works well for almost 60% of the cases and fails for the rest 40%. In case of failure, which is detected only when the jump instruction reaches the execute stage (where the conditional codes are being set), we must get rid of the 2 stray instructions (not to be executed) which enter the pipeline. We do so by introducing bubbles in the appropriate stages.
4. **Return Instruction :** In case of a ret instruction, we can never predict the target location as we did in jump. Therefore, we compulsorily have to stall/bubble the instruction succeeding ret instructions and wait till the ret instruction reaches the memory stage, to find out the exact target location.

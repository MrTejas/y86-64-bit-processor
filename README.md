# Intro to Processor Architecture - Project (Spring 2023)

## 1.Overall Goal (Total Marks - 100)

Each group (2 students) must develop a processor architecture design based on the Y86 ISA using Verilog. The design
should be thoroughly tested to satisfy all the specification requirements using simulations. The project submission
must include the following

- A report describing the design details of the various stages of the processor architecture, the supported features
(including simulation snapshots of the features supported) and the challenges encountered. (Marks-15)
- Verilog code for processor design and testbench

## 2.Specifications

The required specifications in the processor design are as follows:

- A bare minimum processor architecture must implement a sequential design as discussed in Section 4.3 of
textbook. (Marks-25)
- A full fledged processor architecture implementation with 5 stage pipeline as discussed in Sections 4.4 and 4.5
of textbook, which includes support for eliminating pipeline hazards. (Marks-40)

Your submission should at least have the first design mentioned above in order to get minimal marks. However, your
goal should be to submit a design with pipelined architecture so that you score maximum marks.

### Important points to notice:
- Both the above implementations must execute all the instructions from Y86 ISA except call and retinstructions
to get the above mentioned marks.
- Additional marks if you also execute call and ret instructions. (Marks-10)

## 3.Design Approach
The design approach should be modular, i.e., each stage has to be coded as separate modules and tested independently
in order to help the integration without too many issues.


## 4.Targets and Evaluation

Each group will be evaluated twice during the project - firstly on Feb 20. (Marks-10)

The final evaluation will happen in the 1st week of March (dates will be announced later).

## 5.Suggestions for Design Verification

Please adhere to the following verification approaches as much as possible.
- You can individually test each stage/module for its intended functionality by creating module specific test
inputs.
- Please write an assembly program for any algorithm (e.g., sorting algorithm) using Y86 ISA and the corresponding encoded instructions and use the encoded instructions to test your integrated design.
- If possible, you can also think of an automated testbench that will help you to verify your design efficiently, i.e., automatically verify the state of the processor and memory after execution of each instruction in the program.

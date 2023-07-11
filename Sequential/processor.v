`include "./ADD/ADDx64.v"
`include "./ADD/ADDx1.v"
`include "./SUB/SUBx64.v"
`include "./SUB/SUBx1.v"
`include "./XOR/XORx64.v"
`include "./AND/ANDx64.v"
`include "ALU.v"
`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "pc_update.v"

module processor;
    reg clk;
    reg [63:0] PC;
    wire [3:0] icode, ifun, rA, rB;
    wire signed [63:0] valA, valB, valC, valE, valM, valP;
    wire [63:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14;
    wire instr_invalid, mem_error, mainmem_error;
    wire cnd;
    wire[2:0]cc_out;
    reg [0:79] instr;

    reg [2:0]cc_in;
    reg [7:0] instr_memory[0:255];
    wire [63:0] PC_new;


fetch fcall(clk, PC, instr, icode, ifun, rA, rB, valC, valP, mem_error, instr_invalid);
decode dcall(clk, icode, ifun, rA, rB, valA, valB, valM, valE, cnd, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14);
execute ecall(clk, icode, ifun, valA, valB, valC, cc_in, valE, cnd, cc_out);

always @(posedge clk)
begin 
    if(icode == 4'b0110)
    begin 
        cc_in <= cc_out;
    end
end

memory mcall(clk, icode, valA, valE, valM, valP, mainmem_error);
pc_update pcall(clk, icode, cnd, PC_new, valC, valM, valP);

always @(PC)  // whenever PC changes, new instr is loaded
begin
    instr = {instr_memory[PC],instr_memory[PC+1],instr_memory[PC+2],
            instr_memory[PC+3],instr_memory[PC+4],instr_memory[PC+5],
            instr_memory[PC+6],instr_memory[PC+7],instr_memory[PC+8],
            instr_memory[PC+9]};  
end


always @(icode) begin
    if(icode==0 && ifun==0) 
      $finish;
  end

always@(mem_error)
begin 
    if(mem_error == 1)
    begin
        $display("Memory Error!");
        $finish;
    end
end

always@(instr_invalid)
begin 
    if(instr_invalid == 1)
    begin
        $display("Invalid Instruction!");
        PC = PC +1;
    end
end

always #10 clk = ~clk;
always @(*)
begin
    PC <= PC_new;
end

initial begin
    $dumpfile("processor.vcd");
    $dumpvars(0, processor);
    clk = 0;
    PC = 64'd0;
end

always @(posedge clk)
begin
    $display("clk=%d PC=%d icode=%b ifun=%b rA=%b rB=%b valA=%d valB=%d valC=%d valE=%b valM=%d valP=%d Z_F=%d cnd=%d mainmemerr=%b\n",clk,PC,icode,ifun,rA,rB,valA,valB,valC,valE,valM,valP,cc_in[0],cnd,mainmem_error);
end

initial begin
    cc_in = 3'd0;
    instr_memory[0]=8'h30; //3 0
    instr_memory[1]=8'hF6; //F rB=0
    instr_memory[2]=8'h00;           
    instr_memory[3]=8'h00;           
    instr_memory[4]=8'h00;           
    instr_memory[5]=8'h00;           
    instr_memory[6]=8'h00;           
    instr_memory[7]=8'h00;           
    instr_memory[8]=8'h00;          
    instr_memory[9]=8'hff; //V=255

    instr_memory[10]=8'h30;
    instr_memory[11]=8'hF7;
    instr_memory[12]=8'h00;           
    instr_memory[13]=8'h00;           
    instr_memory[14]=8'h00;           
    instr_memory[15]=8'h00;           
    instr_memory[16]=8'h00;           
    instr_memory[17]=8'h00;           
    instr_memory[18]=8'h00;          
    instr_memory[19]=8'h1f; //V=31

    instr_memory[20]=8'h20;
    instr_memory[21]=8'h76;

    instr_memory[22] = 8'h40;       //rmmovq instruction
    instr_memory[23] = 8'h53;
    {instr_memory[24],instr_memory[25],instr_memory[26],instr_memory[27],instr_memory[28],instr_memory[29],instr_memory[30],instr_memory[31]} = 64'd0;

    instr_memory[32] = 8'h50;       //mrmovq instruction
    instr_memory[33] = 8'h53;
    {instr_memory[34],instr_memory[35],instr_memory[36],instr_memory[37],instr_memory[38],instr_memory[39],instr_memory[40],instr_memory[41]} = 64'd0;

    instr_memory[42] = 8'h60;       //add instruction
    instr_memory[43] = 8'h9A;

    instr_memory[44] = 8'h10;       // nop

    instr_memory[45] = 8'h10;       // nop

    instr_memory[46] = 8'h10;       // nop

    instr_memory[47] = 8'h10;       // nop

    instr_memory[48] = 8'h00;       // halt

end

endmodule
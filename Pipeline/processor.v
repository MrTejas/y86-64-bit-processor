`include "pipe_control.v"
`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "ALU.v"
`include "./ADD/ADDx64.v"
`include "./ADD/ADDx1.v"
`include "./SUB/SUBx64.v"
`include "./SUB/SUBx1.v"
`include "./XOR/XORx64.v"
`include "./AND/ANDx64.v"

module processor;

reg clk;

// no need for fetch pipe registers as they are present in the fetch module itself
// input and output predicted PC for fetch
reg [63:0] F_predictedPC;
wire [63:0] f_predictedPC;
reg [0:3] stat = 4'b1000;


//-------------------DECODE--------------------
// decode pipe registers
wire [3:0] D_icode, D_ifun, D_rA, D_rB;
wire signed [63:0] D_valC, D_valP;
wire [0:3] D_stat;
// decode signals
wire [3:0] d_srcA, d_srcB;


//-------------------EXECUTE--------------------
// execute pipe registers
wire [3:0] E_icode, E_ifun;
wire signed [63:0] E_valA, E_valB, E_valC;
wire [3:0] E_srcA, E_srcB, E_dstE, E_dstM;
wire [0:3] E_stat;
// execute signals
wire [3:0] e_dstE;
wire signed [63:0] e_valE;
wire e_cnd;

//-------------------MEMORY--------------------
// memory pipe registers
wire [3:0] M_icode, M_dstE, M_dstM;
wire signed [63:0] M_valA, M_valE;
wire [0:3] M_stat;
wire M_cnd;
// memory signals
wire signed [63:0] m_valM;
wire [0:3] m_stat;

//-------------------WRITEBACK-----------------
// writeback pipe registers
wire [0:3] W_stat; 
wire [3:0] W_icode, W_dstE, W_dstM;
wire signed [63:0] W_valE, W_valM;



//-------------REGISTER FILE-------------------
wire signed [63:0] R0,R1,R2,R3,R4,R5,R6,R7,                       
            R8,R9,R10,R11,R12,R13,R14;


//-----------STALLS AND BUBBLES----------------
wire F_stall, D_stall, D_bubble, E_bubble, M_bubble, W_stall, set_cc;

// clock of T = 20
always #10 clk = ~clk;

// --------------Linking Modules Together--------
fetch fetch(
    .D_stat(D_stat),.D_icode(D_icode),.D_ifun(D_ifun),.D_rA(D_rA),
    .D_rB(D_rB),.D_valC(D_valC),.D_valP(D_valP),
    .f_predictedPC(f_predictedPC),
    .M_icode(M_icode),.M_cnd(M_cnd),.M_valA(M_valA),
    .W_icode(W_icode),.W_valM(W_valM),
    .F_predictedPC(F_predictedPC),
    .clk(clk),
    .F_stall(F_stall),.D_stall(D_stall),.D_bubble(D_bubble)
    );

  decode decode(
    .E_bubble(E_bubble),
    .clk(clk),
    .D_stat(D_stat),.D_icode(D_icode),.D_ifun(D_ifun),.D_rA(D_rA),
    .D_rB(D_rB),.D_valC(D_valC),.D_valP(D_valP),
    .e_dstE(e_dstE),.M_dstE(M_dstE),.M_dstM(M_dstM),.W_dstE(W_dstE),.W_dstM(W_dstM),
    .e_valE(e_valE),.M_valE(M_valE),.m_valM(m_valM),.W_valE(W_valE),.W_valM(W_valM),.W_icode(W_icode),
    .E_stat(E_stat),.E_icode(E_icode),.E_ifun(E_ifun),.E_valC(E_valC),.E_valA(E_valA),.E_valB(E_valB),
    .E_dstE(E_dstE),.E_dstM(E_dstM),.E_srcA(E_srcA),.E_srcB(E_srcB),
    .d_srcA(d_srcA),.d_srcB(d_srcB),
    .R0(R0),.R1(R1),.R2(R2),.R3(R3),.R4(R4),
    .R5(R5),.R6(R6),.R7(R7),.R8(R8),.R9(R9),
    .R10(R10),.R11(R11),.R12(R12),.R13(R13),.R14(R14)
    );

  execute execute(
    .M_stat(M_stat),.M_icode(M_icode),.M_cnd(M_cnd),.M_valE(M_valE),.M_valA(M_valA),.M_dstE(M_dstE),.M_dstM(M_dstM),
    .e_valE(e_valE),.e_dstE(e_dstE),
    .E_stat(E_stat),.E_icode(E_icode),.E_ifun(E_ifun),.E_valC(E_valC),.E_valA(E_valA),.E_valB(E_valB),.E_dstE(E_dstE),.E_dstM(E_dstM),
    .e_cnd(e_cnd),.m_stat(m_stat),
    .W_stat(W_stat),
    .clk(clk),
    .set_cc(set_cc)
    );


  memory memory(
    .W_stat(W_stat),.W_icode(W_icode),.W_valE(W_valE),.W_valM(W_valM),.W_dstE(W_dstE),.W_dstM(W_dstM),
    .m_valM(m_valM),.m_stat(m_stat),
    .M_stat(M_stat),.M_icode(M_icode),.M_cnd(M_cnd),.M_valE(M_valE),.M_valA(M_valA),.M_dstE(M_dstE),.M_dstM(M_dstM),
    .clk(clk)
    );

  pipe_control pipe_control(
    .F_stall(F_stall),.D_stall(D_stall),.D_bubble(D_bubble),.E_bubble(E_bubble),.W_stall(W_stall),.set_cc(set_cc),
    .D_icode(D_icode),.d_srcA(d_srcA),.d_srcB(d_srcB),.E_icode(E_icode),.E_dstM(E_dstM),.e_cnd(e_cnd),.M_icode(M_icode),.m_stat(m_stat),.W_stat(W_stat)
    );



// stopping program based on error flags from stat
always @(stat)
begin
    case (stat)
        4'b0001:
        begin
            $display("Invalid Instruction Encounterd, Stopping!");
            $finish;
        end
        4'b0010:
        begin
            $display("Memory Leak Encounterd, Stopping!");
            $finish;
        end
        4'b0100:
        begin
            $display("Halt Encounterd, Halting!");
            $finish;
        end
        4'b1000:
        begin
            // All OK (No action required)
        end
    endcase    
end

// each instruction ends at writeback stage
// thus the status codes for stopping the program must be seen at the end of each instruction
// that is why the last stage (writeback) is used for checking the status codes
always @(W_stat)
begin
    stat = W_stat;
end


// PC update based on predicted PC at every pos edge
always @(posedge clk )
begin
    F_predictedPC = f_predictedPC;    
end

initial begin
    $dumpfile("processor.vcd");
    $dumpvars(0,processor);
    F_predictedPC = 64'd0;
    clk = 0;
    // $monitor("clk=%d f_predictedPC=%d F_predictedPC=%d D_icode=%d,E_icode=%d, M_icode=%d, ifun=%d,rax=%d,rdx=%d,rbx=%d,rcx=%d\n",clk,f_predictedPC,F_predictedPC, D_icode,E_icode,M_icode,D_ifun,R0,R2,R3,R1);
    $monitor("clk=%d f_predictedPC=%d F_predictedPC=%d D_icode=%d,E_icode=%d, M_icode=%d, m_valM=%d, f_stall=%d, ifun=%d, R1=%d, R2=%d, R3=%d, R4=%d, R5=%d, R6=%d, R7=%d, R8=%d, R9=%d, R10=%d, R11=%d, R12=%d, R13=%d, R14=%d, e_valE=%d\n",clk,f_predictedPC,F_predictedPC, D_icode,E_icode,M_icode,m_valM,F_stall,D_ifun,R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, e_valE);

end

endmodule
module decode (
    clk,
    D_icode,D_ifun,D_rA, D_rB, D_valC, D_valP,
    R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,
    D_stat,
    d_srcA, d_srcB,

    E_icode, E_ifun, E_valC, E_valA, E_valB,
    E_srcA, E_srcB, E_dstE, E_dstM,
    E_stat,
    E_bubble,

    e_dstE, e_valE,
    M_dstE, M_valE,
    M_dstM, m_valM, 
    W_dstE, W_valE,
    W_dstM, W_valM,
    W_icode
);

input clk;
input [3:0] D_icode, D_ifun, D_rA, D_rB;
input signed [63:0] D_valC, D_valP;                                // pipe registers for decode stage (input)
output reg signed [63:0] R0,R1,R2,R3,R4,R5,R6,R7,                     // Register file
                R8,R9,R10,R11,R12,R13,R14;
input [0:3] D_stat;                                             // status code for decode
output reg[3:0] d_srcA, d_srcB;                                 // srcA, and srcB for decode stage (to be calculated here)

output reg [3:0] E_icode, E_ifun;                               // pipe registers for execute stage (output)
output reg signed [63:0] E_valA, E_valB, E_valC;
output reg [3:0] E_srcA, E_srcB, E_dstE, E_dstM;  
output reg [0:3] E_stat;
input E_bubble;                                                 // bubble flag for execute stage

input [3:0] e_dstE, M_dstE, M_dstM, W_dstE, W_dstM, W_icode;    // registers used for data forwarding in different cases
input signed [63:0] e_valE, M_valE, m_valM, W_valE, W_valM;            // values used in data forwarding in different cases

reg [3:0] d_dstE, d_dstM;
reg [63:0] d_valA, d_valB;                                      // d_valX = actual valX calculated in decode stage
reg [63:0] d_rvalA, d_rvalB;                                    // d_rvalX = valX if no data forwarding is required
reg [63:0] register[0:14];                                      // array of registers used in this module for indexing (as verilog doesnot allow passing it as parameter)


// assigning random (no significance) values to the registers initially
initial
begin
    register[0] = 64'd12;        //rax
    register[1] = 64'd10;        //rcx
    register[2] = 64'd101;       //rdx
    register[3] = 64'd3;       //rbx
    register[4] = 64'd254;       //rsp
    register[5] = 64'd50;        //rbp
    register[6] = -64'd143;      //rsi
    register[7] = 64'd10000;     //rdi
    register[8] = 64'd990000;    //r8
    register[9] = -64'd12345;    //r9
    register[10] = 64'd12345;    //r10
    register[11] = 64'd10112;    //r11
    register[12] = 64'd0;        //r12
    register[13] = 64'd1567;     //r13
    register[14] = 64'd8643;     //r14
end


// implementing data forwarding
always @(*) 
begin

    // forwarding data for valA
    if (D_icode==4'h8 | D_icode==4'h7)          // use the incremented PC (for hump and call)
    begin
        d_valA = D_valP;
    end
    else if (d_srcA == e_dstE & e_dstE!=4'hF)   // forward valE from execute
    begin
        d_valA = e_valE;
    end
    else if (d_srcA == M_dstM & M_dstM!=4'hF)   // forward valM from memory
    begin
        d_valA = m_valM;
    end
    else if (d_srcA == M_dstE & M_dstE!=4'hF)   // forward valE from memory
    begin
        d_valA = M_valE;
    end
    else if (d_srcA == W_dstM & W_dstM!=4'hF)   // forward valM from writeback
    begin
        d_valA = W_valM;
    end
    else if (d_srcA == W_dstE & W_dstE!=4'hF)   // forward valE from writeback
    begin
        d_valA = W_valE;
    end
    else                                         // use value read from register
    begin
        d_valA = d_rvalA;
    end



    // forwarding data for valB
    /*if (D_icode==4'h9 | D_icode==4'h7)  // use the incremented PC
    begin
        d_valB = D_valP;
    end*/
    if (d_srcB == e_dstE & e_dstE!=4'hF)          // forward valE from execute
    begin
        d_valB = e_valE;
    end
    else if (d_srcB == M_dstM & M_dstM!=4'hF)          // forward valM from memory
    begin
        d_valB = m_valM;
    end
    else if (d_srcB == M_dstE & M_dstE!=4'hF)          // forward valE from memory
    begin
        d_valB = M_valE;
    end
    else if (d_srcB == W_dstM & W_dstM!=4'hF)          // forward valM from writeback
    begin
        d_valB = W_valM;
    end
    else if (d_srcB == W_dstE & W_dstE!=4'hF)          // forward valE from writeback
    begin
        d_valB = W_valE;
    end
    else                                // use value read from register
    begin
        d_valB = d_rvalB;
    end
end


// assigning src_A and src_B according to icode for decode stage
// also assigning dstE dstM according to icode for writeback stage
always @(*) 
begin
    if (D_icode==4'h0)      // halt
    begin
        // no decode or writeback in halt
    end 
    else if (D_icode==4'h1) // nop
    begin
        // no decode or writeback in nop
    end
    else if (D_icode==4'h2)      // cmovXX rA, rB
    begin
        d_srcA = D_rA;
        d_dstE = D_rB;
    end 
    else if (D_icode==4'h3) // irmovq V, rB
    begin
        d_dstE = D_rB;
    end
    else if (D_icode==4'h4) // rmmovq rA, D(rB)
    begin
        d_srcA = D_rA;
        d_srcB = D_rB;
    end
    else if (D_icode==4'h5) // mrmovq D(rB), rA
    begin
        d_srcB = D_rB;
        d_dstM = D_rA;
    end
    else if (D_icode==4'h6) // OPq rA, rB
    begin
        d_srcA = D_rA;
        d_srcB = D_rB;
        d_dstE = D_rB;
    end
    else if (D_icode==4'h7) // jXX Dest
    begin
        // no decode or writeback in jump
    end
    else if (D_icode==4'h8) // call Dest
    begin
        d_srcB = 4;
        d_dstE = 4;
    end
    else if (D_icode==4'h9) // ret
    begin
        d_srcA = 4;
        d_srcB = 4;
        d_dstE = 4;
    end
    else if (D_icode==4'hA) // pushq rA
    begin
        d_srcA = D_rA;
        d_srcB = 4;
        d_dstE = 4;
    end
    else if (D_icode==4'hB) // popq rA
    begin
        d_srcA = 4;
        d_srcB = 4;
        d_dstE = 4;
        d_dstM = D_rA;
    end
    else                    // not a valid instruction, therefore initializ by F
    begin
        d_srcA = 4'hF;
        d_srcB = 4'hF;
        d_dstE = 4'hF;
        d_dstM = 4'hF;
    end
end

// evaluating tentative valA and valB according to icode and srcA, srcB
always @(*) 
begin
    case (D_icode)
    4'h0: 
    begin
        // no decode stage here
    end
    4'h1: 
    begin
        // no decode stage here
    end
    4'h2: 
    begin
        d_rvalA = register[D_rA];
        d_rvalB = 64'b0;
    end
    4'h3: 
    begin
        d_rvalB = 64'b0;
    end
    4'h4: 
    begin
        d_rvalA = register[D_rA];
        d_rvalB = register[D_rB];
    end
    4'h5: 
    begin
        d_rvalB = register[D_rB];
    end
    4'h6: 
    begin
        d_rvalA = register[D_rA];
        d_rvalB = register[D_rB];
    end
    4'h7:
    begin
        // no decode stage here
    end
    4'h8:
    begin
        d_rvalB = register[4];
    end
    4'h9:
    begin
        d_rvalA = register[4];
        d_rvalB = register[4];
    end
    4'hA:
    begin
        d_rvalA = register[D_rA];
        d_rvalB = register[4];
    end
    4'hB:
    begin
        d_rvalA = register[4];
        d_rvalB = register[4];
    end
endcase
end


// at positive edge, assigning all the values to Execute Register (next stage)
always @(posedge clk )
begin
    if (E_bubble==1'b1) // bubble needs to be introduced in execute stage
    begin
        E_icode <= 4'h1;
        E_ifun <= 4'h0;
        E_valC <= 4'h0;
        E_valA <= 4'h0;
        E_valB <= 4'h0;
        E_dstE <= 4'hF;
        E_dstM <= 4'hF;
        E_srcA <= 4'hF;
        E_srcB <= 4'hF;
        E_stat <= 4'h8;
    end    
    else                // pass the values as they are in decode stage
    begin
        E_icode <= D_icode;
        E_ifun <= D_ifun;
        E_srcA <= d_srcA;
        E_srcB <= d_srcB;
        E_dstE <= d_dstE;
        E_dstM <= d_dstM;
        E_valA <= d_valA;
        E_valB <= d_valB;
        E_valC <= D_valC;
        E_stat <= D_stat;
    end
end

// writeback to register at W_dstE or W_dstM based on W_icode
always @(posedge clk )
begin
    case (W_icode)
    4'h0: 
    begin
        // no writeback stage here
    end
    4'h1: 
    begin
        // no writeback stage here
    end
    4'h2: 
    begin
        register[W_dstE] = W_valE;
    end
    4'h3: 
    begin
        register[W_dstE] = W_valE;
    end
    4'h4: 
    begin
        // no writeback stage here
    end
    4'h5: 
    begin
        register[W_dstM] = W_valM;
    end
    4'h6: 
    begin
        register[W_dstE] = W_valE;
    end
    4'h7:
    begin
        // no writeback stage here
    end
    4'h8:
    begin
        register[W_dstE] = W_valE;
    end
    4'h9:
    begin
        register[W_dstE] = W_valE;
    end
    4'hA:
    begin
        register[W_dstE] = W_valE;
    end
    4'hB:
    begin
        register[W_dstE] = W_valE;
        register[W_dstM] = W_valM;
    end
endcase     
end

// writing back to the register file at the positive edge of the clock
always @(posedge clk )
begin
    R0 <= register[0];
    R1 <= register[1];
    R2 <= register[2];
    R3 <= register[3];
    R4 <= register[4];
    R5 <= register[5];
    R6 <= register[6];
    R7 <= register[7];
    R8 <= register[8];
    R9 <= register[9];
    R10 <= register[10];
    R11 <= register[11];
    R12 <= register[12];
    R13 <= register[13];
    R14 <= register[14];
end

endmodule
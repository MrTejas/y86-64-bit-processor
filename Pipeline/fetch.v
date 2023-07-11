module fetch (
    clk,
    F_stall,
    F_predictedPC,
    M_icode, W_icode, M_valA, W_valM, M_cnd, // for misprediction recovery
    f_predictedPC,

    D_stall,
    D_bubble,
    D_icode, D_ifun,
    D_rA, D_rB,
    D_valC, D_valP,
    D_stat
);

input clk;
input F_stall, D_stall, D_bubble, M_cnd;            // stall and bubble and cnd flags 
input [3:0] M_icode, W_icode;                       // used for checking misprediction of branch
input [63:0] M_valA, W_valM, F_predictedPC;         // used for checking misprediction of branch and input predicted pc


output reg [63:0] f_predictedPC;                    // output predicted pc
output reg [3:0] D_icode, D_ifun, D_rA, D_rB;       // pipe registers in decode
output reg signed [63:0] D_valC, D_valP;            // pipe registers in decode
output reg [0:3] D_stat;                            // status code for decode stage: AllOK, Halt, Adr_error, Instruction_error

reg [3:0] icode, ifun, rA, rB;                      // same as in sequential
reg [63:0] valC, valP;
reg [0:3] stat;                                     // status code for fetch stage: AllOK, Halt, Adr_error, Instruction_error

reg [7:0] instr_mem[0:4096];
reg [0:79] instruction;
reg [63:0] PC;
reg imem_error = 1'b0;
reg instr_invalid = 1'b0;


// ---------------------------------------------------------------------------------------------------------

// finding out instruction from instruction mem and then icode, ifun
always @(*)
begin
    instruction = {instr_mem[PC],
                    instr_mem[PC+1],
                    instr_mem[PC+2],
                    instr_mem[PC+3],
                    instr_mem[PC+4],
                    instr_mem[PC+5],
                    instr_mem[PC+6],
                    instr_mem[PC+7],
                    instr_mem[PC+8],
                    instr_mem[PC+9]
                    };

    icode = instruction[0:3]; // first 4 bytes are icode
    ifun = instruction[4:7]; // next 4 bytes are i fun
end

// ---------------------------------------------------------------------------------------------------------

// finding out stat flags for fetch state
always @(*)
begin
    if (instr_invalid)
    stat = 4'h1;
    else if (imem_error)
    stat = 4'h2;
    else if (icode==4'h0)
    stat = 4'h4;
    else 
    stat = 4'h8;
end

// ---------------------------------------------------------------------------------------------------------

// finding rA, rB, valC, valP, and f_predictedPC
always @(*)
begin
    if(icode==4'h0)
    begin
        valP = PC;
        f_predictedPC=valP;
    end
    else if (icode==4'h1)           // nop instruction
    begin
        valP = PC+1;
        f_predictedPC = valP;
    end
    else if (icode==4'h3)           // irmovq V, rB
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valC = instruction[16:79];
        valP = PC+10;
        f_predictedPC = valP;
    end
    else if (icode==4'h4)           // rmmovq rA, D(rB)
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valC = instruction[16:79];
        valP = PC+10;
        f_predictedPC = valP;
    end
    else if (icode==4'h5)           // mrmovq D(rB), rA
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valC = instruction[16:79];
        valP = PC+10;
        f_predictedPC = valP;
    end
    else if (icode==4'h2)           // cmovxx rA, rB
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valP = PC+2;
        f_predictedPC = valP;
    end
    else if (icode==4'h6)           // OPq rA, rB
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valP = PC+2;
        f_predictedPC = valP;
    end
    else if (icode==4'hA)           // pushq rA
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valP = PC+2;
        f_predictedPC = valP;
    end
    else if (icode==4'hB)           // popq rA
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valP = PC+2;
        f_predictedPC = valP;
    end
    else if (icode==4'h7)           // jXX Dest
    begin
        valC = instruction[8:71];
        valP = PC+9;
        f_predictedPC = valC; // assuming that the jump is taken (true with ~0.6 probability)
    end
    else if (icode==4'h8)           // call Dest
    begin
        valC = instruction[8:71];
        valP = PC+9;
        f_predictedPC = valC; 
    end
    else if (icode==4'h9)           // ret
    begin
        valP = PC+1;
        // no prediction of PC as ret could go anywhere
    end
    else
    begin                           // no valid instruction passed
        instr_invalid=1'b1;
    end
end


// ---------------------------------------------------------------------------------------------------------

initial 
begin
    PC = F_predictedPC; // PC is just the predicted PC as of now (next instruction PC)
end


// handling memory leak and value of PC based on jump, mis-prediction and ret
always @(*) 
begin
    // initially it is assumed that instruction is valid and no mem leak
    instr_invalid = 0;
    imem_error = 0;    

    // if mem leak then imem_error = 1
    if (PC>4096)
    begin
        imem_error = 1'b1;
    end

    // handling PC according to jump and ret
    if(W_icode==4'b1001)
        PC = W_valM;            // getting return PC value from WriteBack (PC gets updated and pipe is unstalled)
    else if(M_icode==4'b0111 & !M_cnd)
        PC = M_valA;            // misprediction of branch
    else
        PC = F_predictedPC;     // else PC is just the fall through PC
end

// ---------------------------------------------------------------------------------------------------------

// at positive edge, assigning all the values to Decode Register (next stage)
always @(posedge clk ) 
begin
    if (F_stall==1'b1)
    begin
        PC = F_predictedPC;   
        // $display("condition 1");
    end
    
    if (D_stall==1'b0 & D_bubble==1'b1)
    begin
        // $display("condition 2");
        // inserting a bubble (nop instruction) 
        D_icode <= 4'h1;
        D_ifun <= 4'h0;
        D_rA <= 4'hF;
        D_rB <= 4'hF;
        D_valC <= 64'b0;
        D_valP <= 64'b0;
        D_stat <= 4'h8;
    end
    else
    begin
        // $display("condition 3, here D_icode = %b",D_icode);
        // passing the instruction values as it is to the next stage
        D_icode <= icode;
        D_ifun <= ifun;
        D_rA <= rA;
        D_rB <= rB;
        D_valC <= valC;
        D_valP <= valP;
        D_stat <= stat;
    end

end

// ---------------------------------------------------------------------------------------------------------

initial 
begin
    
    instr_mem[0]=8'h30; //3 0
    instr_mem[1]=8'hF6; //F rB=0
    instr_mem[2]=8'h00;           
    instr_mem[3]=8'h00;           
    instr_mem[4]=8'h00;           
    instr_mem[5]=8'h00;           
    instr_mem[6]=8'h00;           
    instr_mem[7]=8'h00;           
    instr_mem[8]=8'h00;          
    instr_mem[9]=8'hff; //V=255

    instr_mem[10]=8'h30;
    instr_mem[11]=8'hF7;
    instr_mem[12]=8'h00;           
    instr_mem[13]=8'h00;           
    instr_mem[14]=8'h00;           
    instr_mem[15]=8'h00;           
    instr_mem[16]=8'h00;           
    instr_mem[17]=8'h00;           
    instr_mem[18]=8'h00;          
    instr_mem[19]=8'h1f; //V=31

    instr_mem[20]=8'h20;
    instr_mem[21]=8'h76;

    instr_mem[22] = 8'h40;       //rmmovq instruction
    instr_mem[23] = 8'h53;
    {instr_mem[24],instr_mem[25],instr_mem[26],instr_mem[27],instr_mem[28],instr_mem[29],instr_mem[30],instr_mem[31]} = 64'd0;

    instr_mem[32] = 8'h50;       //mrmovq instruction
    instr_mem[33] = 8'h53;
    {instr_mem[34],instr_mem[35],instr_mem[36],instr_mem[37],instr_mem[38],instr_mem[39],instr_mem[40],instr_mem[41]} = 64'd0;

    instr_mem[42] = 8'h60;       //add instruction
    instr_mem[43] = 8'h9A;

    instr_mem[44] = 8'h10;       // nop

    instr_mem[45] = 8'h10;       // nop

    instr_mem[46] = 8'h10;       // nop

    instr_mem[47] = 8'h10;       // nop

    instr_mem[48] = 8'h00;       // halt

end
    
endmodule
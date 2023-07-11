module decode (
    clk,
    icode,ifun,
    rA,rB,
    valA, valB, valM, valE, cnd,
    R0, R1, R2, R3, R4, R5,  R6, R7, R8, R9, R10, R11, R12, R13, R14
);

input clk;
input [3:0] rA, rB, icode, ifun; // half byte values
input signed[63:0] valE; // val from Execution stage
input [63:0] valM;  // val from Memory stage
input cnd; // condition flag for conditional instructions
output reg signed[63:0] valA, valB;
output reg signed[63:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14;

reg signed[63:0] reg_temp[0:14]; // 15 registers of 64 bit each

// assigning some values to the registers in the beginning to work with
initial
begin
    reg_temp[0] = 64'd12;        //rax
    reg_temp[1] = 64'd10;        //rcx
    reg_temp[2] = 64'd101;       //rdx
    reg_temp[3] = 64'd3;       //rbx
    reg_temp[4] = 64'd254;       //rsp
    reg_temp[5] = 64'd50;        //rbp
    reg_temp[6] = -64'd143;      //rsi
    reg_temp[7] = 64'd10000;     //rdi
    reg_temp[8] = 64'd990000;    //r8
    reg_temp[9] = -64'd12345;    //r9
    reg_temp[10] = 64'd12345;    //r10
    reg_temp[11] = 64'd10112;    //r11
    reg_temp[12] = 64'd0;        //r12
    reg_temp[13] = 64'd1567;     //r13
    reg_temp[14] = 64'd8643;     //r14
end

always @(*)
begin
    case (icode)
        4'b0110:// OPx rA, rB
        begin
            valA = reg_temp[rA]; // first operand
            valB = reg_temp[rB]; // second operand
        end


        4'b0011: // irmovq V, rB
        begin
            // nothing happens in decode stage
        end
        
        
        4'b0101: //mrmovq D(rB), rA
        begin
            valB = reg_temp[rB];
        end

        
        4'b0100: //rmmovq rA, D(rB)
        begin
            valA = reg_temp[rA];
            valB = reg_temp[rB];
        end

        
        4'b1010: //pushq rA
        begin
            valA = reg_temp[rA];
            valB = reg_temp[4]; // 4th register corresponds to %rsp (stack pointer)
        end

        
        4'b1011: //popq rA
        begin
            valA = reg_temp[4];  //// 4 must be there 
            valB = reg_temp[4];  //// 4 must be there
        end


        4'b0111: // jXX Dest
        begin
            // nothing happens in decode stage
        end


        4'b1000: // call Dest
        begin
            valB = reg_temp[4];
        end

        
        4'b1001: //ret
        begin
            valA = reg_temp[4];
            valB = reg_temp[4];
        end

        
        4'b0010: //cmovXX rA, rB
        begin
            valA = reg_temp[rA];            
        end

    endcase
end

always @(posedge clk)
begin
    case (icode)
        4'b0010:                        //cmovXX
        begin
            if(cnd)
            reg_temp[rB] = valE;
        end
        4'b0011: reg_temp[rB] = valE;   //irmovq
        4'b0101: reg_temp[rA] = valM;   //mrmovq
        4'b0110: reg_temp[rB] = valE;   //OPq
        4'b1000: reg_temp[4] = valE;    //call
        4'b1001: reg_temp[4] = valE;    //ret
        4'b1010: reg_temp[4] = valE;    //pushq
        4'b1011:
        begin
            reg_temp[4] = valE;
            reg_temp[rA] = valM;
        end 
    endcase
    R0 <= reg_temp[0];
    R1 <= reg_temp[1];
    R2 <= reg_temp[2];
    R3 <= reg_temp[3];
    R4 <= reg_temp[4];
    R5 <= reg_temp[5];
    R6 <= reg_temp[6];
    R7 <= reg_temp[7];
    R8 <= reg_temp[8];
    R9 <= reg_temp[9];
    R10 <= reg_temp[10];
    R11 <= reg_temp[11];
    R12 <= reg_temp[12];
    R13 <= reg_temp[13];
    R14 <= reg_temp[14];
end

endmodule
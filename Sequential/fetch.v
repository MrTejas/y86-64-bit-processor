module fetch(clk, PC, instr, icode, ifun, rA, rB, valC, valP, mem_error, instr_invalid);

input clk;
input [63:0] PC;
input [0:79] instr;

output reg[3:0] icode, ifun;
output reg [3:0] rA, rB;
output reg signed[63:0] valC;
output reg [63:0] valP;

output reg mem_error = 1'b0, instr_invalid = 1'b0;

always @(*)
begin
  if(PC>255)
  begin
    mem_error = 1;
  end

  icode = instr[0:3];
  ifun = instr[4:7];

  case(icode)
  4'b0000:   //halt
  begin
    valP = PC + 1;
  end

  4'b0001:   //nop
  begin
    valP = PC + 1;
  end

  4'b0010:   //cmoXX
  begin
    rA = instr[8:11];
    rB = instr[12:15];
    valP = PC + 2;
  end

  4'b0011:   //irmovq
  begin
    rA = instr[8:11];
    rB = instr[12:15];
    valC = instr[16:79];
    valP = PC + 10;
  end

  4'b0100:   //rmmovq
  begin
    rA = instr[8:11];
    rB = instr[12:15];
    valC = instr[16:79];
    valP = PC + 10;
  end

  4'b0101:   //mrmovq
  begin
    rA = instr[8:11];
    rB = instr[12:15];
    valC = instr[16:79];
    valP = PC + 10;
  end

  4'b0110:   //OPq
  begin
    rA = instr[8:11];
    rB = instr[12:15];
    valP = PC + 2;
  end

  4'b0111:   //jXX
  begin
    valC = instr[8:71];
    valP = PC + 9;
  end
  
  4'b1000:   //call
  begin
    valC = instr[8:71];
    valP = PC + 9;
  end

  4'b1001:   //ret
  begin
    valP = PC + 1;
  end

  4'b1010:   //pushq
  begin
    rA = instr[8:11];
    rB = instr[12:15];
    valP = PC + 2;
  end

  4'b1011:   //popq
  begin
    rA = instr[8:11];
    rB = instr[12:15];
    valP = PC + 2;
  end

  default:
    instr_invalid = 1'b1;
    //valP = PC + 1;
  endcase
end

endmodule
module execute(clk, icode, ifun, valA, valB, valC, cc_in, valE, cnd, cc_out);

input clk;
input [3:0] icode, ifun;
input signed [63:0] valA, valB, valC;
input [2:0]cc_in;

output reg [63:0] valE;
output reg cnd;
output reg [2:0] cc_out;

wire [63:0] valE_BC, valE_OP, valE_IN, valE_DE;
wire t_OF1, t_OF2, t_OF3;
wire OF;

ALU E1(valB, valC, 2'b00, valE_BC, t_OF1);
ALU E2(valA, valB, ifun[1:0], valE_OP, OF);
ALU E3(valB, 64'd1, 2'b00, valE_IN, t_OF2);
ALU E4(valB, 64'd1, 2'b01, valE_DE, t_OF3);

always @(*)
begin
    case(icode)
    /*4'b0010:   //cmovxx
    begin
        case(ifun)
        4'b0000: cnd = 1;
        4'b0001: cnd = (O_F^S_F)|Z_F;
        4'b0010: cnd = O_F^S_F;
        4'b0011: cnd = Z_F;
        4'b0100: cnd = ~Z_F;
        4'b0101: cnd = ~(S_F^O_F);
        4'b0110: cnd = ~(S_F^O_F)&~Z_F;
        endcase
        valE = valA;
    end*/
    4'b0010: valE = valA;       //cmovXX
    4'b0011: valE = 0 + valC;   //irmovq
    4'b0100: valE = valE_BC;    //rmmovq
    4'b0101: valE = valE_BC;    //mrmovq

    4'b0110:                    //OPq
    begin
        valE = valE_OP;
        cc_out[2] <= OF;
        cc_out[1] <= valE[63];
        cc_out[0] <= (valE == 0)? 1'b1:1'b0;
    end

    /*4'b0111:                    //jXX
    begin
        case(ifun)
        4'b0000: cnd = 1;
        4'b0001: cnd = (O_F^S_F)|Z_F;
        4'b0010: cnd = O_F^S_F;
        4'b0011: cnd = Z_F;
        4'b0100: cnd = ~Z_F;
        4'b0101: cnd = ~(S_F^O_F);
        4'b0110: cnd = ~(S_F^O_F)&~Z_F;
        endcase
    end*/

    4'b1000: valE = valE_DE;     //call
    4'b1001: valE = valE_IN;     //ret
    4'b1010: valE = valE_DE;     //pushq
    4'b1011: valE = valE_IN;     //popq

    endcase
end

assign zf = cc_in[0];
assign sf = cc_in[1];
assign of = cc_in[2];

always @(posedge clk)
begin
    if(icode == 2 || icode == 7) // for cmove and jump
    begin
        case(ifun)
        4'b0000: cnd = 1;           //unconditional
        4'b0001: cnd = (of^sf)|zf;  //le
        4'b0010: cnd = (of^sf);     //l
        4'b0011: cnd = zf;          //e
        4'b0100: cnd = ~zf;         //ne
        4'b0101: cnd = ~(of^sf);    //ge
        4'b0110: cnd = ~(of^sf) & ~(zf); //g
        endcase
    end
end

endmodule
module pc_update(clk, icode, cnd, PC_new, valC, valM, valP);

input [3:0] icode;
input cnd,clk;
input [63:0] valC, valM, valP;
output reg [63:0] PC_new;

always@(posedge clk)
begin
    case(icode)
        4'b0000: PC_new <= 0;
        4'b0001: PC_new <= valP;
        4'b0010: PC_new <= valP;
        4'b0011: PC_new <= valP;
        4'b0100: PC_new <= valP;
        4'b0101: PC_new <= valP;
        4'b0110: PC_new <= valP;
        4'b0111: PC_new <= (cnd==1) ? valC:valP;
        4'b1000: PC_new <= valC;
        4'b1001: PC_new <= valM;
        4'b1010: PC_new <= valP;
        4'b1011: PC_new <= valP;
    endcase
end
endmodule

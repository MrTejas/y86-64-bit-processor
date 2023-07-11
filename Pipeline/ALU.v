module ALU(A, B, control, result, overflow);
input signed [63:0] A,B;
input signed [1:0] control;

output signed [63:0] result;
reg signed [63:0] result;

output signed overflow;
reg overflow;

wire signed [63:0] out_sum;
wire signed [63:0] out_diff;
wire signed [63:0] out_and;
wire signed [63:0] out_xor;
wire OF_add, OF_diff;

ADDx64 G1(A, B, out_sum, OF_sum);
SUBx64 G2(A, B, out_diff, OF_diff);
ANDx64 G3(A, B, out_and);
XORx64 G4(A, B, out_xor);

always @(*)
begin
case(control)
2'b00:
begin
result = out_sum;
overflow = OF_sum;
end
2'b01:
begin
result = out_diff;
overflow = OF_diff;
end
2'b10:
begin
result = out_and;
overflow = 0;
end
2'b11:
begin
result = out_xor;
overflow = 0;
end
endcase
end
endmodule
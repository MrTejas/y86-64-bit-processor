module SUBx64(num1, num2, diff, overflow);

input signed [63:0] num1, num2;
output signed [63:0] diff;
output overflow;
wire b[64:0];

assign b[0]=1'b0;

genvar x;
generate for(x=0;x<64;x=x+1)
begin
    SUBx1 M1(num1[x], num2[x], b[x], b[x+1], diff[x]);
end
endgenerate

xor X1(overflow, b[64], b[63]);

endmodule

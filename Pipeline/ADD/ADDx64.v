module ADDx64(A, B, sum, OF);

// A and B are signed 64 bit registers
// sum stores 64 bit output
// OF means overflow

input signed [63:0] A;
input signed [63:0] B;
output signed [63:0] sum;
output OF;

wire [64:0] carry;

assign carry[0]=1'b0;

genvar j;
generate for(j = 0; j < 64; j = j + 1)
begin
    ADDx1 A11(A[j], B[j], carry[j], sum[j], carry[j+1]);
end
endgenerate

wire OF1, OF2, na, nb, ns;
not(ns, sum[63]);
not(nb, B[63]);
not(na, A[63]);
and(OF1, na, nb, sum[63]);
and(OF2, A[63], B[63], ns);
or(OF, OF1, OF2);

// OF is xor of last two bits of carry register array

endmodule
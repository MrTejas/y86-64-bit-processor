module ANDx64(A, B, out);

// A and B are signed 64 bit registers
// out stores 64 bit output

input signed [63:0] A;
input signed [63:0] B;
output signed [63:0] out;

genvar j;
generate for(j = 0; j < 64; j = j + 1)
begin
    and(out[j], A[j], B[j]);
end
endgenerate

endmodule
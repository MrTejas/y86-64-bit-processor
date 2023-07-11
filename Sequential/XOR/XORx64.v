module XORx64(num1, num2, result);

input signed[63:0] num1, num2;
output signed[63:0] result;

genvar x;
for(x=0;x<64;x=x+1)
begin
    xor (result[x], num1[x], num2[x]);
end


endmodule
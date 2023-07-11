`timescale 10ps/1ps
`include "XORx64.v"
module tb_XORx64();
reg signed [63:0] num1, num2;
wire signed [63:0] result;

XORx64 M1(num1, num2, result);

initial begin
    $dumpfile("tb_XORx64.vcd");
    $dumpvars(0, tb_XORx64);

    $monitor("time: %0d\n a  : %b\t%d\n b  : %b\t%d\n out: %b\t%d\n ", $time, num1, num1, num2, num2, result, result);

    num1 = 64'd1024;
    num2 = 64'd1023;

    #10
    num1 = 64'd10;
    num2 = 64'd5;

    #10
    num1 = 64'd12;
    num2 = 64'd3;
end
endmodule

// iverilog -o tb_XORx64 tb_XORx64.v XORx64.v
// vvp tb_XORx64

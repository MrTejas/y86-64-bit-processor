`timescale 10ps/1ps
`include "ADDx1.v"
`include "ADDx64.v"
module ADDx64_test();

reg signed [63:0] a;
reg signed [63:0] b;

wire signed [63:0] sum;
wire OF;

ADDx64 AT22(a,b,sum,OF);

initial
    begin
        $dumpfile("ADDx64_test.vcd");
        $dumpvars(0, ADDx64_test);
        a = 64'b0;
        b = 64'b0;
        
        $monitor("time: %0d\n a  : %b\t%d\n b  : %b\t%d\n sum: %b\t%d\n overflow=%b\n ", $time, a,a,b,b,sum,sum, OF);

        // #5 a = 64'd2811; b= 64'd1012;
        // #5 a = -64'd1243; b= 64'd1234;
        // #5 a = -64'd7478; b=-64'd46474;
        // #5 a = 64'd1092835; b = -64'd1020;
        // #5 a = 64'd7890678653; b = 64'd4238598110567;
        // #5 a = 64'b0111111111111111111111111111111111111111111111111111111111111111; b = 64'd1;
        // #5 a = -64'd9223372036854770000; b=-64'd6000;
        // #5 a = 64'd4238; b=-64'd4238;
        // #5 a = -64'd4238598110567; b = -64'd4238598110567;

        // edge cases
        
        #5 a = -64'd9223372036854775808; b = -64'd9223372036854775808;
        #5 a = 64'd9223372036854775807; b = 64'd9223372036854775807;
        #5 a = 64'd9223372036854775807; b = -64'd9223372036854775808;
    end
endmodule
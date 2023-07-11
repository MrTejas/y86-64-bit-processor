`timescale 10ps/1ps
`include "ADDx1.v"
module ADDx1_test();

reg A, B, C;
wire signed sum;
wire carry;
integer i;

ADDx1 AT21(A, B, C, sum, carry);

initial
    begin
        $dumpfile("ADDx1_test.vcd");
        $dumpvars(0, ADDx1_test);
        {A, B, C} = 0;

        $monitor($time, ": A=%b, B=%b, C=%b, sum=%b, carry=%b\n", A, B, C, sum, carry);
            for(i = 0; i < 8; i = i + 1) 
            begin
                #1 {A,B,C} = i;
            end
    end
endmodule
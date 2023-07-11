`timescale 10ps/1ps
`include "SUBx1.v"
module tb_SUBx1();

reg A, B, borrow_in;
wire diff, borrow_out;
integer x;

SUBx1 SUB1(A, B, borrow_in, borrow_out, diff);

initial begin
    $dumpfile("tb_SUBx1.vcd");
    $dumpvars(0, tb_SUBx1);

    {A, B, borrow_in} = 0;

    for(x=0;x<=7;x=x+1)
    begin
        #10 {A, B, borrow_in}=x;
    end
end

always@(diff, borrow_out)
begin
        $display("time = %0t\t\t %b %b %b\t\t%b %b",$time, A, B, borrow_in, borrow_out, diff);
end

endmodule

// Commands to run (terminal)
// iverilog -o tb_SUBx1 tb_SUBx1.v SUBx1.v
// vvp tb_SUBx1
// gtkwave tb_SUBx1.vcd
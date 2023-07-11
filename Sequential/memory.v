module memory(clk, icode, valA, valE, valM, valP, mainmem_error);
    input clk;
    input [3:0] icode;
    input [63:0] valA, valE, valP;
    output reg [63:0] valM;
    output reg mainmem_error;

    reg [63:0] mainmem[255:0];

    always @(*)
    begin
        mainmem_error = 0;
        if(valE > 255)
        begin
            mainmem_error = 1;
        end
        case(icode)
            4'b0101: valM = mainmem[valE];   //mrmovq
            4'b1001: valM = mainmem[valA];   //ret
            4'b1011: valM = mainmem[valA];   //popq
        endcase
    end

    always @(posedge clk)
    begin
        mainmem_error = 0;
        if(valE > 255)
        begin
            mainmem_error = 1;
        end
        case(icode)
            4'b0100: mainmem[valE] = valA;   //rmmovq
            4'b1010: mainmem[valE] = valA;   //pushq
            4'b1000: mainmem[valE] = valP;   //call
        endcase
    end

endmodule
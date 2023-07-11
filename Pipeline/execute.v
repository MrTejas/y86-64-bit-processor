module execute(clk, E_stat, E_icode, E_ifun, E_valC, E_valA, E_valB, E_dstE, E_dstM, W_stat, m_stat, set_cc,
                M_stat, M_icode, M_cnd, M_valE, M_valA, e_valE, M_dstE, M_dstM, e_dstE, e_cnd);

// upper parameters are inputs and lower ones are outputs

//input parameters

input clk;
input [0:3] E_stat;
input [3:0] E_icode, E_ifun, E_dstE, E_dstM;
input signed [63:0] E_valC, E_valA, E_valB;
input [3:0] W_stat;
input [3:0] m_stat;
input set_cc;

//output parameters

output reg [0:3] M_stat;
output reg [3:0] M_icode;
output reg signed [63:0] M_valE, M_valA, e_valE;
output reg [3:0] M_dstE, M_dstM, e_dstE;
output reg M_cnd;
output reg e_cnd;

reg [2:0] CC;   // 2 is OF, 1 is SF, 0 is ZF

initial
begin
    CC[0] = 0;
    CC[1] = 0;
    CC[2] = 0;
end

wire ZF, SF, OF;  // 2 is OF, 1 is SF, 0 is ZF

always @(*)
begin
    if(set_cc)
    begin
        CC[2] = OF;
        CC[1] = e_valE[63];
        CC[0] = (e_valE == 0) ? 1'b1:1'b0;
    end
end


wire t_OF1, t_OF2, t_OF3, t_OF4;
wire [63:0] valE_BC, valE_AB, valE_OP, valE_IN, valE_DE;

ALU E1(E_valB, E_valC, 2'b00, valE_BC, t_OF1);
//ALU E2(E_valA, E_valB, 2'b00, valE_AB, t_OF2);
ALU E3(E_valA, E_valB, E_ifun[1:0], valE_OP, OF);
ALU E4(E_valB, 64'd1, 2'b00, valE_IN, t_OF3);
ALU E5(E_valB, 64'd1, 2'b01, valE_DE, t_OF4);

always @(*)
begin
    case(E_icode)
    4'b0010: e_valE = E_valA;       //cmove (here value can be valE_AB also)
    4'b0011: e_valE = 0 + E_valC;   //irmovq (here value can be valE_BC also)
    4'b0100: e_valE = valE_BC;      //rmmovq
    4'b0101: e_valE = valE_BC;      //mrmovq

    4'b0110:                        //OPq
    begin
        e_valE=valE_OP;
        if(set_cc)
        begin
            CC[0] = (e_valE == 0) ? 1'b1:1'b0;   //ZF
            CC[1] = e_valE[63];                  //SF
            CC[2] = OF;                          //OF
        end
    end

    4'b1000: e_valE = valE_DE;     //call
    4'b1001: e_valE = valE_IN;     //return
    4'b1010: e_valE = valE_DE;     //pushq
    4'b1011: e_valE = valE_IN;     //popq 
    endcase
end

assign ZF = CC[0];
assign SF = CC[1];
assign OF = CC[2];

always @(*)
begin
    if(E_icode == 2 || E_icode == 7)  //for cmove and jump
    begin
        case(E_ifun)
        4'b0000: e_cnd = 1;           //unconditional
        4'b0001: e_cnd = (OF^SF)|ZF;  //le
        4'b0010: e_cnd = (OF^SF);     //l
        4'b0011: e_cnd = ZF;          //e
        4'b0100: e_cnd = ~ZF;         //ne
        4'b0101: e_cnd = ~(SF^OF);    // ge
        4'b0110: e_cnd = ~(SF^OF)&~ZF;// g      
        endcase
    end
end

always @(*)
begin
    if(E_icode == 2 || E_icode == 7)
    begin
        e_dstE = (e_cnd == 1) ? E_dstE : 4'b1111;    //empty register
    end
    else
    begin
        e_dstE = E_dstE;
    end
end

always @(posedge clk)
begin
    // here M_bubble is not considered if consiidered need nop
    M_stat <= E_stat;
    M_icode <= E_icode;
    M_cnd <= e_cnd;
    M_valE <= e_valE;
    M_valA <= E_valA;
    M_dstE <= e_dstE;
    M_dstM <= E_dstM;
end

endmodule
module ADDx1(A, B, C, S, carry);
    input A,B,C;
    output S, carry;
    wire w1, w2, w3;

    xor(w1, A, B);
    xor(S, w1, C);
    and(w2, A, B);
    and(w3, w1, C);
    or(carry, w3, w2);
endmodule

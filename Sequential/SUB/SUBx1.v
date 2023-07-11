module SUBx1(A, B, borrow_in, borrow_out, diff);

input A, B, borrow_in;
output diff, borrow_out;

// calculating difference
xor X1(w1, A, B);
xor X2(diff, w1, borrow_in);

// calculating borrow_out
xnor XN1(w2, A, B);
and A1(w3, borrow_in, w2);

not NT1(w4, A);
and A2(w5, w4, B);
or O1(borrow_out, w3, w5);

endmodule
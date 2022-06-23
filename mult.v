module mult(
         input signed [31:0] inA, 
		 input signed [31:0] inB, 

		 output signed [31:0] mult
 	);
    assign mult = inA * inB;   
endmodule
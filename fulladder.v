module fulladder(
        input inA, 
		input inB, 
        input Cin,
        
		output add,
		output Co
 	); 

    assign add = inA ^ inB ^ Cin;
	assign Co = (inA & inB) | ((inA | inB) & Cin);

 endmodule
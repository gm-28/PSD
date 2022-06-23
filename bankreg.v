/*	Relatório sumário 
	Foram implementadas todas as especificações requeridas.

	Para criar a constante são usados diretamente os bits da entrada Selout:
		Selout[x]:
			bit 0 - sinal parte imaginaria
			bit 1 - sinal parte real
			bit 2 - valor parte imaginaria
			bit 3 - valor parte real
*/

module reg_bank(
		 input clock, // Master clock, active in the posedge
		 input reset, // Master reset, synchronous and active high
		 //--- Data input port ----------------------------------------------------
		 input regwe, // Register write enable: set to 1 to write the register
		 // selected by selwreg with the data at port inA
		 input [63:0] inA, // Data input
		 input [ 3:0] selwreg, // Select register index [0 to 15] to write data from port inA
		 input [ 1:0] endreg, // Data enable: 00-write both data fields
		 // 10/01-write only data field selected by 1’b0
		 // 11: swap high word and low word
		 //--- Data output ports --------------------------------------------------
		 output reg [63:0] outA, // Data output A, registered
		 output reg [63:0] outB, // Data output B, registered
		 input [ 3:0] seloutA, // Select register index [0 to 15] to output port outA
		 input [ 3:0] seloutB, // Select register index [0 to 15] to output port outB
		 input cnstA, // Define whether the output ports A and B are loaded with
		 input cnstB, // the contents of the register bank or a fixed constant
		 input enrregA, // Read enable to output register outA (loads output register)
		 input enrregB // Read enable to output register outB (loads output register)
 ); 

	
reg [63:0] regbank [0:15];
integer i;	
	
always @(posedge clock)
	if(reset)
		begin
			for (i = 0; i < 16; i = i+1)
				begin
						regbank [i] <= 64'h0; 
				end
		end
	else 	
		if(regwe)
			begin
				case(endreg)
					2'b00: regbank[selwreg] <= inA;
					2'b01: regbank[selwreg][63:32] <= inA[63:32];
					2'b10: regbank[selwreg][31:0] <= inA[31:0];	
					2'b11: regbank[selwreg] <= {inA[31:0], inA[63:32]};
				endcase
			end

always @(posedge clock)
	if(reset)
		outA <= 64'h0;
	else 
		if(cnstA==0)
			begin
				if(enrregA)
					outA <= regbank[seloutA];
			end
		else
			begin
				outA <= {{(31){seloutA[1]}}, seloutA[3], {(31){seloutA[0]}}, seloutA[2]};
			end

always @(posedge clock)
	if(reset)
		outB <= 64'h0;
	else
		if(cnstB==0)
			begin
				if(enrregB)
					outB <= regbank[seloutB];
			end
		else
			begin
				outB <= {{(31){seloutB[1]}}, seloutB[3], {(31){seloutB[0]}}, seloutB[2]};
			end

endmodule





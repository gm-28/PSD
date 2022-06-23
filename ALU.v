/*	Relatório sumário
	O módulo ALU.v tem como entrada opr que escolhe através de um switch case a operação a executar:
		0 - Entrada inA para outAB;
		1 - Entrada inB para outAB;
		2 - soma de inA com inB;
		3 - Subtração de inB a inA;
		4 - Multiplicação de inA e inB como números imaginários;
		6 - Multiplicação da parte real e da parte imaginaria de inA por inB;
		8 - Comparação de inA com inB;
		9 - Conversão de inA para coordenadas polares;
		10 - Conversão de inB para coordenadas polares.

    As operações de adição e subtração utilizam um módulo criado por nós, que se baseia no Ripple 
    carry adder estudado nas aulas e que usa um fulladder com carry in e carry out.
    No caso da subtração o operando inB é negado de modo a reutilizar o módulo do ripple carry.

    A operação de multiplicação da parte real e da parte imaginaria usa um módulo que faz a 
    multiplicação de 32 bits por 32 bits, ignorando quando há overflow, como discutido nas aulas
    práticas.

    A operação de multiplicação de números imaginários aplica este último módulo às diferentes 
    partes (reais e imaginarias) de inA e inB de modo a obter o resultado certo.

    Por fim, a operação de conversão de coordenadas retangulares para coordenadas polares aplica
    o módulo rec2pol.v, realizado para as aulas práticas no início do semestre, adaptado, mas 
    limitado ao 1  e 4 quadrante.

    A saída outAB é atualizada a cada Transição positiva do ciclo do clock de acordo com opr.
    No entanto, para o caso da conversão de coordenadas retangulares só após 31 ciclos.
    Deste modo, é utilizado o contador presente no módulo ALU.v desde as linhas 75 a 95.

    Todas as operações funcionam para números em complemento para 2.

	Para testar a ALU criamos a testbench ALU_tb.v que testa cada operação ordenadamente e 
	casos que consideramos serem mais importantes. Por exemplo, teste com números negativos.

	NOTA 1: Para o caso de conversão de coordenadas retangulares para coordenadas polares é
	necessário que o ficheiro atanLUTd.hex esteja no diretório de simulação quando se testa 
	no ISE da Xilinx caso contrário o valor do ângulo não é corretamente cálculado.
	NOTA 2: As funções  $sqrt() e  $atan2() disponiveis no compilador iverilog não estão 
	disponiveis no ISE da Xilinx. Assim, testamos com valores com resultado conhecido.
 */

`include "rc_adder.v"
`include "mult.v"
`include "fulladder.v"
`include "rec2po.v"

module ALU(
		 input clock, // Master clock, active in the posedge
		 input reset, // Master reset, synchronous and active high
		 
		 input start, 
		 input [63:0] inA, 
		 input [63:0] inB,
		 input [ 4:0] opr, 

		 output reg signed [63:0] outAB, 
		 output done 
 );

 reg regdone;
 reg [4:0] count;
 reg sig;
 
 wire [63:0] add;
 wire [63:0] sub;
 wire [63:0] mult;
 wire [63:0] mult_im;
 wire signed [31:0] modA;
 wire signed [31:0] modB;
 wire signed [31:0] angleA;
 wire signed [31:0] angleB;
 wire Co1;
 wire Co2;
 wire Co3;
 wire Co4;
 wire Co5;
 
 rc_adder adder1(inA[31:0], inB[31:0],1'b0, add[31:0], Co1);
 rc_adder adder2(inA[63:32], inB[63:32],1'b0, add[63:32], Co2);

 rc_adder sub1(inA[31:0], -inB[31:0],1'b0, sub[31:0], Co3);
 rc_adder sub2(inA[63:32], -inB[63:32],1'b0, sub[63:32], Co4);

 mult mult1(inA[31:0], inB[31:0], mult[31:0]);
 mult mult2(inA[63:32], inB[63:32], mult[63:32]);
 mult mult3(inA[63:32], inB[31:0] , mult_im[31:0]);
 mult mult4(inA[31:0], inB[63:32], mult_im[63:32]);
 
 rec2pol rec2pol1(clock, reset , start, inA[63:32], inA[31:0], modA, angleA);
 rec2pol rec2pol2(clock, reset , start, inB[63:32], inB[31:0], modB, angleB);
 
 assign done = regdone;
 
 always @(posedge clock)
	if (reset)
			count <= 5'd0;
		else 
		begin
			if(start)
				count <= 5'd0;
			else
			begin
				if (count[4:0]==5'b11111)
					begin
						sig <= 1'b1;
						count <= 5'd0;
					end
				else
					begin
						count <= count + 1;
						sig <= 1'b0;
					end
			end
		end

 always @(posedge clock)
	if(reset)
		begin
			outAB <= 64'h0;
			regdone <= 1'b0;
		end
	else 
	if(regdone)
			regdone <= 1'b0;
	else 
	if(start || sig)
		begin
			case(opr)
			5'b00000:
				begin
					outAB <= inA;
					regdone <= 1'b1;
				end
			5'b00001:
				begin
					outAB <= inB;
					regdone <= 1'b1;
				end
			5'b00010:
				begin
					outAB <= add;
					regdone <= 1'b1;
				end
			5'b00011:
				begin
					outAB <= sub;
					regdone <= 1'b1;
				end
			5'b00100:
				begin
					outAB[63:32] <= mult[63:32] - mult[31:0]; 
					outAB[31:0] <= mult_im[63:32] + mult_im[31:0];
					regdone <= 1'b1;
				end
			5'b00110:
				begin
					outAB <= mult;
					regdone <= 1'b1;
				end
			5'b01000:
				begin
					outAB <= inA == inB;
					regdone <= 1'b1;
				end
			5'b01001:
				begin
					if(sig)
						begin
							outAB <= {modA,angleA};
							regdone <= 1'b1;
						end
				end
			5'b01010:
				begin
					if(sig)	
						begin
							outAB <= {modB,angleB};
							regdone <= 1'b1;
						end
				end
			endcase
		end

endmodule			
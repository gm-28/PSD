
`timescale 1ns / 1ns

module bankreg_tb;
 
// general parameters 
parameter CLOCK_PERIOD = 10;              // Clock period in ns
parameter MAX_SIM_TIME = 100_000_000;     // Set the maximum simulation time (time units=ns)

// Registers for driving the inputs:
reg  clock, reset, regwe, cnstA, cnstB, enrregA, enrregB;
reg [63:0] inA; 
reg [ 3:0] selwreg;
reg [ 1:0] endreg;
reg [ 3:0] seloutA; 
reg [ 3:0] seloutB;


// Wires to connect to the outputs:
wire [63:0] outA;
wire [63:0] outB;

// Instantiate the module under verification:
reg_bank reg_bank_1
      ( 
	    .clock(clock), // master clock, active in the positive edge
        .reset(reset), // master reset, synchronous and active high
        .regwe(regwe),
        .inA(inA),   
		.selwreg(selwreg),
		.endreg(endreg),
		.outA(outA),
		.outB(outB),
		.seloutA(seloutA),
		.seloutB(seloutB),
		.cnstA(cnstA),
		.cnstB(cnstB),
		.enrregA(enrregA),
		.enrregB(enrregB)
        ); 
          
//---------------------------------------------------
initial begin
    $dumpfile ("bankreg.vcd"); // Change filename as appropriate. 
    $dumpvars(0, bankreg_tb); 
end
// Setup initial signals
initial
begin
	clock = 1'b0;
	reset = 1'b0;
	inA = 0;
	selwreg = 0;
	endreg = 0;
	seloutA = 0;
	seloutB = 0;
	cnstA = 1'b0;
	cnstB = 1'b0;
	enrregA = 1'b0;
	enrregB = 1'b0;
end

//---------------------------------------------------
// generate a 50% duty-cycle clock signal
initial
begin  
  forever
    # (CLOCK_PERIOD / 2 ) clock = ~clock;
end

//---------------------------------------------------
// Apply the initial reset for 2 clock cycles:
initial
begin
  # (CLOCK_PERIOD/3) // wait a fraction of the clock period to 
                     // misalign the reset pulse with the clock edges:
  reset = 1;
  # (2 * CLOCK_PERIOD ) // apply the reset for 2 clock periods
  reset = 0;
end

//---------------------------------------------------
// Set the maximum simulation time:
initial
begin
  # ( MAX_SIM_TIME )
  $stop;
end

//---------------------------------------------------
// The verification program (THIS IS TRUE A PROGRAM!) Fazer ciclo para testar multiplos resultados
integer i, aux1;
reg[63:0] aux;
initial
begin
  // Wait 10 clock periods
  #( 10*CLOCK_PERIOD );

	inA = 64'h0000000000000003;
	selwreg = 3'b000;
	endreg = 2'b00;
	seloutA = 3'b000;
	
	$display("Write-Read TEST");
	
	for(i = 0 ; i <= 15; i = i+1 ) begin
		//inA =  $urandom_range(0, 100000);
		inA = inA+1;
		selwreg = selwreg + 1;
		seloutA = selwreg;
		execrw(inA, selwreg, endreg);
		
		if(outA!=inA) 
			$display("WRONG: Result: %h Expected Result: %h", outA, inA);
		else $display("Correct: Result: %h", outA);
	end
	
	$display("Endreg TEST");
	
	inA = 64'h0000000100000002;
	endreg = 2'b01;
	execrw(inA, selwreg, endreg);
	aux[63:0] = 64'h0000000100000000;
	
	if(outA[63:32]!=aux[63:32]) 
			$display("WRONG: Result: %h Expected Result: %h", outA, aux);
	else $display("Correct: Result: %h", outA);
	
	endreg = 2'b10;
	execrw(inA, selwreg, endreg);
	aux[63:0] = 64'h0000000000000002;
	
	if(outA[31:0]!=aux[31:0])
			$display("WRONG: Result: %h Expected Result: %h", outA, aux);
	else $display("Correct: Result: %h", outA);
	
	endreg = 2'b11;
	execrw(inA, selwreg, endreg);
	
	if(outA!=64'h0000000200000001) 
			$display("WRONG: Result: %h Expected Result: %h", outA, 64'h0000000200000001);
	else $display("Correct: Result: %h", outA);
	
	$display("Cnst TEST");
	seloutB=4'b0000;
	execcnst();
	if(outB!=64'h0000000000000000) 
			$display("WRONG: Result: %h Expected Result: %h", outB, 64'h0000000000000000);
	else $display("Correct: Result: %h", outB);
	
	seloutB=4'b1000;
	execcnst();
	if(outB!=64'h0000000100000000) 
			$display("WRONG: Result: %h Expected Result: %h", outB, 64'h0000000100000000);
	else $display("Correct: Result: %h", outB);
	
	seloutB=4'b0100;
	execcnst();
	if(outB!=64'h0000000000000001) 
			$display("WRONG: Result: %h Expected Result: %h", outB, 64'h0000000000000001);
	else $display("Correct: Result: %h", outB);
	
	seloutB=4'b0101;
	execcnst();
	if(outB!=64'h00000000ffffffff) 
			$display("WRONG: Result: %h Expected Result: %h", outB, 64'h00000000ffffffff);
	else $display("Correct: Result: %h", outB);
	
	seloutB=4'b1010;
	execcnst();
	if(outB!=64'hffffffff00000000) 
			$display("WRONG: Result: %h Expected Result: %h", outB, 64'hffffffff00000000);
	else $display("Correct: Result: %h", outB);
	
	seloutB=4'b1111;
	execcnst();
	if(outB!=64'hffffffffffffffff) 
			$display("WRONG: Result: %h Expected Result: %h", outB, 64'hffffffffffffffff);
	else $display("Correct: Result: %h", outB);

	seloutB=4'b0011;
	execcnst();
	if(outB!=64'hfffffffefffffffe) 
			$display("WRONG: Result: %h Expected Result: %h", outB, 64'hfffffffefffffffe);
	else $display("Correct: Result: %h", outB);
	
  #( 10*CLOCK_PERIOD );
  //$stop;
  $finish;   
end


//---------------------------------------------------
// Simulate the sequential controller
task execrw;
input [63:0] inA;
input [ 3:0] selwreg;
input [ 1:0] endreg;
//input [ 3:0] seloutA,
begin
	inA = inA; // Apply operands
	selwreg = selwreg;
	endreg = endreg;
	@(posedge clock);
	regwe = 1'b1;
	@(posedge clock);
	@(posedge clock);
	regwe = 1'b0;
	enrregA = 1'b1;
	@(posedge clock);
	enrregA = 1'b0;
	@(posedge clock);

 
  // Print the results:
  // You may not watt to do this when verifying some millions of operands...
  // Add a flag to enable/disable this print
  //if(flag==1) $display("SQRT(%d) = %d", x, sqrt );
  
  end  
endtask

task execcnst;

begin
	cnstB=1'b1;
	@(posedge clock);
	enrregB= 1'b1;
	@(posedge clock);
	cnstB=1'b0;
	enrregB = 1'b0;
	@(posedge clock);

  end  
endtask

endmodule

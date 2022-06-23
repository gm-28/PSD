`timescale 1ns / 1ns

module ALU_tb;
 
// general parameters 
parameter CLOCK_PERIOD = 10;              // Clock period in ns
parameter MAX_SIM_TIME = 100_000_000;     // Set the maximum simulation time (time units=ns)

// Registers for driving the inputs:
reg  clock, reset, start;
reg [63:0] inA; 
reg [63:0] inB;
reg [ 4:0] opr;

// Wires to connect to the outputs:
wire [63:0] outAB;
wire signed [31:0] mod;
wire signed [31:0] angle;
wire done;

assign mod = outAB[63:32];
assign angle = outAB[31:0];

// Instantiate the module under verification:
ALU ALU_1
      ( 
	    .clock(clock), // master clock, active in the positive edge
        .reset(reset), // master reset, synchronous and active high
        .start(start),
		.opr(opr),
        .inA(inA),
		.inB(inB),
		.outAB(outAB),
		.done(done)
        ); 
          
//---------------------------------------------------
initial begin
    $dumpfile ("ALU.vcd"); // Change filename as appropriate. 
    $dumpvars(0, ALU_tb); 
end
// Setup initial signals
initial
begin
	clock = 1'b0;
	reset = 1'b0;
	start = 1'b0;
	inA = 0;
	inB = 0;
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
// The verification program
integer i, aux, aux1;
initial
begin
  // Wait 10 clock periods
  #( 10*CLOCK_PERIOD );
	inA = 64'h0000000100000001;
	opr = 5'b00000;
	$display("outAB<=inA TEST");
	exeopr(inA, inB, opr);
	
	if(outAB!=inA) 
			$display("WRONG: Result: %h Expected Result: %h\n", outAB, inA);
	else $display("Correct: Result: %h\n", outAB);

	
	inB = 64'h0000000200000002;
	opr = 5'b00001;
	$display("outAB<=inB TEST");
	exeopr(inA, inB, opr);
	
	if(outAB!=inB) 
			$display("WRONG: Result: %h Expected Result: %h\n", outAB, inB);
	else $display("Correct: Result: %h\n", outAB);

	
	inA = 64'h000000ff000000ff;
	inB = 64'h000000ff000000ff;
	opr = 5'b00010;
	
	$display("ADD TEST Positive Number");
	
	exeopr(inA, inB, opr);
	
	if(outAB!=64'h000001fe000001fe) 
			$display("WRONG: Result: %h Expected Result: %h\n", outAB, 64'h000001fe000001fe);
	else $display("Correct: Result: %h\n", outAB);

	inA = 64'hffffffffffffffff;
	inB = 64'h0000000100000002;
	opr = 5'b00010;
	
	$display("ADD TEST Negative Number");
	
	exeopr(inA, inB, opr);
	
	if(outAB!=64'h0000000000000001) 
			$display("WRONG: Result: %h Expected Result: %h \n", outAB, 64'h0000000000000001);
	else $display("Correct: Result: %h \n", outAB);

	inA = 64'h000000ff000000ff;
	inB = 64'h000000ff000000ff;
	opr = 5'b00011;

	$display("SUB TEST Positive Number");
	
	exeopr(inA, inB, opr);	

	if(outAB!=64'h0000000000000000) 
			$display("WRONG: Result: %h Expected Result: %h\n", outAB,64'h0000000000000000);
	else $display("Correct: Result: %h\n", outAB);

	inA = 64'hffffffffffffffff;
	inB = 64'h0000000100000001;
	opr = 5'b00011;

	$display("SUB TEST Negative Number");
	
	exeopr(inA, inB, opr);	

	if(outAB!=64'hfffffffefffffffe) 
			$display("WRONG: Result: %h Expected Result: %h\n", outAB,64'hfffffffefffffffe);
	else $display("Correct: Result: %h\n", outAB);

	inA = 64'h0000000100000001;
	inB = 64'h0000000100000001;
	opr = 5'b01000;

	$display("COMPARISON TEST");
	
	exeopr(inA, inB, opr);	

	if(outAB!=64'h0000000000000001) 
			$display("WRONG: Result: %h Expected Result: %h\n", outAB,64'h0000000000000001);
	else $display("Correct: Result: %h\n", outAB);
	
	inA = 64'h0000000fffffffff;
	inB = 64'h0000000300000002;
	opr = 5'b00110;

	$display("MULTIPLICATION TEST Negative Number");
	
	exeopr(inA, inB, opr);	

	if(outAB != {inA[63:32] * inB[63:32] , inA[31:0] * inB[31:0]}) 
			$display("WRONG: Result: %h Expected Result: %h\n", outAB,{inA[63:32] * inB[63:32] , inA[31:0] * inB[31:0]});
	else $display("Correct: Result: %h\n", outAB);

	inA = 64'h0000000100000003;
	inB = 64'h0000000200000002;
	opr = 5'b00100;

	$display("MULTIPLICATION TEST COMPLEX");

	exeopr(inA, inB, opr);	

	if(outAB != 64'hfffffffc00000008) 
			$display("WRONG: Result: %h Expected Result: %h \n", outAB,64'hfffffffc00000008);
	else $display("Correct: Result: %h \n", outAB);

	$display("Conversion to polar coords inA TEST");
	//123+j*456
	inA = 64'h0000007b000001c8;
	opr = 5'b01001;
	execcordic(inA[63:32],inA[31:0], opr);
	
	$display("\nConversion to polar coords inB TEST");
	inB = 64'h00000000ffffffff;
	opr = 5'b01010;
	execcordic(inB[63:32],inB[31:0], opr);

  #( 10*CLOCK_PERIOD );
  $stop;
  //$finish;   
end


//---------------------------------------------------
// Simulate the sequential controller
task exeopr;
input [63:0] inA;
input [63:0] inB;
input [ 4:0] opr;

begin
	inA = inA;
	inB = inB; 
	opr = opr;
	@(posedge clock);
	start = 1'b1;
	@(posedge clock);
	start = 1'b0;
	@(posedge clock);
  end  
endtask

	// set to zero to disable printing the simulation results 
	// by the task "execcordic"
	integer printresults = 1;

//--------------------------------------------------------------------
	// float parameters to convert the integer results to fractional results:
	real fracfactor = 1<<16;
	real fracfactorangle = 1<<24;
	real PI = 3.1415926536;
	
	// The X and Y in float format, required to compute the real values:
	real Xr, Yr;
	
	// The "true" values of modules, angle and the % errors:
	real real_mod, real_atan, err_mod, err_atan;
	
	//--------------------------------------------------------------------
	// Execute a CORDIC: 
	task execcordic;
	input signed [31:0] X;
	input signed [31:0] Y;
	input [ 4:0] opr;
	begin
		inA[63:32] = {X[15:0],16'd0}; // Apply operands {X[15:0],16'd0}
		inA[31:0] = {Y[15:0],16'd0}; 
		inB[63:32] = {X[15:0],16'd0}; // Apply operands {X[15:0],16'd0}
		inB[31:0] = {Y[15:0],16'd0};
		opr = opr;

	   @(posedge clock);
	   start = 1;
	   @(posedge clock);
	   start = 0;
	   
	   repeat( 32 )
	   	@(posedge clock);
	   
	   // Wait some clocks to separate the calls to the task
	   repeat( 10 )
	   	@(posedge clock);
	   
	   if ( printresults )
	   begin  
	   	// Calculate the expected results:
	   	  Xr = X[15:0];
	   	  Yr = Y[15:0];
	   	  //real_mod = $sqrt( Xr*Xr+Yr*Yr);
	   	  //real_atan = $atan2(Yr,Xr) * 180 / PI;
	   	 // err_mod = 100 * ( real_mod - (mod / fracfactor) ) / (mod / fracfactor);
	   	  //err_atan = 100 * ( real_atan - (angle / fracfactorangle) ) / (angle / fracfactorangle);

	   	  /*$display("Xi=%d, Yi = %d, Mod=%f  Angle=%f drg Exptd: M=%f, A=%f drg (ERRORs = %f%% %f%%)",
	   	  		       X, Y, mod/fracfactor, angle/fracfactorangle,
	   	  		       real_mod, real_atan, err_mod, err_atan );*/	
		  $display("Xi=%d, Yi = %d, Mod=%f  Angle=%f drg",
	   	  		       X, Y, mod/fracfactor, angle/fracfactorangle);	
	    end
	
	end
	endtask

endmodule

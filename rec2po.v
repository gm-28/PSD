`include "ATAN_ROM.v"
`include "ITERCOUNTER.v"
`include "MODSCALE.v"

module rec2pol( 
                input clock,
				input reset,
				input start,               // set to 1 for one clock to start 
				input  signed [31:0] x,    // X component, 16Q16
				input  signed [31:0] y,    // Y component, 16Q16
				output signed [31:0] mod,  // Modulus, 16Q16
				output signed [31:0] angle // Angle in degrees, 8Q24
			  );

wire [5:0] rom_addr;
wire signed [31:0] data_out_rom;

reg signed [33:0] xr;
reg signed [31:0] zr;
reg signed [33:0] yr;

ITERCOUNTER counter(clock, reset, start, rom_addr);
ATAN_ROM atan(rom_addr, data_out_rom);
MODSCALE scale(xr, mod);

assign angle = zr;


always @(posedge clock) 
	if (reset)
		zr <= 32'd0;
	else 
    begin
        if(start)
            zr <= 32'd0;
        else
            if(yr[33])
                zr <= zr - data_out_rom;
            else
                zr <= zr + data_out_rom;
    end

always @(posedge clock) 
	if (reset)
		zr <= 32'd0;
	else 
    begin
        if(start)
            zr <= 32'd0;
        else
            if(yr[33])
                zr <= zr - data_out_rom;
            else
                zr <= zr + data_out_rom;
    end

always @(posedge clock) 
	if (reset)
		yr <= 34'd0;
	else 
    begin
        if(start)
            yr <= y;
        else
            if(yr[33])
                yr <= yr + (xr >>> rom_addr);
            else
                yr <= yr - (xr >>> rom_addr);
    end

always @(posedge clock) 
	if (reset)
		xr <= 34'd0;
	else 
    begin
        if(start)
            xr <= x;
        else
            if(yr[33])
                xr <= xr - (yr >>> rom_addr);
            else
                xr <= xr + (yr >>> rom_addr);
    end

endmodule
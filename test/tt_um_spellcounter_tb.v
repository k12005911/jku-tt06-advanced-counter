`default_nettype none
`timescale 1us/1ns
`include "tt_um_spellcounter.v"


/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

// testbench is controlled by test.py
module tt_um_spellcounter_tb ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tt_um_spellcounter_tb.vcd");
        $dumpvars (0, tt_um_spellcounter_tb);
        #1;
    end

    // wire up the inputs and outputs
        
        
    
    reg [7:0] ui_in;    // Dedicated inputs - connected to the input switches
    wire [7:0] uo_out;   // Dedicated outputs - connected to the 7 segment display
    reg [7:0] uio_in;   // IOs: Bidirectional Input path
    wire [7:0] uio_out;  // IOs: Bidirectional Output path
    wire [7:0] uio_oe;   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    reg       ena;      // will go high when the design is enabled
    reg       clk;      // clock, 1MHz clock required
    reg       rst_n;    // reset_n - low to reset
    
//DUT
    tt_um_spellcounter spellcounter (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .ui_in      (ui_in),
        .uo_out      (uo_out),
        .uio_in      (uio_in),
        .uio_out      (uio_out),
        .uio_oe      (uio_oe),
        .ena      (ena),
        .clk      (clk),
        .rst_n      (rst_n)  
        );
	
	initial begin
	    ui_in = 8'b1111_1111;
	    uio_in = 8'b1111_1111;	//bit 0 = updown select -> upcount
	    ena = 1'b1;
	    rst_n = 1'b0;
	    clk = 1'b0;
	    
		#10; rst_n = 1'b1;
		
		#1000; ui_in = 8'b1111_0111;
		#1; ui_in = 8'b1111_1111;
		
		
		#1000000; $finish;
		
	end
	
	always #1 clk = ~clk;
	

endmodule

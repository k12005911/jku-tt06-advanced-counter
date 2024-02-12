`default_nettype none
`timescale 1us/1ns
`include "decodeshift.v"


/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

// testbench is controlled by test.py
module tb_decodeshift ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb_decodeshift.vcd");
        $dumpvars (0, tb_decodeshift);
        #1;
    end

    // wire up the inputs and outputs
        
    reg [31:0] cnt_in;
    reg clk;
    reg reset;
    reg trigger;
    
    wire [7:0] segOut;
    wire shiftOut;
        
//DUT
    decodeshift decodeshift (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .cnt_in      (cnt_in),    
        .clk     (clk),   
        .reset     (reset),   
        .trigger    (trigger),  
        .segOut     (segOut),   
        .shiftOut        (shiftOut)
        );

	
	initial begin


    	cnt_in= 24'h654321;
    	clk= 1'b0;
    	reset= 1'b1;
    	trigger= 1'b0;

		#10; reset = 1'b0;
		#40; trigger = 1'b1;
		#10; trigger = 1'b0;
		#300; trigger = 1'b1;
		#10; trigger = 1'b0;
		
		#300; $finish;
		
	end
	
	always #5 clk = ~clk;
	

endmodule

`default_nettype none
`timescale 1us/1ns
`include "clkscaler.v"


/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

// testbench is controlled by test.py
module tb_clkscaler ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb_clkscaler.vcd");
        $dumpvars (0, tb_clkscaler);
        #1;
    end

    // wire up the inputs and outputs
       
    reg clk;    
    reg reset;
    reg [5:0] trigger;   
    wire inc_clk;   
    wire ref_clk;   
        
        
//DUT
    clkscaler#(19'd12000, 19, 6) myclkscaler (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .clk      (clk),    
        .reset     (reset),   
        .trigger    (trigger),  
        .inc_clk     (inc_clk),   
        .ref_clk        (ref_clk)
        );


	
	initial begin


    	clk= 1'b0;
    	reset= 1'b1;
    	trigger= 1'b0;

	#10; reset = 1'b0;
	#100; trigger = 6'b000100;
	#12000; trigger = 6'b000000;
	#100; trigger = 6'b000100;
	#100; trigger = 6'b000000;
	#100; trigger = 6'b000100;
	
	#30000; $finish;
		
	end
	
	always #1 clk = ~clk;
	

endmodule

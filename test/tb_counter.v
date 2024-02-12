`default_nettype none
`timescale 1ns/1ps
`include "counter.v"


/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

// testbench is controlled by test.py
module tb_counter ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb_counter.vcd");
        $dumpvars (0, tb_counter);
        #1;
    end

    // wire up the inputs and outputs
        
    reg inc;
    reg up_down_sel;
    reg carry_en;
    reg carry_in;
    reg max_en;
    reg  [3:0] max_val;
    reg clk;
    reg reset;
    
    wire [3:0]cnt_out;
    wire carry_out;

//DUT
    counter counter (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .inc      (inc),    
        .up_down_sel     (up_down_sel),   
        .carry_en     (carry_en),   
        .carry_in    (carry_in),  
        .max_en     (max_en),   
        .max_val        (max_val),      
        .clk        (clk),      
        .reset      (reset),  
        .cnt_out    (cnt_out),
        .carry_out  (carry_out)   
        );

	initial begin
	    inc = 1'b0;
		forever begin
			#20 inc = ~inc;
			#10 inc = ~inc;
		end
	end
	
	initial begin

	    up_down_sel = 1'b0;
	    carry_en = 1'b0;
	    carry_in = 1'b0;
	    max_en = 1'b0;
	    max_val = 4'b0001;
	    clk = 1'b0;
	    reset = 1'b1;

		#10; reset = 1'b0;
		
		#400; carry_en = 1'b1;
		#400; carry_en = 1'b0;
		#10; max_en = 1'b1;
		#100; max_val = 4'b1000;
		#300; up_down_sel = 1'b1;
		
		#400; $finish;
		
	end
	
	always #5 clk = ~clk;
	

endmodule

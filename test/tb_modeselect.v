`default_nettype none
`timescale 1ns/1ps
`include "modeselect.v"


/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

// testbench is controlled by test.py
module tb_modeselect ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb_modeselect.vcd");
        $dumpvars (0, tb_modeselect);
        #1;
    end

    // wire up the inputs and outputs
        
    reg  [23:0] cnt_in; 	//button press for value change
    reg carry_set;
    reg max_set;
    reg refresh_limits;
    reg reset;
    reg clk;
    
    wire [23:0] max_out;
    wire max_en;
    wire carry_en;    
        

//DUT
    modeselect #(6) mymodeselect (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .cnt_in      (cnt_in),    
        .carry_set     (carry_set),   
        .max_set     (max_set), 
        .refresh_limits (refresh_limits),  
        .reset    (reset),  
        .clk     (clk),   
        .max_out        (max_out),      
        .max_en        (max_en),      
        .carry_en      (carry_en)
        );

	
	initial begin

		cnt_in = 24'h00_0000; 
    		carry_set = 1'b0;
    		max_set = 1'b0;
    		reset = 1'b1;
    		clk = 1'b0;
    		refresh_limits = 1'b0;
    		

		#10; reset = 1'b0;
		
		#10; carry_set = 1'b1;
		#20; carry_set = 1'b0;
		
		#10; max_set = 1'b1;
		#20; max_set = 1'b0;
		
		#10; max_set = 1'b1;
		#1;  carry_set = 1'b1;
		#20; max_set = 1'b0;
		#1;  carry_set = 1'b0;
		
		#10; cnt_in = 24'h123456;
		
		#10; refresh_limits = 1'b1;
		#10; refresh_limits = 1'b0;
		
		#10; carry_set = 1'b1;
		#20; carry_set = 1'b0;
		
		#10; max_set = 1'b1;
		#20; max_set = 1'b0;
		
		#10; max_set = 1'b1;
		#1;  carry_set = 1'b1;
		#20; max_set = 1'b0;
		#1;  carry_set = 1'b0;
		
		#10; cnt_in = 24'h004300;
		
		#10; refresh_limits = 1'b1;
		#10; refresh_limits = 1'b0;
		
		#10; carry_set = 1'b1;
		#20; carry_set = 1'b0;
		
		#10; max_set = 1'b1;
		#20; max_set = 1'b0;
		
		#10; max_set = 1'b1;
		#1;  carry_set = 1'b1;
		#20; max_set = 1'b0;
		#1;  carry_set = 1'b0;
		
		#20; carry_set = 1'b1;
		
		#10; cnt_in = 24'h204302;
		
		
		#10; refresh_limits = 1'b1;
		
		#10; cnt_in = 24'h20002;
		
		#10; refresh_limits = 1'b0;
		
		
		#20; carry_set = 1'b0;
		
		/*
		#30; carry_set = 1'b1;
		#80; carry_set = 1'b0;
		
		#10; cnt_in = 24'h00_0710; 
		
		#10; carry_set = 1'b1;
		#20; cnt_in = 24'h52_0710; 
		#80; carry_set = 1'b0;
		
		#10; cnt_in = 24'h40_0008; 
		#10; carry_set = 1'b1;
		#80; max_set = 1'b1;
		#80; carry_set = 1'b0;
		#20; cnt_in = 24'h52_0710; 
		#80; carry_set = 1'b1;
		#80; max_set = 1'b0;
		#80; carry_set = 1'b0;
		*/
		
		#80; $finish;
		
	end
	
	always #1 clk = ~clk;
	

endmodule

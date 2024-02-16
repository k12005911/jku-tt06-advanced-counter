`default_nettype none

module synchronizer #(parameter DIGITS = 6)(

   	//Inputs
    input wire [DIGITS-1:0] data_in,	//Asynchronous Parallel Data In
    
    input wire clk,			//System Clock
    input wire reset,			//System Reset
    
    	//Outputs
    output wire [DIGITS-1:0] data_out	//Synchronous Parallel Data Out
);

    	//Assisting Output Signals
    reg [DIGITS-1:0] data_state;

    always @(posedge reset or posedge (clk)) begin
    	if (reset) begin
    		data_state <= 'd0;
    	end else begin
    		data_state <= data_in;
    	end
    end
    
	//Assigning temporary signals to the outputs
    assign data_out = data_state;

endmodule

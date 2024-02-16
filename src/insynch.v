`default_nettype none

module synchronizer #(parameter DIGITS = 6)(

     
    input wire [DIGITS-1:0] data_in,
    input wire clk,
    input wire reset,
    
    output wire [DIGITS-1:0] data_out
);

    reg [DIGITS-1:0] data_state;

    always @(posedge reset or posedge (clk)) begin
    	if (reset) begin
    		data_state <= 'd0;
    	end else begin
    		data_state <= btn_in;
    	end
    end
    
    assign data_out = data_state;

endmodule

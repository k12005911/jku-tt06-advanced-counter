`default_nettype none

module insynch #(parameter DIGITS = 6)(

     
    input wire [DIGITS-1:0] btn_in,
    input wire clk,
    input wire reset,
    
    output wire [DIGITS-1:0] btn_out
);

    reg [DIGITS-1:0] btn_state;

    always @(posedge reset or posedge (clk)) begin
    	if (reset) begin
    		btn_state <= 'd0;
    	end else begin
    		btn_state <= btn_in;
    	end
    end
    
    assign btn_out = btn_state;

endmodule

`default_nettype none

module modeselect #(parameter DIGITS = 6)(

    input wire  [4*DIGITS-1:0] cnt_in, 	//button press for value change
    
    input wire carry_set,
    input wire max_set,
    input wire refresh_limits,
    
    input wire reset,
    input wire clk,
    
    output wire [4*DIGITS-1:0] max_out,
    
    output wire max_en,
    output wire carry_en
);
    reg [4*DIGITS-1:0] current_limit;
    reg [4*DIGITS-1:0] current_output;
    
    reg max_flag;
    reg carry_flag;
    
    integer j;
    
    always @(posedge reset or posedge clk) begin
    	if (reset) begin
    		max_flag <= 1'b0;
    		current_limit <= 'd0;
    		current_output <= 'd0;
    		carry_flag <= 1'b0;
    	end else begin
    		if (carry_set) begin
    			carry_flag <= 1'b1;
    			max_flag <= 1'b0;
    			for  (j = 0; j<4*DIGITS; j = j+4) begin
    				if (current_limit[j+:4] != 4'd0) begin
    					current_output [j] <= 1'b1;
    				end else begin 
 					current_output [j] <= 1'b0;
    				end
    			end
    		end else if (max_set) begin
    			carry_flag <= 1'b0;
    			max_flag <= 1'b1;
    			current_output <= current_limit;
    		end else begin
    			carry_flag <= 1'b0;
    			max_flag <= 1'b0;
    			current_output <= 'd0;
    		end
    		
    		if (refresh_limits) begin
    			current_limit <= cnt_in;
    		end
    	end
    end
    
    assign carry_en = carry_flag; 
    assign max_en = max_flag && !carry_flag;
    assign max_out = current_output;

endmodule

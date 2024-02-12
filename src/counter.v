`default_nettype none

module counter (

     
    input wire inc,
    input wire up_down_sel,
    input wire carry_en,
    input wire carry_in,
    input wire max_en,
    input wire  [3:0] max_val,
    input wire clk,
    input wire reset,
    
    output wire [3:0] cnt_out,
    output wire carry_out
);
    
    reg[3:0] cnt;
    reg carry;
    
    
    always @(posedge reset or posedge (clk)) begin
    	if (reset) begin
    		cnt <= 0;
    		carry <= 0;
    	end else begin
    		if (up_down_sel) begin
    			if (inc) begin
	    			if (cnt > 0) begin
	    				cnt <= cnt - 4'd1;
	    			end
    			end
    		end else begin  	
	    		if (inc && carry_in) begin
	    			if (max_en) begin
		    			if (cnt >= max_val-4'd2) begin
						cnt <= max_val;
		    			end else begin
	    					cnt <= cnt+4'd2;
	    				end
	    			end else if (carry_en) begin
	    				if (cnt >= 8) begin
	    					cnt <= cnt - 4'd8;
	    					carry <= 1;
	    				end else begin
	    					cnt <= cnt+4'd2;
	    				end
	    			end else begin
	    				if (cnt >= 8) begin
	    					cnt <= 4'd9;
	    				end else begin
	    					cnt <= cnt+4'd2;
	    				end
	    			end
	    		end else if (inc || carry_in) begin
	    			if (max_en) begin
		    			if (cnt >= max_val) begin
						cnt <= max_val;
		    			end else begin
	    					cnt <= cnt+4'd1;
	    				end
	    			end else if (carry_en) begin
	    				if (cnt >= 9) begin
	    					cnt <= cnt - 4'd9;
	    					carry <= 1'd1;
	    				end else begin
	    					cnt <= cnt+4'd1;
	    				end
	    			end else begin
	    				if (cnt >= 9) begin
	    					cnt <= 4'd9;
	    				end else begin
	    					cnt <= cnt+4'd1;
	    				end
	    			end
    			end else if (max_en && cnt > max_val) begin
    				cnt <= max_val;
    			end
		end
    	end
    end
    
    assign cnt_out = cnt;
    assign carry_out = (carry_en && max_val[0]) ? carry : 1'b0; 

endmodule

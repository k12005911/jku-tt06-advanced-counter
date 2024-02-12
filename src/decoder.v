
/*
      -- 1 --
     |       |
     6       2
     |       |
      -- 7 --
     |       |
     5       3
     |       |
      -- 4 --
*/

module decoder (
    input wire [3:0] bcd_in,
    output reg [6:0] segments
);

    always @(*) begin
        case(bcd_in)
            //                7654321
            //		      gfedcba
            0:  segments = 7'b0111111;
            1:  segments = 7'b0000110;
            2:  segments = 7'b1011011;
            3:  segments = 7'b1001111;
            4:  segments = 7'b1100110;
            5:  segments = 7'b1101101;
            6:  segments = 7'b1111101;
            7:  segments = 7'b0000111;
            8:  segments = 7'b1111111;
            9:  segments = 7'b1101111;
	    default:
                segments = 7'b1110001;	// Letter F in case of invalid input
        endcase
    end

endmodule


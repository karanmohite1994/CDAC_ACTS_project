module shiftin_reg
  // This is a shift register that receives data on the MOSI lines
  #(parameter DATA_WIDTH=8)
  (input clk,
   input rst,
   input shift_en,
   input din,
   output reg [DATA_WIDTH-1:0] dataout,
	output reg done
   );
	
   reg [3:0] count;
 
   always @(posedge clk or negedge rst) 
		begin  
			if(!rst) 
				begin 
					dataout <= 0;
					count  <= 0;
					done 	 <= 0;
				end
			else 
				begin
					if(shift_en) 
						begin
							if(count < 8 ) 
								begin
									dataout <= { dataout[DATA_WIDTH-2:0], din };
									count <= count + 1;
									done <= 0;
								end
				else 
					begin
						done 	<= 1;
						count	<= 0;
					end
				end
				
				else
					done <= 0;
				end
	end
endmodule

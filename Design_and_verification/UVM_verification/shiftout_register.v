
module shiftout_reg
// This is a shift register that sends data out to the miso lines 
  #(parameter DATA_WIDTH=8)
  (input clk,
   input rst,
   input [DATA_WIDTH-1:0] datain,
	input sample,
   input shift_en,
   output dout,
	output reg done
   );
	
	reg [3:0] 				count;
   reg [DATA_WIDTH-1:0] sh_reg;
	
   assign dout = sh_reg[DATA_WIDTH-1];
    
   always @(negedge clk or negedge rst or posedge sample) 
	begin
      if(!rst) 
			begin
				sh_reg <= 0;
				count <= 0; 
				done <= 0;
			end 
		else if(sample) 
			begin
				sh_reg <= datain;
				done <= 0;
			end
		else if(shift_en) 
			begin
				if(count < 8) 
					begin
						sh_reg 	<= sh_reg << 1;
						count 	<= count + 1;
						done 		<= 0;
					end
				else 
					begin
						done <= 1;
						count <= 0;
					end  
			end
		else
			done <= 0;
	end
endmodule
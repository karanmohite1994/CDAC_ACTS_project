
//freq divided by 2

module frequency_divider (  
		output out_clk,
      input  in_clk ,
		input  en,
      input  rst
	);

	reg 		temp_clk;

	assign 	out_clk = temp_clk;
	
	always @(posedge in_clk or negedge rst) 
		begin
			if (!rst)
				temp_clk <= 1'b0;
			else if(en)
				temp_clk <= ~out_clk;	
			else
				temp_clk <= 1'b0;
		end
		
endmodule


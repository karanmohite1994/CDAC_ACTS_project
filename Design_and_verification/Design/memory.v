module memory 
  # (parameter ADDR_WIDTH = 8,
     parameter DATA_WIDTH = 8,
     parameter DEPTH = 256 
    )
  
  ( 		input 					   clk,
   		input [ADDR_WIDTH-1:0]	addr,
   		inout [DATA_WIDTH-1:0]	data,
   		input 					   en,
   		input 					   wr_en,
   		input 					   rd_en
  );
  
  reg [DATA_WIDTH-1:0] 	tmp_data;
  reg [DATA_WIDTH-1:0] 	mem [0:DEPTH-1];			
  
  always @ (posedge clk) 
	  begin
		 if (en & wr_en & !rd_en)
			mem[addr] <= data;
	  end
  
  always @ (posedge clk) 
	  begin
		 if (en & rd_en & !wr_en)
			tmp_data <= mem[addr];
	  end
  
  assign data = en & rd_en ? tmp_data : 'hz;

endmodule

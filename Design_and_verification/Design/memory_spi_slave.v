
module memory_spi_slave(
		input   mosi,
		output  miso,
		input   clk,
		input   sclk,
		input   cs,
		input   rst
    );

//-----memory element-------------	
    reg  [7:0] address;
	 wire [7:0] mdata;
	 reg 			mem_wr, mem_rd;
	
//----------fsm states----------------
	
   localparam [3:0] start         = 4'b0000;
	localparam [3:0] Inst_shiftin  = 4'b0001;
	localparam [3:0] Adr_shiftin   = 4'b0010;
	localparam [3:0] Data_load     = 4'b0011;
	localparam [3:0] Data_shiftout = 4'b0100;
	localparam [3:0] waitst1       = 4'b0101;
	localparam [3:0] waitst2       = 4'b0110;
	localparam [3:0] Data_shiftin  = 4'b0111;
	localparam [3:0] waitst3       = 4'b1000;
	localparam [3:0] waitst4       = 4'b1001;
	 
	reg 	[3:0] nxtst;
	 
	reg 			mem_sin_en,mem_sout_en,mem_sample; 						//shiftin shiftout enables
	reg 			mem_en; 															//memory enable
	wire 			mem_sin_done,mem_sout_done;  
	reg 	[7:0] mem_data_shift;
	wire 	[7:0] datao;
	
	 assign mdata = (mem_wr && mem_en) ? datao : 'hz;					//when write enable and memory enable is high then 
																						// output data from shiftin reg will assign to memory data
	 memory m1( .clk(clk),.addr(address),.data(mdata),.en(mem_en),.wr_en(mem_wr),.rd_en(mem_rd));
	
	 shiftin_reg sr1(.clk(sclk),.rst(rst),.shift_en(mem_sin_en),.din(mosi),.dataout(datao),.done(mem_sin_done));  // shift in register
	
	 shiftout_reg sr2(.clk(sclk),.rst(rst),.datain(mem_data_shift),.sample(mem_sample),.shift_en(mem_sout_en),.dout(miso),.done(mem_sout_done)); // shift out register


	 always @(posedge clk or negedge rst) 
		 begin
			if(!rst) 
				begin
					nxtst           <= start;
					mem_sin_en      <= 1'b0;
					mem_sout_en     <= 1'b0;
					mem_sample      <= 1'b0;
					mem_data_shift  <= 1'b0;
					mem_en          <= 1'b0;
					mem_wr			 <= 1'b0;
					mem_rd 		    <= 1'b0;
				end
			
		else if(!cs) 
		begin
			case(nxtst)
				start         	:	begin
											 mem_en         <= 0;
											 mem_sout_en    <= 0; 
											 mem_sin_en     <= 0;
											 mem_sample     <= 1'b0;
											 mem_wr	       <= 1'b0;
											 mem_rd 	       <= 1'b0;
											 mem_data_shift <= 0;
											 nxtst          <= Inst_shiftin;									 
										end
									 
				Inst_shiftin  	: begin
										mem_sin_en <= 1;								//enabling shiftin register 
										 if(mem_sin_done == 1) 
											 begin // check for shifting in is done
												{mem_wr,mem_rd} <= datao[1:0];
												mem_sin_en <= 0; 						//disable shiftin register 
												nxtst <= waitst1;
											 end
										else
											nxtst <= Inst_shiftin;
									end
									 
				waitst1		  : begin 
										nxtst <= waitst2; 							// wait for one clock cycle
									 end
									 
				waitst2       : begin
									 nxtst <= Adr_shiftin;							// wait for one clock cycle
									 end
				
				Adr_shiftin   : begin
										mem_sin_en <= 1;								//enabling shiftin register 
									 if(mem_sin_done == 1) 
										 begin 											// check for shifting in is done
												address <= datao;
												mem_sin_en <= 0; 						// disable shift register
											if({mem_wr,mem_rd} == 2'b01) 
												begin 									// read mode
													nxtst <= waitst4;
													mem_en <= 1;
												end
											else if({mem_wr,mem_rd} == 2'b10) 	//write mode
														nxtst <= waitst3;
												end
											else
														nxtst <= Adr_shiftin;
									 end
									 
				waitst3       : begin
										nxtst <= Data_shiftin;						// wait for one clock cycle
									 end
									 
				Data_shiftin  : begin
										mem_sin_en   <= 1;								//enabling shiftin register 
									 if(mem_sin_done == 1) 
										 begin 												// check for shifting in is done
											mem_en     <= 1;
											mem_sin_en <= 0; 								//disable shiftin register 
											nxtst  <= start;
										 end
									 else
										nxtst <= Data_shiftin;
									 end
									 
			   waitst4       : begin
										nxtst <= Data_load;								// wait for one clock cycle
									 end
									 
				Data_load     : begin
										 mem_data_shift <= mdata;
										 mem_sample <= 1; 								// sample enable
										 mem_en     <= 0; 								// disable memory
										 nxtst <= Data_shiftout;
									 end
									 
				Data_shiftout : begin
										 mem_sample <= 0;  								//enable sampling
										 mem_sout_en <= 1;								// enable shift registers
									 if(mem_sout_done == 1) 
										 begin
											mem_sout_en <= 0;
											nxtst <= start;
										 end
									 else
											nxtst <= Data_shiftout;
									 end
									 
				default       : nxtst <= start;
				
			endcase
		end
		else	
			begin
				nxtst <= start;
			end
	end
endmodule

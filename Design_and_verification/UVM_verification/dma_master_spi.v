
/*
s[0] ---> memory
s[1] ---> IO1
s[2] ---> IO2
s[3] ---> IO3
s[4] ---> IO4

spi_mode cpol cpha
   0      0    0
Data sampled on rising edge and shifted out on the falling edge 

Mode set register

*/

module dma_spi_master(
	//-----SPI signals---------
	input     			MISO, 						//master in slave out
	output         	MOSI, 						//master out slave in
	output   	[4:0] SS,
	output         	sclk, 						// spi clock
						
	//-----DMA signals-----------
	input					clk, 							//system clock
	input     	     	rst,
	output    			BREQ,							//bus request
	input 				BGNT,							//bus grant
	input   		[7:0] data,
	input  		[3:0] DREQ,							//DMA IO device request
	input      	[1:0] DS,							//data select
	output reg 	[3:0] DACK,							//DMA acknowledge
	output reg       	dma_busy,
   output reg       	dma_done	
    );
	 
	reg 			[7:0] addr;    					// address register
	reg 			[3:0] data_cnt;  					//data count
	reg 			[7:0] ch_sel;  					// channel select
	reg 			[7:0] mode_set;					// mode set registers
	

	wire 			[3:0] DGNT; 						// IO device grant 
	wire 					rt_pri;						//rotating priority enable
	wire 					pr_en; 						// priority enable
	wire 					out_clk;
	//-------------------spi-------------------------
	reg 			[4:0] slave;
	reg 			[3:0] spi_cnt;
	reg 			[7:0] spi_addr,data_shift,data_out;
	reg 					dma_sin_en,dma_sout_en,dma_sample; 				//spi shift register enables
	wire 					dma_sin_done,dma_sout_done; 						// spi shift done flag
	reg 					spi_done;

	//spi FSM local parameter
	localparam [4:0] mem_read_st       = 5'b00000;
	localparam [4:0] mem_write_st      = 5'b00001;
	localparam [4:0] io_read_st        = 5'b00010;
	localparam [4:0] io_write_st       = 5'b00011;
	localparam [4:0] startm            = 5'b00100;
	localparam [4:0] startio           = 5'b00101;
	localparam [4:0] mem_check         = 5'b00110;
	localparam [4:0] Ist_load_m        = 5'b00111;
	localparam [4:0] Ist_shiftout_m    = 5'b01000;
	localparam [4:0] Adr_shiftout_m    = 5'b01001;
	localparam [4:0] Adr_load_m        = 5'b01010;
	localparam [4:0] data_shiftin_m    = 5'b01011;
	localparam [4:0] Ist_load_io       = 5'b01100;
	localparam [4:0] Ist_shiftout_io   = 5'b01101;
	localparam [4:0] waitst1           = 5'b01110;
	localparam [4:0] waitst2           = 5'b01111;
	localparam [4:0] Adr_shiftout_io   = 5'b10000;
	localparam [4:0] Adr_load_io       = 5'b10001;
	localparam [4:0] Data_load_io      = 5'b10010;
	localparam [4:0] Data_shiftout_io  = 5'b10011;
	localparam [4:0] Data_shiftin_io   = 5'b10100; 
	localparam [4:0] check_io          = 5'b10101;
	localparam [4:0] stop              = 5'b10110;
	localparam [4:0] Data_shiftout_m   = 5'b10111;
	localparam [4:0] waitst3           = 5'b11000;
	localparam [4:0] waitst4           = 5'b11001;
   localparam [4:0] Data_load_m       = 5'b11010;
	localparam [4:0] waitst5           = 5'b11011;
	localparam [4:0] waitst6           = 5'b11100;
	reg 		  [4:0] nstate1,nstate2;
	
	//------------------------------------------------
	assign 	sclk 		= out_clk;
	assign 	rt_pri 	= ch_sel[4];
	assign	SS 		= slave;
	
	assign pr_en = (DREQ > 0 && !BGNT) ? 1'b1 : 1'b0; 		//enable priority resolver when DMA requests and no bus grant
	assign BREQ  = (DGNT > 0 ) ? 1'b1 : 1'b0; 				//send Bus request when DMA grant is generated and bus grant is low

//--------fifo reg---------
	reg 			fifo_wr,fifo_rd; 									//fifo read write enable
	wire [7:0] 	fifo_dataout,fifo_datain; 						// fifo in/out data
	wire 			fifo_emp,fifo_full;								//fifo empty and full
 
   //------------frequency divider------------------------
	frequency_divider fd(.out_clk(out_clk),.in_clk(clk),.en(dma_sin_en || dma_sout_en),.rst(rst) ); 		
	
	shiftin_reg 		sr1		(.clk(out_clk),.rst(rst),.shift_en(dma_sin_en),.din(MISO),.dataout(fifo_datain),.done(dma_sin_done));  // shift in register
	shiftout_reg 		sr2		(.clk(out_clk),.rst(rst),.datain(data_shift),.sample(dma_sample),.shift_en(dma_sout_en),.dout(MOSI),.done(dma_sout_done)); // shift out register
	
   FIFO_Buf 			data_buf	(.clk(clk),.rst(rst),.wr_en(fifo_wr),.data(fifo_datain),.full_o(fifo_full),.rd_en(fifo_rd),.data_out(fifo_dataout),.empty(fifo_emp));
   
	priority_resolver prd		(.gnt(DGNT),.req(DREQ),.clk(clk),.rst(rst),.rot_en(rt_pri),.pr_en(pr_en));

	//initial $monitor("nstate1=%0b nstate2=%0b slave=%0b addr=%0b data_cnt=%0b ch_sel=%0b mode_sel=%0b",nstate1,nstate2,slave,addr,data_cnt,ch_sel,mode_set);
	always @(posedge clk or negedge rst) 
		begin
			if(!rst) 
				begin //active low reset
					addr       <= 8'h0;
					data_cnt   <= 4'h0;
					ch_sel     <= 8'h0;
					DACK       <= 4'b1111;
					slave	   <= 5'b11111;
					dma_busy   <= 1'b0;
					nstate1    <= mem_read_st;
					nstate2    <= io_read_st;
					addr       <= 0;    // address register
					data_cnt   <= 0;  //data count
					ch_sel     <= 0;  // channel select
					mode_set   <= 0;
					fifo_wr    <= 0;
					fifo_rd    <= 0;
					dma_sin_en <= 0;
					dma_sout_en <= 0;
					dma_sample <= 0;
					spi_cnt    <= 0;
					spi_addr   <= 0;
					data_shift <= 0;
					data_out   <= 0;
				end
		
		else if(!BGNT) 
			begin
			dma_busy   <= 0;
			nstate1    <= mem_read_st;
			nstate2    <= io_read_st;
			dma_done   <= 0;
			slave      <= 5'b11111;
			
			case (DS)
				2'b00 : addr     <= data;
				2'b01 : data_cnt <= data;
				2'b10 : ch_sel   <= data;
				2'b11 : mode_set <= data;
			endcase
		end
		
		else if(BGNT) 
			begin
				dma_busy <= 1'b1;
				case (DGNT) //active low ack IO devices
					4'b1000 :begin DACK <= 4'b0111; if(mode_set[3:0] == 4'b0110) ch_sel[3:0] <= DGNT; end
					4'b0100 :begin DACK <= 4'b1011; if(mode_set[3:0] == 4'b0110) ch_sel[3:0] <= DGNT; end
					4'b0010 :begin DACK <= 4'b1101; if(mode_set[3:0] == 4'b0110) ch_sel[3:0] <= DGNT; end
					4'b0001 :begin DACK <= 4'b1110; if(mode_set[3:0] == 4'b0110) ch_sel[3:0] <= DGNT; end
					default : DACK <= 4'b1111;
				endcase
			
//------------read write unit----------------------------------
            
			if(mode_set[3:0] == 4'b1001) begin//memory read IO device write
			//$display("memory read IO device write");
				case (nstate1)
					mem_read_st : begin 											//memory select in read mode
										dma_busy <= 1;
										fifo_wr  <= 0;
										fifo_rd  <= 0;
										dma_sin_en   <= 0;
										dma_sout_en  <= 0;
										dma_sample   <= 0;
										spi_cnt  <= data_cnt;
										spi_addr <= addr;
										data_shift <= 0;
										if(dma_done == 0)
											nstate1  <= startm;
										else
											nstate1  <= mem_read_st;
									end
					
					startm   : begin
										slave     <= 5'b11110;
										spi_cnt   <= spi_cnt - 1;
										nstate1   <= Ist_load_m;
							      end
				
				Ist_load_m  : begin 												//instruction load
										dma_sample <= 1;
										data_shift <= 8'h1; 						// read instruction
										nstate1 <= Ist_shiftout_m;
							      end
			
			Ist_shiftout_m : begin 												// instruction shift out 
										dma_sout_en <= 1;							//enabling shifting
										dma_sample  <= 0;							//disable sample
											if(dma_sout_done == 1'b1) 
												begin 								//check for shifting out done
													nstate1 <= Adr_load_m;
													dma_sout_en <= 0;
												end
											else
											nstate1 <= Ist_shiftout_m;
									end
				 
				 Adr_load_m :  begin 											// address load 
										dma_sample <= 1; 							//sampling in shiftout register is enable
										data_shift <= spi_addr;
										spi_addr <= spi_addr + 1; 				// increment address
										nstate1 <= Adr_shiftout_m;
									end
			
			Adr_shiftout_m : begin 												// address shift out
											dma_sample  <= 0;
											dma_sout_en <= 1; 						// enable the shiftout register
										if(dma_sout_done == 1'b1) 
											begin 										//checking for shifting out is done
												nstate1 <= waitst1;
												dma_sout_en <= 0;
											end
										else
											nstate1 <= Adr_shiftout_m;
									end
					
					waitst1  : 	begin
										nstate1 <= data_shiftin_m;
									end
			
			data_shiftin_m : begin
										dma_sin_en <= 1;							//enabling shiftin register 
									if(dma_sin_done == 1) 
										begin 										// check for shifting in is done
											fifo_wr <= 1; 							// enable fifo in write mode
											fifo_rd <= 0;
											nstate1 <= mem_check;
											dma_sin_en <= 0; 
										end
									else
										nstate1 <= data_shiftin_m;
									end
				   
					mem_check : begin
										fifo_wr <= 0;
										slave <= 5'b11111;
									if(spi_cnt == 0) 							// check for data reading is done 
										nstate1 <= io_write_st; 
									else
										begin
											nstate1 <= startm;
										end
									end
									
				io_write_st  : begin  										// IO device write 
										nstate1  <= startio;
										spi_cnt  <= data_cnt; 				// setting data count value
									end
									
					startio   : begin 
										slave   <= ~{ch_sel[3:0],1'b0}; 	// selecting IO device
										spi_cnt <= spi_cnt - 1;        
										nstate1 <= Ist_load_io;
									end
									
				Ist_load_io  : begin 										// instruction load
										dma_sample <= 1;
										data_shift <= 8'h2; 					// write instruction
										nstate1    <= Ist_shiftout_io;
									end
									
		Ist_shiftout_io    : begin
										dma_sout_en <= 1;
										dma_sample  <= 0;
									if(dma_sout_done == 1'b1) 
										begin
											dma_sout_en <= 0;
											fifo_rd <= 1;
											fifo_wr <= 0;
											nstate1 <= waitst6;
										end
									else
										nstate1 <= Ist_shiftout_io;
									end
				
					waitst6   : begin
										nstate1 <= Data_load_io;
										fifo_rd <= 0;
										fifo_wr <= 0;
									end
									
			  Data_load_io  : begin 										// address load 
										dma_sample <= 1;
										//fifo_rd <= 0;
										data_shift <= fifo_dataout;
										nstate1 <= Data_shiftout_io;
									end
									
		Data_shiftout_io   : begin
										fifo_rd <= 0;
										dma_sout_en <= 1;
										dma_sample  <= 0;
									if(dma_sout_done == 1'b1) 
										begin
											nstate1 <= check_io;
											dma_sout_en <= 0;
										end
									else
										nstate1 <= Data_shiftout_io;
									end
									
					check_io  : begin
										if(fifo_emp == 1)
											nstate1 <= stop;
									else
										nstate1 <= startio;
									end
									
						stop   : begin
										dma_done <= 1;
										dma_busy <= 0;
										nstate1 <= mem_read_st;
									end
									
						default: nstate1 <= mem_read_st;
				endcase
		
			end 
//-----------------------------------------------			
			else if(mode_set[3:0] == 4'b0110) begin 					//I/O AND WRITE INTO MEMORY  
				//$display("I/O AND WRITE INTO MEMORY");
				case (nstate2)			
								
		        io_read_st : begin    				  					//I/0 select in read mode
										spi_cnt  <= data_cnt;  				// Store how much data we want to transfer
										nstate2  <= startio;
										dma_busy <= 1;
										fifo_wr  <= 0;
										fifo_rd  <= 0;
										dma_sin_en   <= 0;
										dma_sout_en  <= 0;
										dma_sample   <= 0;
									if(dma_done == 0)//
										nstate2  <= startio;
									else
										nstate2  <= io_read_st;//
				               end
									
		         startio   : begin
										slave   <= ~{ch_sel[3:0],1'b0}; 		// selecting IO device.and lsb refers to memory select
										spi_cnt <= spi_cnt - 1;        		//decrement count value after every transacation 
										data_shift <= 8'h1; 
										nstate2 <= Ist_load_io;
                           end
									
		      Ist_load_io  : begin                                 	//instruction load
										dma_sample     <= 1;
										data_shift <= 8'h1;  					// read instruction
										nstate2    <= Ist_shiftout_io;
				               end
									
		   Ist_shiftout_io : begin                                  // instruction shift out
										dma_sout_en <= 1;                   //enabling shifting
										dma_sample  <= 0;                   //disable sample
				               if(dma_sout_done == 1'b1) 
										begin        								//check for shifting out done
											nstate2 <= waitst2 ;
											dma_sout_en <= 0;
										end
									else
										nstate2 <= Ist_shiftout_io;
									end
									
				waitst2     : begin
										nstate2 <= waitst3 ;
								  end 
								  
				waitst3     : begin
									nstate2 <= Data_shiftin_io;
								  end
								  
		Data_shiftin_io   : begin
										dma_sin_en <= 1;								//enabling shiftin register 
								  if(dma_sin_done == 1) 
									  begin 												// check for shifting in is done
										  fifo_wr <= 1; 								// enable fifo in write mode
										  fifo_rd <= 0;
										  nstate2 <= check_io;
										  dma_sin_en <= 0;
									  end
								  else
											nstate2 <= Data_shiftin_io;
								  end
								  
		         check_io : begin
										fifo_wr <= 0;
									if(spi_cnt == 0) 
										begin 											// check for data reading is done 
										  nstate2 <=mem_write_st; 
										  slave <= 5'b11111;
										end
								  else begin
								    nstate2 <= startio;
								  end
								  end
								  
           mem_write_st : begin                        					//memory select in write mode
									  spi_cnt  <= data_cnt;
									  spi_addr <= addr;
									  nstate2  <= startm;
				              end
								  
		        startm    : begin
									  slave     <= 5'b11110;
									  spi_cnt   <= spi_cnt - 1;
									  data_shift <= 8'h2;           					// write instruction
									  nstate2   <= Ist_load_m;
                          end
								  
			   Ist_load_m  : begin      												//instruction load
									  dma_sample <= 1;
									  nstate2 <= Ist_shiftout_m;
				              end
								  
		   Ist_shiftout_m : begin                                       	// instruction shift out 
									  dma_sout_en <= 1;                       	//enabling shifting
									  dma_sample  <= 0;                       	//disable sample
					           if(dma_sout_done == 1'b1) 
									  begin             									//check for shifting out done
										  dma_sout_en <= 0;
										  nstate2 <= waitst4;
									  end
								  else
											nstate2 <= Ist_shiftout_m;
								  end
				
					waitst4	: begin
								  nstate2 <=  Adr_load_m;
								  end
								  
		       Adr_load_m : begin     												// address load 
									  dma_sample <= 1;               					//sampling in shiftout register is enable
									  data_shift <= spi_addr;
									  spi_addr <= spi_addr + 1;     						// increment address
									  nstate2 <= Adr_shiftout_m;
								  end
								  
			Adr_shiftout_m : begin      // address shift out
									  dma_sample  <= 0;
									  dma_sout_en <= 1;        						// enable the shiftout register
								  if(dma_sout_done == 1'b1) 
									  begin 													//checking for shifting out is done
										  nstate2 <= waitst5;
										  fifo_wr <= 0; 
										  fifo_rd <= 1;  									// enable fifo in read mode
										  dma_sout_en <= 0;
									  end
				              else
											nstate2 <= Adr_shiftout_m;
								  end
					waitst5  : begin
									  nstate2 <= Data_load_m;
									  fifo_wr <= 0; 
									  fifo_rd <= 0;  									// enable fifo in read mode
								  end
			 Data_load_m 	: begin
									  dma_sample <= 1;               			//sampling in shiftout register is enable
									  fifo_rd <= 0;
									  data_shift <= fifo_dataout;
									  nstate2 <= Data_shiftout_m;
								  end
								  
		Data_shiftout_m   : begin
									  dma_sout_en <= 1;              //enabling shiftin register 
									  dma_sample <= 0;
					           if(dma_sout_done == 1) 
									  begin 									// check for shifting in is done
										  nstate2 <= mem_check;
										  dma_sout_en <= 0;
									  end
				              else
								     nstate2 <= Data_shiftout_m;
								  end
								  
		        mem_check : begin
									  if(spi_cnt == 0) 
										  begin           				// check for data writing is done 
											  nstate2 <= stop;   
											  slave <= 5'b11111;
										  end
										else 
											begin
												  nstate2 <= startm;
											end 
										end
								  
					  stop   : begin
									  dma_done <= 1;
									  dma_busy <= 0;
									  nstate2 <= io_read_st;
							     end

				endcase   
			end
		end
	end
	
endmodule


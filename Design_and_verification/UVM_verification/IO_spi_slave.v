
module IO_spi_slave(
	 //-----SPI Signal-------
	 input        MOSI,
	 output       MISO,
	 input        sclk,
	 input        cs,
	 
	 //-----IO signals--------
	 input         clk,
	 input         wr_en,
	 input         rst,
	 input         rd_en,
	 input         wreq, // write request
	 input  [7:0]  indata_tx,
	 output [7:0]  outdata_rx,
	 output        DREQ,
	 input         DACK,
	 output        io_full,
	 output 			io_empty
    );

	 reg 				io_wr, io_rd;
	 reg 				io_en;
//--------------------------
	// reg miso_reg;
	 
    localparam [3:0] start         = 4'b0000;
	 localparam [3:0] Inst_shiftin  = 4'b0001;
	 localparam [3:0] Data_load     = 4'b0011;
	 localparam [3:0] Data_shiftout = 4'b0100;
	 localparam [3:0] check_st      = 4'b0101;
	 localparam [3:0] waitst1       = 4'b0110;
	 localparam [3:0] waitst2       = 4'b0111;
	 localparam [3:0] Data_shiftin  = 4'b1000;
	 reg 			[3:0] nxtst;
	 
	 reg 					io_sin_en,io_sout_en,io_sample; 				//shiftin shiftout enables
	 wire 				io_sin_done,io_sout_done;  
	 wire [7:0] 		io_data_shift;
	 wire [7:0] 		data_shiftin, dataio_out;
	  
	 assign DREQ = wreq; 													//requesting to DMA
	 assign io_data_shift = dataio_out;
	 
	iodevice m1( .clk(clk), .rst(rst), .rdtx(io_rd && io_en) ,.wrtx(wr_en), .indata_tx(indata_tx), .outdata_tx(dataio_out), .rdrx(rd_en), .wrrx(io_wr && io_en), .indata_rx(data_shiftin), .outdata_rx(outdata_rx), .fulltx(io_full), .emptyrx(io_empty));
	
	shiftin_reg sr1(.clk(sclk),.rst(rst),.shift_en(io_sin_en),.din(MOSI),.dataout(data_shiftin),.done(io_sin_done));  // shift in register
	
	shiftout_reg sr2(.clk(sclk),.rst(rst),.datain(io_data_shift),.sample(io_sample),.shift_en(io_sout_en),.dout(MISO),.done(io_sout_done)); // shift out register

  
	always @(posedge clk or negedge rst) begin
		if(!rst) 
			begin
				nxtst      <= start;
				io_sin_en  <= 1'b0;
				io_sout_en <= 1'b0;
				io_sample  <= 1'b0;
				io_wr      <= 1'b0;
				io_rd      <= 1'b0;
				io_en      <= 1'b0;
				//data_shift <= 1'b0;
			end
			
		else if(!cs) 
			begin 
				case(nxtst)
					start         : begin
											 io_sout_en <= 0; 
											 io_sin_en  <= 0;
											 io_en      <= 0;
											 io_sample  <= 0;
											 io_wr      <= 0;
											 io_rd      <= 0;
											 io_en      <= 0;
											 nxtst  <= Inst_shiftin;
										 end
										 
					Inst_shiftin  : begin
											 io_sin_en <= 1;									//enabling shiftin register 
											 if(io_sin_done == 1) 
												begin 											// check for shifting in is done
													{io_wr,io_rd} <= data_shiftin[1:0];
													io_sin_en <= 0; 							//disable shiftin register 
													nxtst <= check_st;
												end
										 else
													nxtst <= Inst_shiftin;
										 end
										 
					check_st		  : begin 
											if({io_wr,io_rd} == 2'b01) 
											 begin 													//check for read 
																										//	data_shift <= dataio_out;
												nxtst <= Data_load;
												io_en  <= 1;
											 end
										 else if({io_wr,io_rd} == 2'b10) 
											 begin													//check for write
												nxtst <= waitst2;
											 end
										 end
										 
					waitst2       : begin  
											nxtst <= Data_shiftin;
										 end
										 
					Data_shiftin  : begin
											 io_sin_en <= 1;										//enabling shiftin register 
											 if(io_sin_done == 1) 
												 begin 												// check for shifting in is done
													io_en  <= 1; 									//enable memory
													io_sin_en <= 0; 								// disable shift register
													nxtst <= start;
												 end
											 else
													nxtst <= Data_shiftin;
										 end
										 
					Data_load     : begin
											// data_shift <= dataio_out;
											 io_en <= 0; 
											 nxtst <= waitst1;
										 end
										 
					waitst1        : begin 
											 io_en <= 0;
											 io_sample <= 1; // sample enable
											 nxtst <= Data_shiftout;
										 end	
										 
					Data_shiftout : begin
											 io_sample  <= 0;  //enable sampling
											 io_sout_en <= 1;// enable shift registers
										 if(io_sout_done == 1) 
											 begin
												io_sout_en <= 0;
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
			nxtst 		<= start;
		   io_sin_en  	<= 1'b0;
			io_sout_en 	<= 1'b0;
			io_sample  	<= 1'b0;
			io_wr      	<= 1'b0;
			io_rd      	<= 1'b0;
			io_en      	<= 1'b0;
		end
	end
endmodule

/*
module test_dma_spi;
	reg        clock, reset, HLDA;//Hold ACk
	reg  [7:0] data;
	reg  [1:0] DSel;//data select
	wire       Dbusy, HRQ;//Hold request
	wire       dma_done;
	wire       sclock;
	 
//-------IO device 0--------------
	reg        wr0, rd0, wreq0;
	reg  [7:0] indata0;
	wire [7:0] outdata0;
	wire       io_full0,io_empty0 ;
//-------IO device 1--------------
	reg        	wr1, rd1, wreq1;  
	reg 	[7:0] indata1;
	wire	[7:0] outdata1; 
	wire       	io_full1,io_empty1;
//-------IO device 2-------------- 
	 reg        wr2, rd2, wreq2; 
	 reg  [7:0] indata2;
	 wire [7:0] outdata2;
	 wire       io_full2,io_empty2;
//-------IO device 3--------------
	 reg       	wr3, rd3, wreq3; 
	 reg  [7:0] indata3;
	 wire [7:0] outdata3;
	 wire       io_full3,io_empty3 ;
	 
	 event ev1;
//--------temp--------------------
	wire MOSI,MISO;
	
	dma_top dut(
//-------DMA signals------------
	 clock, reset, HLDA,			//Hold ACk
	 data,
	 DSel,							//data select
	 Dbusy, HRQ,					//Hold request
	 dma_done,
    sclock,
	 
//-------IO device 0--------------
	 wr0, rd0, wreq0, 
	 indata0,
	 outdata0,
    io_full0,io_empty0 ,
//-------IO device 1--------------
    wr1, rd1, wreq1,   
    indata1,
    outdata1, 
	  io_full1,io_empty1,
//-------IO device 2-------------- 
	 wr2, rd2, wreq2, 
	 indata2,
	 outdata2,
	 io_full2,io_empty2, 
//-------IO device 3--------------
	 wr3, rd3, wreq3, 
	 indata3,
	 outdata3,
	 io_full3,io_empty3 ,
	 
//--------temp--------------------
	 MOSI,MISO
    ); 


	 initial 
		 begin
					clock=0;	reset=0;  		HLDA=0;
			#10 	reset=1; indata0=8'h13;
					rd0=0;	rd1=0; rd2=0; 	rd3=0;
		 end
	 
	 initial 	
		forever #5 clock = ~clock;
	 
	 always@(posedge clock) 
		 begin
			if(dma_done == 1) 
				begin
					HLDA = 0;
					-> ev1;
				end
			if(io_empty0) 
				begin
					rd0=1;
				end
		 end	
	 initial 
		begin
			#10 
			 @(posedge clock);
			 DSel=0; data=8'h6; 
			 
			 @(posedge clock);
			 DSel=1; data=1;
			 
			 @(posedge clock);
			 DSel=2; data=8'b00000001;
			 
			 @(posedge clock);
			 DSel=3; data=8'b00000110;
			 
			 @(posedge clock);
			 #5
			 @(posedge clock);
			 
			 wr0 = 1;  
			 @(posedge clock);
			 
			 wr0 = 0;
			 @(posedge clock);
			 
			 HLDA = 1;
			 
			 @(ev1) 

			 @(posedge clock);
			 DSel=0; data=8'h6; 
			 
			 @(posedge clock);
			 DSel=1; data=1;
			 
			 @(posedge clock);
			 DSel=2; data=8'b00000001;
			 
			 @(posedge clock);
			 DSel=3; data=8'b00001001;
			 
			 @(posedge clock);
			 HLDA = 1;
			 
		end
endmodule
*/
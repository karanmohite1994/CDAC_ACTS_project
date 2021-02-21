
module dma_top(
//-------DMA signals------------
	input        clock, reset, HLDA,//Hold ACk  
	input  [7:0] datain, 
	input  [1:0] DSel,//data select
	output       Dbusy, HRQ,//Hold request
	output       dma_done,
	output       sclock, // slave clock
	 
//-------IO device 0--------------
	input        wr0, rd0, wreq0, 
	input  [7:0] indata0,
	output [7:0] outdata0,
	output       io_full0,io_empty0 ,
//-------IO device 1--------------
	input        wr1, rd1, wreq1,   
	input  [7:0] indata1,
	output [7:0] outdata1,  
	output       io_full1,io_empty1,
//-------IO device 2-------------- 
	input        wr2, rd2, wreq2, 
	input  [7:0] indata2,
	output [7:0] outdata2,
	output       io_full2,io_empty2, 
//-------IO device 3--------------
	input        wr3, rd3, wreq3, 
	input  [7:0] indata3,
	output [7:0] outdata3,
	output       io_full3,io_empty3 ,
	 
//--------temp--------------------
	output MOSI,MISO
    );   
    
	wire 			sck;
	wire [4:0] 	slave;  
	wire [3:0] 	D_REQ, D_ACK; 
	
	wire 		msi;
	wire 		mso_slave_io0, mso_slave_io1,mso_slave_io2, mso_slave_io3, mso_slave_memory;	//miso slave
	assign 	MISO 	= slave[0]==0 ? mso_slave_memory : slave[1]==0 ? mso_slave_io0 : slave[2]==0 ? mso_slave_io1 : slave[3]==0 ? mso_slave_io2 : mso_slave_io3;
	assign 	MOSI 	= msi; 
	assign 	sclock 	= sck; 
	
	dma_spi_master dm(.MISO(MISO),.MOSI(msi),.SS(slave),.sclk(sck),.clk(clock),.BREQ(HRQ),.rst(reset),.BGNT(HLDA),.data(datain), .DREQ(D_REQ), .DS(DSel), .DACK(D_ACK),.dma_busy(Dbusy),.dma_done(dma_done)	); //dma master
	
	memory_spi_slave ms1(.mosi(msi),.miso(mso_slave_memory),.sclk(sck),.clk(clock),.cs(slave[0]),.rst(reset)); // memory slave
	
	IO_spi_slave ios0(.MOSI(msi),.MISO(mso_slave_io0),.sclk(sck),.clk(clock),.cs(slave[1]),.wr_en(wr0),.rst(reset),.rd_en(rd0),.wreq(wreq0), .indata_tx(indata0), .outdata_rx(outdata0), .DREQ(D_REQ[0]), .DACK(D_ACK[0]), .io_full(io_full0), .io_empty(io_empty0) );
   IO_spi_slave ios1(.MOSI(msi),.MISO(mso_slave_io1),.sclk(sck),.clk(clock),.cs(slave[2]),.wr_en(wr1),.rst(reset),.rd_en(rd1),.wreq(wreq1), .indata_tx(indata1), .outdata_rx(outdata1), .DREQ(D_REQ[1]), .DACK(D_ACK[1]), .io_full(io_full1), .io_empty(io_empty1) );
	IO_spi_slave ios2(.MOSI(msi),.MISO(mso_slave_io2),.sclk(sck),.clk(clock),.cs(slave[3]),.wr_en(wr2),.rst(reset),.rd_en(rd2),.wreq(wreq2), .indata_tx(indata2), .outdata_rx(outdata2), .DREQ(D_REQ[2]), .DACK(D_ACK[2]), .io_full(io_full2), .io_empty(io_empty2) );
	IO_spi_slave ios3(.MOSI(msi),.MISO(mso_slave_io3),.sclk(sck),.clk(clock),.cs(slave[4]),.wr_en(wr3),.rst(reset),.rd_en(rd3),.wreq(wreq3), .indata_tx(indata3), .outdata_rx(outdata3), .DREQ(D_REQ[3]), .DACK(D_ACK[3]), .io_full(io_full3), .io_empty(io_empty3) );

endmodule


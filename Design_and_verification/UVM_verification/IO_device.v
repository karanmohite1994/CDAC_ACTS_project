module iodevice(
	input        clk, rst,
	input        rdtx, wrtx, 		//transmitter read write enable
	input        wrrx,rdrx,  		// receiver read write enable
	input  [7:0] indata_tx,  		//transmitter input data
	input  [7:0] indata_rx,  		//receiver input data
	output [7:0] outdata_tx, 		//transmitter output data
	output [7:0] outdata_rx, 		//receiver output data
	output       fulltx, emptytx, //transmitter full and empty signal
	output       fullrx, emptyrx  //receiver full and empty signal
    );
	
	FIFO_Buf fiforx	(.clk(clk),.rst(rst),.wr_en(wrrx),.data(indata_rx),.full_o(fullrx),.rd_en(rdrx),.data_out(outdata_rx),.empty(emptyrx));
	FIFO_Buf fifotx	(.clk(clk),.rst(rst),.wr_en(wrtx),.data(indata_tx),.full_o(fulltx),.rd_en(rdtx),.data_out(outdata_tx),.empty(emptytx));
	
endmodule

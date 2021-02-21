interface intf;
//----------DMA Signals-----------
    bit clk;
    bit rst;
    bit HLDA; //hold the Acknowledgment
    bit [7:0] datain;  //input data
    bit [1:0] DSel;  //Data Select
    bit Dbusy, HRQ; //Hold request
    bit dma_done;	
    bit  MISO,MOSI;
    bit sclk;
//-------IO device 0--------------
    bit       wr0, rd0; //input write0, read0 
    bit       wreq0; //write request0 IO device 0 
    bit [7:0] indata0; //input data 0
    bit [7:0] outdata0; //output data 0
    bit io_full0,io_empty0; 

//-------IO device 1--------------
    bit       wr1, rd1;//input write1, read1 
    bit       wreq1;  //write request1 IO device 1
    bit [7:0] indata1; //input data 1
    bit [7:0] outdata1; //output data 1
    bit io_full1,io_empty1; 

//-------IO device 2--------------
    bit       wr2, rd2; //input write2, read2 
    bit       wreq2; //write request2 IO device 2
    bit [7:0] indata2; //input data 2
    bit [7:0] outdata2; //output data 2
    bit io_full2,io_empty2; 
	 
//-------IO device 3--------------
    bit       wr3, rd3; //input write3, read3 
    bit       wreq3;// write request3 IO device 3 
    bit [7:0] indata3; //input data 3
    bit [7:0] outdata3; //output data 3
    bit io_full3,io_empty3; 

endinterface :intf

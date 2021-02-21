`include "uvm_macros.svh"
`include "dma_top.v"
import uvm_pkg::* ;
`include "transaction.sv"
`include "sequencer.sv"
`include "sequence.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "environment.sv"
`include "interface.sv"
`include "test.sv"


//-----------------Top Module----------------//
module top_spi_dma();
  
  intf intfs(); //interface
  

  dma_top dut(.clock(intfs.clk),.reset(intfs.rst),.sclock(intfs.sclk),.HLDA(intfs.HLDA),.datain(intfs.datain),
	        .DSel(intfs.DSel),.Dbusy(intfs.Dbusy),.HRQ(intfs.HRQ),.dma_done(intfs.dma_done),
		.wr0(intfs.wr0),.rd0(intfs.rd0),.wreq0(intfs.wreq0),.indata0(intfs.indata0),.outdata0(intfs.outdata0),.io_full0(intfs.io_full0),.io_empty0(intfs.io_empty0),
		.wr1(intfs.wr1),.rd1(intfs.rd1),.wreq1(intfs.wreq1),.indata1(intfs.indata1),.outdata1(intfs.outdata1),.io_full1(intfs.io_full1),.io_empty1(intfs.io_empty1),
		.wr2(intfs.wr2),.rd2(intfs.rd2),.wreq2(intfs.wreq2),.indata2(intfs.indata2),.outdata2(intfs.outdata2),.io_full2(intfs.io_full2),.io_empty2(intfs.io_empty2),
		.wr3(intfs.wr3),.rd3(intfs.rd3),.wreq3(intfs.wreq3),.indata3(intfs.indata3),.outdata3(intfs.outdata3),.io_full3(intfs.io_full3),.io_empty3(intfs.io_empty3),
		.MOSI(intfs.MOSI),.MISO(intfs.MISO));

   initial begin
	intfs.clk = 0; intfs.rst = 0; //reset
	#50
	intfs.rst = 1;	
		
   end

   initial forever #10 intfs.clk = ~ intfs.clk;  //clock generation

   initial begin 
      uvm_config_db #(virtual intf) :: set(null,"*", "intfs", intfs);   //setting  interface
        
      run_test("my_test");  
                                               
   end
endmodule

//vsim -novopt top_spi_dma

 // ----------- TRANSACTION --------------
  class my_txn extends uvm_sequence_item ;

   //-------input signals------------
	      bit        rst;
         rand bit        HLDA;
         rand bit  [7:0] datain;
	 rand bit  [1:0] DSel;     
	 rand bit        wr0;
         rand bit        rd0; 
         rand bit        wreq0; 
	 rand bit  [7:0] indata0;
	 rand bit        wr1;
         rand bit        rd1; 
         rand bit        wreq1; 
	 rand bit  [7:0] indata1;
	 rand bit        wr2;
         rand bit        rd2;
         rand bit        wreq2; 
	 rand bit  [7:0] indata2;
	 rand bit        wr3;
         rand bit        rd3;
         rand bit        wreq3; 
	 rand bit  [7:0] indata3;

//-------output signals------------
         bit       Dbusy;
         bit       HRQ;  
	 bit       io_full0,io_empty0;       
	 bit       io_full1,io_empty1;   
	 bit       io_full2,io_empty2;   
	 bit       io_full3,io_empty3;    
	 bit	   dma_done;          
         bit [7:0] outdata0;
         bit [7:0] outdata1;
         bit [7:0] outdata2;
	 bit [7:0] outdata3;

  `uvm_object_utils_begin(my_txn)

	`uvm_field_int(HLDA,UVM_DEFAULT)
	`uvm_field_int(rst,UVM_DEFAULT)
	`uvm_field_int(datain,UVM_DEFAULT)
	`uvm_field_int(DSel,UVM_DEFAULT)
	`uvm_field_int(wr0,UVM_DEFAULT)
	`uvm_field_int(rd0,UVM_DEFAULT)
	`uvm_field_int(wreq0,UVM_DEFAULT)
	`uvm_field_int(indata0,UVM_DEFAULT)
	`uvm_field_int(wr1,UVM_DEFAULT)
	`uvm_field_int(rd1,UVM_DEFAULT)
	`uvm_field_int(wreq1,UVM_DEFAULT)
	`uvm_field_int(indata1,UVM_DEFAULT)
	`uvm_field_int(wr2,UVM_DEFAULT)
	`uvm_field_int(rd2,UVM_DEFAULT)
	`uvm_field_int(wreq2,UVM_DEFAULT)
	`uvm_field_int(indata2,UVM_DEFAULT)
	`uvm_field_int(wr3,UVM_DEFAULT)
	`uvm_field_int(rd3,UVM_DEFAULT)
	`uvm_field_int(wreq3,UVM_DEFAULT)
	`uvm_field_int(indata3,UVM_DEFAULT)
	`uvm_field_int(Dbusy,UVM_DEFAULT)
	`uvm_field_int(HRQ,UVM_DEFAULT)
	`uvm_field_int(io_full0,UVM_DEFAULT)
	`uvm_field_int(io_empty0,UVM_DEFAULT)
	`uvm_field_int(io_full1,UVM_DEFAULT)
	`uvm_field_int(io_empty1,UVM_DEFAULT)
	`uvm_field_int(io_full2,UVM_DEFAULT)
	`uvm_field_int(io_empty2,UVM_DEFAULT)
	`uvm_field_int(io_full3,UVM_DEFAULT)
	`uvm_field_int(io_empty3,UVM_DEFAULT)
	`uvm_field_int(outdata0,UVM_DEFAULT)
	`uvm_field_int(outdata1,UVM_DEFAULT)
	`uvm_field_int(outdata2,UVM_DEFAULT)
	`uvm_field_int(outdata3,UVM_DEFAULT)

   `uvm_object_utils_end

    function new(string name = "") ;
      super.new(name) ;
    endfunction
    
  endclass

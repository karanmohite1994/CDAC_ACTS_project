// ----- DRIVER ----------------------------------------------------
  class my_drv extends uvm_driver #(my_txn) ;
    `uvm_component_utils(my_drv)

    virtual intf vif ; //virtual interface

    function new(string name, uvm_component parent) ;
      super.new(name, parent) ;
    endfunction
    
    function void build_phase(uvm_phase phase) ;       
      `uvm_info(get_type_name(), "...build phase...", UVM_MEDIUM) 
      if( !uvm_config_db #(virtual intf)::get(this, "", "intfs", vif) ) 
        `uvm_error(get_type_name(), "uvm_config_db: get 'dut_if' failed...")
      else
        `uvm_info(get_type_name(), "uvm_config_db: get 'dut_if' success...", UVM_MEDIUM)
    endfunction
    
    task run_phase(uvm_phase phase) ;
      `uvm_info(get_type_name(), "...run phase...", UVM_MEDIUM)
      forever begin
	my_txn trxn = my_txn::type_id::create("trxn") ;
        seq_item_port.get_next_item(trxn) ;
        @(posedge vif.clk) ;
	//--------DMA Signals------------- 
	    vif.HLDA    = trxn.HLDA ;
	    vif.DSel    = trxn.DSel ;
	    vif.HLDA    = trxn.HLDA ;
	    vif.datain  = trxn.datain ;
      //----------IO device 0------------ 
	    vif.wr0      = trxn.wr0 ;
	    vif.rd0      = trxn.rd0 ; 
	    vif.wreq0    = trxn.wreq0 ;  
	    vif.indata0  = trxn.indata0 ;  

      //----------IO device 1------------ 
	    vif.wr1      = trxn.wr1 ;
	    vif.rd1      = trxn.rd1 ; 
	    vif.wreq1    = trxn.wreq1 ;  
	    vif.indata1  = trxn.indata1 ;

     //----------IO device 2------------ 
	    vif.wr2      = trxn.wr2 ;
	    vif.rd2      = trxn.rd2 ; 
	    vif.wreq2    = trxn.wreq2 ;  
	    vif.indata2  = trxn.indata2 ; 	

    //----------IO device 3------------ 
	    vif.wr3      = trxn.wr3 ;
	    vif.rd3      = trxn.rd3 ; 
	    vif.wreq3    = trxn.wreq3 ;  
	    vif.indata3  = trxn.indata3 ;

            seq_item_port.item_done() ;
	end
    endtask
  endclass : my_drv

//--------------IO device control-------------------------------------------
  class io_device_control extends uvm_driver #(my_txn) ;
    `uvm_component_utils(io_device_control)

    virtual intf vif ; //virtual interface

    function new(string name, uvm_component parent) ;
      super.new(name, parent) ;
    endfunction
    
    function void build_phase(uvm_phase phase) ;   
      `uvm_info(get_type_name(), "...build phase...", UVM_MEDIUM)     
      if( !uvm_config_db #(virtual intf)::get(this, "", "intfs", vif) ) 
        `uvm_error(get_type_name(), "uvm_config_db: get 'dut_if' failed...")
      else
        `uvm_info(get_type_name(), "uvm_config_db: get 'dut_if' success...", UVM_MEDIUM)
    endfunction
    
    task run_phase(uvm_phase phase) ;
      `uvm_info(get_type_name(), "...run phase...", UVM_MEDIUM)
      forever begin
        @(posedge vif.clk);
//-----------------IO device 0---------------------------------------
	if(vif.dma_done == 1) begin

	//when data from memory is load into IO device then read 
	//enable set to extract the data from IO buffer 
	if(vif.io_empty0 == 0)begin 
	   vif.rd0 = 1;
	  `uvm_info(get_type_name(), "...IO device 0 is enable..", UVM_HIGH)
	end
	else
	   vif.rd0 = 0;
//-----------------IO device 1---------------------------------------
	if(vif.io_empty1 == 0)begin
	   vif.rd1 = 1;
	  `uvm_info(get_type_name(), "...IO device 1 is enable..", UVM_HIGH)
	end
	else
	   vif.rd1 = 0;
//-----------------IO device 2---------------------------------------
	if(vif.io_empty2 == 0)begin
	   vif.rd2 = 1;
	  `uvm_info(get_type_name(), "...IO device 2 is enable..", UVM_HIGH)
	end
	else
	   vif.rd2 = 0; 
//-----------------IO device 3---------------------------------------
	if(vif.io_empty3 == 0)begin
	   vif.rd3 = 1;
	  `uvm_info(get_type_name(), "...IO device 3 is enable..", UVM_HIGH)
	end
	else
	   vif.rd3 = 0;
       end

       end
    endtask
  endclass : io_device_control


//------CPU Driver-------------------------------------------
  class cpu_drv extends uvm_driver #(my_txn) ;
    `uvm_component_utils(cpu_drv)

    virtual intf vif ; //virtual interface
    bit en;

    function new(string name, uvm_component parent) ;
      super.new(name, parent) ;
    endfunction
    
    function void build_phase(uvm_phase phase) ;   
      `uvm_info(get_type_name(), "...cpu build phase...", UVM_MEDIUM)     
      if( !uvm_config_db #(virtual intf)::get(this, "", "intfs", vif) ) 
        `uvm_error(get_type_name(), "uvm_config_db: get 'dut_if' failed...")
      else
        `uvm_info(get_type_name(), "uvm_config_db: get 'dut_if' success...", UVM_MEDIUM)
    endfunction
    
    task run_phase(uvm_phase phase) ;
      `uvm_info(get_type_name(), "...cpu run phase...", UVM_MEDIUM)
      forever begin
        @(posedge vif.clk) ;
	if(({vif.wr0,vif.wr1,vif.wr2,vif.wr3} > 0)) //checking for IO request
	   en = 1;

	if(vif.HRQ == 1 && en == 1) //checking for bus request and DMA busy
	begin
        // @(posedge vif.clk);
	   vif.HLDA = 1'b1; //provide bus grant
	   `uvm_info(get_type_name(), "....bus granted....", UVM_MEDIUM)
	   en = 0;
	end
	else if(vif.dma_done == 1 )  
	begin
	  @(posedge vif.clk);
	   vif.HLDA = 1'b0;  //disable bus
	  `uvm_info(get_type_name(), "....bus grant disable....", UVM_MEDIUM)
	end	
      end
    endtask
  endclass : cpu_drv

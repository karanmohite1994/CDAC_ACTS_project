//-------MONITOR---------------------------------------------
  class my_monitor extends uvm_monitor;
    `uvm_component_utils(my_monitor)

    virtual intf vif;

    uvm_analysis_port #(my_txn) my_analysis_port;

    function new(string name, uvm_component parent) ;
      super.new(name, parent) ;
    endfunction  
 

    //build phase
    virtual function void build_phase(uvm_phase phase) ; 

      `uvm_info(get_type_name(),"-build phase-",UVM_MEDIUM)
      super.build_phase(phase);
      my_analysis_port=new ("my_analysis_port",this); 
      
      if( !uvm_config_db #(virtual intf)::get(this, "", "intfs", vif) ) 
        `uvm_error("my_monitor", "uvm_config_db: get 'dut_if' failed...")
      else
        `uvm_info("my_monitor", "uvm_config_db: get 'dut_if' success...", UVM_MEDIUM)
    endfunction

    //run phase
    virtual task run_phase(uvm_phase phase) ; 
        `uvm_info(get_type_name(),"-runphase-",UVM_MEDIUM)
	super.run_phase(phase);
	
	forever begin
	    my_txn trxn = my_txn::type_id::create("trxn") ;
      //----------DMA Signals------------- 
	    trxn.rst     = vif.rst;
	    trxn.HLDA    = vif.HLDA ;
	    trxn.DSel    = vif.DSel ;
	    trxn.HLDA    = vif.HLDA ;
	    trxn.datain  = vif.datain;

      //----------IO device 0------------ 
	    trxn.wr0      = vif.wr0 ;
	    trxn.rd0      = vif.rd0 ; 
	    trxn.wreq0    = vif.wreq0 ;  
	    trxn.indata0  = vif.indata0 ;  

      //----------IO device 1------------ 
	    trxn.wr1      = vif.wr1 ;
	    trxn.rd1      = vif.rd1 ; 
	    trxn.wreq1    = vif.wreq1 ;  
	    trxn.indata1   = vif.indata1 ;

     //----------IO device 2------------ 
	    trxn.wr2      = vif.wr2 ;
	    trxn.rd2      = vif.rd2 ; 
	    trxn.wreq2    = vif.wreq2 ;  
	    trxn.indata2  = vif.indata2 ; 	

    //----------IO device ------------ 
	    trxn.wr3      = vif.wr3 ;
	    trxn.rd3      = vif.rd3 ; 
	    trxn.wreq3    = vif.wreq3 ;  
	    trxn.indata3  = vif.indata3 ; 
   //-------------------------------------
            trxn.Dbusy     = vif.Dbusy;
            trxn.HRQ       = vif.HRQ;                    
	    trxn.io_full0  = vif.io_full0;
	    trxn.io_empty0 = vif.io_empty0;       
	    trxn.io_full1  = vif.io_full1;
	    trxn.io_empty1 = vif.io_empty1;   
	    trxn.io_full2  = vif.io_full2; 
	    trxn.io_empty2 = vif.io_empty2;   
	    trxn.io_full3  = vif.io_full3;
	    trxn.io_empty3 = vif.io_empty3;
	    trxn.dma_done  = vif.dma_done;
	    @(posedge vif.clk);
            trxn.outdata0  = vif.outdata0;
            trxn.outdata1  = vif.outdata1;
	    trxn.outdata2  = vif.outdata2;
            trxn.outdata3  = vif.outdata3;
 	    my_analysis_port.write(trxn); //sends transaction through analysis port
	end
    endtask

  endclass

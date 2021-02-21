//-------Scoreboard--------------------------------------
class my_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(my_scoreboard)
    virtual intf vif;
    bit  [7:0] mem [16] ;
    byte  ip_ptr,op_ptr; //
    bit [7:0] idata0, idata1, idata2, idata3;
    bit req_en;

    uvm_analysis_imp #(my_txn, my_scoreboard) scb_port;

    function new(string name, uvm_component parent) ;
      super.new(name, parent) ;
    endfunction  
 
    //build phase
    virtual function void build_phase(uvm_phase phase) ; 

      super.build_phase(phase);
      scb_port=new ("scb_port",this); 
      `uvm_info(get_type_name(),"-build phase-",UVM_MEDIUM)
   
    endfunction

    //scoreboard write
    virtual function void write(my_txn trxn);
	if(!trxn.rst) begin
	   `uvm_info(get_type_name(),"-scoreboard reset done-",UVM_MEDIUM)
	   ip_ptr   <= 0;
	   op_ptr   <= 0;
	   req_en   <= 0;
	end
	else begin

        if(trxn.HLDA == 0) begin
	  if(trxn.wr0 == 1 ) begin
		
		`uvm_info(get_type_name(), $sformatf("input data: indata0=%0h ip_ptr=%0h",
			trxn.indata0,ip_ptr), UVM_MEDIUM)
	         mem[ip_ptr] <= trxn.indata0;
	         ip_ptr++;
	   end

	   else if(trxn.wr1 == 1) begin
		
		`uvm_info(get_type_name(), $sformatf("input data: indata1=%0h io_ptr=%0h",
			trxn.indata1,ip_ptr), UVM_MEDIUM)
	         mem[ip_ptr] <= trxn.indata1;
	         ip_ptr++;
	   end

	   else if(trxn.wr2 == 1) begin
		
		`uvm_info(get_type_name(), $sformatf("input data: indata2=%0h io_ptr=%0h",
			trxn.indata2,ip_ptr), UVM_MEDIUM)
	         mem[ip_ptr] <= trxn.indata2;
	         ip_ptr++;
	   end

	   else if(trxn.wr3 == 1) begin
		
		`uvm_info(get_type_name(), $sformatf("input data: indata3=%0h io_ptr=%0h",
			trxn.indata3,ip_ptr), UVM_MEDIUM)
	         mem[ip_ptr] <= trxn.indata3;
	         ip_ptr++;
	   end

	   else 
	      ip_ptr <= 0;
	end
	
	   //`uvm_info(get_type_name(), $sformatf("output data: outdata0=%0h, outdata1=%0h, outdata2=%0h, outdata3=%0h, \n", trxn.outdata0, trxn.outdata1, trxn.outdata2, trxn.outdata3), UVM_MEDIUM)
	   if(trxn.rd0 == 1 && trxn.io_empty0 == 0 && req_en == 0) begin
	      
	      if(mem[op_ptr] == trxn.outdata0) 
		 `uvm_info(get_type_name(),$sformatf("data matching: indata=%0h outdata0=%0h op_ptr=%0h ",mem[op_ptr], trxn.outdata0, op_ptr), UVM_MEDIUM)
	      else 
		 `uvm_error(get_type_name(), $sformatf("data matching fails: indata=%0h outdata0=%0h op_ptr=%0h ",mem[op_ptr], trxn.outdata0, op_ptr))
	      op_ptr <= op_ptr + 1;
	   end
	   else if(trxn.rd1 == 1 && trxn.io_empty1 == 0 && req_en == 0) begin
	      
	      if(mem[op_ptr] == trxn.outdata1) 
		 `uvm_info(get_type_name(),$sformatf("data matching: indata=%0h outdata1=%0h op_ptr=%0h ",mem[op_ptr], trxn.outdata1, op_ptr), UVM_MEDIUM)
	      else
		 `uvm_error(get_type_name(), $sformatf("data matching fails: indata=%0h outdata1=%0h op_ptr=%0h ",mem[op_ptr], trxn.outdata1, op_ptr))
	      op_ptr <= op_ptr + 1;
	   end
	   else if(trxn.rd2 == 1 && trxn.io_empty2 == 0 && req_en == 0) begin   
	         
	      if(mem[op_ptr] == trxn.outdata2) 
		 `uvm_info(get_type_name(),$sformatf("data matching: indata=%0h outdata2=%0h op_ptr=%0h ",mem[op_ptr], trxn.outdata2, op_ptr), UVM_MEDIUM)
	      else
		 `uvm_error(get_type_name(), $sformatf("data matching fails: indata=%0h outdata2=%0h op_ptr=%0h ",mem[op_ptr], trxn.outdata2, op_ptr))	
	      op_ptr <= op_ptr + 1;  
	   end
	   else if(trxn.rd3 == 1 && trxn.io_empty3 == 0 && req_en == 0) begin
	      
	      if(mem[op_ptr] == trxn.outdata3) 
		`uvm_info(get_type_name(),$sformatf("data matching: indata=%0h outdata3=%0h op_ptr=%0h ",mem[op_ptr], trxn.outdata3, op_ptr), UVM_MEDIUM)
	      else
		 `uvm_error(get_type_name(), $sformatf("data matching fails: indata=%0h outdata3=%0h op_ptr=%0h ",mem[op_ptr], trxn.outdata3, op_ptr))
	      op_ptr <= op_ptr + 1;
	   end

	      else 
	          op_ptr <= 0;
	// end
	if(trxn.HLDA == 1)
	   ip_ptr <= 0;
	if(trxn.wr0 == 1 || trxn.wr1 == 1 || trxn.wr2 == 1 || trxn.wr3 == 1)
	   op_ptr <= 0;
	end

	if({trxn.wreq0,trxn.wreq1,trxn.wreq2,trxn.wreq3} > 0) begin
	   req_en = 1;
	   `uvm_info(get_type_name(),"--Multiple IO device request arrived--",UVM_MEDIUM)
	end

	if(req_en == 1) begin
	   if(trxn.wr0 == 1) begin
	      idata0 <= trxn.indata0; 
	      `uvm_info(get_type_name(), $sformatf("input data: indata0=%0h ",
			trxn.indata0), UVM_LOW)
	   end
	   if(trxn.wr1 == 1) begin
	      idata1 <= trxn.indata1; 
	      `uvm_info(get_type_name(), $sformatf("input data: indata1=%0h ",
			trxn.indata1), UVM_LOW)
	   end
	   if(trxn.wr2 == 1) begin
	      idata2 <= trxn.indata2; 
	      `uvm_info(get_type_name(), $sformatf("input data: indata2=%0h ",
			trxn.indata2), UVM_LOW)
	   end
	   if(trxn.wr3 == 1) begin
	      idata3 <= trxn.indata3; 
	      `uvm_info(get_type_name(), $sformatf("input data: indata3=%0h ",
			trxn.indata3), UVM_LOW)
	   end
	

	if(trxn.rd2 == 1 && trxn.io_empty2 == 0) begin
	     `uvm_info(get_type_name(),"===========device select=============",UVM_MEDIUM)
	      if(idata3 == trxn.outdata2) 
		 `uvm_info(get_type_name(), $sformatf("IO device3 is selected : outdata=%0h ",
			trxn.outdata2), UVM_MEDIUM)

	      else if(idata2 == trxn.outdata2) 
		 `uvm_info(get_type_name(), $sformatf("IO device2 is selected : outdata=%0h ",
			trxn.outdata2), UVM_MEDIUM)

	      else if(idata1 == trxn.outdata2) 
		 `uvm_info(get_type_name(), $sformatf("IO device1 is selected : outdata=%0h ",
			trxn.outdata2), UVM_MEDIUM)

	      else if(idata0 == trxn.outdata2) 
		 `uvm_info(get_type_name(), $sformatf("IO device0 is selected : outdata=%0h ",
			trxn.outdata2), UVM_MEDIUM)
	      
	 end
		
	end
    endfunction

 endclass : my_scoreboard


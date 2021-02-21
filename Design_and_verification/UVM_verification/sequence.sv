 //------  RANDOM SEQUENCE ----------------------------------------------
   class rand_seq extends uvm_sequence #(my_txn) ;
       `uvm_object_utils(rand_seq)
 
       function new(string name = "") ;
          super.new(name) ;
       endfunction

       task body();
          `uvm_info(get_type_name(), "Random sequence", UVM_MEDIUM)
          repeat(50) begin
             my_txn trxn = my_txn::type_id::create("trxn") ; 
             start_item(trxn) ;
             if( !trxn.randomize())   // randomizing the test inputs
	       `uvm_error(get_type_name(),"randomize failed")
             finish_item(trxn) ;
          end
	endtask
    endclass

  //------  SEQUENCE 1 ---------------------------------------------
   //single read from IO device and write into memeory
   class readIo_writeMem_1 extends uvm_sequence #(my_txn) ;
      `uvm_object_utils(readIo_writeMem_1)
    
       function new(string name = "") ;
          super.new(name) ;
       endfunction

       task set_registers(); //setting value of internal registers of DMA
	my_txn trxn = my_txn::type_id::create("trxn") ; 
	 trxn.DSel = 2'b00;
	 repeat(4) begin
           start_item(trxn) ;
           case (trxn.DSel)
	      2'b00 : trxn.datain = 8'h3; //starting address
	      2'b01 : trxn.datain = 8'h1;  // count value
	      2'b10 : trxn.datain = 8'b00000010; // IO device 1 select 
	      2'b11 : trxn.datain = 8'b00000110; //mode select
	   endcase
           finish_item(trxn) ;
	   trxn.DSel = trxn.DSel + 1;
	 end
       endtask

       task bus_gnt(); //give bus grant to DMA
	  my_txn trxn = my_txn::type_id::create("trxn") ; 
	  start_item(trxn) ;
	  trxn.HLDA = 1'b1;
	  finish_item(trxn) ;
       endtask

       task Load_IOdevice(); //writing data into IO device
	  my_txn trxn = my_txn::type_id::create("trxn") ;
	  start_item(trxn) ;
	  trxn.wr1 = 1'b1; //enable write 
	  trxn.rd1 = 1'b0;
	  trxn.indata1 = 8'hA6;
	  finish_item(trxn) ;

       endtask

       task body(); 
	`uvm_info(get_type_name(), "single Read from IO and write into Memory", UVM_MEDIUM)
	  begin
	     Load_IOdevice();
	     set_registers();
	     bus_gnt();
	  end
	  
       endtask

   endclass

//------  SEQUENCE 2 ---------------------------------------------
  //single read from memory and write into io
   class readMem_writeIo_1 extends uvm_sequence #(my_txn) ;
      `uvm_object_utils(readMem_writeIo_1)
    
       function new(string name = "") ;
          super.new(name) ;
       endfunction

       task set_registers(); //setting value of internal registers of DMA
	 my_txn trxn = my_txn::type_id::create("trxn") ; 
	 trxn.DSel = 2'b00;
	 repeat(4) begin
           start_item(trxn) ;
           case (trxn.DSel)
	      2'b00 : trxn.datain = 8'h3; //starting address
	      2'b01 : trxn.datain = 8'h1;  // count value
	      2'b10 : trxn.datain = 8'b00000001; // IO device 0 select 
	      2'b11 : trxn.datain = 8'b00001001; //mode select
	   endcase   
           finish_item(trxn) ;
	  trxn.DSel = trxn.DSel + 1;
	 end
       endtask

       task bus_gnt(); //give bus grant to DMA
	  my_txn trxn = my_txn::type_id::create("trxn") ; 
	  start_item(trxn) ;
	  trxn.HLDA = 1'b1;
	  finish_item(trxn) ;
       endtask

       task body(); 
	  `uvm_info(get_type_name(), "single Read from Memory and write into IO device", UVM_MEDIUM)
	  set_registers();
	  bus_gnt();
       endtask
   endclass

//------  SEQUENCE 3 ---------------------------------------------
  //burst read from IO and write into memory
   class readIo_writeMem_burst extends uvm_sequence #(my_txn) ;
      `uvm_object_utils(readIo_writeMem_burst)
    
       function new(string name = "") ;
          super.new(name) ;
       endfunction

       task set_registers(); //setting value of internal registers of DMA
	 my_txn trxn = my_txn::type_id::create("trxn") ; 
	 trxn.DSel = 2'b00;
	 repeat(4) begin
           start_item(trxn) ;
           case (trxn.DSel)
	      2'b00 : trxn.datain = 8'hA6; //starting address
	      2'b01 : trxn.datain = 8'd15;  // data count value
	      2'b10 : trxn.datain = 8'b00000100; // IO device 2 select 
	      2'b11 : trxn.datain = 8'b00000110; //mode select
	   endcase
           finish_item(trxn) ;
	   trxn.DSel = trxn.DSel + 1;
	 end
       endtask

       task bus_gnt(); //give bus grant to DMA
	  my_txn trxn = my_txn::type_id::create("trxn") ; 
	  start_item(trxn) ;
	  trxn.HLDA = 1'b1;
	  finish_item(trxn) ;
       endtask

       task Load_IOdevice(); //writing data into IO device
	  my_txn trxn = my_txn::type_id::create("trxn") ; 
	  repeat(15) begin //writing data into io device 8 times
	     start_item(trxn) ;
	     trxn.wr2 = 1'b1; //enable write 
	     trxn.rd2 = 1'b0;
	     trxn.indata2 = $random;
	     finish_item(trxn) ;
	  end
       endtask

       task body(); 
	  `uvm_info(get_type_name(), "Burst Read from IO and write into Memory", UVM_MEDIUM)
	   Load_IOdevice();
	   set_registers();
	   bus_gnt();
        endtask
   endclass

//------  SEQUENCE 4 ---------------------------------------------
//burst read from IO device and write into memeory
   class readMem_writeIo_burst extends uvm_sequence #(my_txn) ;
      `uvm_object_utils(readMem_writeIo_burst)
    
       function new(string name = "") ;
          super.new(name) ;
       endfunction

        task set_registers(); //setting value of internal registers of DMA
	 my_txn trxn = my_txn::type_id::create("trxn") ; 
	 trxn.DSel = 2'b00;
	 repeat(4) begin
           start_item(trxn) ;
           case (trxn.DSel)
	      2'b00 : trxn.datain = 8'hA6; //starting address
	      2'b01 : trxn.datain = 8'd15;  // data count value
	      2'b10 : trxn.datain = 8'b00001000; // IO device 3 select 
	      2'b11 : trxn.datain = 8'b00001001; //mode select
	   endcase
           finish_item(trxn) ;
	   trxn.DSel = trxn.DSel + 1;
	 end
       endtask


       task bus_gnt(); //give bus grant to DMA
	  my_txn trxn = my_txn::type_id::create("trxn") ; 
	  start_item(trxn) ;
	  trxn.HLDA = 1'b1;
	  finish_item(trxn) ;
       endtask

       task body(); 
	  `uvm_info(get_type_name(), "Burst Read from memory and write into IO", UVM_MEDIUM)
	  set_registers();
	  bus_gnt();
       endtask
   endclass

//------  SEQUENCE 5 ---------------------------------------------
  //multiple IO device request to DMA 
  class multiple_IO_req extends uvm_sequence #(my_txn) ;
      `uvm_object_utils(multiple_IO_req)
    
       function new(string name = "") ;
          super.new(name) ;
       endfunction

       task set_registers(); //setting value of internal registers of DMA
	 my_txn trxn = my_txn::type_id::create("trxn") ; 
	 trxn.DSel = 2'b11;
	 repeat(4) begin
           start_item(trxn) ;
           case (trxn.DSel)
	      2'b00 : trxn.datain = 8'h3; //starting address
	      2'b01 : trxn.datain = 8'h1;  // count value
	      2'b10 : trxn.datain = 8'b00000000; // IO select 
	      2'b11 : trxn.datain = 8'b00000110; //mode select
	   endcase
           finish_item(trxn) ;
	   trxn.DSel = trxn.DSel - 1;
	 end
       endtask

       task Load_IOdevice(); //writing single data into all IO devices
	  my_txn trxn = my_txn::type_id::create("trxn") ;
	  start_item(trxn) ;
          trxn.wr0 = 1'b1; 
          trxn.rd0 = 1'b0;
          trxn.wr1 = 1'b1; 
          trxn.rd1 = 1'b0;
          trxn.wr2 = 1'b1; 
          trxn.rd2 = 1'b0;
          trxn.wr3 = 1'b1; 
          trxn.rd3 = 1'b0;
          trxn.indata0 = 8'h45;
          trxn.indata1 = 8'hb6;
          trxn.indata2 = 8'h15;
          trxn.indata3 = 8'h3c;
          finish_item(trxn) ;
       endtask

       task set_Io_req();
	  my_txn trxn = my_txn::type_id::create("trxn") ; 
	  start_item(trxn) ;
	  trxn.datain = 8'h3;
	  trxn.wreq0 = 1'b1;
          trxn.wreq1 = 1'b1;
          trxn.wreq2 = 1'b1; 
          trxn.wreq3 = 1'b1;
	  finish_item(trxn) ;
       endtask
       
       task bus_gnt(); //give bus grant to DMA
	  my_txn trxn = my_txn::type_id::create("trxn") ; 
	  start_item(trxn) ;
	  trxn.HLDA = 1'b1;
	  finish_item(trxn) ;
       endtask

       task body(); 
    	  `uvm_info(get_type_name(), " multiple IO device request to DMA ", UVM_MEDIUM)
	  Load_IOdevice(); 
	  set_registers();
	  set_Io_req();
	  bus_gnt();
       endtask
   endclass

//------  SEQUENCE 6 ---------------------------------------------
  //multiple IO device request to DMA with rotating priotity enable
  class multiple_IO_req_rot extends uvm_sequence #(my_txn) ;
      `uvm_object_utils(multiple_IO_req_rot)
    
       function new(string name = "") ;
          super.new(name) ;
       endfunction

       task set_registers(); //setting value of internal registers of DMA
	 my_txn trxn = my_txn::type_id::create("trxn") ; 
	 trxn.DSel = 2'b11;
	 repeat(4) begin
           start_item(trxn) ;
           case (trxn.DSel)
	      2'b00 : trxn.datain = 8'h3; //starting address
	      2'b01 : trxn.datain = 8'h1;  // count value
	      2'b10 : trxn.datain = 8'b00010000; // IO select with rotating priority enable 
	      2'b11 : trxn.datain = 8'b00000110; //mode select
	   endcase
           finish_item(trxn) ;
	   trxn.DSel = trxn.DSel - 1;
	 end
       endtask

       task set_Io_req();
	  my_txn trxn = my_txn::type_id::create("trxn") ; 
	  start_item(trxn) ;
	  trxn.datain = 8'h3;
	  trxn.wreq0 = 1'b1;
          trxn.wreq1 = 1'b1;
          trxn.wreq2 = 1'b1; 
          trxn.wreq3 = 1'b1;
	  finish_item(trxn) ;
       endtask

        task Load_IOdevice(); //writing single data into all IO devices
	  my_txn trxn = my_txn::type_id::create("trxn") ;
	  start_item(trxn) ;
          trxn.wr0 = 1'b1; 
          trxn.rd0 = 1'b0;
          trxn.wr1 = 1'b1; 
          trxn.rd1 = 1'b0;
          trxn.wr2 = 1'b1; 
          trxn.rd2 = 1'b0;
          trxn.wr3 = 1'b1; 
          trxn.rd3 = 1'b0;
          trxn.indata0 = 8'h45;
          trxn.indata1 = 8'hb6;
          trxn.indata2 = 8'h15;
          trxn.indata3 = 8'h3c;
          finish_item(trxn) ;
       endtask

        task bus_gnt(); //give bus grant to DMA
	  my_txn trxn = my_txn::type_id::create("trxn") ; 
	  start_item(trxn) ;
	  trxn.HLDA = 1'b1;
	  finish_item(trxn) ;
       endtask

       task body(); 
	  `uvm_info(get_type_name(), " multiple IO device request to DMA with rotating priority enable", UVM_MEDIUM)
	  Load_IOdevice();
	  set_registers();
	  set_Io_req();
	  bus_gnt();
       endtask
   endclass

//--------------  SEQUENCE 7 ---------------------------------------------
//single read from memory and write into io
   class readMem_writeIo extends uvm_sequence #(my_txn) ;
      `uvm_object_utils(readMem_writeIo)
    
       function new(string name = "") ;
          super.new(name) ;
       endfunction

       task set_registers(); //setting value of internal registers of DMA
	 my_txn trxn = my_txn::type_id::create("trxn") ; 
	 trxn.DSel = 2'b00;
	 repeat(4) begin
           start_item(trxn) ;
           case (trxn.DSel)
	      2'b00 : trxn.datain = 8'h3; //starting address
	      2'b01 : trxn.datain = 8'h1;  // count value
	      2'b10 : trxn.datain = 8'b00000100; // IO device 2 select 
	      2'b11 : trxn.datain = 8'b00001001; //mode select
	   endcase   
           finish_item(trxn) ;
	  trxn.DSel = trxn.DSel + 1;
	 end
       endtask

       task bus_gnt(); //give bus grant to DMA
	  my_txn trxn = my_txn::type_id::create("trxn") ; 
	  start_item(trxn) ;
	  trxn.HLDA = 1'b1;
	  finish_item(trxn) ;
       endtask

       task body(); 
	  `uvm_info(get_type_name(), "single Read from Memory and write into IO device", UVM_MEDIUM)
	  set_registers();
	  bus_gnt();
       endtask
   endclass

  // ----- MAIN SEQUENCE --------------------------------------------------
   class main_seq extends uvm_sequence #(my_txn) ;
      `uvm_object_utils(main_seq)
 
      bit rand_flag = 0;
      rand_seq rs;
      readIo_writeMem_1     s1;
      readMem_writeIo_1     s2;
      readIo_writeMem_burst s3;
      readMem_writeIo_burst s4;
      multiple_IO_req       s5;
      multiple_IO_req_rot   s6;
      readMem_writeIo       s7;

      function new(string name = "") ;
         super.new(name) ;
      endfunction
    
      task body();
      
        if(starting_phase != null)
        starting_phase.raise_objection(this) ;

        if($value$plusargs("rand_flag=%b", rand_flag)) //checking random flag
            `uvm_info("main_seq", "random flag is given", UVM_MEDIUM)

	if(rand_flag)
           `uvm_do (rs)
	 else begin
	    #50
  	    `uvm_do (s1)
	    #2500
  	    `uvm_do (s2)
	    #2500
  	    `uvm_do (s3)
 	    #41000
  	    `uvm_do (s4)
	    #41000
	    `uvm_do (s5)
	    #2500
	    `uvm_do (s7)
	    #2500
	    `uvm_do (s5)
	    #2500
	    `uvm_do (s7)
	    #2500
	    `uvm_do (s6)
	    #2500
	    `uvm_do (s7)
	    #2500
	    `uvm_do (s6)
	    #2500
	    `uvm_do (s7)
	    #2500
	    `uvm_do (s6)
	 end
         if(starting_phase != null)
             starting_phase.drop_objection(this) ;
      endtask
  endclass : main_seq

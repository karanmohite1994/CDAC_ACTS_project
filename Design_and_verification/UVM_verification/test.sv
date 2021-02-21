  // -------------- TEST --------------
  class my_test extends uvm_test ;
    `uvm_component_utils(my_test)
    
    my_env m_env ;

    function new(string name, uvm_component parent) ;
      super.new(name, parent) ;
    endfunction
    
    function void build_phase(uvm_phase phase) ;
      m_env = my_env::type_id::create("m_env", this) ;
    endfunction
    
    task run_phase(uvm_phase phase) ;
      main_seq seq ;
      seq = main_seq::type_id::create("seq") ;
      `uvm_info("", "...DMA TEST...", UVM_HIGH)
      seq.starting_phase = phase ;
      seq.start(m_env.m_agn.m_sqr) ;
    endtask
  endclass : my_test

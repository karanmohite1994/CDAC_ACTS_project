// ----- ENVIRONMENT -----------------------------------------------
class my_env extends uvm_env ;
    `uvm_component_utils(my_env)
    
    my_agent m_agn;
    my_scoreboard m_scrbrd;
   
    function new(string name, uvm_component parent) ;
        super.new(name, parent) ;
    endfunction

    function void build_phase(uvm_phase phase) ;
	`uvm_info(get_type_name(),"build phase",UVM_MEDIUM);
        m_agn = my_agent::type_id::create("m_agn",this) ;
	m_scrbrd = my_scoreboard::type_id::create("m_scrbrd",this) ;
    endfunction

    function void connect_phase(uvm_phase phase) ;
	`uvm_info(get_type_name(),"connect_phase",UVM_MEDIUM);
	m_agn.m_mtr.my_analysis_port.connect(m_scrbrd.scb_port);
    endfunction
    
  endclass : my_env


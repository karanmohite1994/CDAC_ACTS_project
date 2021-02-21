// --------- AGENT -------------------------
  class my_agent extends uvm_agent ;
    `uvm_component_utils(my_agent)
    
    uvm_analysis_port #(my_txn) my_analysis_port;

    my_sqr            m_sqr ;
    my_drv            m_drv ;
    cpu_drv           c_drv;
    io_device_control iod_drv;
    my_monitor        m_mtr;
   
    function new(string name, uvm_component parent) ;
      super.new(name, parent) ;
    endfunction

    //build phase
    function void build_phase(uvm_phase phase) ;
      `uvm_info(get_type_name(),"-build phase-",UVM_MEDIUM)
      my_analysis_port = new ("my_analysis_port",this);
      m_sqr    = my_sqr::type_id::create("m_sqr", this) ;
      m_drv    = my_drv::type_id::create("m_drv", this) ;
      c_drv    = cpu_drv::type_id::create("c_drv", this) ;
      iod_drv  = io_device_control::type_id::create("iod_drv", this) ;
      m_mtr    = my_monitor::type_id::create("m_mtr", this);
   
    endfunction

    //connect phase
    function void connect_phase(uvm_phase phase) ;
      `uvm_info(get_type_name(),"-connect phase-",UVM_MEDIUM)
      m_drv.seq_item_port.connect(m_sqr.seq_item_export) ;
      my_analysis_port.connect(m_mtr.my_analysis_port) ;
    endfunction
    
  endclass : my_agent

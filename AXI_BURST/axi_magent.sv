class axi_magent extends uvm_agent;
	axi_sqr     axi_sqr_i;
	axi_driver  axi_driver_i;
	axi_monitor axi_monitor_i;
	axi_cov     axi_cov_i;
	`uvm_component_utils(axi_magent)
	`NEW_COMP
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(),"AXI-Master_Agent Build_Phase is Started",UVM_NONE)
		axi_sqr_i    = axi_sqr::type_id::create("axi_sqr_i",this);
		axi_driver_i = axi_driver::type_id::create("axi_driver_i",this);
		axi_monitor_i= axi_monitor::type_id::create("axi_monitor_i",this);
		axi_cov_i    = axi_cov::type_id::create("axi_cov_i",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		`uvm_info(get_type_name(),"AXI-Master_Agent Connect_Phase is Started",UVM_NONE)
		axi_driver_i.seq_item_port.connect(axi_sqr_i.seq_item_export);
		axi_monitor_i.ap_port.connect(axi_cov_i.analysis_export);
	endfunction
endclass

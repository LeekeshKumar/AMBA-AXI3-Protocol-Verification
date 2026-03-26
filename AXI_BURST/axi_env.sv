class axi_env extends uvm_env;
	axi_magent axi_magent_i;
	axi_sagent axi_sagent_i;
	axi_sbd    axi_sbd_i;
	`uvm_component_utils(axi_env)
	`NEW_COMP
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(),"AXI-ENV Build_Phase is Started",UVM_NONE)
		axi_magent_i = axi_magent::type_id::create("axi_magent_i",this);
		axi_sagent_i = axi_sagent::type_id::create("axi_sagent_i",this);
		axi_sbd_i	 = axi_sbd::type_id::create("axi_sbd_i",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		`uvm_info(get_type_name(),"AXI-ENV Connect_Phase is Started",UVM_NONE)
		axi_magent_i.axi_monitor_i.ap_port.connect(axi_sbd_i.write_ap);
		axi_sagent_i.axi_monitor_i.ap_port.connect(axi_sbd_i.read_ap);
	endfunction

endclass

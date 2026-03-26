class axi_sagent extends uvm_agent;
	axi_responder axi_responder_i;
	axi_monitor axi_monitor_i;
	`uvm_component_utils(axi_sagent)
	`NEW_COMP
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(),"AXI-Slave_Agent Build_Phase is Started",UVM_NONE)
		axi_responder_i = axi_responder::type_id::create("axi_responder_i",this);
		axi_monitor_i   = axi_monitor::type_id::create("axi_monitor_i",this);
	endfunction

endclass

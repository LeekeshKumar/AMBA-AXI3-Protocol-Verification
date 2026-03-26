class base_test extends uvm_test;
	axi_env axi_env_i;
	`uvm_component_utils(base_test)
	`NEW_COMP
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(),"AXI-Base-Test Build_Phase is Started",UVM_NONE)
		axi_env_i = axi_env::type_id::create("axi_env",this);
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction
endclass

class test_1wr extends base_test;
	`uvm_component_utils(test_1wr)
	`NEW_COMP
	task run_phase(uvm_phase phase);
		wr_rd_seq seq = wr_rd_seq::type_id::create("seq");
		phase.raise_objection(this);
		phase.phase_done.set_drain_time(this,100);
		seq.start(axi_env_i.axi_magent_i.axi_sqr_i);
		phase.drop_objection(this);
	endtask
endclass

class test_2wr_rd extends base_test;
	`uvm_component_utils(test_2wr_rd)
	`NEW_COMP
	task run_phase(uvm_phase phase);
		axi_2wr_rd_seq seq = axi_2wr_rd_seq::type_id::create("seq");
		phase.raise_objection(this);
		phase.phase_done.set_drain_time(this,100);
		seq.start(axi_env_i.axi_magent_i.axi_sqr_i);
		phase.drop_objection(this);
	endtask
endclass

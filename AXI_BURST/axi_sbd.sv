`uvm_analysis_imp_decl (_master)
`uvm_analysis_imp_decl (_slave)
class axi_sbd extends uvm_scoreboard;
	`uvm_component_utils(axi_sbd)
	`NEW_COMP
	uvm_analysis_imp_master#(axi_tx,axi_sbd) write_ap;
	uvm_analysis_imp_slave #(axi_tx,axi_sbd) read_ap;
	axi_tx m_txQ[$],tx,mtx,stx;
	axi_tx s_txQ[$];
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(),"AXI-Scoreboard Build_Phase is Started",UVM_NONE)
		write_ap = new("write_ap",this);
		read_ap  = new("read_ap",this);
	endfunction

	virtual function void write_master(axi_tx t);
		$cast(mtx,t);
		mtx.print();
		m_txQ.push_back(mtx);
	endfunction
	virtual function void write_slave(axi_tx t);
		$cast(stx,t);
		s_txQ.push_back(stx);
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
			wait(m_txQ.size!=0 && s_txQ.size!=0);
			mtx = m_txQ.pop_front();
			stx = s_txQ.pop_front();
			if(mtx.compare(stx)) axi_common::matching++;
			else axi_common::mis_matching++;
		end
	endtask

	function void report_phase(uvm_phase phase);
		if(axi_common::matching!=0 && axi_common::mis_matching==0)begin
			`uvm_info("AXI_SBD",$sformatf("----- TEST-PASSED -----"),UVM_NONE);
			`uvm_info("AXI_SBD",$sformatf("     Matchings=%0d",axi_common::matching),UVM_NONE);
			`uvm_info("AXI_SBD",$sformatf("   Mis-Matchings=%0d",axi_common::mis_matching),UVM_NONE);
		end
		else begin
			`uvm_info("AXI_SBD",$sformatf("----- TEST-FAILED -----"),UVM_NONE);
			`uvm_info("AXI_SBD",$sformatf("     Matchings=%0d",axi_common::matching),UVM_NONE);
			`uvm_info("AXI_SBD",$sformatf("   Mis-Matchings=%0d",axi_common::mis_matching),UVM_NONE);
		end
	endfunction	

endclass

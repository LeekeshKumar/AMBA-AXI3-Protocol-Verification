class axi_monitor extends uvm_monitor;
	`uvm_component_utils(axi_monitor)
	`NEW_COMP
	virtual axi_intrf vif;
	uvm_analysis_port#(axi_tx) ap_port;
	axi_tx tx;
	function void build_phase(uvm_phase phase);
		`uvm_info(get_type_name(),"AXI-Monitor Build_Phase is Started",UVM_NONE)
		super.build_phase(phase);
		if(!uvm_config_db#(virtual axi_intrf)::get(this,"","vif",vif))begin
			`uvm_fatal(get_type_name(),"Virtual interface not set");
		end
		ap_port = new("ap_port",this);
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
			@(posedge vif.aclk);
			if(vif.awvalid==1 && vif.awready==1)begin
				tx = axi_tx::type_id::create("tx");
				tx.wr_rd =  WRITE;
				tx.id    =  vif.awid;
				tx.addr  =  vif.awaddr;
				tx.len   =  vif.awlen;
				tx.size  =  vif.awsize;
				tx.burst =  vif.awburst;
			end
			if(vif.wvalid==1 && vif.wready==1)begin
				tx.data.push_back(vif.wdata);
				tx.strbQ.push_back(vif.wstrb);
			end
			if(vif.bvalid==1 && vif.bready==1)begin
				tx.responseQ.push_back(vif.bresp);
				ap_port.write(tx);
				tx.print();
			end
			if(vif.arvalid==1 && vif.arready==1)begin
				tx = axi_tx::type_id::create("tx");
				tx.wr_rd =  READ;
				tx.id    =  vif.arid;
				tx.addr  =  vif.araddr;
				tx.len   =  vif.arlen;
				tx.size  =  vif.arsize;
				tx.burst =  vif.arburst;
			end
			if(vif.rvalid==1 && vif.rready==1)begin
				tx.data.push_back(vif.rdata);
				tx.responseQ.push_back(vif.rresp);
				if(vif.rlast==1)begin
					ap_port.write(tx);
					tx.print();
				end
			end
		end
	endtask
	
endclass

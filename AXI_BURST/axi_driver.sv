class axi_driver extends uvm_driver#(axi_tx);
	`uvm_component_utils(axi_driver)
	`NEW_COMP
	virtual axi_intrf vif;

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_type_name(),"AXI-Driver Build_Phase is Started",UVM_NONE)
		if(!uvm_config_db#(virtual axi_intrf)::get(this,"","vif",vif))begin
			`uvm_fatal(get_type_name(),"Virtual interface not set");
		end
	endfunction
	
	task run_phase(uvm_phase phase);
		`uvm_info(get_type_name(),"AXI-Driver run_phase is Started",UVM_NONE)
		forever begin
			wait(vif.aresetn == 1);
			seq_item_port.get_next_item(req);
			req.print();
			drive_tx(req);
			seq_item_port.item_done();
		end
	endtask

	//=============================
	//          DRIVE TX	
	//=============================
	task drive_tx(axi_tx tx);
		if(tx.wr_rd == 1)begin
			write_addr_phase(tx);
			write_data_phase(tx);
			write_resp_phase(tx);
		end
		else begin
			read_addr_phase(tx);
			read_data_phase(tx);
		end
	endtask

	//=============================
	//     WRITE ADDRESS PHASE          	
	//=============================
	task write_addr_phase(axi_tx tx);
		@(posedge vif.aclk);
		vif.awid     =  tx.id;
		vif.awaddr   =  tx.addr;
		vif.awlen    =  tx.len;
		vif.awsize   =  tx.size;
		vif.awburst  =  tx.burst;
		vif.awvalid  =  1;
		wait(vif.awready == 1);
		reset_write_addr_phase();
	endtask


	//=============================
	//     WRITE DATA PHASE          	
	//=============================
	task write_data_phase(axi_tx tx);
		for(int i=0;i<=tx.len;i++)begin
			@(posedge vif.aclk);
			vif.wid     =  tx.id;
			vif.wdata   =  tx.data.pop_front();
			vif.wstrb   =  4'b1111;
			vif.wlast   =  (i==tx.len) ? 1:0;
			vif.wvalid  =  1;
			wait(vif.wready == 1);
			reset_write_data_phase();
		end
	//	reset_write_data_phase();
	endtask


	//=============================
	//    WRITE RESPONSE PHASE          	
	//=============================

	task write_resp_phase(axi_tx tx);
		while(vif.bvalid == 0) @(posedge vif.aclk);
		if(vif.bvalid == 1)begin
			@(posedge vif.aclk);
			vif.bready = 1;
		end
		@(posedge vif.aclk) vif.bready = 0;
	endtask	


	//=============================
	//     READ ADDRESS PHASE          	
	//=============================
	task read_addr_phase(axi_tx tx);
		@(posedge vif.aclk);
		vif.arid     =  tx.id;
		vif.araddr   =  tx.addr;
		vif.arlen    =  tx.len;
		vif.arsize   =  tx.size;
		vif.arburst  =  tx.burst;
		vif.arvalid  =  1;
		wait(vif.arready == 1);
		reset_read_addr_phase();
	endtask

	//========================
	//	  READ DATA PHASE
	//========================
	task read_data_phase(axi_tx tx);
		for(int i=0;i<=tx.len;i++)begin
			while(vif.rvalid == 0)@(posedge vif.aclk);
			if(vif.rvalid == 1)begin
				tx.data.push_back(vif.rdata);
				@(posedge vif.aclk);
				vif.rready = 1;
			end
			@(posedge vif.aclk) vif.rready = 0;
		end
	endtask
	
	task reset_write_addr_phase();
		@(posedge vif.aclk);
		vif.awid     = 0; 
		vif.awaddr   = 0; 
		vif.awlen    = 0; 
		vif.awsize   = 0; 
		vif.awburst  = FIXED; 
		vif.awvalid  = 0; 
	endtask

	task reset_write_data_phase();
		@(posedge vif.aclk);
		vif.wid     = 0;  
		vif.wdata   = 0; 
		vif.wstrb   = 0;  
		vif.wlast   = 0;  
		vif.wvalid  = 0; 
	endtask

	task reset_read_addr_phase();
		@(posedge vif.aclk);
		vif.arid     = 0; 
		vif.araddr   = 0; 
		vif.arlen    = 0; 
		vif.arsize   = 0; 
		vif.arburst  = FIXED; 
		vif.arvalid  = 0; 
	endtask


endclass

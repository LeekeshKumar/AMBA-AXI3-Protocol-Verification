class axi_cov extends uvm_subscriber#(axi_tx);
	`uvm_component_utils(axi_cov)
	axi_tx tx;
	
	covergroup axi_c;
		CP_WR_RD:coverpoint tx.wr_rd{
			bins WRITES = {WRITE};
			bins READS  = {READ};
		}

	endgroup

	function new(string name,uvm_component parent);
		super.new(name,parent);
		axi_c = new();
	endfunction

	virtual function void write(axi_tx t);
		tx = new t;
		axi_c.sample();
	endfunction

endclass

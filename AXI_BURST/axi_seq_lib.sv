class base_seq extends uvm_sequence#(axi_tx);
	`uvm_object_utils(base_seq)
	`NEW_OBJ
endclass

class wr_rd_seq extends base_seq;
	axi_tx t[$],temp;
	`uvm_object_utils(wr_rd_seq)
	`NEW_OBJ
	task body();
		`uvm_do_with(req, {req.wr_rd == 1;req.size==3;req.burst==INCR;})
		temp = new req;
	
		`uvm_do_with(req, {req.wr_rd == 0;
								req.id == temp.id;
								req.addr == temp.addr;
								req.len == temp.len;
								req.size == temp.size;
								req.burst==temp.burst;})

	endtask
endclass

class axi_2wr_rd_seq extends base_seq;
	axi_tx t[$],temp;
	wr_rd_seq seq;
	`uvm_object_utils(axi_2wr_rd_seq)
	`NEW_OBJ
	task body();
		repeat(2)begin
			`uvm_do(seq);
		end	
	endtask
	
endclass

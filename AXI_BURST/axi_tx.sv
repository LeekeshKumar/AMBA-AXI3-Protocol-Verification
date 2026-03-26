class axi_tx extends uvm_sequence_item;
	rand wr_rd_e wr_rd;
	rand bit[3:0]  id;
	rand bit[`ADDR_WIDTH-1:0] addr;
	rand bit[3:0]  len;
	rand bit[2:0]  size;
	rand burst_e  burst;
	rand bit[`DATA_WIDTH-1:0] data[$];
	rand bit[`STRB_WIDTH-1:0] strbQ[$];
		 resp_e responseQ[$];

	`uvm_object_utils_begin(axi_tx)
		`uvm_field_enum(wr_rd_e,wr_rd,UVM_ALL_ON)
		`uvm_field_int(id,UVM_ALL_ON)
		`uvm_field_int(addr,UVM_ALL_ON)
		`uvm_field_int(len,UVM_ALL_ON)
		`uvm_field_int(size,UVM_ALL_ON)
		`uvm_field_enum(burst_e,burst,UVM_ALL_ON)
		`uvm_field_queue_int(data,UVM_ALL_ON)
		`uvm_field_queue_int(strbQ,UVM_ALL_ON)
		`uvm_field_queue_enum(resp_e,responseQ,UVM_ALL_ON)
	`uvm_object_utils_end

	`NEW_OBJ

	constraint dataQ_respQ{
		if(wr_rd==WRITE){
			data.size() == len+1; 
			strbQ.size()== len+1;
		}
		else{
			data.size() == 0; 
			strbQ.size()== 0;
		}	
	}
	constraint burst_type{
		burst != RESERVED;
	}
endclass

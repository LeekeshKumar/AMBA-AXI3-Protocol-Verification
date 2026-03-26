module top;
	reg aclk,aresetn;
	axi_intrf pif(aclk,aresetn);

	always #5 aclk=~aclk;
	initial begin
		aclk=0;
		aresetn=0;
		repeat(2)@(posedge aclk);
		aresetn=1;
	end

	initial begin
		uvm_config_db #(virtual axi_intrf)::set(uvm_root::get(),"*","vif",pif);
		run_test("test_5wr_rd");
	end

endmodule

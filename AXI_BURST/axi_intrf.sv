interface axi_intrf(input reg aclk,aresetn);
		
	//--> WRITE ADDRESS CHANNEL SIGNALS
	bit[3:0] awid;
	bit[`ADDR_WIDTH-1:0] awaddr;
	bit[3:0] awlen;
	bit[2:0] awsize;
	burst_e awburst;
	bit[1:0] awlock;
	bit[3:0] awcache;
	bit[2:0] awprot;
	bit awvalid;
	bit awready;

	//--> WRITE DATA CHANNEL SIGNALS
	bit[3:0] wid;
	bit[`DATA_WIDTH-1:0] wdata;
	bit[`STRB_WIDTH-1:0] wstrb;
	bit wlast;
	bit wvalid;
	bit wready;

	//--> WRITE RESPONSE CHANNEL SIGNALS
	bit[3:0] bid;
	resp_e bresp;
	bit bvalid;
	bit bready;

	//--> READ ADDRESS CHANNEL SIGNALS
	bit[3:0] arid;
	bit[`ADDR_WIDTH-1:0] araddr;
	bit[3:0] arlen;
	bit[2:0] arsize;
	burst_e  arburst;
	bit[1:0] arlock;
	bit[3:0] arcache;
	bit[2:0] arprot;
	bit arvalid;
	bit arready;

	//--> READ DATA AND RESPONSE CHANNEL SIGNALS
	bit[3:0] rid;
	resp_e   rresp;
	bit[`DATA_WIDTH-1:0] rdata;
	bit rlast;
	bit rvalid;
	bit rready;
/*
	clocking drv_cb@(posedge aclk);
		default input #0 output #1;
		output awid;
		output awaddr;
		output awlen;
		output awsize;
		output awburst;
		output awlock;
		output awcache;
		output awprot;
		output awvalid;
		input  awready;
		
		output  wid;
		output  wdata;
		output  wstrb;
		output wlast;
		output wvalid;
		input  wready;

		input  bid;
		input  bresp;
		input bvalid;
		output bready;

		output arid;
		output araddr;
		output arlen;
		output arsize;
		output arburst;
		output arlock;
		output arcache;
		output arprot;
		output arvalid;
		input  arready;

		input  rid;
		input  rresp;
		input  rdata;
		input  rlast;
		input  rvalid;
		output rready;
	endclocking

	clocking slv_cb@(posedge aclk);
		default input #1 output #0;
		input awid;
		input awaddr;
		input awlen;
		input awsize;
		input awburst;
		input awlock;
		input awcache;
		input awprot;
		input awvalid;
		output  awready;
		
		input  wid;
		input  wdata;
		input  wstrb;
		input wlast;
		input wvalid;
		output  wready;

		output  bid;
		output  bresp;
		output bvalid;
		input bready;

		input arid;
		input araddr;
		input arlen;
		input arsize;
		input arburst;
		input arlock;
		input arcache;
		input arprot;
		input arvalid;
		output  arready;

		output  rid;
		output  rresp;
		output  rdata;
		output  rlast;
		output  rvalid;
		input rready;	

	endclocking
*/
endinterface

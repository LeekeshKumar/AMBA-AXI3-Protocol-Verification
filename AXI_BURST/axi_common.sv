`define NEW_COMP \
		function new(string name,uvm_component parent); \
			super.new(name,parent); \
		endfunction

`define NEW_OBJ \
		function new(string name=""); \
			super.new(name); \
		endfunction

`define DATA_WIDTH 64
`define ADDR_WIDTH 32
`define STRB_WIDTH `DATA_WIDTH/8

typedef enum bit {READ,WRITE} wr_rd_e;
typedef enum bit[1:0] {FIXED,INCR,WRAP,RESERVED}burst_e;
typedef enum bit[1:0] {OKAY,EXOKAY,SLVERR,DECERR}resp_e; 

class axi_common;
	static int matching;
	static int mis_matching;
endclass


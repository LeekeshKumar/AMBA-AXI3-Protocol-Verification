class axi_responder extends uvm_component;
    `uvm_component_utils(axi_responder)
    `NEW_COMP

    bit [7:0] mem[*]; //to store wdata

    bit [7:0] fixed_fifo[$];

    //--------------------------------------------------
    // Write Address Channel Signals
    //--------------------------------------------------
    bit [3:0]              awid_t;
    bit [`ADDR_WIDTH-1:0]  awaddr_t;
    bit [3:0]              awlen_t;
    bit [2:0]              awsize_t;
    burst_e                awburst_t;

    //--------------------------------------------------
    // Write Data Channel Signals
    //--------------------------------------------------
    bit [3:0]              wid_t;
    bit [`DATA_WIDTH-1:0]  wdata_t;
    bit [3:0]              wstrb_t;

    //--------------------------------------------------
    // Read Address Channel Signals
    //--------------------------------------------------
    bit [3:0]              arid_t;
    bit [`ADDR_WIDTH-1:0]  araddr_t;
    bit [3:0]              arlen_t;
    bit [2:0]              arsize_t;
    burst_e                arburst_t;

    //--------------------------------------------------
    // Wrap Boundary Variables
    //--------------------------------------------------
    bit [`ADDR_WIDTH-1:0]  wrap_lower;
    bit [`ADDR_WIDTH-1:0]  wrap_upper;

    //--------------------------------------------------
    // Virtual Interface
    //--------------------------------------------------
    virtual axi_intrf vif;

    //--------------------------------------------------
    // Build Phase
    //--------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "AXI Responder Build Phase Started", UVM_NONE)
        if (!uvm_config_db#(virtual axi_intrf)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not set");
    endfunction

    //--------------------------------------------------
    // Run Phase
    //--------------------------------------------------
    task run_phase(uvm_phase phase);
        wait(vif.aresetn == 1);
        forever begin
            @(posedge vif.aclk);

            //--- Write Address Channel Handshake ---
            if (vif.awvalid == 1) begin
                vif.awready = 1;
                awid_t    = vif.awid;
                awaddr_t  = vif.awaddr;
                awlen_t   = vif.awlen;
                awsize_t  = vif.awsize;
                awburst_t = vif.awburst;
                wrap_calc(awaddr_t, awsize_t, awlen_t);
            end
            else vif.awready = 0;

            //--- Write Data Channel Handshake ---
            if (vif.wvalid == 1) begin
                vif.wready = 1;
                wid_t   = vif.wid;
                wdata_t = vif.wdata;
                wstrb_t = vif.wstrb;

                $display("=========>>>>  wdata= %h", wdata_t);

                //--- FIXED: push each byte into the flat FIFO queue ---
                if (awburst_t == FIXED) begin
                    for (int i = 0; i < 2**awsize_t; i++) begin
                        fixed_fifo.push_back(wdata_t[8*i+:8]);
                        $display("=========>>>> FIXED push[%0d]= %h  depth=%0d",
                                 i, wdata_t[8*i+:8], fixed_fifo.size());
                    end
                end

                //--- INCR / WRAP: write bytes into memory at advancing address ---
                else begin
                    for (int i = 0; i < 2**awsize_t; i++) begin
                        mem[awaddr_t+i] = wdata_t[8*i+:8];
                        $display("=========>>>> %0h data[%0d]= %h",
                                 awaddr_t+i, i, mem[awaddr_t+i]);
                    end
                end

                $display("=========>>>>........................");
                awaddr_t = next_address_calc(awburst_t, awaddr_t, awsize_t);

                if (vif.wlast == 1) begin
                    fork
                        write_resp(wid_t);
                    join_none
                end
            end
            else vif.wready = 0;

            //--- Read Address Channel Handshake ---
            if (vif.arvalid == 1) begin
                vif.arready = 1;
                arid_t    = vif.arid;
                araddr_t  = vif.araddr;
                arlen_t   = vif.arlen;
                arsize_t  = vif.arsize;
                arburst_t = vif.arburst;
                wrap_calc(araddr_t, arsize_t, arlen_t);

                fork
                    read_data_resp(arid_t);
                join_none
            end
            else vif.arready = 0;
        end
    endtask

    //--------------------------------------------------
    // Wrap Boundary Calculation
    // total_bytes = (2**size) * (len+1)
    // lower_wrap  = addr - (addr % total_bytes)
    // upper_wrap  = lower_wrap + total_bytes - 1
    //--------------------------------------------------
    function void wrap_calc(
        input  bit [`ADDR_WIDTH-1:0] addr,
        input  bit [2:0]             size,
        input  bit [3:0]             len
    );
        int total_bytes;
        int remainder;
        total_bytes = (2**size) * (len + 1);
        remainder   = addr % total_bytes;
        wrap_lower  = addr - remainder;
        wrap_upper  = wrap_lower + total_bytes - 1;
    endfunction

    //--------------------------------------------------
    // Write Response Phase
    //--------------------------------------------------
    task write_resp(bit [3:0] id);
        @(posedge vif.aclk);
        vif.bid    = id;
        vif.bresp  = OKAY;
        vif.bvalid = 1;
        wait(vif.bready == 1);
        @(posedge vif.aclk);
        vif.bid    = 0;
        vif.bresp  = OKAY;
        vif.bvalid = 0;
    endtask

    //--------------------------------------------------
    // Read Data and Response Phase
    //--------------------------------------------------
    task read_data_resp(bit [3:0] id);
        bit [`DATA_WIDTH-1:0] data_t;
        for (int i = 0; i <= arlen_t; i++) begin
            @(posedge vif.aclk);
            vif.rid   = id;
            vif.rresp = OKAY;

            //--- FIXED: pop bytes from the flat FIFO queue ---
            if (arburst_t == FIXED) begin
                for (int j = 0; j < 2**arsize_t; j++) begin
                    if (fixed_fifo.size() > 0) begin
                        data_t[8*j+:8] = fixed_fifo.pop_front();
                        $display("=========>>>> FIXED pop[%0d]= %h  depth left=%0d",
                                 j, data_t[8*j+:8], fixed_fifo.size());
                    end
                    else begin
                        data_t[8*j+:8] = 8'h00;
                        `uvm_warning(get_type_name(),
                            $sformatf("FIXED FIFO underflow at beat %0d lane %0d", i, j))
                    end
                end
            end

            //--- INCR / WRAP: read bytes from memory at advancing address ---
            else begin
                for (int j = 0; j < 2**arsize_t; j++) begin
                    data_t[8*j+:8] = mem[araddr_t+j];
                    $display("=========>>>> %0h rdata[%0d]= %h",
                             araddr_t+j, j, mem[araddr_t+j]);
                end
            end

            $display("=========>>>> *** rdata= %h", data_t);
            $display("=========>>>>........................");

            vif.rdata  = data_t;
            araddr_t   = next_address_calc(arburst_t, araddr_t, arsize_t);
            vif.rlast  = (i == arlen_t) ? 1 : 0;
            vif.rvalid = 1;
            wait(vif.rready == 1);
            @(posedge vif.aclk);
            vif.rid    = 0;
            vif.rresp  = OKAY;
            vif.rdata  = 0;
            vif.rlast  = 0;
            vif.rvalid = 0;
        end
    endtask

    // Next Address Calculation
    function bit [`ADDR_WIDTH-1:0] next_address_calc(
        burst_e               burst,
        bit [`ADDR_WIDTH-1:0] addr,
        bit [2:0]             burst_size
    );
        bit [`ADDR_WIDTH-1:0] next_addr;
        case (burst)
            FIXED: return addr;
            INCR:  return addr + (2**burst_size);
            WRAP: begin
                next_addr = addr + (2**burst_size);
                if (next_addr >= wrap_upper)
                    return wrap_lower;
                else
                    return next_addr;
            end
        endcase
    endfunction

endclass

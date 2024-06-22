// ----------------------------------------------------------------------------
// AXI4 stream 
// ----------------------------------------------------------------------------
interface AXI4S #(
	parameter AXI4S_DATA_BITS = 512
) (
    input  logic aclk
);

localparam AXI4S_KEEP_BITS = AXI4S_DATA_BITS / 8;

typedef logic [AXI4S_DATA_BITS-1:0] data_t;
typedef logic [AXI4S_KEEP_BITS-1:0] keep_t;

data_t          tdata;
keep_t  		tkeep;
logic           tlast;
logic           tready;
logic           tvalid;

// Tie off unused master signals
task tie_off_m ();
    tdata      = 0;
    tkeep      = 0;
    tlast     = 1'b0;
    tvalid     = 1'b0;
endtask

// Tie off unused slave signals
task tie_off_s ();
    tready     = 1'b0;
endtask

// Master
modport m (
	import tie_off_m,
	input tready,
	output tdata, tkeep, tlast, tvalid
);

// Slave
modport s (
    import tie_off_s,
    input tdata, tkeep, tlast, tvalid,
    output tready
);

endinterface

// ----------------------------------------------------------------------------
// Generic meta interface
// ----------------------------------------------------------------------------
interface metaIntf #(
	parameter type STYPE = logic[63:0]
) (
	input  logic aclk
);

logic valid;
logic ready;
STYPE data;

task tie_off_s ();
	ready = 1'b0;
endtask

task tie_off_m ();
	data = 0;
	valid = 1'b0;
endtask

modport s (
	import tie_off_s,
	input  valid,
	output ready,
	input  data
);

modport m (
	import tie_off_m,
	output valid,
	input  ready,
	output data
);

endinterface
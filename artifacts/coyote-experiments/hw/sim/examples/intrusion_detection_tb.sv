`timescale 1ns / 1ps

module intrusion_detection_tb(); 

// Clock and Reset 
logic clk; 
logic rst; 

// Inputs to the payload extractor 
logic [511:0] input_tdata; 
logic [63:0] input_tkeep; 
logic input_tvalid; 
logic input_tlast; 

// Output: ML-decision and QPN
logic [31:0] meta_output; 

// Meta-interface as output of the intrusion_detection_decider - QPN and decision
metaIntf #(.STYPE(logic [24:0])) ml_decision ();

// AXI-port as output of the payload extractor
AXI4S #(.AXI4S_DATA_BITS(512)) payload_output(); 

// Initialize the payload_extractor as dut_1
payload_extractor dut_sim_1(
    .nclk(clk), 
    .nresetn(rst), 
    .m_axis_rx_data_i(input_tdata), 
    .m_axis_rx_keep_i(input_tkeep), 
    .m_axis_rx_valid_i(input_tvalid), 
    .m_axis_rx_last_i(input_tlast), 
    .m_axis_payload_tx(payload_output), 
    .meta_tx_o(meta_output)
); 

// Initialize the intrusion_detection_decider as dut_2 and connect it accordingly
intrusion_detection_decider dut_sim_2(
    .nclk(clk), 
    .nresetn(rst), 
    .s_axis_payload_rx(payload_output), 
    .meta_rx_i(meta_output), 
    .m_rdma_intrusion_decision(ml_decision)
);

// Generate the required clock signal 
initial begin 
    clk = 1'b0; 
    forever #1 clk = !clk; 
end 

// Generate the test stimulus 
initial begin 
    // Initial reset (low active reset)
    input_tvalid <= 1'b0; 
    input_tlast <= 1'b0; 
    input_tdata <= 512'b0; 
    input_tkeep <= 64'h0; 
    rst <= 1'b0; 

    #4
    rst <= 1'b1; 

    #2
    // First part of the incoming write, including header
    input_tvalid <= 1'b1; 
    input_tlast <= 1'b0; 
    input_tdata[511:0] <= 512'h52f724d8d0046341b5c9baebaf7b2b65d20c9ec2176e293b1c5f728000000000ffff400800001804b7123848604afd0a5c4afd0a09681164004000002c040245; 
    // input_tdata[511:0] <= 512'hd20c9ec2176e293b00040000000000000000c0ca877f00007af5158000000000ffff400600002804b7123848644afd0a584afd0af9671164004000003c040245; 
    input_tkeep <= 64'hfffffffffffffffff; 

    #2

    input_tvalid <= 1'b1; 
    input_tlast <= 1'b0; 
    input_tdata[511:0] <= 512'h52f724d8d0046341b5c9baebaf7b2b65d20c9ec2176e293bd17e19e26b7cd6718754f1547c213ed5251e893fc54ff1a6758eef9aeba639bcd7103e86afc34f20;
    // input_tdata[511:0] <= 512'hd20c9ec2176e293bd17e19e26b7cd6718754f1547c213ed5251e893fc54ff1a6758eef9aeba639bcd7103e86afc34f2052f724d8d0046341b5c9baebaf7b2b65;
    input_tkeep <= 64'hfffffffffffffffff;

    #30 

    input_tvalid <= 1'b1; 
    input_tlast <= 1'b1; 
    input_tdata[511:0] <= 512'h0000000000000000000000000000000000000000f090a185d17e19e26b7cd6718754f1547c213ed5251e893fc54ff1a6758eef9aeba639bcd7103e86afc34f20; 
    // input_tdata[511:0] <= 512'h21e7d3b0ec0e0b7ed17e19e26b7cd6718754f1547c213ed5251e893fc54ff1a6758eef9aeba639bcd7103e86afc34f2052f724d8d0046341b5c9baebaf7b2b65;
    input_tkeep <= 64'h00000fffffffffff; 
    // input_tkeep <= 64'h0fffffffffffffff;
    

    // Resetting the input signal completely 
    #2
    input_tvalid <= 1'b0; 
    input_tlast <= 1'b0; 
    input_tdata <= 512'b0; 
    input_tkeep <= 64'h0; 

end 

endmodule 

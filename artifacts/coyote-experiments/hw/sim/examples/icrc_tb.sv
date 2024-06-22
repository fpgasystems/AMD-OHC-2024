`timescale 1ns / 1ps

module icrc_tb(); 

 // Clock and Reset 
logic clk; 
logic rst; 


// AXI-port as output of the payload extractor
AXI4S #(.AXI4S_DATA_BITS(512)) icrc_input(); 
// AXI-port as output of the payload extractor
AXI4S #(.AXI4S_DATA_BITS(512)) icrc_output(); 

assign icrc_output.tready = 1'b1;

icrc dut_sim_1(
    .m_axis_rx(icrc_input), 
    .m_axis_tx(icrc_output), 
    .nclk(clk), 
    .nresetn(rst)
); 


initial begin 
    clk = 1'b0; 
    forever #1 clk = !clk; 
end 


initial begin 
    // Initial reset (low active reset)
    icrc_input.tvalid <= 1'b0; 
    icrc_input.tlast <= 1'b0; 
    icrc_input.tdata <= 512'b0; 
    icrc_input.tkeep <= 64'h0; 
    icrc_output.tready <= 1'b1; 
    rst <= 1'b0; 

    #4

    rst <= 1'b1; 

    #2 

    icrc_input.tvalid <= 1'b1; 
    icrc_input.tlast <= 1'b0; 
    icrc_input.tkeep <= 64'hffffffffffffffff; 
    icrc_input.tdata <= 512'h52f724d8d0046341b5c9baebaf7b2b65d20c9ec2176e293b1c5f728000000000ffff400800001804b7123848604afd0a5c4afd0a09681164004000002c040245;

    #2 

    icrc_input.tvalid <= 1'b1; 
    icrc_input.tlast <= 1'b0; 
    icrc_input.tkeep <= 64'hffffffffffffffff; 
    icrc_input.tdata <= 512'h52f724d8d0046341b5c9baebaf7b2b65d20c9ec2176e293bd17e19e26b7cd6718754f1547c213ed5251e893fc54ff1a6758eef9aeba639bcd7103e86afc34f20;

    #30

    icrc_input.tvalid <= 1'b1; 
    icrc_input.tlast <= 1'b1; 
    icrc_input.tkeep <= 64'h000000ffffffffff; 
    icrc_input.tdata <= 512'h0000000000000000000000000000000000000000f090a185d17e19e26b7cd6718754f1547c213ed5251e893fc54ff1a6758eef9aeba639bcd7103e86afc34f20;

    #2

    icrc_input.tvalid <= 1'b0; 
    icrc_input.tlast <= 1'b0; 
    icrc_input.tkeep <= 64'h0; 
    icrc_input.tdata <= 512'b0; 

end 

endmodule 
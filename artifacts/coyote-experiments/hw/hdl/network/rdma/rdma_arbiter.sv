/**
  * Copyright (c) 2021, Systems Group, ETH Zurich
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * 1. Redistributions of source code must retain the above copyright notice,
  * this list of conditions and the following disclaimer.
  * 2. Redistributions in binary form must reproduce the above copyright notice,
  * this list of conditions and the following disclaimer in the documentation
  * and/or other materials provided with the distribution.
  * 3. Neither the name of the copyright holder nor the names of its contributors
  * may be used to endorse or promote products derived from this software
  * without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */

`timescale 1ns / 1ps

import lynxTypes::*;

`include "axi_macros.svh"
`include "lynx_macros.svh"

/**
 * @brief   RDMA arbitration
 *
 * Arbitration layer between all present user regions
 */
module rdma_arbiter (

    // Input clock and reset 
    input  wire             aclk,
    input  wire             aresetn,

    // Network
    // Outgoing: Sending Queue Meta-Information
    metaIntf.m              m_rdma_sq_net,
    // Incoming: ACKs Meta-Information for Acking Elements in the Queue
    metaIntf.s              s_rdma_ack_net,

    // Incoming: Read and Write Requests 
    metaIntf.s              s_rdma_rd_req_net,
    metaIntf.s              s_rdma_wr_req_net,

    // Outgoing: Answers to reads from a user   
    AXI4S.m                 m_axis_rdma_rd_net,

    // Incoming: Data to be written in a user 
    AXI4S.s                 s_axis_rdma_wr_net,

    /////////////////////////////////////////////////
    //
    // User - Multiple user interfaces for all vFPGAs 
    //
    /////////////////////////////////////////////////

    // Incoming Sending Queue Meta-Information from the users 
    metaIntf.s              s_rdma_sq_user [N_REGIONS],

    // Outgoing: ACKs Meta-Information for Acking Elements in the Queues of the users 
    metaIntf.m              m_rdma_ack_user [N_REGIONS],

    // Outgoing: Read and Write Requests to the users in the vFPGAs 
    metaIntf.m              m_rdma_rd_req_user [N_REGIONS],
    metaIntf.m              m_rdma_wr_req_user [N_REGIONS],

    // Incoming: Answers to reads from the users   
    AXI4SR.s                s_axis_rdma_rd_user [N_REGIONS],

    // Outgoing: Data to be written in a user 
    AXI4SR.m                m_axis_rdma_wr_user [N_REGIONS]
);

//
// Arbitration
//

// Arbitration RDMA requests host: Takes N requests from the users to use the RDMA-stack and outputs a single arbitrated RDMA-request to the networking stack 
rdma_meta_tx_arbiter inst_rdma_req_host_arbiter (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_meta(s_rdma_sq_user),
    .m_meta(m_rdma_sq_net),
    .vfid()
);

// Arbitration ACKs: Takes a single incoming ACK from the networking stack and distributes it to the right user 
rdma_meta_rx_arbiter inst_rdma_ack_arbiter (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_meta(s_rdma_ack_net),
    .m_meta(m_rdma_ack_user),
    .vfid()
);

//
// Memory
//

// Read command and data: Takes in multiple commands and data from multiple users, forwards only one to the stack 
rdma_mux_cmd_rd inst_mux_cmd_rd (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_req(s_rdma_rd_req_net),
    .m_req(m_rdma_rd_req_user),
    .s_axis_rd(s_axis_rdma_rd_user),
    .m_axis_rd(m_axis_rdma_rd_net)
);

// Write command crossing: Takes in multiple write commands and data from the stack, forwards to the correct user 
rdma_mux_cmd_wr inst_mux_cmd_wr (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_req(s_rdma_wr_req_net),
    .m_req(m_rdma_wr_req_user),
    .s_axis_wr(s_axis_rdma_wr_net),
    .m_axis_wr(m_axis_rdma_wr_user)
);

endmodule
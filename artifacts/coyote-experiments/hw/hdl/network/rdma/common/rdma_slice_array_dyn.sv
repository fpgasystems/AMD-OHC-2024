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

import lynxTypes::*;

`include "axi_macros.svh"
`include "lynx_macros.svh"

/**
 * @brief   RDMA slice array
 *
 * RDMA slicing
 *
 */
module rdma_slice_array_dyn #(
    parameter integer       N_STAGES = 2  
) (
    // Network
    metaIntf.m              m_rdma_qp_interface_n,
    metaIntf.m              m_rdma_conn_interface_n,

    metaIntf.m              m_rdma_sq_n,
    metaIntf.s              s_rdma_cq_n,
    metaIntf.s              s_rdma_rq_rd_n,
    metaIntf.s              s_rdma_rq_wr_n,
    AXI4S.m                 m_axis_rdma_rd_n,
    AXI4S.s                 s_axis_rdma_wr_n,
    
    // User
    metaIntf.s              s_rdma_qp_interface_u,
    metaIntf.s              s_rdma_conn_interface_u,

    metaIntf.s              s_rdma_sq_u,
    metaIntf.m              m_rdma_cq_u,
    metaIntf.m              m_rdma_rq_rd_u,
    metaIntf.m              m_rdma_rq_wr_u,
    AXI4S.s                 s_axis_rdma_rd_u,
    AXI4S.m                 m_axis_rdma_wr_u,

    input  wire             aclk,
    input  wire             aresetn
);

metaIntf #(.STYPE(rdma_qp_ctx_t)) rdma_qp_interface_s [N_STAGES+1]();
metaIntf #(.STYPE(rdma_qp_conn_t)) rdma_conn_interface_s [N_STAGES+1]();
metaIntf #(.STYPE(dreq_t)) rdma_sq_s [N_STAGES+1]();
metaIntf #(.STYPE(ack_t)) rdma_cq_s [N_STAGES+1]();
metaIntf #(.STYPE(req_t)) rdma_rq_rd_s [N_STAGES+1]();
metaIntf #(.STYPE(req_t)) rdma_rq_wr_s [N_STAGES+1]();
AXI4S #(.AXI4S_DATA_BITS(AXI_NET_BITS)) axis_rdma_rd_s [N_STAGES+1]();
AXI4S #(.AXI4S_DATA_BITS(AXI_NET_BITS)) axis_rdma_wr_s [N_STAGES+1]();

// Slaves
`META_ASSIGN(s_rdma_cq_n, rdma_cq_s[0])
`META_ASSIGN(s_rdma_rq_rd_n, rdma_rq_rd_s[0])
`META_ASSIGN(s_rdma_rq_wr_n, rdma_rq_wr_s[0])
`AXIS_ASSIGN(s_axis_rdma_wr_n, axis_rdma_wr_s[0])

`META_ASSIGN(s_rdma_qp_interface_u, rdma_qp_interface_s[0])
`META_ASSIGN(s_rdma_conn_interface_u, rdma_conn_interface_s[0])
`META_ASSIGN(s_rdma_sq_u, rdma_sq_s[0])
`AXIS_ASSIGN(s_axis_rdma_rd_u, axis_rdma_rd_s[0])

// Masters
`META_ASSIGN(rdma_qp_interface_s[N_STAGES], m_rdma_qp_interface_n)
`META_ASSIGN(rdma_conn_interface_s[N_STAGES], m_rdma_conn_interface_n)
`META_ASSIGN(rdma_sq_s[N_STAGES], m_rdma_sq_n)
`AXIS_ASSIGN(axis_rdma_rd_s[N_STAGES], m_axis_rdma_rd_n)

`META_ASSIGN(rdma_cq_s[N_STAGES], m_rdma_cq_u)
`META_ASSIGN(rdma_rq_rd_s[N_STAGES], m_rdma_rq_rd_u)
`META_ASSIGN(rdma_rq_wr_s[N_STAGES], m_rdma_rq_wr_u)
`AXIS_ASSIGN(axis_rdma_wr_s[N_STAGES], m_axis_rdma_wr_u)

for(genvar i = 0; i < N_STAGES; i++) begin

    // RDMA qp interface
    axis_register_slice_rdma_184 inst_rdma_qp_interface (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(rdma_qp_interface_s[i].valid),
        .s_axis_tready(rdma_qp_interface_s[i].ready),
        .s_axis_tdata (rdma_qp_interface_s[i].data),
        .m_axis_tvalid(rdma_qp_interface_s[i+1].valid),
        .m_axis_tready(rdma_qp_interface_s[i+1].ready),
        .m_axis_tdata (rdma_qp_interface_s[i+1].data)
    );

    // RDMA conn interface
    axis_register_slice_rdma_184 inst_rdma_conn_interface (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(rdma_conn_interface_s[i].valid),
        .s_axis_tready(rdma_conn_interface_s[i].ready),
        .s_axis_tdata (rdma_conn_interface_s[i].data),
        .m_axis_tvalid(rdma_conn_interface_s[i+1].valid),
        .m_axis_tready(rdma_conn_interface_s[i+1].ready),
        .m_axis_tdata (rdma_conn_interface_s[i+1].data)
    );

    // RDMA send queue
    axis_register_slice_rdma_256 inst_rdma_sq_nc (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(rdma_sq_s[i].valid),
        .s_axis_tready(rdma_sq_s[i].ready),
        .s_axis_tdata (rdma_sq_s[i].data),
        .m_axis_tvalid(rdma_sq_s[i+1].valid),
        .m_axis_tready(rdma_sq_s[i+1].ready),
        .m_axis_tdata (rdma_sq_s[i+1].data)
    );

    // RDMA acks
    axis_register_slice_rdma_32 inst_rdma_cq_nc (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(rdma_cq_s[i].valid),
        .s_axis_tready(rdma_cq_s[i].ready),
        .s_axis_tdata (rdma_cq_s[i].data),
        .m_axis_tvalid(rdma_cq_s[i+1].valid),
        .m_axis_tready(rdma_cq_s[i+1].ready),
        .m_axis_tdata (rdma_cq_s[i+1].data)
    );

    // RDMA rd command
    axis_register_slice_rdma_128 inst_rdma_req_rd_nc (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(rdma_rq_rd_s[i].valid),
        .s_axis_tready(rdma_rq_rd_s[i].ready),
        .s_axis_tdata (rdma_rq_rd_s[i].data),
        .m_axis_tvalid(rdma_rq_rd_s[i+1].valid),
        .m_axis_tready(rdma_rq_rd_s[i+1].ready),
        .m_axis_tdata (rdma_rq_rd_s[i+1].data)
    );

    // Read data crossing
    axis_register_slice_rdma_data_512 inst_rdma_data_rd_nc (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(axis_rdma_rd_s[i].tvalid),
        .s_axis_tready(axis_rdma_rd_s[i].tready),
        .s_axis_tdata (axis_rdma_rd_s[i].tdata),
        .s_axis_tkeep (axis_rdma_rd_s[i].tkeep),
        .s_axis_tlast (axis_rdma_rd_s[i].tlast),
        .m_axis_tvalid(axis_rdma_rd_s[i+1].tvalid),
        .m_axis_tready(axis_rdma_rd_s[i+1].tready),
        .m_axis_tdata (axis_rdma_rd_s[i+1].tdata),
        .m_axis_tkeep (axis_rdma_rd_s[i+1].tkeep),
        .m_axis_tlast (axis_rdma_rd_s[i+1].tlast)
    );

    // RDMA wr command
    axis_register_slice_rdma_128 inst_rdma_req_wr_nc (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(rdma_rq_wr_s[i].valid),
        .s_axis_tready(rdma_rq_wr_s[i].ready),
        .s_axis_tdata (rdma_rq_wr_s[i].data),
        .m_axis_tvalid(rdma_rq_wr_s[i+1].valid),
        .m_axis_tready(rdma_rq_wr_s[i+1].ready),
        .m_axis_tdata (rdma_rq_wr_s[i+1].data)
    );

    // Write data crossing
    axis_register_slice_rdma_data_512 inst_rdma_data_wr_nc (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(axis_rdma_wr_s[i].tvalid),
        .s_axis_tready(axis_rdma_wr_s[i].tready),
        .s_axis_tdata (axis_rdma_wr_s[i].tdata),
        .s_axis_tkeep (axis_rdma_wr_s[i].tkeep),
        .s_axis_tlast (axis_rdma_wr_s[i].tlast),
        .m_axis_tvalid(axis_rdma_wr_s[i+1].tvalid),
        .m_axis_tready(axis_rdma_wr_s[i+1].tready),
        .m_axis_tdata (axis_rdma_wr_s[i+1].tdata),
        .m_axis_tkeep (axis_rdma_wr_s[i+1].tkeep),
        .m_axis_tlast (axis_rdma_wr_s[i+1].tlast)
    );

end

endmodule

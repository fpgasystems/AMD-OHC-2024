// WARNING: Uses absolute IP-addresses of alveo-u55c-08, must be changed in order to run on a different server

// alveo-u55c-03:
// 10.253.74.74 - 184371786
// 10.1.212.173 - 167892141
// MAC: 08:c0:eb:c6:40:ca - 9624682381514

// alveo-u55c-04: 
// 10.253.74.78 - 184371790
// 10.1.212.174 - 167892142

// alveo-u55c-08:
// 10.253.74.94 - 184371806
// 10.1.212.178 - 167892146
// MAC: 08:c0:eb:c6:40:aa - 9624682381482

// alveo-u55c-09:
// 10.253.74.98 - 184371810
// 10.1.212.179 - 167892147
// MAC: b8:59:9f:e8:94:9a - 202695074419866

// alveo-u55c-10:
// 10.253.74.102 - 184371814
// 10.1.212.180 - 167892148

// hacc-box-02:
// 10.253.74.120 - 184371832
// 10.1.212.7 - 167891975

// hacc-box-03:
// 10.253.74.130 - 184371842
// 10.1.212.8 - 167891976

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <sys/queue.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <byteswap.h>
#include <rdma/rdma_cma.h>
#include <unistd.h>
#include <time.h>
#include <stdbool.h>
#include <unistd.h> 


struct ibvQ {
    // Node 
    uint32_t ip_addr; 

    // Queue 
    uint32_t qpn; 
    uint32_t psn;
    uint32_t rkey;

    // Buffer 
    uint64_t *vaddr;
    uint32_t size;

    // Global ID 
    char gid[33];

	/*uint32_t function_pointer_1;
	uint32_t function_pointer_2;
	uint32_t function_pointer_3;*/

    /*uint32_t gidToUint(int idx);
    void uintToGid(int idx, uint32_t  ip_addr);
    void print(const char *name);*/
};

uint32_t gidToUint(int idx) {
	return (uint32_t)idx;
}

void uintToGid(int idx, uint32_t ip_addr)  {
	printf("Was not implemented! \n");
}

void print(const char *name) {
	printf("Was not implemented! \n");
}

const int msgAck = 1;
const int msgNAck = 0; 
const int hugePageSize = (2*1024*1024);

int main(int argc, char *argv[]) 
{
	// Testing parameters, later to be set with function arguments 
	uint32_t n_bench_runs = 1;
	uint32_t n_reps = 1; 
	uint32_t min_size = 64; 
	uint32_t max_size = 64;
	bool lat_test = 1;
	bool thr_test = 0;
	bool write_op = 1;
	// uint32_t own_server_no = 10;
	uint32t ip_addr = 0; 

	uint32_t mult_factor = 1; 
	if(write_op) {
		mult_factor = 2; 
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// CREATION OF LOCAL ELEMENTS FOR COMMUNICATION 
	//
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Get device to be opened 
	struct ibv_device **dev_list; 
	dev_list = ibv_get_device_list(NULL);
	if(!dev_list) {
		printf("1 - Device not found! \n");
		goto end;
		return -1;
	} else {
		printf("Found the following device: %s \n", ibv_get_device_name(dev_list[0]));
	}

	// Communication context 
	struct ibv_context *context; 
	context = ibv_open_device(dev_list[0]);
	if(!context) {
		printf("2 - Context not created, Device couldn't be opened! \n");
		goto end;
		return -1; 
	} else {
		printf("Opened the following device: %s \n", ibv_get_device_name(context->device));
	}

	// Communication Protection Domain 
	struct ibv_pd *pd; 
	pd = ibv_alloc_pd(context);
	if(!pd) {
		printf("3 - Protection Domain couldn't be allocated! \n");
		goto end;
		return -1;
	} else {
		printf("Allocated the Protection Domain. \n");
	}

	// Register Memory Region 
	uint32_t n_pages = (max_size + hugePageSize -1) / hugePageSize;
	printf("Size of the allocated buffer: %d Bytes. \n", (n_pages*hugePageSize));
	uint64_t *buf = calloc(1, n_pages*hugePageSize);
	if(buf == NULL) {
		printf("3.5 - Couldn't obtain a buffer in the required size! \n");
		goto end; 
	} else {
		printf("Buffer obtained successfully! \n");
	}
	struct ibv_mr *mr; 
	mr = ibv_reg_mr(pd,  buf, max_size, IBV_ACCESS_LOCAL_WRITE | IBV_ACCESS_REMOTE_WRITE | IBV_ACCESS_REMOTE_READ);
	if(!mr) {
		printf("4 - Memory Region couldn't be allocated! \n");
		goto end;
		return -1;
	} else {
		printf("Allocated the Memory Region. \n");
	}

	// Create completion channel
	struct ibv_comp_channel *comp_channel; 
	comp_channel = ibv_create_comp_channel(context);
	if(!comp_channel) {
		printf("5 - Completion Channel couldn't be created! \n");
		goto end;
		return -1;
	} else {
		printf("Created the Completion Channel. \n");
	}

	// Create completion queue 
	struct ibv_cq *comp_queue; 
	comp_queue = ibv_create_cq(context, 100, NULL, comp_channel, 0);
	if(!comp_queue) {
		printf("6 - Completion Queue couldn't be created! \n");
		goto end;
		return -1;
	} else {
		printf("Created the Completion Queue. \n");
	}

	// Create init attributes for the queue pair
	struct ibv_qp_init_attr qp_init_attr; 
	memset(&qp_init_attr, 0, sizeof(qp_init_attr));
	qp_init_attr.send_cq = comp_queue;
	qp_init_attr.recv_cq = comp_queue;
	qp_init_attr.qp_type = IBV_QPT_RC;
	qp_init_attr.cap.max_send_wr = 1000; 
	qp_init_attr.cap.max_recv_wr = 1000; 
	qp_init_attr.cap.max_send_sge = 1; 
	qp_init_attr.cap.max_recv_sge = 1; 
	printf("Created the QP Init Attributes. \n");

	// Create Queue Pair 
	struct ibv_qp *qp; 
	qp = ibv_create_qp(pd, &qp_init_attr);
	if(!qp) {
		printf("7 - Queue Pair couldn't be created! \n");
		goto end;
		return -1;
	} else {
		printf("Created a Queue Pair. \n");
	}

	// Set Queue Pair to INIT
	struct ibv_qp_attr attr; 
	memset(&attr, 0 , sizeof(attr));
	attr.qp_state = IBV_QPS_INIT; 
	attr.port_num = 1;
	attr.pkey_index = 0; 
	attr.qp_access_flags = IBV_ACCESS_REMOTE_WRITE | IBV_ACCESS_REMOTE_READ; 
	attr.path_mtu = 4096; 

	switch(ibv_modify_qp(qp, &attr, IBV_QP_STATE | IBV_QP_ACCESS_FLAGS | IBV_QP_PKEY_INDEX | IBV_QP_PORT)) {
		case 0: printf("Set the Queue Pair to INIT. \n"); break;
		case -1: printf("8 - Queue Pair couldn't be set to INIT - unspecified! \n"); goto end; return -1; break; 
		case EINVAL: printf("8 - Queue Pair couldn't be set to INIT - Invalid Value provided! \n"); goto end; return -1; break; 
		case ENOMEM: printf("8 - Queue Pair couldn't be set to INIT - not enough resources! \n"); goto end; return -1; break;
		default: printf("I don't know what's going on. \n"); goto end; return -1; break;
	}


	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// Set up socket for meta-communication to set up queue pairs
	//
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	int sockfd = -1, connfd; 
	char recv_buf[1024];
	memset(recv_buf, 0, 1024);
	struct sockaddr_in server; 

	// Create socket and test if operation was successful or not 
	sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if(sockfd == -1) {
		printf("9 - Socket couldn't be created! \n");
		goto end; 
		return -1; 
	} else {
		printf("Created socket. \n");
	}

	// Force connect the socket
	if(setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int)) < 0) {
		printf("9.5 - Couldn't set socket option SO_REUSEADDR! \n");
		goto end;
	} else {
		printf("Set socket option SO_REUSEADDR. \n");
	}

	// Server connection given by Protocol, Address, Port
	server.sin_family = AF_INET; 
	server.sin_addr.s_addr = INADDR_ANY; 
	server.sin_port = htons(18488);
	// server.sin_port = htons(4791);

	// Try to bind the socket to the network interface of server, test if that was successful
	if(bind(sockfd, (struct sockaddr*)&server, sizeof(server)) < 0) {
		printf("10 - Couldn't bind a socket! \n");
		goto end;
		return -1;
	} else {
		printf("Bind to a socket. \n");
	}

	// Try to listen to the port
	if(sockfd < 0) {
		printf("11 - Could not listen to the port! \n");
		goto end;
		return -1;
	} else {
		printf("Listened to the port. \n");
	}

	// Listen to the port 
	listen(sockfd, 1);

	// Accept incoming connection 
	connfd = accept(sockfd, NULL, 0);
	
	if(connfd < 0) {
		printf("12 - Acceptance of incoming connection failed! \n");
		goto end;
		return -1;
	} else {
		printf("Accepted the incoming connection \n");
	}

	// Read qpid from the connection, close if that didn't work 
	uint32_t recv_qpid; 
	if (read(connfd, recv_buf, sizeof(uint32_t)) != sizeof(uint32_t)) {
		close(connfd);
		printf("13 - Could not read the qpid from the incoming connection! \n");
		goto end;
		return -1;
	} else {
		memcpy(&recv_qpid, recv_buf, sizeof(uint32_t));
		printf("Received the remote qpid %d. \n", recv_qpid);
	}

	// Send ack for acceptable qpair ID 
	int ack = msgAck; 
	if(write(connfd, &ack, 1) != 1) {
		close(connfd);
		printf("14 - Could not send an ACK to the remote side! \n");
		goto end;
		return -1; 
	} else {
		printf("Ack was sent to the remote side. \n");
	}

	// Read a queue from the socket connection 
	// printf("Size of the read content: %d \n", read(connfd, recv_buf, sizeof(struct ibvQ)));
	printf("Size of ibvQ-structur: %ld \n", sizeof(struct ibvQ));
	if(read(connfd, recv_buf, sizeof(struct ibvQ)) != sizeof(struct ibvQ)) {
		close(connfd);
		printf("15 - Could not read a remote queue! \n");
		printf("What was read: %s \n", recv_buf);
		goto end;
		return -1;
	} else {
		printf("Remote queue was read. \n");
	}

	struct ibvQ *remote_ibvQ;
	remote_ibvQ = (struct ibvQ*)malloc(sizeof(struct ibvQ));
	memcpy(remote_ibvQ, recv_buf, sizeof(struct ibvQ));

	// Build remote gid from the received IP-Address
	uint64_t remote_gid;
	remote_gid = 0x0000FFFF00000000 | (uint64_t)remote_ibvQ->ip_addr;
	// printf("ORed remote GID: %ld \n", remote_gid);
	uint32_t high_part = htonl((uint32_t)(remote_gid >> 32));
	uint32_t low_part = htonl((uint32_t) remote_gid & 0xFFFFFFFF);
	remote_gid = ((uint64_t)(low_part) << 32) | high_part;
	// printf("Transformed remote GID: %ld \n", remote_gid);

	// Printout of the received information 
	printf("Received Information \n");
	printf("Remote IP-Addr: %d \n", remote_ibvQ->ip_addr);
	printf("Remote QPN: %d \n", remote_ibvQ->qpn);
	printf("Remote PSN: %d \n", remote_ibvQ->psn);
	printf("Remote rkey: %d \n", remote_ibvQ->rkey);
	printf("Remote vaddr: %p \n", remote_ibvQ->vaddr);
	printf("Remote size: %d \n", remote_ibvQ->size);
	printf("Remote GID: %s \n", remote_ibvQ->gid);
	printf("Transformed Remote GID: %ld \n", remote_gid);

	// Setting up the local information of the ibvQ to send to the remote side 
	struct ibvQ *local_ibvQ; 
	local_ibvQ = (struct ibvQ*)malloc(sizeof(struct ibvQ));
	local_ibvQ->qpn = qp->qp_num;
	local_ibvQ->rkey = mr->rkey;
	local_ibvQ->vaddr = buf; 
	local_ibvQ->psn = remote_ibvQ->psn; 
	local_ibvQ->size = n_pages*hugePageSize;
	// local_ibvQ->ip_addr = 184371778 + (own_server_no-1)*4;
	local_ibvQ->ip_addr = ip_addr; 
	// local_ibvQ->ip_addr = 184371810;
	// local_ibvQ->ip_addr = 184371814;
	// local_ibvQ->ip_addr = 184371814; 
	sprintf(local_ibvQ->gid, "%08x%08x%08x%08x", local_ibvQ->ip_addr, local_ibvQ->ip_addr, local_ibvQ->ip_addr, local_ibvQ->ip_addr);
	// local_ibvQ->gid = 0; 

	// Printout of the received information 
	printf("Sent Information \n");
	printf("Local IP-Addr: %d \n", local_ibvQ->ip_addr);
	printf("Local QPN: %d \n", local_ibvQ->qpn);
	printf("Local PSN: %d \n", local_ibvQ->psn);
	printf("Local rkey: %d \n", local_ibvQ->rkey);
	printf("Local vaddr: %p \n", local_ibvQ->vaddr);
	printf("Local size: %d \n", local_ibvQ->size);
	printf("Local GID: %s \n", local_ibvQ->gid);

	// Send the local queue to the remote target
	if(write(connfd, local_ibvQ, sizeof(struct ibvQ)) != sizeof(struct ibvQ)) {
		close(connfd);
		printf("16 - Could not send my local Queue to the remote side! \n");
		goto end;
		return -1; 
	} else {
		printf("Local Queue was sent to the remote side. \n");
	}

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// CREATE THE CONNECTION BETWEEN THE QUEUES  
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Change queuepair to RTR (ready to receive)
	memset(&attr, 0, sizeof(attr));
	union ibv_gid ibv_gid_variable;
	for(int i = 0; i < 16; i++) {
		ibv_gid_variable.raw[i] = (uint8_t) 0;
	}
	ibv_gid_variable.global.subnet_prefix = (__be64)0;
	// ibv_gid_variable.global.interface_id = (__be64)7082751587679928320;
	ibv_gid_variable.global.interface_id = (__be64)remote_gid;
	attr.qp_state = IBV_QPS_RTR;
	attr.path_mtu = IBV_MTU_4096;
	attr.dest_qp_num = remote_ibvQ->qpn;
	// attr.rq_psn = 0; //remote_ibvQ->psn;
	attr.rq_psn = remote_ibvQ->psn;
	attr.max_dest_rd_atomic = 1;
	attr.min_rnr_timer = 12;
	attr.ah_attr.dlid = 0; 
	attr.ah_attr.sl = 0;
	attr.ah_attr.static_rate = 0; 
	attr.ah_attr.is_global = 1;
	attr.ah_attr.src_path_bits = 0;
	attr.ah_attr.port_num = 1;
	attr.ah_attr.grh.dgid = ibv_gid_variable;
	attr.ah_attr.grh.flow_label = 0;
	attr.ah_attr.grh.sgid_index = 3;
	attr.ah_attr.grh.hop_limit = 0xFF;
	attr.ah_attr.grh.traffic_class = 0; 

	/*attr.alt_ah_attr.dlid = 0; 
	attr.alt_ah_attr.sl = 0;
	attr.alt_ah_attr.static_rate = 0; 
	attr.alt_ah_attr.is_global = 1;
	attr.alt_ah_attr.src_path_bits = 0;
	attr.alt_ah_attr.port_num = 1;
	attr.alt_ah_attr.grh.dgid = ibv_gid_variable;
	attr.alt_ah_attr.grh.flow_label = 0;
	attr.alt_ah_attr.grh.sgid_index = 3;
	attr.alt_ah_attr.grh.hop_limit = 0xFF;
	attr.alt_ah_attr.grh.traffic_class = 0; 
	attr.alt_pkey_index = 0;
	attr.alt_port_num = 1;
	attr.alt_timeout = 22; */

	union ibv_gid gid; 
	int rc = ibv_query_gid(context, 1, 3, &gid);
	if(rc) {
		printf("Querying the gid didn't work! \n");
		goto end;
	} else {
		printf("GID-values: \n");
		printf(" - Subnet prefix: %lld \n", gid.global.subnet_prefix);
		printf(" - Interface ID: %lld \n", gid.global.interface_id);
	}

	// Printout of data sent to the remote side
	printf("IBV_QP_STATE: %d \n", attr.qp_state);
	printf("IBV_QP_PATH_MTU: %d \n", attr.path_mtu);
	printf("IBV_QP_DEST_QPN: %d \n", attr.dest_qp_num);
	printf("IBV_QP_RQ_PSN: %d \n", attr.rq_psn);
	printf("IBV_QP_MAX_DEST_RD_ATOMIC: %d \n", attr.max_dest_rd_atomic);
	printf("IBV_QP_MIN_RNR_TIMER: %d \n", attr.min_rnr_timer);
	printf("IBV AH ATTR: \n");
	printf(" - DLID: %d \n", attr.ah_attr.dlid);
	printf(" - Service Level: %d \n", attr.ah_attr.sl);
	printf(" - Static Rate: %d \n", attr.ah_attr.static_rate);
	printf(" - Is Global: %d \n", attr.ah_attr.is_global);
	printf(" - src_path_bits: %d \n", attr.ah_attr.src_path_bits);
	printf(" - port number: %d \n", attr.ah_attr.port_num);
	printf(" - Global Routing Header: \n");
	printf(" - - flow_label: %d \n", attr.ah_attr.grh.flow_label);
	printf(" - - sgid_index: %d \n", attr.ah_attr.grh.sgid_index);
	printf(" - - hop_limit: %d \n", attr.ah_attr.grh.hop_limit);
	printf(" - - traffic class: %d \n", attr.ah_attr.grh.traffic_class);
	printf(" - - Global ID: \n");
	printf(" - - - - Subnet Prefix: %lld \n", attr.ah_attr.grh.dgid.global.subnet_prefix);
	printf(" - - - - Interface ID: %lld \n", attr.ah_attr.grh.dgid.global.interface_id);

	errno = ibv_modify_qp(qp, &attr, IBV_QP_STATE | IBV_QP_AV | IBV_QP_PATH_MTU | IBV_QP_DEST_QPN | IBV_QP_RQ_PSN | IBV_QP_MAX_DEST_RD_ATOMIC | IBV_QP_MIN_RNR_TIMER);
	switch(errno) {
		case 0: printf("Set the Queue Pair to RTR. \n"); break;
		default: printf("17 - Returned error: %s!\n", strerror(errno)); 
		// goto end; 
	}

	// Change queuepair to RTS 
	memset(&attr, 0, sizeof(attr));
	attr.qp_state = IBV_QPS_RTS;
	attr.sq_psn = remote_ibvQ->psn;
	attr.timeout = 19; 
	attr.min_rnr_timer = 30; 
	attr.retry_cnt = 10; 
	attr.rnr_retry = 1;
	attr.max_rd_atomic = 1; 
	attr.path_mig_state = IBV_MIG_REARM;
	
	errno = ibv_modify_qp(qp, &attr, IBV_QP_STATE | IBV_QP_SQ_PSN | IBV_QP_TIMEOUT | IBV_QP_RETRY_CNT | IBV_QP_RNR_RETRY | IBV_QP_MAX_QP_RD_ATOMIC | IBV_QP_PATH_MIG_STATE | IBV_QP_MIN_RNR_TIMER);
	if(errno == 0) {
		printf("Set the Queue Pair to RTS. \n");
	} else {
		printf("18 - Returned error: %s!\n", strerror(errno));
		// goto end; 
	}

	// Fill the data as required for WRITE test
	// printf("\n"); 
	// printf("Memory Filling: \n");
	/*uint64_t *hMem = (uint64_t*)local_ibvQ->vaddr; 
	for(int i = 0; i < max_size/64; i++) {
		for(int j = 0; j < 8; j++) {
			// hMem[i*8+j] = i+j; 
			hMem[i*8+j] = 1;
			printf("- hMem[%d]: %d -", (i*8+j), (i+j));
		}
	}*/

	unsigned char *hMem = (unsigned char*) local_ibvQ->vaddr; 
	/*for(int i = 0; i<max_size/64; i++) {
		for(int j = 0; j < 64; j++) {
			hMem[i*64+j] = 'A';
		}
	}*/

	/*FILE *file_ptr; 
	file_ptr = fopen("ACK_test.txt", "rb"); 
	const size_t file_size = fread(hMem, sizeof(unsigned char), hugePageSize, file_ptr); 
	printf("File Size = %d bytes \n", file_size); 
	fclose(file_ptr); */ 

	hMem[0] = 0x48;
	hMem[1] = 0x65;
	hMem[2] = 0x6c;
	hMem[3] = 0x6c;
	hMem[4] = 0x6f;
	hMem[5] = 0x2c;
	hMem[6] = 0x20;
	hMem[7] = 0x41; 
	hMem[8] = 0x4D; 
	hMem[9] = 0x44; 
	hMem[10] = 0x20; 
	hMem[11] = 0x4F; 
	hMem[12] = 0x48; 
	hMem[13] = 0x43; 
	hMem[14] = 0x21;
	hMem[15] = 0x20;
	hMem[16] = 0x49;
	hMem[17] = 0x20;
	hMem[18] = 0x62;
	hMem[19] = 0x6c;
	hMem[20] = 0x6f;
	hMem[21] = 0x63;
	hMem[22] = 0x6b;
	hMem[23] = 0x20;
	hMem[24] = 0x6e;
	hMem[25] = 0x65;
	hMem[26] = 0x74;
	hMem[27] = 0x77;
	hMem[28] = 0x6f;
	hMem[29] = 0x72;
	hMem[30] = 0x6b;
	hMem[31] = 0x20;
	hMem[32] = 0x74;
	hMem[33] = 0x68;
	hMem[34] = 0x72;
	hMem[35] = 0x65;
	hMem[36] = 0x61;
	hMem[37] = 0x74;
	hMem[38] = 0x73;
	hMem[39] = 0x20;
	hMem[40] = 0x62;
	hMem[41] = 0x75;
	hMem[42] = 0x74;
	hMem[43] = 0x20;
	hMem[44] = 0x74;
	hMem[45] = 0x68;
	hMem[46] = 0x69;
	hMem[47] = 0x73;
	hMem[48] = 0x20;
	hMem[49] = 0x69;
	hMem[50] = 0x73;
	hMem[51] = 0x20;
	hMem[52] = 0x6e;
	hMem[53] = 0x6f;
	hMem[54] = 0x74;
	hMem[55] = 0x20;
	hMem[56] = 0x61;
	hMem[57] = 0x20;
	hMem[58] = 0x74;
	hMem[59] = 0x68;
	hMem[60] = 0x72;
	hMem[61] = 0x65;
	hMem[62] = 0x61;
	hMem[63] = 0x74;

	printf("Mem content: %s \n", hMem); 

	// Create Scatter-Gather-Element 
	struct ibv_sge sg; 
	memset(&sg, 0, sizeof(sg));
	sg.addr = (unsigned char*)hMem; 
	sg.length = 64; //local_ibvQ->size;
	sg.lkey = mr->lkey;

	// Create Work Request
	struct ibv_send_wr wr; 
	memset(&wr, 0, sizeof(wr));
	wr.wr_id = 0; 
	wr.sg_list = &sg; 
	wr.num_sge = 1;

	if(write_op) {
		wr.opcode = IBV_WR_RDMA_WRITE;
	} else {
		wr.opcode = IBV_WR_RDMA_READ; 
	}
	// wr.opcode = IBV_WR_RDMA_WRITE; 
	wr.send_flags = IBV_SEND_SIGNALED;
	wr.wr.rdma.remote_addr = (uintptr_t)remote_ibvQ->vaddr;
	wr.wr.rdma.rkey = remote_ibvQ->rkey; 

	// Create "Bad Work Request" for failed WRITE operations 
	struct ibv_send_wr *bad_wr; 

	// Sync-Up handshake with the remote side - WRITE
	/*uint32_t sync_ack = 0;
	if(write(connfd, &sync_ack, sizeof(uint32_t)) != sizeof(uint32_t)) {
		close(connfd);
		printf("18 - Could not send sync_ack! \n");
		goto end; 
		return -1;
	} else {
		printf("Send sync-ack successfully. \n");
	}

	// Sync-Up handshake with the remote side - READ 
	while(read(connfd, &sync_ack, sizeof(uint32_t)) != sizeof(uint32_t)) {
		usleep(1000);
	}
	if(sync_ack == 0) {
		printf("Received sync-ack successfully. \n");
	} else {
		printf("19 - Could not receive sync_ack! \n");
		goto end; 
		return -1;
	} */

	// Send out the data 
	struct ibv_wc wc;
	ibv_post_send(qp, &wr, &bad_wr); 
	
	// Poll for the incoming ACK 
	ibv_poll_cq(comp_queue, 1, &wc);

	// Check the status of the received WQE
	if(wc.status == IBV_WC_SUCCESS) {
		printf("Message was ACKed! \n");
	} else {
		printf("25 - Failed Status %s (%d) for wr_id %d! \n", ibv_wc_status_str(wc.status), wc.status, (int)wc.wr_id);
	}



	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// CLEAN-UP OF ELEMENTS 
	//
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	end:
	printf("\n");
	printf("\n");
	printf("############################################################################################# \n");
	printf("This is the end... \n");
	printf(" - Free the buffer now! \n");
	if(buf != NULL) {
		printf("Buffer is not a nullpointer! \n");
		free((void*)*buf);
	} else {
		printf("Couldn't free the buffer! \n");
	}
	printf(" - Destroy the queue pair! \n");
	ibv_destroy_qp(qp);
	printf(" - Destroy the completion queue! \n");
	ibv_destroy_cq(comp_queue);
	printf(" - Destroy the completion channel! \n");
	ibv_destroy_comp_channel(comp_channel);
	printf(" - Dereg the memory region! \n");
	ibv_dereg_mr(mr);
	printf(" - Deallocate the Protection Domain! \n");
	ibv_dealloc_pd(pd);
	printf(" - Close the device! \n");
	ibv_close_device(context);
	printf(" - Close the socket! \n");
	printf("\n");
	close(connfd);

	return 0;
}
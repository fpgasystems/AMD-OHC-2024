#include "cService.hpp"

namespace fpga {

cService* cService::cservice = nullptr;

// ======-------------------------------------------------------------------------------
// Ctor, dtor
// ======-------------------------------------------------------------------------------

/**
 * @brief Constructor
 * 
 * @param vfid - Id of the targeted vFPGA
 * @param priority - priority-based scheduling enabled 
 * @param reorder - reordering in scheduling enabled 
 */
cService::cService(int32_t vfid, bool priority, bool reorder) 
    : vfid(vfid), cSched(vfid, priority, reorder) 
{
    // ID - create service- and socket-IDs as strings based on the vfids. 
    service_id = ("coyote-daemon-vfid-" + std::to_string(vfid)).c_str();
    socket_name = ("/tmp/coyote-daemon-vfid-" + std::to_string(vfid)).c_str();
}

// ======-------------------------------------------------------------------------------
// Sig handler
// ======-------------------------------------------------------------------------------

/**
 * @brief Signal handler - Wrapper with official name 
 * 
 * @param signum : Kill signal
 */
void cService::sig_handler(int signum)
{   
    cservice->my_handler(signum);
}

/**
 * @brief Actual signal handler to deal with an incoming SIGTERM signal. 
 * 
 * @param signum - Kill signal 
*/
void cService::my_handler(int signum) 
{
    // Only handle the incoming SIGTERM, all other signals leave unhandled again
    if(signum == SIGTERM) {
        // Store notice that KILL was sent to the process identified by pid
        syslog(LOG_NOTICE, "SIGTERM sent to %d\n", (int)pid);//cService::getPid());
        // Remove socket name from the file system 
        unlink(socket_name.c_str());

        run_req = false;
        run_rsp = false;
        
        // Make sure to finish the two threads 
        thread_req.join();
        thread_rsp.join();

        // Send kill-message to the process identified by pid
        kill(pid, SIGTERM);

        // Log everything and turn off 
        syslog(LOG_NOTICE, "Exiting");
        closelog();
        exit(EXIT_SUCCESS);
    } else {
        syslog(LOG_NOTICE, "Signal %d not handled", signum);
    }
}

// ======-------------------------------------------------------------------------------
// Init
// ======-------------------------------------------------------------------------------

/**
 * @brief Initialize the daemon service (a.k.a. cService), create child processes and set permission rights 
 * 
 */
void cService::daemon_init()
{
    // Fork
    DBG3("Forking...");

    // Create a new child process and store its pid 
    pid = fork();
    if(pid < 0 ) 
        exit(EXIT_FAILURE);
    if(pid > 0 ) 
        exit(EXIT_SUCCESS);

    // Sid - create a session and check if it worked out as expected
    if(setsid() < 0) 
        exit(EXIT_FAILURE);

    // Signal handler

    // For SIGTERM, point to the own sig_handler here in cService
    signal(SIGTERM, cService::sig_handler);
    // Ignore both SIGCHILD and SIGHUP
    signal(SIGCHLD, SIG_IGN);
    signal(SIGHUP, SIG_IGN);

    // Fork - Create another child process and check if that worked out as expected 
    pid = fork();
    if(pid < 0 ) 
        exit(EXIT_FAILURE);
    if(pid > 0 ) 
        exit(EXIT_SUCCESS);

    // Permissions - everything is allowed for all processes (original and forked children)
    umask(0);

    // Cd - change to home directory 
    if((chdir("/")) < 0) {
        exit(EXIT_FAILURE);
    }

    // Syslog - Log that the service was successfully started 
    openlog(service_id.c_str(), LOG_NOWAIT | LOG_PID, LOG_USER);
    syslog(LOG_NOTICE, "Successfully started %s", service_id.c_str());

    // Close fd - close filedescriptors for standard in, standard out and standard error 
    close(STDIN_FILENO);
    close(STDOUT_FILENO);
    close(STDERR_FILENO);
}

/**
 * @brief Initialize listening socket for UNIX filesystem communication (local interprocess communication)
 * 
 */
void cService::socket_init() 
{
    syslog(LOG_NOTICE, "Socket initialization");

    sockfd = -1;
    struct sockaddr_un server;
    socklen_t len;

    // Create the socket for AF_UNIX communication and check for success 
    if((sockfd = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
        syslog(LOG_ERR, "Error creating a server socket");
        exit(EXIT_FAILURE);
    }

    // Set server: AF_UNIX, copy path from socket_name
    server.sun_family = AF_UNIX;
    strcpy(server.sun_path, socket_name.c_str());
    // Unlink the server so that it gets deleted when it's not used anymore 
    unlink(server.sun_path);
    len = strlen(server.sun_path) + sizeof(server.sun_family);
    
    // Bind the socket and check for success of that operation 
    if(bind(sockfd, (struct sockaddr *)&server, len) == -1) {
        syslog(LOG_ERR, "Error bind()");
        exit(EXIT_FAILURE);
    }

    if(listen(sockfd, maxNumClients) == -1) {
        syslog(LOG_ERR, "Error listen()");
        exit(EXIT_FAILURE);
    }
}

/**
 * @brief Accept connections via the socket for interprocess communication 
 * 
 */
void cService::accept_connection()
{
    // Variables for storing incoming client connection 
    sockaddr_un client;
    socklen_t len = sizeof(client); 

    // File Descriptor for the connection 
    int connfd;
    char recv_buf[recvBuffSize];
    int n;

    // Try to accept an incoming connection 
    if((connfd = accept(sockfd, (struct sockaddr *)&client, &len)) == -1) {
        syslog(LOG_NOTICE, "No new connections");
    } else {
        syslog(LOG_NOTICE, "Connection accepted, connfd: %d", connfd);

        pid_t rpid = 0;
        if(n = read(connfd, recv_buf, sizeof(pid_t)) == sizeof(pid_t)) {
            memcpy(&rpid, recv_buf, sizeof(pid_t));
            syslog(LOG_NOTICE, "Registered pid: %d", rpid);
        } else {
            syslog(LOG_ERR, "Registration failed, connfd: %d, received: %d", connfd, n);
        }

        mtx_cli.lock();
        
        if(clients.find(connfd) == clients.end()) {
            clients.insert({connfd, std::make_unique<cThread>(vfid, rpid, this)});
            syslog(LOG_NOTICE, "Connection thread created");
        }

        mtx_cli.unlock();
    }

    nanosleep((const struct timespec[]){{0, sleepIntervalDaemon}}, NULL);
}

// ======-------------------------------------------------------------------------------
// Tasks
// ======-------------------------------------------------------------------------------
void cService::addTask(int32_t oid, std::function<int32_t(cProcess*, std::vector<uint64_t>)> task) {
    if(task_map.find(oid) == task_map.end()) {
        task_map.insert({oid, task});
    }
}

void cService::removeTask(int32_t oid) {
    if(bstreams.find(oid) != bstreams.end()) {
		bstreams.erase(oid);
    }
}

// ======-------------------------------------------------------------------------------
// Threads
// ======-------------------------------------------------------------------------------

void cService::process_requests() {
    char recv_buf[recvBuffSize];
    memset(recv_buf, 0, recvBuffSize);
    uint8_t ack_msg;
    int32_t msg_size;
    int32_t request[2], opcode, tid;
    int n;
    run_req = true;

    syslog(LOG_NOTICE, "Starting thread");

    while(run_req) {
        for (auto & el : clients) {
            mtx_cli.lock();
            int connfd = el.first;

            if(read(connfd, recv_buf, 2 * sizeof(int32_t)) == 2 * sizeof(int32_t)) {
                memcpy(&request, recv_buf, 2 * sizeof(int32_t));
                tid = request[0];
                opcode = request[1];
                syslog(LOG_NOTICE, "Client: %d, tid %d, opcode: %d", el.first, tid, opcode);

                switch (opcode) {

                // Close connection
                case defOpClose:
                    syslog(LOG_NOTICE, "Received close connection request, connfd: %d", connfd);
                    close(connfd);
                    clients.erase(el.first);
                    break;

                // Schedule the task
                default:
                    // Check bitstreams
                    if(isReconfigurable()) {
                        if(!checkBitstream(opcode))
                            syslog(LOG_ERR, "Opcode invalid, connfd: %d, received: %d", connfd, n);
                    }

                    // Check task map
                    if(task_map.find(opcode) == task_map.end())
                       syslog(LOG_ERR, "Opcode invalid, connfd: %d, received: %d", connfd, n);

                    auto taskIter = task_map.find(opcode);
         
                    
                    // Read the payload size
                    if(n = read(connfd, recv_buf, sizeof(int32_t)) == sizeof(int32_t)) {
                        memcpy(&msg_size, recv_buf, sizeof(int32_t));

                        // Read the payload
                        if(n = read(connfd, recv_buf, msg_size) == msg_size) {
                            std::vector<uint64_t> msg(msg_size / sizeof(uint64_t)); 
                            memcpy(msg.data(), recv_buf, msg_size);

                            syslog(LOG_NOTICE, "Received new request, connfd: %d, msg size: %d",
                                el.first, msg_size);

                            // Schedule
                            el.second->scheduleTask(std::unique_ptr<bTask>(new cTask(tid, opcode, 1, taskIter->second, msg)));
                            syslog(LOG_NOTICE, "Task scheduled, client %d, opcode %d", el.first, opcode);
                        } else {
                            syslog(LOG_ERR, "Request invalid, connfd: %d, received: %d", connfd, n);
                        }

                    } else {
                        syslog(LOG_ERR, "Payload size not read, connfd: %d, received: %d", connfd, n);
                    }
                    break;

                }
            }

            mtx_cli.unlock();
        }

        nanosleep((const struct timespec[]){{0, sleepIntervalRequests}}, NULL);
    }
}

void cService::process_responses() {
    int n;
    int ack_msg;
    run_rsp = true;
    cmplEv cmpl_ev;
    int32_t cmpl[2];
    
    while(run_rsp) {

        for (auto & el : clients) {
            cmpl_ev = el.second->getCompletedNext();
            cmpl[0] = std::get<0>(cmpl_ev);
            cmpl[1] = std::get<1>(cmpl_ev);
            if(cmpl[0] != -1) {
                syslog(LOG_NOTICE, "Running here...");
                int connfd = el.first;

                if(write(connfd, &cmpl, 2 * sizeof(int32_t)) == 2 * sizeof(int32_t)) {
                    syslog(LOG_NOTICE, "Sent completion, connfd: %d, tid: %d, code: %d", connfd, cmpl[0], cmpl[1]);
                } else {
                    syslog(LOG_ERR, "Completion could not be sent, connfd: %d", connfd);
                }
            }
        }

        nanosleep((const struct timespec[]){{0, sleepIntervalCompletion}}, NULL);
    }
}

/**
 * @brief Main run service
 * 
 */
void cService::run() {
    // Init daemon
    daemon_init();

    // Run scheduler
    if(isReconfigurable()) run_sched();

    // Init socket
    socket_init();
    
    // Init threads
    syslog(LOG_NOTICE, "Thread initialization");

    thread_req = std::thread(&cService::process_requests, this);
    thread_rsp = std::thread(&cService::process_responses, this);

    // Main
    while(1) {
        accept_connection();
    }
}

}
#include <dirent.h>
#include <iterator>
#include <cstdlib>
#include <cstring>
#include <sstream>
#include <iostream>
#include <stdlib.h>
#include <string>
#include <sys/stat.h>
#include <syslog.h>
#include <unistd.h>
#include <vector>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <iomanip>
#include <chrono>
#include <thread>
#include <limits>
#include <assert.h>
#include <stdio.h>
#include <sys/un.h>
#include <errno.h>
#include <wait.h>
#include <vector>
#include <unordered_map>
#include <mutex>
#include <condition_variable>
#include <any>

#include "cSched.hpp"
#include "cThread.hpp"

using namespace std;

namespace fpga {

/**
 * @brief Coyote service
 * 
 * Coyote daemon, provides background scheduling service.
 * 
 */
class cService : public cSched {
private: 
    // Singleton - guarantee that exactly one cService exists for one vFPGA
    static cService *cservice;

    // Forks - Process ID
    pid_t pid;

    // ID - vFID to identify the vFPGA, service_id to identify the service itself
    int32_t vfid = { -1 };
    string service_id;

    // Threads for request and response: Both actual threads and booleans to store interaction with them
    bool run_req = { false };
    thread thread_req;
    bool run_rsp = { false };
    thread thread_rsp;

    // Connection - Sockets. Socket name, file descriptor and current ID. 
    string socket_name;
    int sockfd;
    int curr_id = { 0 };

    // Clients - map of clients (which are cThreads via cProcesses) and a mutex to make their accesses safe
    mutex mtx_cli;
    unordered_map<int, std::unique_ptr<cThread>> clients;

    // Task map - holds functions that return int32 and take a cProcess and a vector as input
    unordered_map<int, std::function<int32_t(cProcess*, std::vector<uint64_t>)>> task_map;

    // Constructor of the class - takes vfid, priority and reorder 
    cService(int32_t vfid, bool priority = true, bool reorder = true);

    // Actually starts the daemon / cService
    void daemon_init();

    // Inits the socket for networking connections 
    void socket_init();

    // Accepts incoming connections via the socket 
    void accept_connection();

    // Signal handlers - sig_handler is just the conformal wrapper for my_handler
    static void sig_handler(int signum);
    void my_handler(int signum);

    // Functions to request and close processes / threads. 
    void process_requests();
    void process_responses();

public:

    /**
     * @brief Creates a service for a single vFPGA
     * 
     * @param vfid - vVFPGA id
     * @param f_req - Process requests
     * @param f_rsp - Process responses
     */

    static cService* getInstance(int32_t vfid, bool priority = true, bool reorder = true) {
        if(cservice == nullptr) 
            cservice = new cService(vfid, priority, reorder);
        return cservice;
    }

    /**
     * @brief Run service
     * 
     * @param f_req - process requests lambda
     * @param f_rsp - process responses lambda
     */
    void run();

    /**
     * @brief Add an arbitrary user task
     * 
     */
    void addTask(int32_t oid, std::function<int32_t(cProcess*, std::vector<uint64_t>)> task);
    
    // Remove Task from the service, identified by oid
    void removeTask(int32_t oid);

};


}       
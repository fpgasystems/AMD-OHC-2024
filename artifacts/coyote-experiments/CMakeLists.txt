cmake_minimum_required(VERSION 3.0)
project(test)

set(CYT_DIR ${CMAKE_SOURCE_DIR})
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CYT_DIR}/cmake)

find_package(CoyoteHW REQUIRED)

#
# Static
#

if(EXAMPLE STREQUAL "hloglog_dyn")
    message("** Hyperloglog example")
    set(EN_PR 1)
    set(N_REGIONS 3)
    set(N_CONFIGS 1)
    set(COMP_CORES 6)

    load_apps(
        VFPGA_C0_0 "examples/hyperloglog"
        VFPGA_C0_1 "examples/hyperloglog"
        VFPGA_C0_2 "examples/hyperloglog"
    )
endif()

if(EXAMPLE STREQUAL "aes") 
    message("** AES, 4 regions, example")
 	set(FDEV_NAME "u55c")
	set(N_REGIONS 4)
    set(EN_WB 1)
	set(EN_PR 1)
	set(N_CONFIGS 1)
	set(EN_MEM 0)
	set(EN_STRM 1)
	set(COMP_CORES 8)

    load_apps(
        VFPGA_C0_0 "examples/aes_cntr"
        VFPGA_C0_1 "examples/aes_cntr"
        VFPGA_C0_2 "examples/aes_cntr"
        VFPGA_C0_3 "examples/aes_cntr"
    )
endif()

if(EXAMPLE STREQUAL "rdma") 
    message("** RDMA, example")
 	set(FDEV_NAME "u55c")
	set(N_REGIONS 1)
	set(EN_PR 0)
    set(EN_WB 1)
	set(N_CONFIGS 1)
	set(EN_MEM 1)
	set(EN_STRM 1)
    set(EN_RDMA 1)
    set(N_RDMA_AXI 2)
    set(N_CARD_AXI 4)
	set(COMP_CORES 8)
endif()

if(EXAMPLE STREQUAL "static")
    set(FDEV_NAME "u250")
    set(BUILD_STATIC 1)
    set(BUILD_SHELL 0)
    set(COMP_CORES 8)
    set(N_REGIONS 3)

    load_apps(
        VFPGA_C0_0 "examples/perf_host"
        VFPGA_C0_1 "examples/perf_host"
        VFPGA_C0_2 "examples/perf_host"
    )
endif()

#
# Create build targets
#

create_hw() 

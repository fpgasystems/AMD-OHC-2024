# Shell ctrl layer
proc cr_bd_design_ctrl { parentCell } {
  upvar #0 cfg cnfg

  # CHANGE DESIGN NAME HERE
  set design_name design_ctrl

  common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

########################################################################################################
########################################################################################################
# SHELL CTRL
########################################################################################################
########################################################################################################

########################################################################################################
# Create interface ports
########################################################################################################
  
  # Shell config
  set axi_cnfg [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 axi_cnfg ]
  set_property -dict [ list \
    CONFIG.ADDR_WIDTH {64} \
    CONFIG.DATA_WIDTH {64} \
    CONFIG.PROTOCOL {AXI4LITE} \
  ] $axi_cnfg

  set axi_ctrl_main [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 axi_ctrl_main ]
  set_property -dict [list \
    CONFIG.MAX_BURST_LENGTH {16} \
    CONFIG.ID_WIDTH {6} \
    CONFIG.NUM_WRITE_OUTSTANDING {8} \
    CONFIG.NUM_READ_OUTSTANDING {8} \
    CONFIG.SUPPORTS_NARROW_BURST {0} \
    CONFIG.ADDR_WIDTH {64} \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.DATA_WIDTH {512} \
    CONFIG.NUM_READ_THREADS {2} \
    CONFIG.NUM_WRITE_THREADS {2} \
  ] $axi_ctrl_main

  # Dynamic control
  for {set i 0}  {$i < $cnfg(n_reg)} {incr i} {    
    set cmd "set axi_ctrl_$i \[ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 axi_ctrl_$i ]
            set_property -dict \[ list \
            CONFIG.ADDR_WIDTH {64} \
            CONFIG.DATA_WIDTH {64} \
            CONFIG.PROTOCOL {AXI4LITE} \
            ] \$axi_ctrl_$i"
    eval $cmd
  }

  # AVX control
  if {$cnfg(en_avx) eq 1} {
    for {set i 0}  {$i < $cnfg(n_reg)} {incr i} {    
      set cmd "set axim_ctrl_$i \[ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 axim_ctrl_$i ]
              set_property -dict \[ list \
                CONFIG.ADDR_WIDTH {64} \
                CONFIG.DATA_WIDTH {256} \
                CONFIG.HAS_BRESP {1} \
                CONFIG.HAS_BURST {1} \
                CONFIG.HAS_CACHE {1} \
                CONFIG.HAS_LOCK {1} \
                CONFIG.HAS_PROT {1} \
                CONFIG.HAS_QOS {0} \
                CONFIG.HAS_REGION {0} \
                CONFIG.HAS_RRESP {1} \
                CONFIG.HAS_WSTRB {1} \
                CONFIG.NUM_READ_OUTSTANDING {8} \
                CONFIG.NUM_WRITE_OUTSTANDING {8} \
                CONFIG.PROTOCOL {AXI4} \
                CONFIG.READ_WRITE_MODE {READ_WRITE} \
              ] \$axim_ctrl_$i"
      eval $cmd
    }
  }


########################################################################################################
# Create ports
########################################################################################################
  
  # Main system reset
  set aresetn [ create_bd_port -dir I -type rst aresetn ]

  # Main system clock
  set cmd "set aclk \[ create_bd_port -dir I -type clk aclk ]
            set_property -dict \[ list \
            CONFIG.FREQ_HZ $cnfg(aclk_f)000000 \
            CONFIG.ASSOCIATED_BUSIF {axi_cnfg"
            for {set i 0}  {$i < $cnfg(n_reg)} {incr i} {
                append cmd ":axi_ctrl_$i"
            }
            append cmd "} \
              CONFIG.ASSOCIATED_RESET {aresetn} \
  ] \$aclk"
  eval $cmd

########################################################################################################
# Create interconnect and components
########################################################################################################
  
     # Create instance: axi_interconnect_0, and set properties
  if {$cnfg(en_avx) eq 1} {
    set ic0_mi [expr {2*$cnfg(n_reg) + 1}]
  } else {
    set ic0_mi [expr {$cnfg(n_reg) + 1}]
  }

  set cmd "set axi_interconnect_0 \[ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
          set_property -dict \[ list \
          CONFIG.S00_HAS_REGSLICE {4} \
          CONFIG.NUM_MI {$ic0_mi} \
          CONFIG.S00_HAS_DATA_FIFO {2} \
          CONFIG.STRATEGY {2} \ "
  if {$cnfg(en_avx) eq 1} {
    for {set i 0} {$i <= 2 * $cnfg(n_reg)} {incr i} {
      append cmd [format " CONFIG.M%02d_HAS_REGSLICE {4}"  $i]
    }
  } else {
    for {set i 0} {$i <= $cnfg(n_reg)} {incr i} {
      append cmd [format " CONFIG.M%02d_HAS_REGSLICE {4}"  $i]
    }
  }
  append cmd "] \$axi_interconnect_0"
  eval $cmd

########################################################################################################
# Create interface connections
########################################################################################################
  
  #
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_ports axi_cnfg] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_S00_AXI [get_bd_intf_ports axi_ctrl_main] [get_bd_intf_pins axi_interconnect_0/S00_AXI]

  # Dynamic control
  if {$cnfg(en_avx) eq 1} {
    for {set i 0}  {$i < $cnfg(n_reg)} {incr i} { 
      set j [expr {$i*2 + 1}]
      set cmd [format "connect_bd_intf_net -intf_net axi_interconnect_0_M%02d_AXI \[get_bd_intf_ports axi_ctrl_%d] \[get_bd_intf_pins axi_interconnect_0/M%02d_AXI]" $j $i $j]
      eval $cmd 
      set j [expr {$i*2 + 2}]
      set cmd [format "connect_bd_intf_net -intf_net axi_interconnect_0_M%02d_AXI \[get_bd_intf_ports axim_ctrl_%d] \[get_bd_intf_pins axi_interconnect_0/M%02d_AXI]" $j $i $j]
      eval $cmd 
    }
  } else {
    for {set i 0}  {$i < $cnfg(n_reg)} {incr i} { 
      set j [expr {$i + 1}]
      set cmd [format "connect_bd_intf_net -intf_net axi_interconnect_0_M%02d_AXI \[get_bd_intf_ports axi_ctrl_%d] \[get_bd_intf_pins axi_interconnect_0/M%02d_AXI]" $j $i $j]
      eval $cmd 
    }
  }

########################################################################################################
# Create port connections
########################################################################################################

  set cmd_clk "connect_bd_net \[get_bd_ports aclk] \[get_bd_pins axi_interconnect_0/ACLK] \[get_bd_pins axi_interconnect_0/S00_ACLK] \[get_bd_pins axi_interconnect_0/M00_ACLK] "
  set cmd_rst "connect_bd_net \[get_bd_ports aresetn] \[get_bd_pins axi_interconnect_0/ARESETN] \[get_bd_pins axi_interconnect_0/S00_ARESETN] \[get_bd_pins axi_interconnect_0/M00_ARESETN] "

  if {$cnfg(en_avx) eq 1} { 
    for {set i 1}  {$i <= 2 * $cnfg(n_reg)} {incr i} {
      append cmd_clk [format " \[get_bd_pins axi_interconnect_0/M%02d_ACLK]" $i]
      append cmd_rst [format " \[get_bd_pins axi_interconnect_0/M%02d_ARESETN]" $i]
    }
  } else {
    for {set i 1}  {$i <= $cnfg(n_reg)} {incr i} {
      append cmd_clk [format " \[get_bd_pins axi_interconnect_0/M%02d_ACLK]" $i]
      append cmd_rst [format " \[get_bd_pins axi_interconnect_0/M%02d_ARESETN]" $i]
    }
  }

  eval $cmd_clk
  eval $cmd_rst
 

########################################################################################################
# Create address segments
########################################################################################################
  
  # Static config
  create_bd_addr_seg -range 0x00008000 -offset 0x00000000 [get_bd_addr_spaces /axi_ctrl_main] [get_bd_addr_segs axi_cnfg/Reg] SEG_axi_cnfg_Reg

  if {$cnfg(en_avx) eq 1} { 
    for {set i 0}  {$i < $cnfg(n_reg)} {incr i} {
      set cmd [format "create_bd_addr_seg -range 0x00040000 -offset 0x000%02x0000 \[get_bd_addr_spaces /axi_ctrl_main] \[get_bd_addr_segs axi_ctrl_$i/Reg] SEG_axi_ctrl_$i\_Reg" [expr {0x10 + $i *4}]]
      eval $cmd
      set cmd [format "create_bd_addr_seg -range 0x00040000 -offset 0x00%03x0000 \[get_bd_addr_spaces /axi_ctrl_main] \[get_bd_addr_segs axim_ctrl_$i/Reg] SEG_axim_ctrl_$i\_Reg" [expr {0x100 + $i *4}]]
      eval $cmd
    }
  } else {
    for {set i 0}  {$i < $cnfg(n_reg)} {incr i} {
      set cmd [format "create_bd_addr_seg -range 0x00040000 -offset 0x000%02x0000 \[get_bd_addr_spaces /axi_ctrl_main] \[get_bd_addr_segs axi_ctrl_$i/Reg] SEG_axi_ctrl_$i\_Reg" [expr {0x10 + $i *4}]]
      eval $cmd
    }
  }

  save_bd_design
  close_bd_design $design_name 

  return 0
}
# End of cr_bd_design_ctrl()
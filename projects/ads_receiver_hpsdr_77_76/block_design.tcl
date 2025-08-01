# Create ports
create_bd_port -dir I lclk_p_0 
create_bd_port -dir I lclk_n_0
create_bd_port -dir I aclk_p_0
create_bd_port -dir I aclk_n_0
create_bd_port -dir I -from 0 -to 0 din_a_p_0
create_bd_port -dir I -from 0 -to 0 din_a_n_0
create_bd_port -dir I -from 0 -to 0 din_b_p_0
create_bd_port -dir I -from 0 -to 0 din_b_n_0

create_bd_port -dir O adc_spi_sclk
create_bd_port -dir O adc_spi_sdio
create_bd_port -dir O adc_spi_cs
create_bd_port -dir O adc_reset

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

# Create clk_wiz
cell xilinx.com:ip:clk_wiz:6.0 mmcm_0 {
    PRIMITIVE MMCM
    NUM_OUT_CLKS 3
    PRIM_IN_FREQ 272.16
    PRIM_SOURCE Differential_clock_capable_pin
    USE_RESET false
    CLKOUT1_DRIVES BUFG
    CLKOUT1_JITTER 109.769
    CLKOUT1_PHASE_ERROR 81.996
    CLKOUT1_REQUESTED_OUT_FREQ 77.76
    CLKOUT1_REQUESTED_PHASE 180
    CLKOUT1_USED true
    CLKOUT2_DRIVES BUFG
    CLKOUT2_JITTER 85.845
    CLKOUT2_PHASE_ERROR 81.996
    CLKOUT2_REQUESTED_OUT_FREQ 272.16
    CLKOUT2_REQUESTED_PHASE 180.000
    CLKOUT2_USED true
    CLKOUT3_DRIVES BUFG
    CLKOUT3_JITTER 126.149
    CLKOUT3_PHASE_ERROR 81.996
    CLKOUT3_REQUESTED_OUT_FREQ 38.88
    CLKOUT3_REQUESTED_PHASE 90.000
    CLKOUT3_USED true
    FEEDBACK_SOURCE FDBK_AUTO
} {
  clk_in1_p lclk_p_0
  clk_in1_n lclk_n_0
  locked led_o
}

# Create processing_system7
cell xilinx.com:ip:processing_system7 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/qmtech_xc7z020.xml
  PCW_USE_M_AXI_GP1 1
  PCW_FPGA0_PERIPHERAL_FREQMHZ 200
  PCW_CLK0_FREQ 200000000
  PCW_FPGA_FCLK0_ENABLE 1
} {
  M_AXI_GP0_ACLK mmcm_0/clk_out1
  M_AXI_GP1_ACLK mmcm_0/clk_out1
  SPI0_SCLK_O adc_spi_sclk
  SPI0_MOSI_O adc_spi_sdio
  SPI0_SS_I const_0/dout
  SPI0_SS_O adc_spi_cs
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 64 DIN_FROM 0 DIN_TO 0
} {
  din ps_0/GPIO_O
  dout adc_reset
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in const_0/dout
  dcm_locked mmcm_0/locked
  slowest_sync_clk mmcm_0/clk_out3
}

# ADC
cell hnch:user:axis_ads5294_twolane_doubleword axis_ads5294_twolane_0 {
} {
  frame_clock_p aclk_p_0
  frame_clock_n aclk_n_0
  sample_clk mmcm_0/clk_out1
  bit_clock mmcm_0/clk_out2
  half_clk mmcm_0/clk_out3
  din_a_p din_a_p_0
  din_a_n din_a_n_0
  din_b_p din_b_p_0
  din_b_n din_b_n_0
  serdes_rst rst_0/peripheral_reset
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 64 DIN_FROM 1 DIN_TO 1
} {
  din ps_0/GPIO_O
  dout axis_ads5294_twolane_0/bit_slip
}

# idelay_ctrl
cell xilinx.com:ip:util_idelay_ctrl util_idelay_ctrl_0 {
} {
  ref_clk ps_0/FCLK_CLK0
  rst rst_0/peripheral_reset
}

# sign extension
cell hnch:user:sign_extend sign_extend_0 {
} {
  data_in axis_ads5294_twolane_0/data_out
}

# RX 0

module rx_0 {
  source projects/ads_receiver_hpsdr_77_76/rx.tcl
} {
  hub_0/S_AXI ps_0/M_AXI_GP0
}

# RX 1

module rx_1 {
  source projects/ads_receiver_hpsdr_77_76/rx.tcl
} {
  hub_0/S_AXI ps_0/M_AXI_GP1
}


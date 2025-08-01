set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets system_i/mmcm_0/inst/clk_in1_system_mmcm_0_0]

create_clock -period 3.6743 -name bit_clk -add [get_ports lclk_p_0]
create_clock -period 12.860 -name sample_clk -waveform {0.000 6.430} -add [get_ports aclk_p_0]

# clock

set_property IOSTANDARD LVDS_25 [get_ports lclk_p_0]
set_property IOSTANDARD LVDS_25 [get_ports lclk_n_0]

set_property DIFF_TERM TRUE [get_ports lclk_p_0]
set_property DIFF_TERM TRUE [get_ports lclk_n_0]

set_property PACKAGE_PIN Y20 [get_ports lclk_p_0]
set_property PACKAGE_PIN Y21 [get_ports lclk_n_0]

# clock

set_property IOSTANDARD LVDS_25 [get_ports aclk_p_0]
set_property IOSTANDARD LVDS_25 [get_ports aclk_n_0]

set_property DIFF_TERM TRUE [get_ports aclk_p_0]
set_property DIFF_TERM TRUE [get_ports aclk_n_0]

set_property PACKAGE_PIN AA21 [get_ports aclk_p_0]
set_property PACKAGE_PIN AB21 [get_ports aclk_n_0]

# data

set_property IOSTANDARD LVDS_25 [get_ports {din_a_p_0[*]}]
set_property IOSTANDARD LVDS_25 [get_ports {din_a_n_0[*]}]

set_property DIFF_TERM true [get_ports {din_a_p_0[*]}]
set_property DIFF_TERM true [get_ports {din_a_n_0[*]}]

#set_property PACKAGE_PIN T21 [get_ports {din_a_p_0[0]}]
#set_property PACKAGE_PIN U21 [get_ports {din_a_n_0[0]}]
set_property PACKAGE_PIN W20 [get_ports {din_a_p_0[0]}]
set_property PACKAGE_PIN W21 [get_ports {din_a_n_0[0]}]

set_property IOSTANDARD LVDS_25 [get_ports {din_b_p_0[*]}]
set_property IOSTANDARD LVDS_25 [get_ports {din_b_n_0[*]}]

set_property DIFF_TERM true [get_ports {din_b_p_0[*]}]
set_property DIFF_TERM true [get_ports {din_b_n_0[*]}]

#set_property PACKAGE_PIN V22 [get_ports {din_b_p_0[0]}]
#set_property PACKAGE_PIN W22 [get_ports {din_b_n_0[0]}]
set_property PACKAGE_PIN T22 [get_ports {din_b_p_0[0]}]
set_property PACKAGE_PIN U22 [get_ports {din_b_n_0[0]}]


# SPI

set_property IOSTANDARD LVCMOS25 [get_ports adc_spi_*]

set_property PACKAGE_PIN Y14 [get_ports adc_spi_sclk]
set_property PACKAGE_PIN U15 [get_ports adc_spi_sdio]
set_property PACKAGE_PIN U16 [get_ports adc_spi_cs]

# output enable

set_property IOSTANDARD LVCMOS25 [get_ports {adc_reset}]
set_property PACKAGE_PIN U20 [get_ports {adc_reset}]



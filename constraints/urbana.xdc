# RealDigital Urbana board (Spartan-7 XC7S50-CSGA324-1)

# 100 MHz system oscillator
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports CLK_100MHZ]

# Active-high push-button reset
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS25} [get_ports reset]

# HDMI TMDS clock pair
set_property -dict {PACKAGE_PIN V17 IOSTANDARD TMDS_33} [get_ports hdmi_tmds_clk_n]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD TMDS_33} [get_ports hdmi_tmds_clk_p]

# HDMI TMDS data pairs
set_property -dict {PACKAGE_PIN U18 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_n[0]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_n[1]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_n[2]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_p[0]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_p[1]}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD TMDS_33} [get_ports {hdmi_tmds_data_p[2]}]

# Configuration voltage for Bank 0
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.Config.SPI_buswidth 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

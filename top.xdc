# Clocks
set_property -dict {PACKAGE_PIN H13 IOSTANDARD LVCMOS33} [get_ports clk_i]
create_clock -period 50.000 [get_ports clk_i]


# MCU SPI
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports sclk_i]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports sdi_i]
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports sdo_o]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports csn_i]

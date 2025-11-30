# basys3_template.xdc
# Map your board pins here. Adjust names for your Basys3 rev.

set_property PACKAGE_PIN W5 [get_ports clk100]
set_property IOSTANDARD LVCMOS33 [get_ports clk100]

# Buttons
set_property PACKAGE_PIN V17 [get_ports {btn0}] # BTN0
set_property IOSTANDARD LVCMOS33 [get_ports {btn0}]
set_property PACKAGE_PIN W13 [get_ports {btn1}] # BTN1
set_property IOSTANDARD LVCMOS33 [get_ports {btn1}]
set_property PACKAGE_PIN U18 [get_ports {btn2}] # BTN2
set_property IOSTANDARD LVCMOS33 [get_ports {btn2}]

# 7-seg segments (a-g)
set_property PACKAGE_PIN U16 [get_ports {seg[0]}] # a
set_property PACKAGE_PIN E19 [get_ports {seg[1]}] # b
set_property PACKAGE_PIN D19 [get_ports {seg[2]}] # c
set_property PACKAGE_PIN C18 [get_ports {seg[3]}] # d
set_property PACKAGE_PIN B18 [get_ports {seg[4]}] # e
set_property PACKAGE_PIN A18 [get_ports {seg[5]}] # f
set_property PACKAGE_PIN D16 [get_ports {seg[6]}] # g
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

# Anodes
set_property PACKAGE_PIN H17 [get_ports {an[0]}]
set_property PACKAGE_PIN K16 [get_ports {an[1]}]
set_property PACKAGE_PIN J17 [get_ports {an[2]}]
set_property PACKAGE_PIN H15 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

# LEDs
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# Note: Verify pins for your board revision; this is a template.

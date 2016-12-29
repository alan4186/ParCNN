# A list of directory locations that other scripts will use to determine output locations
import os.path
# Path to the root directory of the project.
# Append to this to create absolute paths for the  other locations
project_root = os.path.expanduser('~/Documents/co_processors/ParCNN/')

# Output location for the .h file used in verilog
network_params = project_root + 'Hardware/network_params.h'

# Output location for the read port mux .v file
read_port_mux = project_root + 'Hardware/v/read_port_mux.v'

# Output location for window selector .v file
window_selector = project_root + 'Hardware/v/window_selector.v'

# Directory with Kernel CSVs 
kernel_path = project_root + 'Software/Verilog_Builder/kernel_base2/'

# Path to .h file that instantiates the kernel in verilog
kernel_defs = project_root + 'Hardware/kernel_defs.h'


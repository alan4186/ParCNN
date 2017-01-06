# A list of directory locations that other scripts will use to determine output locations
import os.path
# Path to the root directory of the project.
# Append to this to create absolute paths for the  other locations
project_root = os.path.expanduser('~/Documents/co_processors/ParCNN/')

# Directory with Kernel CSVs 
kernel_path = project_root + 'Software/Verilog_Builder/kernel_base2/'

# Path to .h file that instantiates the kernel in verilog
kernel_defs = project_root + 'Hardware/kernel_defs.h'


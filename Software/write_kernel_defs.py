# read csv and write kerel_defs.h
import csv
import network_params
import os


def genKernelWire(kp,kf,kw_name):
    with open(kp+kf,'rb') as f:
        reader = csv.reader(f)
        k = list(reader)
       
        k_wire = 'assign k[' +str(count) +'] = { '
        for r in k:
            for rc in r:
                # w = str(network_params.CAMERA_PIXEL_WIDTH)+"'b" + rc + ', '
                w = "1'b" + rc + ', '
                k_wire = k_wire + w

        k_wire = k_wire[0:-2] + '};\n'
        return k_wire


def listdir_nohidden(path):
    for f in os.listdir(path):
        if not f.startswith('.'):
            yield f

if __name__ == '__main__':
    kp = './kernel_base2/'
    kf_list = listdir_nohidden(kp)  
    name = 'kernel'
    count = 0

    kernel_def = 'wire [(`KERNEL_SIZE_SQ*`CAMERA_PIXEL_WIDTH)-1:0] k[`NUM_KERNELS-1:0];\n'
    for kf in kf_list:
        k_wire = genKernelWire(kp,kf,name+str(count))
        kernel_def = kernel_def + k_wire 
        count = count + 1

    with open('../Hardware/kernel_defs.v','w') as f:
        f.write(kernel_def)


# ParCNN
The Parametric Convolutional Neural Network project!

## Description
This project is builds off of my ECE undergraduate senior design project at Miami University which is in my [Hardware-CNN](https://github.com/alan4186/Hardware-CNN) repo.  This Project is in its early stages (as of 01/01/2017) but aims to create a parametric design that computes the output of a convolutional neural network with an arbitrary number and combination of convolutional, rectifying and max pooling layers.  A python script or GUI will be used to create the necessary verilog files to synthesize a design.  

The original Hardware-CNN project used parametric bit widths, but these made the code difficult to read.  This project will use 8 bit weights and inputs.  Multiply and addition operations used in convolution will output 32 bit values similar to the way TensorFlow works with quantized networks.  A long term goal of this project is to be able to export a quantized TensorFlow network to hardware but for now just getting it working is the priority.

## Target Device
The first version of this project will be tested on an Altera DE2-150i but the goal is to be able to easily create a design for any Altera FPGA.

from collections import OrderedDict
from Tkinter import *
import math

from tensorflow.examples.tutorials.mnist import input_data
from convLayer import ConvLayer
# A class to describe the network that will be implemented in hardware
class Net:

    def __init__(self, project_name, steps):
        self.layers = OrderedDict()
        self.project_name = project_name
        
        # Training settings
        self.training_steps = steps

    def add_conv(self, name, kx_size, ky_size, kz_size, num_kernels, ix_size, iy_size, iz_size, sharing_factor, rq_max, rq_min, kernels):
        self.layers[name] = ConvLayer(name,kx_size,ky_size,kz_size,num_kernels,ix_size,iy_size,iz_size,sharing_factor, rq_max, rq_min, kernels)

    def add_relu(self):
        print 'under construction'

    def add_max_pool(self):
        print 'under construction'

        
    def export_cnn_module(self):
        #TODO create project directory

        cnn_module = ''
        port_list = \
"""module cnn (
input clock,
input reset,
input [7:0] pixel_in,
output [7:0] pixel_out
);
"""
        cnn_module = cnn_module + port_list

        # create wire declarations
        num_wires = len(self.layers.keys()) + 2
        wire8 = "wire [7:0] wire8 ["+str(num_wires)+":0];\n\n"
        
        cnn_module = cnn_module + wire8 
        
        wire_index = 0
        # instantiate layer modules
        for pair in self.layers.items():
            v = pair[1]
            #inst = v.write_inst(pair[0], wire_index, wire_index+1)
            inst = v.export(pair[0], wire_index, wire_index+1)
            wire_index += 1 
            cnn_module += inst

        cnn_module +="\nassign pixel_out = wire8["+str(wire_index)+"];\n\n"

        cnn_module += "endmodule"
        with open("../"+self.project_name+"cnn.v",'w') as f:
            f.write(cnn)
        
        return cnn_module

    def train(self):

        # TODO get training data
        mnist = input_data.read_data_sets('MNIST_data', one_hot=True)
        
        # TODO split commands dictionary into seperate functions in the respective classes
        # Create dictionary to translate layer classes into functions
        commands = { 
            'conv':self.conv2d,
            'relu':tf.nn.relu,
            'bias':add_bias,
            'max_pool':self.max_pool
            } 

        #TODO parametric input/output size
        input_placeholder = tf.placeholder(tf.float32, shape=[None, 784])
        target_placeholder = tf.placeholder(tf.float32, shape=[None,10])

        # Build the Tensorflow graph
        layer_outputs = [input_placeholder]
        for l in self.layers:
            layer_outputs.append(l.tf_function(layer_outputs[-1]))
            

        cross_entropy = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(y_conv, y_))
        train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)
        correct_prediction = tf.equal(tf.argmax(y_conv,1), tf.argmax(y_,1))
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
        init_op = tf.global_variables_initializer()

        with tf.Session() as sess:
            init_op.run()
            
            # start training
            for i in range(self.training_steps):
                batch = mnist.train.next_batch(50)
                if i%100 == 0:
                    train_accuracy = accuracy.eval(feed_dict={
                        x:batch[0], y_: batch[1] })
                    print("step %d, training accuracy %g"%(i, train_accuracy))
                    train_step.run(feed_dict={x: batch[0], y_: batch[1]})

            print("test accuracy %g"%accuracy.eval(feed_dict={
                x: mnist.test.images, y_: mnist.test.labels}))

            #TODO save network
"""  Move these functions to their respective classes
    def add_bias(self,h, bias):
        # h: the input to the layer
        # bias: the tensorflow variable to add to the input
        return bias+h

    def max_pool(self, x,dims):
        # x: the tensorflow input to the layer 
        # dims: an x/y tuple representing the pool dimensions

        #TODO implement variable dimension pools
        return tf.nn.max_pool(x, ksize=[1, 2, 2, 1],
            strides=[1, 2, 2, 1], padding='VALID')
"""

    def set_train_steps(self,steps):
        self.training_steps = steps

class InputLayer:
    
    def __init__(self, x_size, y_size):
        self.x_size = x_size
        self.y_size = y_size

class ReluLayer:

    def __init__(self):
        print 'under construction'

class MaxPoolingLayer:

    def __init__(self):
        print 'under construction'


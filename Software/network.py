from collections import OrderedDict

import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

# layer imports
from convLayer import ConvLayer
from biasLayer import BiasLayer
from reluLayer import ReluLayer
from denseLayer import DenseLayer

# A class to describe the network that will be implemented in hardware
class Net:

    def __init__(self, project_name, steps):
        self.layers = OrderedDict()
        self.project_name = project_name
        
        # Training settings
        self.training_steps = steps

    def add_conv(self, name, kx_size, ky_size, kz_size, num_kernels, ix_size, iy_size, iz_size, sharing_factor, rq_max, rq_min):
        self.layers[name] = ConvLayer(name,kx_size,ky_size,kz_size,num_kernels,ix_size,iy_size,iz_size,sharing_factor, rq_max, rq_min)

    def add_bias(self, name, size):
        self.layers[name] = BiasLayer(name, size)

    def add_relu(self, name, size, q_max, q_min):
        self.layers[name] = ReluLayer(name, size, q_max, q_min)

    def add_max_pool(self):
        print 'under construction'

        
    def add_dense(self, name, ix_size, iy_size, iz_size, num_outputs, sharing_factor, rq_max, rq_min):
        # use convolution with kernel_size = input size
        self.layers[name] = DenseLayer(name, ix_size,iy_size,iz_size, num_outputs,sharing_factor, rq_max, rq_min)

    def export_cnn_module(self):
        out_dir = "../generated_modules/"


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
        with open(out_dir+self.project_name+"_cnn.v",'w') as f:
            f.write(cnn_module)
        
        return cnn_module

    def train(self):

        # TODO get arbitrary training data
        mnist = input_data.read_data_sets('MNIST_data', one_hot=True)
        


        #TODO parametric input/output size
        x = tf.placeholder(tf.float32, shape=[None, 784])
        x_images= tf.reshape(x, [-1,28,28,1])
        y_ = tf.placeholder(tf.float32, shape=[None,10]) # labels place holder

        # Build the Tensorflow graph
        layer_outputs = [x_images]
        for name,l in self.layers.items():
            layer_outputs.append(l.tf_function(layer_outputs[-1]))
           
        # Hard code output shape for MNIST
        layer_outputs.append(tf.reshape(layer_outputs[-1],[-1,10]))

        cross_entropy = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(layer_outputs[-1], y_))
        train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)
        correct_prediction = tf.equal(tf.argmax(layer_outputs[-1],1), tf.argmax(y_,1))
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

            print("floating point test accuracy %g"%accuracy.eval(feed_dict={
                x: mnist.test.images, y_: mnist.test.labels}))

            
             
            for name,l in self.layers.items():
                #TODO detemine requantize ranges

                # save the trained network
                l.save_layer()

    """  Move these functions to their respective classes
    def max_pool(self, x,dims):
        # x: the tensorflow input to the layer 
        # dims: an x/y tuple representing the pool dimensions

        #TODO implement variable dimension pools
        return tf.nn.max_pool(x, ksize=[1, 2, 2, 1],
            strides=[1, 2, 2, 1], padding='VALID')
    """

    def set_train_steps(self,steps):
        self.training_steps = steps


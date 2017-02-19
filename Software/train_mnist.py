from collections import OrderedDict
import numpy as np
from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets('MNIST_data', one_hot=True)

import tensorflow as tf
sess = tf.InteractiveSession()

def weight_variable(shape):
    initial = tf.truncated_normal(shape, stddev=0.1)
    return tf.Variable(initial)

def bias_variable(shape):
    initial = tf.constant(0.1, shape=shape)
    return tf.Variable(initial)

def conv2d(x, W):
    return tf.nn.conv2d(x, W, strides=[1, 1, 1, 1], padding='VALID')

def max_pool_2x2(x):
    return tf.nn.max_pool(x, ksize=[1, 2, 2, 1],
                          strides=[1, 2, 2, 1], padding='VALID')

x = tf.placeholder(tf.float32, shape=[None, 784])
y_ = tf.placeholder(tf.float32, shape=[None, 10])



W_conv1 = weight_variable([7, 7, 1, 8])
b_conv1 = bias_variable([8])

x_image = tf.reshape(x, [-1,28,28,1])

h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1)
h_pool1 = max_pool_2x2(h_conv1)

W_fc1 = weight_variable([11 * 11 * 8, 10])
b_fc1 = bias_variable([10])

h_pool1_flat = tf.reshape(h_pool1,[-1, 11 * 11 * 8])
y_conv = tf.matmul(h_pool1_flat, W_fc1) + b_fc1

cross_entropy = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(y_conv, y_))
train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)
correct_prediction = tf.equal(tf.argmax(y_conv,1), tf.argmax(y_,1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
sessvars = sess.run(tf.global_variables_initializer())
#for i in range(20000):
for i in range(5000):
    batch = mnist.train.next_batch(50)
    if i%100 == 0:
        train_accuracy = accuracy.eval(feed_dict={
                               x:batch[0], y_: batch[1] })
        print("step %d, training accuracy %g"%(i, train_accuracy))
    train_step.run(feed_dict={x: batch[0], y_: batch[1]})

print("test accuracy %g"%accuracy.eval(feed_dict={
                                       x: mnist.test.images, y_: mnist.test.labels}))

#########################################
# Put TF variables in dict for exporting
#########################################
cnn = OrderedDict()
cnn['W_conv1'] = W_conv1
cnn['b_conv1'] = b_conv1
cnn['W_fc1'] = W_fc1
cnn['b_fc1'] = b_fc1

#for k,v in cnn.iteritems():
#    np.savetxt(k+".csv", v.eval(), delimiter=",")


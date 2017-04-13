import numpy as np
import math
import tensorflow as tf

def quantize(f, f_min, f_max, q_bw):
    bits = 2**q_bw
    f_range = f_max - f_min
    q = np.round( (f - f_min) * bits / f_range)
    q_offset = np.round( f_min * bits / f_range)
    return q + q_offset

def dequantize(q, f_min, f_max, q_bw):
    bits = 2**q_bw
    f_range = f_max - f_min
    sc = f_range / bits
    return q * sc * sc



def tf_quantize(f, f_min, f_max, q_bw):
    bits = tf.pow(2.0, q_bw)
    f_range = f_max - f_min
    q = tf.round( (f - f_min) * bits / f_range)
    q_offset = tf.round( f_min * bits / f_range)
    return q + q_offset

def tf_dequantize(q, f_min, f_max, q_bw):
    bits = tf.pow(2.0, q_bw)
    f_range = f_max - f_min
    ######################
    # CHANGED FOR TESTING, ADDED -1
    ######################
    #sc = f_range / (bits-1)
    sc = f_range / (bits)
    return q * sc * sc


def tf_reluq(t,zero):
    return tf.maximum(t,zero)

import numpy as np
import math
import tensorflow as tf

def tf_quantize(f, f_min, f_max, q_bw):
    """ Convert floating point tensor to quantized representation

    Quantize the floating point tensor to a signed interger representation. 
    Usually, an 8 bit representation will be used yielding a range of -128
    to 127.  The returned tensor's type is still float32 but its values will
    be integers.

    The integers represent floating point values lineraly spaced between
    f_min and f_max. The range given by f_min and f_max must be symetric.

    Args:
        f: A tensor of type float32
        f_min: A float32 tensor scalar representing the minimum floating 
            point value.  This argument can be converted from an int or
            float to a tensor by tensorflow.
         f_max: A float32 tensor scalar representing the maximum floating 
            point value.  This argument can be converted from an int or
            float to a tensor by tensorflow.
         q_bw: The bitwidth of the quantized value.  Can be of type float,
            int or tensor
    Returns:
        A float32 tensor the same size as f that has been rounded to 
        integers.
    """

    bits = tf.pow(2.0, q_bw) - 1
    f_range = f_max - f_min
    q = tf.round( (f - f_min) * bits / f_range)
    q_offset = tf.round( f_min * bits / f_range)
    return q + q_offset

def tf_dequantize(q, f_min, f_max, q_bw):
    """ Convert a quantized tensor to its floating point representation

    Convert the quantized (but still float32) tensor to the floating point 
    representation. See tf_quantize for details on the range of the
    quantized tensor.

    Args:
        q: A quantized tensor of type float32
        f_min: A float32 tensor scalar representing the minimum floating 
            point value.  This argument can be converted from an int or
            float to a tensor by tensorflow.
        f_max: A float32 tensor scalar representing the maximum floating 
            point value.  This argument can be converted from an int or
            float to a tensor by tensorflow.   bits = tf.pow(2.0, q_bw) - 1

    Returns:
        A float32 tensor the same size as q

    """

    bits = tf.pow(2.0, q_bw) - 1
    f_range = f_max - f_min
    sc = f_range / (bits)
    f = q - tf.round(f_min/sc)
    f *= sc
    f += f_min
    return f


def tf_requantize(q32,input_max,output_max,in_bw,out_bw, clamp=True):
    """ Convert a tensor to a new bitwidth and range

    Convert the new tensor to a new bitwidth and range.  This is usefull for
    reducing the output bitwidth for layers with add or multiply operations.
    Adding or multiplying will increase the bitwidth, this function can
    convert it back to 8 bits and change the range of the quantized tensor
    to utilize more of the quantization range after a convolution.

    The arguments in_bw does not need to be an integer. The bitwidth of a 
    quantized tensor will change when it is multiplied or added.  For 
    convolution the bitwidth is (8*2)-1 + log2(num_elements_in_kernel). In
    most cases this will not be an integer.  For example: a quantized
    convolution with a 5x5 kernel of ones on an image of ones will have an
    output that has a bitwidth of (8*2)-1 + log2(25) = 19.64

    Args:
        q32: A quantized tensor to change the range and bitwidth of.
        input_max: A float or tensor representing the maximum of the
            symetric floating point range of the input tensor q32.
        output_max: A float or tensor representing the maximum of the
            symetric floating point range of the output tensor.
        in_bw: A float or tensor representing the bitwidth of the input 
            tensor q32.  Does not need to be an integer.
        out_bw: A float or tensor representing the bitwidth of the output
            tensor.  Should almost always be 8.0.

    Kwargs:
        clamp: A boolean.  If true, the output tensor will be limited to a 
            range of -128 to 127.

    Returns:
        q8: A quantized float32 tensor in the new bitwidth and range.

    """
    bits_in = (2**in_bw) - 1
    bits_out = (2**out_bw) - 1
    q8 = tf.multiply(q32, input_max / output_max * bits_out / bits_in)
    q8 = q8 - tf.mod(q8,1)
    if clamp:
        q8 = tf.clip_by_value(q8,-128,127)
    return q8


def tf_reluq(t,zero):
    return tf.maximum(t,zero)

def conv_max(mx, num_elements):
    """ Compute the maximum posible output of a Convolution

    The max value is based on the maximum of the symetric quantized range

    """
    return mx**2 * num_elements


if __name__ == "__main__":
    mn = -1.5
    mx = 1.5

    mx2 = conv_max(mx,5)
    mn2 = -mx2

    mx3=8.9648
    mn3 = -mx3

    mx4 = conv_max(mx3,3)
    mn4 = -mx4
    
    im = tf.random_uniform([1,7,7,1],minval=mn,maxval=mx)
    w = tf.random_uniform([5,5,1,1],minval=mn,maxval=mx)
    h_conv1 = tf.nn.conv2d(im,w,strides=[1,1,1,1],padding='VALID')
    w2 = tf.random_uniform([3,3,1,1],minval=mn,maxval=mx)
    h_conv2 = tf.nn.conv2d(h_conv1,w2, strides=[1,1,1,1],padding='VALID')

    imq = tf_quantize(im,mn,mx,8.0)
    wq = tf_quantize(w,mn,mx,8.0)
    h_conv1q = tf.nn.conv2d(imq,wq,strides=[1,1,1,1],padding='VALID')
    h_conv1rq = tf_requantize(h_conv1q,mx2,mx3,15+math.log(5,2),8.0)
    w2q = tf_quantize(w2,mn3,mx3,8.0)
    h_conv2q = tf.nn.conv2d(h_conv1rq,w2q,strides=[1,1,1,1],padding='VALID')
    h_conv2dq = tf_dequantize(h_conv2q,mn4,mx4,15+math.log(3,2))

    err = h_conv2 - h_conv2dq
    mxerr = tf.reduce_max(err)
    init_op = tf.global_variables_initializer()
    with tf.Session() as sess:
        init_op.run()
        print mxerr.eval()


    a = tf.constant(0.1,shape=[1])
    aq = tf_quantize(a,mn,mx,8.0)
    adq = tf_dequantize(aq,mn,mx,8.0)
    arq = tf_requantize(aq,mx,0.2,8.0,8.0)
    adrq = tf_dequantize(arq,-0.2,0.2,8.0)
    test = tf_dequantize(59,-0.2,0.2,8.0)

    init_op = tf.global_variables_initializer()
    with tf.Session() as sess:
        print a.eval()
        print aq.eval()
        print adq.eval()
        print arq.eval()
        print adrq.eval()
        print test.eval()


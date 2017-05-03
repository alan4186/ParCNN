import network

nn = network.Net('test_cnn',10)

nn.add_conv('c1',7,7,1,8,28,28,1,1,10,-10)
nn.add_bias('b1',8)
nn.add_relu('r1',8,10,-10)
nn.add_dense('fc',22,22,8,10,1,10,-10)
nn.add_bias('bfc',10)

nn.train()

nn.export_cnn_module()

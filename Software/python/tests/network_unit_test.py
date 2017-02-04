from network import Net

nn = Net()

k = "{8'd0, 8'd255, 8'd35, ... }"

nn.add_conv("layer1", 4, 4, 10, 28, 28, 1,1024,-1024,k)
nn.add_conv("layer2", 3, 3, 11, 25, 25, 1,2048,-2048,k)
nn.add_conv("layer1", 2, 2, 12, 19, 19, 1,300,-300,k)

print nn.write_cnn_module()

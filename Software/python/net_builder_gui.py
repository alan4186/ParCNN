from collections import OrderedDict
from Tkinter import *

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot 
import numpy as np
import numpy.matlib
from itertools import product, combinations


from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

from network import Net
# A class to describe the network that will be implemented in hardware
class NetBuilderGUI:

    def __init__(self):
        self.top=Tk()
        self.top.wm_title("CNN Builder")

        # Create Network class inst
        self.network = Net('gui project', 200)

        # Create Settings Frames
        self.conv_settings()
        self.relu_settings()
        self.pool_settings()
        self.dense_settings()
        self.train_settings()
        
        self.setting_frames=OrderedDict()
        self.setting_frames['conv'] = self.cs
        self.setting_frames['relu'] = self.rs
        self.setting_frames['pool'] = self.ps
        self.setting_frames['dense'] = self.ds
        self.setting_frames['train'] = self.ts 

        # Create Controls Frame
        self.controls_frame()
       
        # Create Visualization Frame
        self.visualization_frame()

        # Run GUI
        self.top.mainloop()

    def controls_frame(self):
        self.controls = Frame(self.top)
        self.controls.grid(row=0,column=0,rowspan=1)
      
        #ctrl_label = Label(self.controls, text='Layers:')
        #ctrl_label.pack()

        MODES = [
            ("Convolution", "conv", self.c_update_settings),
            ("Relu", "relu", self.r_update_settings),
            ("Max Pooling", "pool", self.p_update_settings),
            ("Fully Connected", "dense", self.d_update_settings),
            ("Training","train", self.t_update_settings)
        ]

        self.strvar = StringVar()
        self.strvar.set("conv") # initialize

        for text, mode, c in MODES:
            b = Button(self.controls, text=text,
                            command=c)
            if mode == "conv":
                b.invoke()
            b.pack(side=LEFT, fill=BOTH)

    def update_settings(self,frame_name):
        for k in self.setting_frames.keys():
            v = self.setting_frames[k]
            v.grid_forget()
        #self.setting_frames[frame_name].grid(row=0,column=1,rowspan=2)
        self.setting_frames[frame_name].grid(row=1,column=0,rowspan=1)


    def c_update_settings(self):
        self.update_settings('conv')
    def r_update_settings(self):
        self.update_settings('relu')
    def p_update_settings(self):
        self.update_settings('pool')
    def d_update_settings(self):
        self.update_settings('dense')
    def t_update_settings(self):
        self.update_settings('train')
         
    def conv_settings(self):
        self.cs = Frame(self.top)
        title = Label(self.cs,text='Convolution Settings')
        title.grid(row=0,column=1,columnspan=2)

        setting_names = ["Layer Name",
                "Input X Size", 
                "Input Y Size",
                "Kernel X Size",
                "Kernel Y Size",
                "Input/Kernel Z Size",
                "Number of Kernels",
                "Requantize Max",
                "Requantize Min"
                ]
        self.conv_labels = {}
        self.conv_entries= {}
        r = 1
        for s in setting_names:
            self.conv_labels[s] = Label(self.cs, text=s)
            self.conv_labels[s].grid(row=r,column=1)
            self.conv_entries[s] = Entry(self.cs)
            self.conv_entries[s].grid(row=r,column=2)
            r +=1
       
        conv_layer_b = Button(self.cs, text="Add Layer", command=self.add_conv_layer)
        conv_layer_b.grid(row=r,column=1,columnspan=2)
        r+=1

    def add_conv_layer(self):
        name = self.conv_entries["Layer Name"].get()
        i_xs = int(self.conv_entries["Input X Size"].get())
        i_ys = int(self.conv_entries["Input Y Size"].get())
        k_xs = int(self.conv_entries["Kernel X Size"].get())
        k_ys = int(self.conv_entries["Kernel Y Size"].get())
        zs = int(self.conv_entries["Input/Kernel Z Size"].get())
        num_k = int(self.conv_entries["Number of Kernels"].get())
        rq_max = int(self.conv_entries["Requantize Max"].get())
        rq_min = int(self.conv_entries["Requantize Min"].get())

        np_kernels = []
        self.network.add_conv(name, k_xs, k_ys, zs, num_k, i_xs, i_ys, zs, 1.0, rq_max, rq_min)

        #self.vf_canvas.pack_forget()
        #self.vf.grid_forget()
        self.visualization_frame()
        
        # update settings to be compatable with this layer
        self.conv_entries["Input/Kernel Z Size"].delete(0,END)
        self.conv_entries["Input/Kernel Z Size"].insert(0,num_k)
        
    def relu_settings(self):
        self.rs = Frame(self.top)
        
        title = Label(self.rs,text='Relu Settings')
        title.grid(row=0,column=1,columnspan=2)

        setting_names = ["Layer Name",
                "Input X Size", 
                "Input Y Size",
                ]
        self.relu_labels = {}
        self.relu_entries = {}
        r = 1
        for s in setting_names:
            self.relu_labels[s] = Label(self.rs, text=s)
            self.relu_labels[s].grid(row=r,column=1)
            self.relu_entries[s] = Entry(self.rs)
            self.relu_entries[s].grid(row=r,column=2)
            r +=1

        relu_layer_b = Button(self.rs, text="Add Layer", command=self.add_relu_layer)
        relu_layer_b.grid(row=r,column=1,columnspan=2)

    def add_relu_layer(self):
        name = self.relu_entries["Layer Name"].get()
        i_xs = int(self.relu_entries["Input X Size"].get())
        i_ys = int(self.relu_entries["Input Y Size"].get())

        # Arbitrary Q max/min
        q_max = 10
        q_min = -10
        self.network.add_relu(name, q_max, q_min)

        self.visualization_frame()

    def pool_settings(self):
        self.ps = Frame(self.top)
        
        title = Label(self.ps,text='Max Pooling Settings')
        title.grid(row=0,column=1,columnspan=2)

        setting_names = ["Pool X Size",
                "Pool Y Size"
                ]
        setting_labels = {}
        setting_entrys = {}
        r = 1
        for s in setting_names:
            setting_labels[s] = Label(self.ps, text=s)
            setting_labels[s].grid(row=r,column=1)
            setting_entrys[s] = Entry(self.ps)
            setting_entrys[s].grid(row=r,column=2)
            r +=1
        
    def dense_settings(self):
        self.ds = Frame(self.top)
        
        title = Label(self.ds,text='Dense Settings')
        title.grid(row=0,column=1,columnspan=2)

        setting_names = ["Layer Name",
                "Input X Size", 
                "Input Y Size",
                "Input Z Size",
                "Output Size (1D)",
                "Requantize Max",
                "Requantize Min"
                ]
        self.dense_labels= {}
        self.dense_entries = {}
        r = 1
        for s in setting_names:
            self.dense_labels[s] = Label(self.ds, text=s)
            self.dense_labels[s].grid(row=r,column=1)
            self.dense_entries[s] = Entry(self.ds)
            self.dense_entries[s].grid(row=r,column=2)
            r +=1
       
        dense_layer_b = Button(self.ds, text="Add Layer", command=self.add_dense_layer)
        dense_layer_b.grid(row=r,column=1,columnspan=2)

    def add_dense_layer(self):
        name = self.dense_entries["Layer Name"].get()
        i_xs = int(self.dense_entries["Input X Size"].get())
        i_ys = int(self.dense_entries["Input Y Size"].get())
        i_zs = int(self.dense_entries["Input Z Size"].get())
        o_s= int(self.dense_entries["Output Size (1D)"].get())
        rq_max = int(self.dense_entries["Requantize Max"].get())
        rq_min = int(self.dense_entries["Requantize Min"].get())

        np_kernels = []
        self.network.add_dense(name, i_xs, i_ys, i_zs, o_s, 1.0, rq_max, rq_min)

        #self.vf_canvas.pack_forget()
        #self.vf.grid_forget()
        self.visualization_frame()

    def train_settings(self):
        self.ts = Frame(self.top)
        title = Label(self.ts,text='Training Settings')
        title.grid(row=0,column=1,columnspan=2)

        setting_names = ["Training Steps",
                "Training Data", 
                "Training Labels", 
                "Testing Data",
                "Testing Labels"
                ]
        self.train_labels = {}
        self.train_entries= {}
        r = 1
        for s in setting_names:
            self.train_labels[s] = Label(self.ts, text=s)
            self.train_labels[s].grid(row=r,column=1)
            self.train_entries[s] = Entry(self.ts)
            self.train_entries[s].grid(row=r,column=2)
            r +=1
       
        train_b = Button(self.ts, text="Train Network", command=self.launch_training)
        train_b.grid(row=r,column=1,columnspan=2)
        r+=1


    def launch_training(self):
        # update training settings
        self.network.set_train_steps(int(self.train_entries['Training Steps'].get()))
        self.network.train()

    def visualization_frame(self):
        # create frame to hold scrollbars and canvas
        self.vf = Frame(self.top, width=816, height=416)
        self.vf.grid(row=0,column=1, rowspan=2)
        self.vf.config(bd=3)
        
        # create cavas that will scroll
        self.vf_canvas = Canvas(self.vf,bg='#FFFFFF',width=400,height=400,scrollregion=(0,0,5000,5000))
        fig = matplotlib.pyplot.figure(facecolor='White')

        draw_functions = {'conv':self.draw_conv_layer,
                'relu':self.draw_relu_layer,
                'dense':self.draw_dense_layer
                }

        num_layers=len(self.network.layers.items())
        if len(self.network.layers) > 0:
            i=1
            # create figure
            for pair in self.network.layers.items():
                name = pair[0]
                l = pair[1] 
                ax= fig.add_subplot(1,num_layers,i,projection='3d')
                draw_functions[l.layer_type](l,[0,0,0],ax)
                i+=1

        
        canvas = FigureCanvasTkAgg(fig,master=self.vf)
        #canvas = FigureCanvasTkAgg(fig,master=self.top)
        plot_widget = canvas.get_tk_widget()
        """ 
        xScrollbar = Scrollbar(self.vf, orient=HORIZONTAL)
        xScrollbar.grid(row=2, column=1, sticky=W+E)
        xScrollbar.config(command=plot_widget.xview)
        
        yScrollbar = Scrollbar(self.vf, orient=VERTICAL)
        yScrollbar.grid(row=1, column=2, sticky=N+S)
        yScrollbar.config(command=plot_widget.yview)      
        """
        # disable geometry propagation now that scroll bars are in place
        self.vf.grid_propagate(0)
        
        xScrollbar = Scrollbar(self.top, orient=HORIZONTAL)
        xScrollbar.grid(row=2, column=1, sticky=W+E)
        xScrollbar.config(command=plot_widget.xview)
        
        yScrollbar = Scrollbar(self.top, orient=VERTICAL)
        yScrollbar.grid(row=0, column=2, rowspan=2,sticky=N+S)
        yScrollbar.config(command=plot_widget.yview)
        
        if num_layers: 
            plot_widget.config(width=400*num_layers, height=400)
        else:
            plot_widget.config(width=400, height=400)
        plot_widget.config(xscrollcommand=xScrollbar.set, yscrollcommand=yScrollbar.set,scrollregion=(0,0,5000,5000))
        #plot_widget.pack(side=LEFT, expand=False)
        plot_widget.grid(row=1, column=1)

        #self.vf.config(width=400, height=400)

    def draw_conv_layer(self, layer,o, ax):
        name = layer.name
        ix = layer.ix_size
        iy = layer.iy_size
        z = layer.z_size
        kx = layer.kx_size
        ky = layer.ky_size 
        nk = layer.num_kernels

        # prevent box from looking long and skinny
        if z > 3*np.min([ix,iy]):
            zs = 3*np.min([ix,iy])
        else:
            zs = z
            
        ko_scale = 0.25
        ko = [ix*ko_scale+o[0], iy*ko_scale+o[1], 0+o[2]]
        self.draw_cube(ix,iy,zs,o ,ax)
        self.draw_cube(kx,ky,zs,ko ,ax)
        max_dim = np.max([ix,iy,zs])*1.05 # will cause problems if multiple layers are in 1 plot
        ax.set_xlim3d(0,max_dim)
        ax.set_ylim3d(0,max_dim)
        ax.set_zlim3d(0,max_dim)
        ax.view_init(30,-30)

        # Z annotation
        ax.text(ix,z/2.0,0,str(z))
        # Input X/Y annotations
        ax.text(ix/2.0,0,iy,str(ix))
        ax.text(ix,0,iy/2.0,str(iy))
        # Kernel X/Y annotations
        ax.text(kx/2.0+ko[0],0,ky+ko[1],str(kx))
        ax.text(kx+ko[0],0,ky/2.0+ko[1],str(ky))
        # number of kernel annotation
        ax.text(ix,z/2.0,-5,'Kernels: '+str(nk))

        matplotlib.pyplot.axis('off')
        matplotlib.pyplot.title(name)
        #return fig

    def draw_relu_layer(self, layer,o, ax):
        name = layer.name
        ix = 30
        iy = 30 
        z = 2

        self.draw_cube(ix,iy,z,o ,ax)
        max_dim = np.max([ix,iy,z])*1.05 # will cause problems if multiple layers are in 1 plot
        ax.set_xlim3d(0,max_dim)
        ax.set_ylim3d(0,max_dim)
        ax.set_zlim3d(0,max_dim)
        ax.view_init(30,-30)

        # Z annotation
        ax.text(ix,z/2.0,0,'relu')

        matplotlib.pyplot.axis('off')
        matplotlib.pyplot.title(name)

    def draw_dense_layer(self, layer,o, ax):
        name = layer.name
        ix = 30
        iy = 30 
        z = 2

        self.draw_cube(ix,iy,z,o ,ax)
        max_dim = np.max([ix,iy,z])*1.05 # will cause problems if multiple layers are in 1 plot
        ax.set_xlim3d(0,max_dim)
        ax.set_ylim3d(0,max_dim)
        ax.set_zlim3d(0,max_dim)
        ax.view_init(30,-30)

        # Z annotation
        ax.text(ix,z/2.0,0,'dense')

        matplotlib.pyplot.axis('off')
        matplotlib.pyplot.title(name)

    def draw_cube(self,x,y,z,o,ax):
        o = [ o[0], o[2], o[1]]
        corners = np.array([[0,0,0],
        [0,0,1],
        [0,1,1],
        #[0,1,0], # leave out back corner
        [1,1,0],
        [1,1,1],
        [1,0,1],
        [1,0,0]
        ])
    
        dim = np.matlib.repmat(np.array([x,z,y]),7,1)
        corners = np.multiply(dim,corners) 
        for s,e in combinations(corners,2):
            sn = (s != np.array([0,0,0])).astype(int)
            en = (e != np.array([0,0,0])).astype(int)
        
            if np.sum(np.power((sn-en),2)) == 1:
                ax.plot3D(*zip(s+o,e+o), color='b')
            

      

g = NetBuilderGUI()


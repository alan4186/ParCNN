from collections import OrderedDict
from Tkinter import *

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot 
import numpy as np
import numpy.matlib
from itertools import product, combinations

import matplotlib
matplotlib.use('TkAgg')

from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

from network import Net
# A class to describe the network that will be implemented in hardware
class NetBuilderGUI:

    def __init__(self):
        self.top=Tk()
        self.top.wm_title("CNN Builder")

        # Create Network class inst
        self.network = Net()

        # Create Settings Frames
        self.conv_settings()
        self.relu_settings()
        self.pool_settings()
        
        self.setting_frames=OrderedDict()
        self.setting_frames['conv'] = self.cs
        self.setting_frames['relu'] = self.rs
        self.setting_frames['pool'] = self.ps
        
        # Create Controls Frame
        self.controls_frame()
       
        # Create Visualization Frame
        self.visualization_frame()

        # Run GUI
        self.top.mainloop()

    def controls_frame(self):
        self.controls = Frame(self.top)
        self.controls.grid(row=0,column=0,rowspan=2)
      
        ctrl_label = Label(self.controls, text='Layers:')
        ctrl_label.pack()

        MODES = [
            ("Convolution", "conv"),
            ("Relu", "relu"),
            ("Max Pooling", "pool"),
        ]

        self.strvar = StringVar()
        self.strvar.set("conv") # initialize

        for text, mode in MODES:
            b = Radiobutton(self.controls, text=text,
                            variable=self.strvar, value=mode,command=self.update_settings)
            if mode == "conv":
                b.invoke()
            b.pack(anchor=W)

    def update_settings(self):
        print "updating settings"
        frame_name = self.strvar.get()
        print frame_name
        for k in self.setting_frames.keys():
            v = self.setting_frames[k]
            v.grid_forget()
        self.setting_frames[frame_name].grid(row=0,column=1,rowspan=2)

        
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
        self.setting_labels = {}
        self.setting_entrys = {}
        r = 1
        for s in setting_names:
            self.setting_labels[s] = Label(self.cs, text=s)
            self.setting_labels[s].grid(row=r,column=1)
            self.setting_entrys[s] = Entry(self.cs)
            self.setting_entrys[s].grid(row=r,column=2)
            r +=1
       
        conv_layer_b = Button(self.cs, text="Add Layer", command=self.add_conv_layer)
        conv_layer_b.grid(row=r,column=1,columnspan=2)
        r+=1

    def add_conv_layer(self):
        name = self.setting_entrys["Layer Name"].get()
        i_xs = int(self.setting_entrys["Input X Size"].get())
        i_ys = int(self.setting_entrys["Input Y Size"].get())
        k_xs = int(self.setting_entrys["Kernel X Size"].get())
        k_ys = int(self.setting_entrys["Kernel Y Size"].get())
        zs = int(self.setting_entrys["Input/Kernel Z Size"].get())
        num_k = int(self.setting_entrys["Number of Kernels"].get())
        rq_max = int(self.setting_entrys["Requantize Max"].get())
        rq_min = int(self.setting_entrys["Requantize Min"].get())

        np_kernels = []
        self.network.add_conv(name, k_xs, k_ys, zs, num_k, i_xs, i_ys, zs, 1.0, rq_max, rq_min, np_kernels)

        #self.vf_canvas.pack_forget()
        #self.vf.grid_forget()
        self.visualization_frame()

        print self.network.layers
        
        # update settings to be compatable with this layer
        self.setting_entrys["Input/Kernel Z Size"].delete(0,END)
        self.setting_entrys["Input/Kernel Z Size"].insert(0,num_k)
        
    def relu_settings(self):
        self.rs = Frame(self.top)
        
        title = Label(self.rs,text='Relu Settings')
        title.grid(row=0,column=1,columnspan=2)

        setting_names = ["Input X Size", 
                "Input Y Size"
                ]
        setting_labels = {}
        setting_entrys = {}
        r = 1
        for s in setting_names:
            setting_labels[s] = Label(self.rs, text=s)
            setting_labels[s].grid(row=r,column=1)
            setting_entrys[s] = Entry(self.rs)
            setting_entrys[s].grid(row=r,column=2)
            r +=1


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

    def visualization_frame(self):
        # create frame to hold scrollbars and canvas
        self.vf = Frame(self.top, width=450, height=450)
        self.vf.grid(row=0,column=2)
        self.vf.config(bd=3)
        
        # create cavas that will scroll
        self.vf_canvas = Canvas(self.vf,bg='#FFFFFF',width=400,height=400,scrollregion=(0,0,5000,5000))
        fig = matplotlib.pyplot.figure(facecolor='White')


        num_layers=len(self.network.layers.items())
        if len(self.network.layers) > 0:
            i=1
            # create figure
            for pair in self.network.layers.items():
                name = pair[0]
                l = pair[1] 
                if l.layer_type == "conv":
                    #self.draw_conv_layer(32,32,50,10,10,[0,0,0],ax)
                    ax= fig.add_subplot(1,num_layers,i,projection='3d')
                    self.draw_conv_layer(l.name,l.ix_size, l.iy_size, l.z_size, l.kx_size, l.ky_size,[0,0,0],ax)
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
        xScrollbar.grid(row=1, column=2, sticky=W+E)
        xScrollbar.config(command=plot_widget.xview)
        
        yScrollbar = Scrollbar(self.top, orient=VERTICAL)
        yScrollbar.grid(row=0, column=3, sticky=N+S)
        yScrollbar.config(command=plot_widget.yview)
        
        if num_layers: 
            plot_widget.config(width=400*num_layers, height=400)
        else:
            plot_widget.config(width=400, height=400)
        plot_widget.config(xscrollcommand=xScrollbar.set, yscrollcommand=yScrollbar.set,scrollregion=(0,0,5000,5000))
        #plot_widget.pack(side=LEFT, expand=False)
        plot_widget.grid(row=1, column=1)

        #self.vf.config(width=400, height=400)

        """
        self.vf_canvas.config(width=400, height=400)
        self.vf_canvas.config(xscrollcommand=xScrollbar.set, yscrollcommand=yScrollbar.set)
        self.vf_canvas.pack(side=LEFT, expand=False,fill=None)
        """ 

    def draw_conv_layer(self,name,ix,iy,z,kx,ky,o,ax):
        #ax = fig.gca(projection='3d')
        ko_scale = 0.25
        ko = [ix*ko_scale+o[0], iy*ko_scale+o[1], 0+o[2]]
        self.draw_cube(ix,iy,z,o ,ax)
        self.draw_cube(kx,ky,z,ko ,ax)
        max_dim = np.max([ix,iy,z])*1.05 # will cause problems if multiple layers are in 1 plot
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

        matplotlib.pyplot.axis('off')
        matplotlib.pyplot.title(name)
        #return fig

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


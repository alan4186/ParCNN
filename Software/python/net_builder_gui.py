from collections import OrderedDict
from Tkinter import *

# A class to describe the network that will be implemented in hardware
class NetBuilderGUI:

    def __init__(self):
        self.top=Tk()
        self.top.wm_title("CNN Builder")

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
       
        # Run GUI
        self.top.mainloop()

    def controls_frame(self):
        self.controls = Frame(self.top)
        self.controls.pack(side =LEFT)
      
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
            v.pack_forget()
        self.setting_frames[frame_name].pack(side=RIGHT)

        
    def conv_settings(self):
        self.cs = Frame(self.top)
        title = Label(self.cs,text='Convolution Settings')
        title.grid(row=0,column=1,columnspan=2)

        setting_names = ["Input X Size", 
                "Input Y Size",
                "Kernel X Size",
                "Kernel Y Size",
                "Number of Kernels",
                "Requantize Max",
                "Requantize Min"
                ]
        setting_labels = {}
        setting_entrys = {}
        r = 1
        for s in setting_names:
            setting_labels[s] = Label(self.cs, text=s)
            setting_labels[s].grid(row=r,column=1)
            setting_entrys[s] = Entry(self.cs)
            setting_entrys[s].grid(row=r,column=2)
            r +=1
         
        
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


g = NetBuilderGUI()


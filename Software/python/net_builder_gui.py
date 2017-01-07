from collections import OrderedDict
from Tkinter import *

# A class to describe the network that will be implemented in hardware
class NetBuilderGUI:

    def __init__(self):
        self.top=Tk()
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

        in_x_size_l = Label(self.cs, text="Input X Size:")
        in_x_size_l.grid(row=1,column=1)
        in_x_size_e = Entry(self.cs)
        in_x_size_e.grid(row=1,column=2)
        
        in_y_size_l = Label(self.cs, text="Input Y Size:")
        in_y_size_l.grid(row=2,column=1)
        in_y_size_e = Entry(self.cs)
        in_y_size_e.grid(row=2,column=2)
        
        kernel_x_size_l = Label(self.cs, text="Kernel X Size:")
        kernel_x_size_l.grid(row=3,column=1)
        kernel_x_size_e = Entry(self.cs)
        kernel_x_size_e.grid(row=3,column=2)
        
        kernel_y_size_l = Label(self.cs, text="Kernel Y Size:")
        kernel_y_size_l.grid(row=4,column=1)
        kernel_y_size_e = Entry(self.cs)
        kernel_y_size_e.grid(row=4,column=2)
        
        
    def relu_settings(self):
        self.rs = Frame(self.top)
        
        title = Label(self.rs,text='Relu Settings')
        title.grid(row=0,column=1,columnspan=2)

        max_range_l = Label(self.rs, text="Input X Size:")
        max_range_l.grid(row=1,column=1)
        max_range_e = Entry(self.rs)
        max_range_e.grid(row=1,column=2)

        min_range_l = Label(self.rs, text="Input Y Size:")
        min_range_l.grid(row=2,column=1)
        min_range_e = Entry(self.rs)
        min_range_e.grid(row=2,column=2)


    def pool_settings(self):
        self.ps = Frame(self.top)
        
        title = Label(self.ps,text='Max Pooling Settings')
        title.grid(row=0,column=1,columnspan=2)

        max_range_l = Label(self.ps, text="Pool X Size:")
        max_range_l.grid(row=1,column=1)

        min_range_l = Label(self.ps, text="Pool Y Size:")
        min_range_l.grid(row=2, column=1)

# For Testing
g = GUI_TEST()

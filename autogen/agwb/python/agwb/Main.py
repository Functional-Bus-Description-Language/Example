"""
This file has been automatically generated
by the agwb (https://github.com/wzab/agwb).
Do not modify it by hand.
"""

from . import agwb


class Subblock_t(agwb.Block):
    x__size = 8
    x__id = 0xe6748e82
    x__ver = 0xac8b5742
    x__fields = {
        'ID':(0x0,(agwb.StatusRegister,)),\
        'VER':(0x1,(agwb.StatusRegister,)),\
        'Add0':(0x2,(agwb.ControlRegister,
        {\
            'A':agwb.BitField(19,0,False),\
            'B':agwb.BitField(29,20,False),\
        })),
        'Add1':(0x3,(agwb.ControlRegister,
        {\
            'C':agwb.BitField(7,0,False),\
        })),
        'Sum':(0x4,(agwb.StatusRegister,)),
        'Add_Stream0':(0x5,(agwb.ControlRegister,
        {\
            'A':agwb.BitField(19,0,False),\
            'B':agwb.BitField(29,20,False),\
        })),
        'Add_Stream1':(0x6,(agwb.ControlRegister,
        {\
            'C':agwb.BitField(7,0,False),\
        })),
        'Sum_Stream':(0x7,(agwb.StatusRegister,)),
    }


class Main(agwb.Block):
    x__size = 64
    x__id = 0x1f1a625a
    x__ver = 0xf3f43cfd
    x__fields = {
        'ID':(0x0,(agwb.StatusRegister,)),\
        'VER':(0x1,(agwb.StatusRegister,)),\
        'C1':(0x2,(agwb.ControlRegister,)),
        'C2':(0x3,(agwb.ControlRegister,)),
        'C3':(0x4,(agwb.ControlRegister,)),
        'S1':(0x5,(agwb.StatusRegister,)),
        'S2':(0x6,(agwb.StatusRegister,)),
        'S3':(0x7,(agwb.StatusRegister,)),
        'CA4':(0x8,2,(agwb.ControlRegister,
        {\
            'Item0':agwb.BitField(7,0,False),\
            'Item1':agwb.BitField(15,8,False),\
            'Item2':agwb.BitField(23,16,False),\
            'Item3':agwb.BitField(31,24,False),\
        })),
        'CA2':(0xa,(agwb.ControlRegister,
        {\
            'Item0':agwb.BitField(7,0,False),\
            'Item1':agwb.BitField(15,8,False),\
        })),
        'SA4':(0xb,2,(agwb.StatusRegister,
        {\
            'Item0':agwb.BitField(7,0,False),\
            'Item1':agwb.BitField(15,8,False),\
            'Item2':agwb.BitField(23,16,False),\
            'Item3':agwb.BitField(31,24,False),\
        })),
        'SA2':(0xd,(agwb.StatusRegister,
        {\
            'Item0':agwb.BitField(7,0,False),\
            'Item1':agwb.BitField(15,8,False),\
        })),
        'Counter0':(0xe,(agwb.StatusRegister,)),
        'Counter1':(0xf,(agwb.StatusRegister,)),
        'Mask':(0x10,(agwb.ControlRegister,)),
        'Version':(0x11,(agwb.StatusRegister,)),
        'Subblock':(0x38,(Subblock_t,)),\
    }


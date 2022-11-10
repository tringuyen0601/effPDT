import numpy as np


e           = str(512)
Input       = np.arange( start =  577,      stop = 641,     step = 1).tolist()
NotInput    = np.arange( start =  577+ 256, stop = 641+256, step = 1).tolist()
Stack       = np.arange( start =  513,      stop = 577,     step = 1).tolist()
NotStack    = np.arange( start =  513+ 256, stop = 577+256, step = 1).tolist()
Output      = np.arange( start =  642,      stop = 706,     step = 1).tolist()


Input       = [str(x) for x in Input]
NotInput    = [str(x) for x in NotInput]
Stack       = [str(x) for x in Stack]
NotStack    = [str(x) for x in NotStack]
Output      = [str(x) for x in Output]

passthrough = str( 641)
anyPush     = str( 897)


#print ( Input)
#print ( len ( Input) )
#print ( NotInput)
#print ( len ( NotInput) )
#print ( Stack)
#print ( len ( Stack) )
#print ( NotStack)
#print ( len ( NotStack) )
#print ( Output)
#print ( len ( Output) )

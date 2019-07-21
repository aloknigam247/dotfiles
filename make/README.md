**Structure of Makefiles**

<pre>
make  
├── ext                 ## contains all external dependencies  
│   ├── common.mk       ## common actions for all deps  
│   └── dep  
│       ├── include     ## header files of deps  
│       ├── lib         ## libs files of deps  
│       └── options.mk  ## options for deps like include and libnames  
├── include             ## include dir for src  
├── Makefile            ## top Makefile  
├── recipe              ## contains project level options and actions  
│   ├── config.mk  
│   └── procs.mk  
└── src                 ## source files  
    └── Makefile        ## compilation of sources
</pre>

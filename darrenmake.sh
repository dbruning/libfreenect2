#!/bin/bash

#mkdir build
cd build 
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/freenect2 -DENABLE_CXX11=ON -DENABLE_PROFILING=ON
make 
make install  

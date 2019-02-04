#!/bin/bash

#It requires doxygen and graphviz
#doxygen: http://www.doxygen.org/download.html
#graphviz: sudo apt-get install graphviz
#see ../docs/html/index.html
rm -fr ../docs
mkdir ../docs
doxygen doxygen_config_file > ../docs/doxy.log 2> ../docs/doxy.err

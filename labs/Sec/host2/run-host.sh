#!/bin/bash

docker run -it --rm -v $PWD/vol:/opt/vol --cap-add=NET_ADMIN --name=host2 host2 bash


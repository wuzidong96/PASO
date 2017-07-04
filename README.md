# PASO
Source codes for my research project for energy-efficient timely transportation.

## Publication 
**Lei Deng**, Mohammad H. Hajiesmaili, Minghua Chen, and Haibo Zeng, 
“Energy-Efficient Timely Transportation of Long-Haul Heavy-Duty Trucks,” 
in Prof. ACM International Conference on Future Energy Systems (e-Energy), June 2016.

## Paper and Slides
- Paper link: http://personal.ie.cuhk.edu.hk/~dl013/paper/EETT.eEnergy.16.pdf
- Slides link: http://personal.ie.cuhk.edu.hk/~dl013/paper/EETT.eEnergy.16.slides.pdf

## Problem Description
- We consider a heavy-duty truck travelling from the source node to the destination node across the national highway system, subject to a hard deadline constraint
- Our goal is to minimize the truck's total fuel consumption
- Our design spaces are:
    - **Route planning**: select a path from the source node to the destination node
    - **Speed planning**: optimize the running speed over each road segment

![System Model](system_model.png)
 
## Code Description
- I use C++ to implement all core parts (see [c++/src](c++/src)).
- I use MATLAB to model power-speed function (see [matlab/power.speed.function.modeling](matlab/power.speed.function.modeling)),
and process data and show figures (see [matlab/data.processing.and.show.fig](matlab/data.processing.and.show.fig)).

## Dataset
- **Transportation Network:** We construct the [U.S. National Highway Systems (NHS)](http://courses.teresco.org/chm/graphs/usa-national.gra)
from the [CHM Project](http://cmap.m-plex.com), 
with **84504** nodes (waypoints) and **89119** (one-direction) edges.
- **Elevation:** We use the [Elevation Point Query Service](http://nationalmap.gov/epqs/)
provided by the U.S. Geological Survey (USGS) to query elevations of all nodes in the NHS graph.
- **Speed Limit:** We use [HERE Map API](https://developer.here.com/api-explorer/rest/traffic/flow-using-corridor)
to obtain the speed limits of all road segments.
- **Heavy-Duty Truck and Fuel Consumption Data:** We use the widely  used [ADVISOR](http://adv-vehicle-sim.sourceforge.net/advisor_doc.html)
vehicle simulator to collection 
fuel-consumption data for a 36-ton truck [Kenworth T800](http://www.kenworth.com/trucks/t800).

## A Sample Output
![A Sample Output](show_path_9_22_40.png)
- You can download the [html source file](show_path_9_22_40.html) and open it in your web browser
to zoom in the map to see more details. 


## How to Run the Code
- Install the Snap library from https://snap.stanford.edu/snap/download.html
- Modify the first line of c++/src/Makefile, i.e., "SNAPROOT = /data/grad/dl013/software/Snap-2.4" to your snap path
- Install the GeographicLib library from https://sourceforge.net/projects/geographiclib/files/distrib/
- Modify the second line of c++/src/Makefile, i.e., "GEOROOT = /data/grad/dl013/software/GeographicLib-1.45/install" to your GeographicLib path
- In the path c++/, run "make" and you can generate a "main" excutable file in the path c++/
- To solve the problem PASO, run "./main source-id(1-22) sinck-id(1-22) T", e.g., run the program with source node 1 and sink node 2 and deadline 10 hours
~~~
./main 1 2 10
~~~
The output solutions will be stored in the result/T800 folder
- Make all bash scripts to be excutable
~~~
chmod +x *.sh
~~~
- To generate html file to display the path information in the browser, run "./get_show_path_html.sh source-id(1-22) sinck-id(1-22) T", e.g.,
~~~
./get_show_path_html.sh 1 2 10
~~~
The output html file will be stored in the html/T800 folder
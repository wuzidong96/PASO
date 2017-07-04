#! /bin/awk -f
# ./get_40_regions_nodes.awk node_info.csv
# print will output with an ORS after each statement
# print will output with an OFS in the same statement for more than one items, such as print $1, $2
# printf will not be influenced by ORS and OFS. You should output ORS and OFS explicitly, such as, printf $0; printf "\n";
# printf deals with user-specified output format, acts like ISO C's printf function, such as, printf "%s,%s\n", "foo", "bar"
	
BEGIN {
	RS="\n"; FS=","; ORS="\n"; OFS=" "; 
    #central points coordinates, 40-element array
    
    #get the five central lat and lon
	lat1 = (50.0+45.0)/2.0;
	lat2 = (45.0+40.0)/2.0;
	lat3 = (40.0+35.0)/2.0;
	lat4 = (35.0+30.0)/2.0;
	lat5 = (30.0+25.0)/2.0;

	lon1 = (-125.0-120.0)/2.0;
	lon2 = (-120.0-115.0)/2.0;
	lon3 = (-115.0-110.0)/2.0;
	lon4 = (-110.0-105.0)/2.0;
	lon5 = (-105.0-100.0)/2.0;
	lon6 = (-100.0-95.0)/2.0;
	lon7 = (-95.0-90.0)/2.0;
	lon8 = (-90.0-85.0)/2.0;
	lon9 = (-85.0-80.0)/2.0;
	lon10 = (-80.0-75.0)/2.0;
	lon11 = (-75.0-70.0)/2.0;

	central_lats[1]= lat1;
	central_lats[2]= lat2;
	central_lats[3]= lat3;
	central_lats[4]= lat1;
	central_lats[5]= lat2;
	central_lats[6]= lat3;
	central_lats[7]= lat4;
	central_lats[8]= lat1;
	central_lats[9]= lat2;
	central_lats[10]= lat3;
	central_lats[11]= lat4;
	central_lats[12]= lat1;
	central_lats[13]= lat2;
	central_lats[14]= lat3;
	central_lats[15]= lat4;
	central_lats[16]= lat1;
	central_lats[17]= lat2;
	central_lats[18]= lat3;
	central_lats[19]= lat4;
	central_lats[20]= lat1;
	central_lats[21]= lat2;
	central_lats[22]= lat3;
	central_lats[23]= lat4;
	central_lats[24]= lat5;
	central_lats[25]= lat1;
	central_lats[26]= lat2;
	central_lats[27]= lat3;
	central_lats[28]= lat4;
	central_lats[29]= lat1;
	central_lats[30]= lat2;
	central_lats[31]= lat3;
	central_lats[32]= lat4;
	central_lats[33]= lat2;
	central_lats[34]= lat3;
	central_lats[35]= lat4;
	central_lats[36]= lat5;
	central_lats[37]= lat2;
	central_lats[38]= lat3;
	central_lats[39]= lat4;
	central_lats[40]= lat2;
  
  
	central_lons[1]= lon1;
	central_lons[2]= lon1;
	central_lons[3]= lon1;
	central_lons[4]= lon2;
	central_lons[5]= lon2;
	central_lons[6]= lon2;
	central_lons[7]= lon2;
	central_lons[8]= lon3;
	central_lons[9]= lon3;
	central_lons[10]= lon3;
	central_lons[11]= lon3;
	central_lons[12]= lon4;
	central_lons[13]= lon4;
	central_lons[14]= lon4;
	central_lons[15]= lon4;
	central_lons[16]= lon5;
	central_lons[17]= lon5;
	central_lons[18]= lon5;
	central_lons[19]= lon5;
	central_lons[20]= lon6;
	central_lons[21]= lon6;
	central_lons[22]= lon6;
	central_lons[23]= lon6;
	central_lons[24]= lon6;
	central_lons[25]= lon7;
	central_lons[26]= lon7;
	central_lons[27]= lon7;
	central_lons[28]= lon7;
	central_lons[29]= lon8;
	central_lons[30]= lon8;
	central_lons[31]= lon8;
	central_lons[32]= lon8;
	central_lons[33]= lon9;
	central_lons[34]= lon9;
	central_lons[35]= lon9;
	central_lons[36]= lon9;
	central_lons[37]= lon10;
	central_lons[38]= lon10;
	central_lons[39]= lon10;
	central_lons[40]= lon11;
    
    #initial arrays nodes, nodes_lat, nodes_lon, dists
    for(i=1; i <= 40; i++)
    {
        nodes[i] = -1;
        nodes_lat[i] = 0;
        nodes_lon[i] = 0;
        dists[i] = 1e20;
    }
    
    #print initial information
    for(i=1; i <= 40; i++)
    {
        #print i, nodes[i], nodes_lat[i], nodes_lon[i], dists[i], central_lats[i], central_lons[i]
    }
}

{
    if(NR > 1)
    {
        for(i in central_lats)
        {
            #print $0;
            #print i
            new_lat = $2;
            new_lon = $3;
            #print $2, $3;
            new_dist = (new_lat - central_lats[i])^2 + (new_lon - central_lons[i])^2
            if(new_dist < dists[i])
            {
                nodes[i]=$1;
                nodes_lat[i] = new_lat;
                nodes_lon[i] = new_lon;
                dists[i] = new_dist;                
            }
        }
    }
}

END {
	for( i=1; i<= 40; i++)
    {
        print i, nodes[i], nodes_lat[i], nodes_lon[i]
    }
}


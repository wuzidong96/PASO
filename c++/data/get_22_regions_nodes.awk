#! /bin/awk -f
# print will output with an ORS after each statement
# print will output with an OFS in the same statement for more than one items, such as print $1, $2
# printf will not be influenced by ORS and OFS. You should output ORS and OFS explicitly, such as, printf $0; printf "\n";
# printf deals with user-specified output format, acts like ISO C's printf function, such as, printf "%s,%s\n", "foo", "bar"
	
BEGIN {
	RS="\n"; FS=","; ORS="\n"; OFS=" "; 
    #central points coordinates, 22-element array
    
    #get the five central lat and lon
    lat1 = (50.0+45.0)/2.0;
    lat2 = (45.0+40.0)/2.0;
    lat3 = (40.0+35.0)/2.0;
    lat4 = (35.0+30.0)/2.0;
    lat5 = (30.0+25.0)/2.0;
    
    lon1 = (-100.0-95.0)/2.0;
    lon2 = (-95.0-90.0)/2.0;
    lon3 = (-90.0-85.0)/2.0;
    lon4 = (-85.0-80.0)/2.0;
    lon5 = (-80.0-75.0)/2.0;
    lon6 = (-75.0-70.0)/2.0;
    
    central_lats[1]= lat1;
    central_lats[2]= lat2;
    central_lats[3]= lat3;
    central_lats[4]= lat4;
    central_lats[5]= lat5;
    central_lats[6]= lat1;
    central_lats[7]= lat2;
    central_lats[8]= lat3;
    central_lats[9]= lat4;
    central_lats[10]= lat5;
    central_lats[11]= lat1;
    central_lats[12]= lat2;
    central_lats[13]= lat3;
    central_lats[14]= lat4;
    central_lats[15]= lat2;
    central_lats[16]= lat3;
    central_lats[17]= lat4;
    central_lats[18]= lat5;
    central_lats[19]= lat2;
    central_lats[20]= lat3;
    central_lats[21]= lat4;
    central_lats[22]= lat2;    
    
    central_lons[1]= lon1;
    central_lons[2]= lon1;
    central_lons[3]= lon1;
    central_lons[4]= lon1;
    central_lons[5]= lon1;
    central_lons[6]= lon2;
    central_lons[7]= lon2;
    central_lons[8]= lon2;
    central_lons[9]= lon2;
    central_lons[10]= lon2;
    central_lons[11]= lon3;
    central_lons[12]= lon3;
    central_lons[13]= lon3;
    central_lons[14]= lon3;
    central_lons[15]= lon4;
    central_lons[16]= lon4;
    central_lons[17]= lon4;
    central_lons[18]= lon4;
    central_lons[19]= lon5;
    central_lons[20]= lon5;
    central_lons[21]= lon5;
    central_lons[22]= lon6;
    
    #initial arrays nodes, nodes_lat, nodes_lon, dists
    for(i=1; i <= 22; i++)
    {
        nodes[i] = -1;
        nodes_lat[i] = 0;
        nodes_lon[i] = 0;
        dists[i] = 1e20;
    }
    
    #print initial information
    for(i=1; i <= 22; i++)
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
	for( i=1; i<= 22; i++)
    {
        print i, nodes[i], nodes_lat[i], nodes_lon[i]
    }
}


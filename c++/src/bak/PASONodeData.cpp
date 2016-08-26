#include "PASONodeData.h"
#include <string>
#undef min  //remember to undef min
#undef max
#include <iostream>
#include "Snap.h"


PASONodeData::PASONodeData()
: lat_(0), lon_(0), ele_(0) 
{    
}

PASONodeData::PASONodeData(double lat, 
                           double lon, 
                           double ele,
                           std::string label)
{
    if( lon < -180 ||
        lon > 180 ||
        lat < -90 ||
        lat > 90 )
    {
        std::cout << "error longitude/latitude" << std::endl; 
        exit(-1);
    }
    lat_ = lat;
    lon_ = lon;
    ele_ = ele;
    label_ = label;
}


PASONodeData::PASONodeData(TSIn& SIn)
{
}


void PASONodeData::Save(TSOut& SOut) const
{
}

std::ostream& operator << (std::ostream& os, const PASONodeData& n)
{
    os << "(lat,lon,x,y,ele,label)=("
       << n.lat_ << ","
       << n.lon_ << ","
       << n.ele_ << ","
       << n.label_ << ")"
       << std::endl;
    return os;
}
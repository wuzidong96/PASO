#ifndef _PASO_NODE_DATA_H
#define _PASO_NODE_DATA_H

#include <string>
#include "Snap.h"

class PASONodeData
{
    public:
    
    ///required by SNAP
    PASONodeData();
    
    PASONodeData(double lon, 
                 double lat, 
                 double x, 
                 double y,
                 double ele,
                 std::string label);
                 
    ///required by SNAP
    PASONodeData(TSIn& SIn);
    ///required by SNAP
    void Save(TSOut& SOut) const;
    
    friend std::ostream& operator << (std::ostream& os, const PASONodeData& n);
    
    double getLat() const {return lat_;};
    double getLon() const {return lon_;};
    double getX() const {return x_;};
    double getY() const {return y_;};
    double getEle() const {return ele_;};
    std::string getLabel() const {return label_;};
    
    void setLat(double lat) {lat_ = lat;}
    void setLon(double lon) {lon_ = lon;}
    void setX(double x) {x_ = x;}
    void setY(double y) {y_ = y;}
    void setEle(double ele) {ele_ = ele;}
    void setLabel(const std::string& label) {label_ = label;}
    
    private:
    
    ///latitude, in decimal degrees, range in [-90, 90]
    double lat_;   
    ///longitude, in decimal degrees, range in [-180, 180] 
    double lon_;
    ///UTM easting in meters
    double x_;
    ///UTM northing in meters
    double y_;
    ///elevation, in meters
    double ele_;
    ///label, e.g., HI11/HI19
    std::string label_;
};

#endif


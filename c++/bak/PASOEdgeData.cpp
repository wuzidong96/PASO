#include <string>
#include "PASOEdgeData.h"
#include "Snap.h"
#undef min
#undef max
#include <iostream>

PASOEdgeData::PASOEdgeData()
:src_(0), des_(0), distance_(0), speed_min_(0), speed_max_(0), time_min_(0), time_max_(0),
grade_(0), coef_a_(0), coef_b_(0), coef_c_(0), coef_d_(0)
{    
}

PASOEdgeData::PASOEdgeData(int src,
                           int des,
                           double distance,
                           double speed_min,
                           double speed_max,
                           double time_min,
                           double time_max,
                           double grade,
                           double coef_a,
                           double coef_b,
                           double coef_c,
                           double coef_d,
                           std::string label)
{
    src_ = src;
    des_ = des;
    distance_ = distance;
    speed_min_ = speed_min;
    speed_max_ = speed_max;
    time_min_ = time_min;
    time_max_ = time_max;
    grade_ = grade;
    coef_a_ = coef_a;
    coef_b_ = coef_b; 
    coef_c_ = coef_c;
    coef_d_ = coef_d;
    label_ = label;
}
                               

PASOEdgeData::PASOEdgeData(TSIn& SIn)
{
}

bool operator == (const PASOEdgeData& e1, const PASOEdgeData& e2)
{
    return ( (e1.src_ == e2.src_) &&  (e1.des_ == e2.des_) );
}

///lexicographical compare src_ and des_ 
bool operator < (const PASOEdgeData& e1, const PASOEdgeData& e2)
{
    if( e1.src_ < e2.src_)
    {
        return true;
    }
    else if( e1.src_ == e2.src_)
    {
        return (e1.des_ < e2.des_);
    }
    else
    {
        return false;
    }
}

std::ostream& operator << (std::ostream& os, const PASOEdgeData& e)
{
    os << "(src,des,distance,speed_min,speed_max,time_min,time_max,grade,coef_a,coef_b,coef_c,coef_d,label)=("
    << e.src_ << ","
    << e.des_ << ","
    << e.distance_ << ","
    << e.speed_min_ << ","
    << e.speed_max_ << ","
    << e.time_min_ << ","
    << e.time_max_ << ","
    << e.grade_ << ","
    << e.coef_a_ << ","
    << e.coef_b_ << ","
    << e.coef_c_ << ","
    << e.coef_d_ << ","
    << e.label_ << ")"
    << std::endl;
    return os;
}
    
    
void PASOEdgeData::Save(TSOut& SOut) const
{
}
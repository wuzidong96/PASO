#ifndef _PASO_EDGE_DATA_H
#define _PASO_EDGE_DATA_H

#include <string>
#include "Snap.h"
#undef min
#undef max
#include <iostream>

class PASOEdgeData
{
    public:
    
    ///required by SNAP
    PASOEdgeData();
    
    PASOEdgeData(bool valid,
                 int src,
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
                 std::string label);
                 
    ///required by SNAP
    PASOEdgeData(TSIn& SIn);
    ///required by SNAP
    void Save(TSOut& SOut) const;
    
    friend bool operator==(const PASOEdgeData& e1, const PASOEdgeData& e2);
    friend bool operator<(const PASOEdgeData& e1, const PASOEdgeData& e2);
    friend std::ostream& operator << (std::ostream& os, const PASOEdgeData& e);
    
    bool isValid() const {return valid_;}    
    int getSrc() const {return src_;}
    int getDes() const {return des_;}
    double getDistance() const {return distance_;}
    double getSpeedMin() const {return speed_min_;}
    double getSpeedMax() const {return speed_max_;}
    double getTimeMin() const {return time_min_;}
    double getTimeMax() const {return time_max_;}
    double getGrade() const {return grade_;}
    double getCoefA() const {return coef_a_;}
    double getCoefB() const {return coef_b_;}
    double getCoefC() const {return coef_c_;}
    double getCoefD() const {return coef_d_;}
    std::string getLabel() const {return label_;}
    
    void setValid(bool valid) {valid_ = valid;}
    void setSrc(int src) {src_ = src;}
    void setDes(int des) {des_ = des;}
    void setDistance(double distance) {distance_ = distance;}
    void setSpeedMin(double speed_min) {speed_min_ = speed_min;}
    void setSpeedMax(double speed_max) {speed_max_ = speed_max;}
    void setTimeMin(double time_min) {time_min_ = time_min;}
    void setTimeMax(double time_max) {time_max_ = time_max;}
    void setGrade(double grade) {grade_ = grade;}
    void setCoefA(double coef_a) {coef_a_ = coef_a;}
    void setCoefB(double coef_b) {coef_b_ = coef_b;}
    void setCoefC(double coef_c) {coef_c_ = coef_c;}
    void setCoefD(double coef_d) {coef_d_ = coef_d;}
    void setLabel(const std::string& label) {label_ = label;}
    
    private:
    ///true if the edge is valid, e.g., all parameters are valid
    bool valid_;
    ///source node index
    int src_;
    ///destination node index
    int des_;
    ///distance, in miles
    double distance_;
    ///minimal speed, in miles per hour
    double speed_min_;
    ///maximal speed, in miles per hour
    double speed_max_;
    ///minimal travel time, in hours
    double time_min_;
    ///maximal travel time, in hours
    double time_max_;
    ///grade, in percentages, e.g. grade_=1.0 means 1.0% grade
    double grade_;
    ///coef a fuel-speed function f(x) = ax^3+bx^2+cx+d
    double coef_a_;
    ///coef b fuel-speed function f(x) = ax^3+bx^2+cx+d
    double coef_b_;
    ///coef c fuel-speed function f(x) = ax^3+bx^2+cx+d
    double coef_c_;
    ///coef d fuel-speed function f(x) = ax^3+bx^2+cx+d
    double coef_d_;
    ///label, e.g., HI460
    std::string label_;
};

#endif
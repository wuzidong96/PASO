#ifndef _PASO_EDGE_DATA_H
#define _PASO_EDGE_DATA_H

#include <string>
#include "Snap.h"
#undef min
#undef max
#include <iostream>
#include <vector>
#include <cmath>
#include <limits>

class PASOEdgeData
{
    public:
    
    ///a 
    enum SpeedFunType  
    { 
        GPH,  //f(x) is gallons per hour 
        GP100M //g(x) is gallons per 100 miles
    }; 
    
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
                 std::string label,
                 SpeedFunType type);
                 
    ///required by SNAP
    PASOEdgeData(TSIn& SIn);
    ///required by SNAP
    void Save(TSOut& SOut) const;
    
    friend bool operator==(const PASOEdgeData& e1, const PASOEdgeData& e2);
    friend bool operator<(const PASOEdgeData& e1, const PASOEdgeData& e2);
    ///merge two edges into one edge
    ///return a valid edge when adding (u,v) + (v,w) where u != w, (u,v)+(v,w)=(u,w),
    ///and when  type(u,v) = type(v,w) and grade_key(u,v) = grade_key(v,w) (this makes us average coefs)
    ///the distance/coef/label will be added, the grade/min speed/max speed will be averaged 
    friend PASOEdgeData operator + (const PASOEdgeData& e1, const PASOEdgeData& e2);
    
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
    int getGradeKey() const {return grade_key_;}
    double getCoefA() const {return coef_a_;}
    double getCoefB() const {return coef_b_;}
    double getCoefC() const {return coef_c_;}
    double getCoefD() const {return coef_d_;}
    std::string getLabel() const {return label_;}
    SpeedFunType getSpeedFunType() const {return type_;}
    const std::vector<int>& getQuantizedValue() const {return quantized_value_;}
    const std::vector<double>& getRepresentativeTime() const {return representative_time_;}
    
    void setValid(bool valid) {valid_ = valid;}
    void setSrc(int src) {src_ = src;}
    void setDes(int des) {des_ = des;}
    void setDistance(double distance) {distance_ = distance;}
    void setSpeedMin(double speed_min) {speed_min_ = speed_min;}
    void setSpeedMax(double speed_max) {speed_max_ = speed_max;}
    void setTimeMin(double time_min) {time_min_ = time_min;}
    void setTimeMax(double time_max) {time_max_ = time_max;}
    void setGrade(double grade) {grade_ = grade; updateGradeKey();}
    void setCoefA(double coef_a) {coef_a_ = coef_a;}
    void setCoefB(double coef_b) {coef_b_ = coef_b;}
    void setCoefC(double coef_c) {coef_c_ = coef_c;}
    void setCoefD(double coef_d) {coef_d_ = coef_d;}
    void setLabel(const std::string& label) {label_ = label;}
    void setSpeedFunType(SpeedFunType type) {type_ = type;}
    
    ///update speed is not like set speed. When we update the speed, we also need to update the 
    ///corresponding other-end speed and travel time.
    void updateSpeedMin(double speed_min);
    void updateSpeedMax(double speed_max);
    
    ///update speed limit such that f(x) is increasing over [speed_min_, speed_max_] and
    ///c(t) is decreasing over [time_min_, time_max_]
    ///@NOTE this only works once we have got all coefs.
    ///@NOTE time limit should be updated accordingly
    ///@NOTE we will set this edge to be invalid if the parameters are bad
    int updateSpeedLimits();
    double fuelTimeFun(double time) const;
    double fuelTimeFunD1(double time) const;
    double fuelTimeFunD2(double time) const;
    bool isFuelTimeFunDecrasing() const;
    /// h(t) = c(t) + lambda*t
    /// h'(t) = c'(t) + lambda
    /// find a t in [time_min, time_max] to minimize h(t)
    double bestTravelTimeGivenLambda(double lambda, double tol = 1e-6) const;
    
    ///find the minimal lambda such that the bestTravelTimeGivenLambda is time_min
    double minimalLambda() const;
    
    ///return h(t) = c(t)+lambda*t, where t is the best travel time
    double newWeightGivenLambda(double lambda) const;
    
    ///sanity-check functions
    bool isSpeedTimeConsistent() const;
    
    ///quantize the fuel time fun according to the level size V
    ///and number of levels N.
    //@NOTE  It will update quantized_value_ and representative_time_!
    int quantizeFuelTimeFun(double V, 
                            int N);
                            
    void printQuantizedValueAndRepresentativeTime();                    
    ///some internal functions
    private: 
    
    ///set grade key here, we can quantize here
    ///grade_key is from -90 to 90, i.e., 
    ///-90 -89 -88 -87 ..., 0, 1, 2, 3, 4,
    void updateGradeKey();
    ///fuel-rate-speed functions f(x) = ax^3 + bx^2 + cx + d
    /// x is speed in mph, f(x) is fuel rate in gph
    ///to make it convex, we should have f''(x) = 6ax + 2b > 0, i.e.,
    /// if a > 0, then x > -b/3a (set min speed)
    /// if a < 0, then x < -b/3a (set max speed)
    double gphSpeedFun(double speed) const;
    /// first-order derivative f'(x) = 3ax^2+2bx+c
    double gphSpeedFunD1(double speed) const;
    /// second-order derivative f''(x) = 6ax + 2b
    double gphSpeedFunD2(double speed) const;
    ///f(x)-based fuel-time functions c(t) = t f(D/t) = aD^3/t^2 + bD^2/t + cD + dt
    /// t is travel time in hours, c(t) is the total fuel consumption in gallons
    double gphFuelTimeFun(double time) const;
    ///first-order derivative c'(t) = -2aD^3/t^3 - bD^2/t^2 + d
    double gphFuelTimeFunD1(double time) const;
    ///second-order derivative c''(t) = 6aD^3/t^4 + 2bD^2/t^3 
    double gphFuelTimeFunD2(double time) const;
    ///update speed limit such that f(x) is increasing over [speed_min_, speed_max_] and
    ///c(t) is decreasing over [time_min_, time_max_]
    ///@NOTE this only works once we have got all coefs.
    ///@NOTE time limit should be updated accordingly
    ///@NOTE we will set this edge to be invalid if the parameters are bad
    int updateGphSpeedLimits();
    
    ///fuel-rate-speed functions g(x) = ax^3 + bx^2 + cx +d
    /// x is speed in mph, g(x) is the fuel rate in gallons per 100 miles
    double gp100mSpeedFun(double speed) const;
    ///first-order derivative g'(x)=3ax^2 + 2bx + c
    double gp100mSpeedFunD1(double speed) const;
    ///second-order derivative g''(x) = 6ax + 2b
    double gp100mSpeedFunD2(double speed) const;
    ///g(x)-based fuel-time functions c(t) = (D/100)*f(D/t) = (D/100)*(aD^3/t^3 + bD^2/t^2 + cD/t + dt)
    /// t is travel time in hours, c(t) is the total fuel consumption in gallons
    double gp100mFuelTimeFun(double time) const;
    ///first-order derivative c'(t) = (D/100)*(-3aD^3/t^4 - 2bD^3/t^3 - cD/t^2 + d)
    double gp100mFuelTimeFunD1(double time) const;
    ///second-order derivative c''(t) = (D/100)*(12aD^3/t^5 + 6bD^3/t^4 + 2cD/t^3) 
    double gp100mFuelTimeFunD2(double time) const;
    ///update speed limit such that f(x) is increasing over [speed_min_, speed_max_] and
    ///c(t) is decreasing over [time_min_, time_max_]
    ///@NOTE this only works once we have got all coefs.
    ///@NOTE time limit should be updated accordingly
    ///@NOTE we will set this edge to be invalid if the parameters are bad
    int updateGp100mSpeedLimits();
 
    ///sanity-check functions
    bool isGphSpeedFunIncreasing() const;
    bool isGphFuelTimeFunDecreasing() const;
    bool isGp100mSpeedFunIncreasing() const;
    bool isGp100mFuelTimeFunDecrasing() const;
    
    ///at the current stage, let us forget the convexity.
    ///So we only have the interface but do not need to implement them
    bool isGphSpeedFunConvex() const;
    bool isGphFuelTimeFunConvex() const;
    bool isGp100mSpeedFunConvex() const;
    bool isGp100mFuelTimeFunConvex() const;
    
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
    ///grade_key, integer, std::floor(grade*10+0.5),
    //e.g. grade_=1.0, then grade_key_ = 10
    //e.g. grade_k=1.67, then grade_key_ = 17
    //@note, it will always set according to grade
    int grade_key_;
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
    ///speed function type, either GPH or GP100M
    SpeedFunType type_;
    ///the following two vectors are only useful during the test procedure and it will keep updating
    ///during the procedure. Don't use them otherwise!
    ///quantized_values is an int vector, e.g., quantized_values_[i] = j, means the i-th non-nan quantized value is integer j
    ///representative_time_ is the corresponding time vector. e.g., representative_time_[i] is the corresponding
    ///travel time such that the i-th quantized value is quantized_values_[i] 
    std::vector<int> quantized_value_;
    std::vector<double> representative_time_;
};

#endif
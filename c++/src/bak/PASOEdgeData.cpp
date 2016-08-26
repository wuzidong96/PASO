#include <string>
#include "PASOEdgeData.h"
#include "Snap.h"
#undef min
#undef max
#include <iostream>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <limits>

PASOEdgeData::PASOEdgeData()
:valid_(false), src_(0), des_(0), distance_(0), speed_min_(0), speed_max_(0), 
time_min_(0), time_max_(0), grade_(0), coef_a_(0), coef_b_(0), coef_c_(0), coef_d_(0), type_(GPH)
{    
}

PASOEdgeData::PASOEdgeData(bool valid,
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
                           SpeedFunType type)
{
    valid_ = valid;
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
    type_ = type;
    //set grade_key
    updateGradeKey();
}
                               

PASOEdgeData::PASOEdgeData(TSIn& SIn)
{
}

bool 
operator == (const PASOEdgeData& e1, const PASOEdgeData& e2)
{
    return ( (e1.src_ == e2.src_) &&  (e1.des_ == e2.des_) );
}

///lexicographical compare src_ and des_ 
bool 
operator < (const PASOEdgeData& e1, const PASOEdgeData& e2)
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

std::ostream& 
operator << (std::ostream& os, const PASOEdgeData& e)
{
    os << "(valid,src,des,distance,speed_min,speed_max,time_min,time_max,grade,grade_key,coef_a,coef_b,coef_c,coef_d,label,type)=("
    << e.valid_ << ","
    << e.src_ << ","
    << e.des_ << ","
    << e.distance_ << ","
    << e.speed_min_ << ","
    << e.speed_max_ << ","
    << e.time_min_ << ","
    << e.time_max_ << ","
    << e.grade_ << ","
    << e.grade_key_ << ","
    << e.coef_a_ << ","
    << e.coef_b_ << ","
    << e.coef_c_ << ","
    << e.coef_d_ << ","
    << e.label_ << ","
    << e.type_ << ")"
    << std::endl;
    return os;
}
    
PASOEdgeData operator + (const PASOEdgeData& e1, const PASOEdgeData& e2)
{
    PASOEdgeData e;
    e.setValid(false);
    int src1 = e1.getSrc();
    int des1 = e1.getDes();
    int src2 = e2.getSrc();
    int des2 = e2.getDes();
    if(e1.isValid() &&
       e2.isValid() &&
       src1 != des2 && 
       des1 == src2 &&
       e1.getGradeKey() == e2.getGradeKey() &&
       e1.getSpeedFunType() == e2.getSpeedFunType())
    {
        int src = src1;
        int des = des2;
        double distance = e1.getDistance() + e2.getDistance();
        double speed_min = (e1.getSpeedMin() + e2.getSpeedMin())/2.0;
        double speed_max = (e1.getSpeedMax() + e2.getSpeedMax())/2.0;
        double time_min = distance/speed_max;
        double time_max = distance/speed_min;
        double grade = (e1.getGrade() + e2.getGrade())/2.0;
        double coef_a = (e1.getCoefA() + e2.getCoefA())/2.0;
        double coef_b = (e1.getCoefB() + e2.getCoefB())/2.0;
        double coef_c = (e1.getCoefC() + e2.getCoefC())/2.0;
        double coef_d = (e1.getCoefD() + e2.getCoefD())/2.0;
        std::string label = e1.getLabel() + ':' + e2.getLabel();
        PASOEdgeData::SpeedFunType type = e1.getSpeedFunType();
        e = PASOEdgeData(true, src, des, distance, speed_min, speed_max, time_min, time_max, grade,
                         coef_a, coef_b, coef_c, coef_d, label, type);
    }
    return e;
}
    
void 
PASOEdgeData::Save(TSOut& SOut) const
{
}

///set grade key here, we can quantize here
///grade_key is from -90 to 90, i.e., 
///-90 -89 -88 -87 ..., 0, 1, 2, 3, 4,...
///if span = 2, they changed to
///-90 -88 -88 -86 ..., 0, 0, 1, 1, 2,...
void PASOEdgeData::updateGradeKey() 
{
    grade_key_ = std::floor(grade_*10+0.5);
    int span = 5;
    grade_key_ = span*(grade_key_/span);
};

double 
PASOEdgeData::fuelTimeFun(double time) const
{
    if(type_ == GPH)
    {
        return gphFuelTimeFun(time);
    }
    else if(type_ == GP100M)
    {
        return gp100mFuelTimeFun(time);
    }
    //just to make compiler happy
    return -1;
}

double 
PASOEdgeData::fuelTimeFunD1(double time) const
{
    if(type_ == GPH)
    {
        return gphFuelTimeFunD1(time);
    }
    else if(type_ == GP100M)
    {
        return gp100mFuelTimeFunD1(time);
    }
    //just to make compiler happy
    return -1;
}

double 
PASOEdgeData::fuelTimeFunD2(double time) const
{
    if(type_ == GPH)
    {
        return gphFuelTimeFunD2(time);
    }
    else if(type_ == GP100M)
    {
        return gp100mFuelTimeFunD2(time);
    }
    //just to make compiler happy
    return -1;
}

bool
PASOEdgeData::isFuelTimeFunDecrasing() const
{
    if(type_ == GPH)
    {
        return isGphFuelTimeFunDecreasing();
    }
    else if(type_ == GP100M)
    {
        return isGp100mFuelTimeFunDecrasing();
    }
    //just to make compiler happy
    return false;
}

int
PASOEdgeData::updateSpeedLimits()
{
    if(type_ == GPH)
    {
        updateGphSpeedLimits();
    }
    else if(type_ == GP100M)
    {
        updateGp100mSpeedLimits();
    }
    else
    {
        return -1;
    }
    return 0;
}


/// h(t) = c(t) + lambda*t
/// h'(t) = c'(t) + lambda
/// find a t in [time_min, time_max] to minimize h(t)
double 
PASOEdgeData::bestTravelTimeGivenLambda(double lambda, double tol) const
{
    double d1 = gp100mFuelTimeFunD1(time_min_) + lambda;
    double d2 = gp100mFuelTimeFunD1(time_max_) + lambda;
    if(d1 <= tol && d2 <= tol) //both d1, d2 <= 0
    {
        return time_max_;
    }
    if(d1 >= -tol && d2 >= -tol) //both d1, d2 >= 0
    {
        return time_min_;
    }
    
    if(d1 > -tol && d2 < tol) // d1 > 0, d2 < 0
    {
        std::cout << "impossible, c(t) is not convex, but let us still return time_max_" << std::endl;
        return time_max_; 
    }
    
    ///d1 < 0, d2 > 0, we need to do binary search such that d = h'(t) = 0
    double t_min = time_min_;
    double t_max = time_max_;
    ///begin at any one side
    double t = t_min;
    double d = d1;
    ///do not use std::fabs, which will convert double to float!!
    int max_iter = 40;
    int iter = 0;
    while(std::abs(d) > tol && iter <= max_iter)
    {
        iter++;
        if(d > tol)
        {
            t_max = t;
        }
        else if(d < -tol)
        {
            t_min = t;
        }
        t = (t_min + t_max)/2.0;
        d = gp100mFuelTimeFunD1(t) + lambda;
    }
    
    return t;
}

double
PASOEdgeData::minimalLambda() const
{
    double val = fuelTimeFunD1(time_min_);
    return -val;
}

double 
PASOEdgeData::newWeightGivenLambda(double lambda) const
{
    double time = bestTravelTimeGivenLambda(lambda);
    double new_weight = 0;
    new_weight += gp100mFuelTimeFun(time);
    new_weight += lambda*time;
    return new_weight;
}


void 
PASOEdgeData::updateSpeedMin(double speed_min) 
{
    speed_min_ = speed_min; 
    speed_max_ = std::max(speed_min_, speed_max_);
    time_min_ = distance_/speed_max_;
    time_max_ = distance_/speed_min_;
}

void 
PASOEdgeData::updateSpeedMax(double speed_max) 
{
    speed_max_ = speed_max; 
    speed_min_ = std::min(speed_min_, speed_max_);
    time_min_ = distance_/speed_max_;
    time_max_ = distance_/speed_min_;
}


bool 
PASOEdgeData::isSpeedTimeConsistent() const
{
    double eps = 1e-10;
    return (speed_min_ <= speed_max_ + eps &&
            std::abs(speed_min_*time_max_ - distance_) <= eps &&
            std::abs(speed_max_*time_min_ - distance_) <= eps);
}


int 
PASOEdgeData::quantizeFuelTimeFun(double V, 
                                  int N)
{
    quantized_value_.clear();
    representative_time_.clear();
    double tol = 1e-3;
    for(int i=1; i <= N; i++)
    {
        //find a time t such that c(t) = (i+1)V
        double t1 = time_min_;
        double t2 = time_max_;
        if(fuelTimeFun(t1) < i*V - tol)
        {
            //does not have such time, don't store and skip
            continue;
        }
        if(fuelTimeFun(t2) > i*V + tol)
        {
            //does not have such time, don't store and skip
            continue;
        }
        //binary search to get t
        double t = (t1+t2)/2.0;
        int max_iter = 40;
        int iter = 0;
        double c = fuelTimeFun(t);
        while(std::abs(c-i*V) > tol
           && std::abs(t1-t2) > tol        
           && iter <= max_iter)
        {
            iter++;
            if(c > i*V + tol)
            {
                t1 = t;
            }
            if(c < i*V - tol)
            {
                t2 = t;
            }
            t = (t1+t2)/2.0;
            c = fuelTimeFun(t);
        }
        quantized_value_.push_back(i);
        representative_time_.push_back(t);
    }
    return 0;
}

void
PASOEdgeData::printQuantizedValueAndRepresentativeTime()
{
    for(int i=0; i < quantized_value_.size(); i++)
    {
        std::cout << "(" << quantized_value_[i] << "," << representative_time_[i] << "),";
    }
    std::cout << std::endl;
}

/******************************** internal gph function family ***********************/
double 
PASOEdgeData::gphSpeedFun(double speed) const
{
    double val = coef_a_*std::pow(speed, 3.0) 
               + coef_b_*std::pow(speed, 2.0)
               + coef_c_*speed
               + coef_d_;
    return val;
}

double 
PASOEdgeData::gphSpeedFunD1(double speed) const
{
    double val = 3.0*coef_a_*std::pow(speed, 2.0) 
               + 2.0*coef_b_*speed
               + coef_c_;
    return val;
}

double 
PASOEdgeData::gphSpeedFunD2(double speed) const
{
    double val = 6.0*coef_a_*speed 
               + 2.0*coef_b_;    
    return val;
}

double 
PASOEdgeData::gphFuelTimeFun(double time) const
{
    double val = coef_a_*std::pow(distance_, 3.0)*std::pow(time, -2.0)
                  + coef_b_*std::pow(distance_, 2.0)/time
                  + coef_c_*distance_
                  + coef_d_*time;
    return val;
}

double 
PASOEdgeData::gphFuelTimeFunD1(double time) const
{    
    double val = -2.0*coef_a_*std::pow(distance_, 3.0)*std::pow(time, -3.0)
                     -  coef_b_*std::pow(distance_, 2.0)*std::pow(time, -2.0)
                     + coef_d_;
    return val;
}

double 
PASOEdgeData::gphFuelTimeFunD2(double time) const
{
    double val = 6.0*coef_a_*std::pow(distance_, 3.0)*std::pow(time, -4.0)
                     + 2.0*coef_b_*std::pow(distance_, 2.0)*std::pow(time, -3.0);
    return val;
}


bool
PASOEdgeData::isGphSpeedFunIncreasing() const
{
    double speed_min_d1 = gphSpeedFunD1(speed_min_);
    double speed_max_d1 = gphSpeedFunD1(speed_max_);
    return ((speed_min_d1 >= -1e-10) &&  (speed_max_d1 >= -1e-10));
}

bool
PASOEdgeData::isGphFuelTimeFunDecreasing() const
{
    double time_min_d1 = gphFuelTimeFunD1(time_min_);
    double time_max_d1 = gphFuelTimeFunD1(time_max_);
    return ((time_min_d1 <= -1e-10) &&  (time_max_d1 <= 1e-10));
}

int
PASOEdgeData::updateGphSpeedLimits() 
{
    ///we only update for valid edges (with valid parameters)
    if(!isValid())
    {
        return -1;
    }
    
    ///update speed limits such that f(x)=ax^3+bx^2+cx+d is convex
    //i.e., if a > 0, let x > -b/3a;
    // if a < 0, let x < -b/3a
    double x = -coef_b_/(3.0*coef_a_);
    if(coef_a_ > 0.0) // a > 0
    {
        updateSpeedMin(std::max(x,speed_min_));
    }
    else //a < 0 
    {
        if(x < 0)
        {
            valid_ = false;
            return -1;
        }
        else
        {
            updateSpeedMax(std::min(x,speed_max_));
        }        
    }
    
    ///update such that c(t) is decreasing over [time_min_, time_max_]
    double tol = 1e-10;
    double d1 = gphFuelTimeFunD1(time_min_);
    double d2 = gphFuelTimeFunD1(time_max_);
    if(d1 <= tol && d2 <= tol) //already in the decreasing region
    {
        return 0;
    }
    
    if(d1 >= -tol && d2 >= -tol) // in the increasing region
    {
        //update min speed to be max speed
        updateSpeedMin(speed_max_);
        return 0;
    }
    // d1 < 0 and d2 > 0, let us binary search to get the optimal time t 
    double t1 = time_min_;
    double t2 = time_max_;
    double t = t1;
    //use the first order derivative
    double d = gphFuelTimeFunD1(t);
    ///do not use std::fabs, which will convert double to float!!
    int max_iter = 40;
    int iter = 0;
    while(std::abs(d) > tol && iter <= max_iter)
    {
        iter++;
        if(d > tol)
        {
            t2 = t;
        }
        else if(d < -tol)
        {
            t = t;
        }
        t = (t1 + t2)/2.0;
        d = gphFuelTimeFunD1(t);
    }
    //update min speed to be distance/t
    updateSpeedMin(distance_/t);
    return 0;
}

/*********************************** internal gp100m function family *****************************/
double 
PASOEdgeData::gp100mSpeedFun(double speed) const
{
    double val = coef_a_*std::pow(speed, 3.0) 
               + coef_b_*std::pow(speed, 2.0)
               + coef_c_*speed
               + coef_d_;
    return val;
}

double 
PASOEdgeData::gp100mSpeedFunD1(double speed) const
{
    double val = 3.0*coef_a_*std::pow(speed, 2.0) 
               + 2.0*coef_b_*speed
               + coef_c_;
    return val;
}

double 
PASOEdgeData::gp100mSpeedFunD2(double speed) const
{
    double val = 6.0*coef_a_*speed 
               + 2.0*coef_b_;    
    return val;
}

double 
PASOEdgeData::gp100mFuelTimeFun(double time) const
{
    double gp100m = coef_a_*std::pow(distance_, 3.0)*std::pow(time, -3.0)
                  + coef_b_*std::pow(distance_, 2.0)*std::pow(time, -2.0)
                  + coef_c_*distance_/time
                  + coef_d_;
    double val = distance_*gp100m/100.0;
    return val;
}

double 
PASOEdgeData::gp100mFuelTimeFunD1(double time) const
{    
    double gp100m_D1 = -3.0*coef_a_*std::pow(distance_, 3.0)*std::pow(time, -4.0)
                     - 2.0*coef_b_*std::pow(distance_, 2.0)*std::pow(time, -3.0)
                     - coef_c_*distance_*std::pow(time, -2.0);
    double val = distance_*gp100m_D1/100.0;
    return val;
}

double 
PASOEdgeData::gp100mFuelTimeFunD2(double time) const
{
    double gp100m_D2 = 12.0*coef_a_*std::pow(distance_, 3.0)*std::pow(time, -5.0)
                     + 6.0*coef_b_*std::pow(distance_, 2.0)*std::pow(time, -4.0)
                     + 2.0*coef_c_*distance_*std::pow(time, -3.0);
    double val = distance_*gp100m_D2/100.0;
    return val;
}

bool
PASOEdgeData::isGp100mSpeedFunIncreasing() const
{
    double speed_min_d1 = gp100mSpeedFunD1(speed_min_);
    double speed_max_d1 = gp100mSpeedFunD1(speed_max_);
    return ((speed_min_d1 >= -1e-10) &&  (speed_max_d1 >= -1e-10));
}

bool
PASOEdgeData::isGp100mFuelTimeFunDecrasing() const
{
    double time_min_d1 = gp100mFuelTimeFunD1(time_min_);
    double time_max_d1 = gp100mFuelTimeFunD1(time_max_);
    return ((time_min_d1 <= -1e-10) &&  (time_max_d1 <= 1e-10));
}


///@WARNING: we did not handle the case coef_a_ = 0. This should
///be okay now because all of coef_a_ is non-zero.
///@NOTE We only consider the case when we use gp100m fuel-rate-speed function,
///under which the fuel-time-function has the same monotonic properties. More
///specifically, g'(x)=0 means that c'(D/x) = 0.
int
PASOEdgeData::updateGp100mSpeedLimits()
{
    ///we only update for valid edges (with valid parameters)
    if(!isValid())
    {
        return -1;
    }
    
    // solve g'(x) = 3ax^2+2bx+c = 0
    double delta = 4.0*std::pow(coef_b_, 2.0) - 12.0*coef_a_*coef_c_;
    if(delta < 0.0) //case 1
    {
        if(coef_a_ > 0) //case 1-1
        {
            //speed function g(x) is always increasing, 
            //do not need to update speed limit
            return 1;
        }
        else //coef_a_ < 0 case 1-2
        {
            //speed function g(x) is always decreasing,
            //this is possible during the large positive grade
            //set the edge to be invalid
            speed_min_ = speed_max_;
            time_max_ = time_min_;
#if 0
            std::cout << "case 1-2 ";
            std::cout << " grade=" << grade_ << " ";
            std::cout << "(" << src_ << "," << des_ 
                          << ") update speed_min_=" << speed_min_  
                          << ", speed_max_=" << speed_max_ 
                          << ", distance_=" << distance_
                          << ", time_min_=" << time_min_
                          << ", time_max_=" << time_max_
                          << ", speed_min*time_max=" << speed_min_*time_max_
                          << ", speed_max*time_min=" << speed_max_*time_min_
                          << std::endl;
            //std::cout << "g(x) always decreasing, impossible, parameters are bad, set edge to be invalid" << std::endl;
#endif
        }
    }
    else // delta >= 0.0, case 2
    {
        if(coef_a_ > 0) //case 2-1
        {
            ///we only care about the right root
            double x2 = (-2.0*coef_b_ + std::sqrt(delta))/(6.0*coef_a_);
            if(speed_max_ <= x2) // all speed interval is in the decreasing part, set to a single point, case 2-1-1
            {
                speed_min_ = speed_max_;
                time_max_ = time_min_;
#if 0
                std::cout << "case 2-1 ";
                std::cout << "(" << src_ << "," << des_ 
                          << ") update speed_min_=" << speed_min_  
                          << ", speed_max_=" << speed_max_ 
                          << ", distance_=" << distance_
                          << ", time_min_=" << time_min_
                          << ", time_max_=" << time_max_
                          << ", speed_min*time_max=" << speed_min_*time_max_
                          << ", speed_max*time_min=" << speed_max_*time_min_
                          << std::endl;
#endif
            }
            else //speed_max_ > x2, case 2-1-2
            {
                if(speed_min_ < x2)  // case 2-1-2-1
                {
                    speed_min_ = x2;
                    time_max_ = distance_/x2;
#if 0
                    std::cout <<"case 2-1-2-1 ";                    
                    std::cout << "(" << src_ << "," << des_ 
                          << ") update speed_min_=" << speed_min_  
                          << ", speed_max_=" << speed_max_ 
                          << ", distance_=" << distance_
                          << ", time_min_=" << time_min_
                          << ", time_max_=" << time_max_
                          << ", speed_min*time_max=" << speed_min_*time_max_
                          << ", speed_max*time_min=" << speed_max_*time_min_
                          << std::endl;
#endif                    
                }      
            }
        }
        else //coef_a_ < 0, case 2-2
        {
            double x1 = (-2.0*coef_b_ + std::sqrt(delta))/(6.0*coef_a_);
            double x2 = (-2.0*coef_b_ - std::sqrt(delta))/(6.0*coef_a_);
            //consider sub-cases by speed_max first and speed_min second
            if(speed_max_ < x1) // speed_max_ < x1, case 2-2-1
            {
                speed_min_ = speed_max_;
                time_max_ = time_min_;
#if 0
                std::cout <<"case 2-2-1 ";
                std::cout << " grade=" << grade_ << ", x1=" << x1 << " ";
                std::cout << "(" << src_ << "," << des_ 
                          << ") update speed_min_=" << speed_min_  
                          << ", speed_max_=" << speed_max_ 
                          << ", distance_=" << distance_
                          << ", time_min_=" << time_min_
                          << ", time_max_=" << time_max_
                          << ", speed_min*time_max=" << speed_min_*time_max_
                          << ", speed_max*time_min=" << speed_max_*time_min_
                          << std::endl;
#endif
            }
            else if(speed_max_ <= x2) // speed_max_ \in [x1, x2], case 2-2-2
            {
                if(speed_min_ < x1) //case 2-2-2-1
                {
                    speed_min_ = x1;
                    time_max_ = distance_/x1;
#if 0
                    std::cout <<"case 2-2-2-1 ";
                    std::cout << "(" << src_ << "," << des_ 
                          << ") update speed_min_=" << speed_min_  
                          << ", speed_max_=" << speed_max_ 
                          << ", distance_=" << distance_
                          << ", time_min_=" << time_min_
                          << ", time_max_=" << time_max_
                          << ", speed_min*time_max=" << speed_min_*time_max_
                          << ", speed_max*time_min=" << speed_max_*time_min_
                          << std::endl;
#endif
                }
            }
            else // speed_max_ > x2, case 2-2-3
            {
                if(speed_min_ < x2) //case 2-2-3-1
                {
                    //speed function g(x) is increasing and then decreasing,
                    //this is impossible, set the edge to be invalid
                    setValid(false);
                    std::cout <<"case 2-2-3-1 ";
                    std::cout << " grade=" << grade_ << ", x2=" << x2 << " ";
                    std::cout << *this;
                    std::cout << "g(x) is increasing and then decreasing, impossible, parameters are bad, set edge to be invalid" << std::endl;
                    return -1;
                }
            }
        }
    }
    return 0;
}
#ifndef _PASO_SOLUTION_H
#define _PASO_SOLUTION_H

#include "Snap.h"
#include "PASONodeData.h"
#include "PASOEdgeData.h"
#undef min
#undef max
#include <string>
#include <vector>
#include <iostream>
///contain all information of a solution to PASO
///@Warning we should set path_ and time_. The rest properties can be calculated by invoking update() method
class PASOSolution
{
    public:
    
    PASOSolution();
    PASOSolution(int n_edge);
    PASOSolution(const std::vector<int>& path);
    
    ///some get function
    ///get the vector
    const std::vector<int>& getPath() const {return path_;}
    const std::vector<double>& getTime() const {return time_;}
    const std::vector<double>& getSpeed() const {return speed_;}
    const std::vector<double>& getDistance() const {return distance_;}
    const std::vector<double>& getFuelCost() const {return fuel_cost_;}
    ///get individual element of any vector
    int getPathI(int i) const {return path_[i];}
    double getTimeI(int i) const {return time_[i];}
    double getSpeedI(int i) const {return speed_[i];}
    double getDistanceI(int i) const {return distance_[i];}
    double getFuelCostI(int i) const {return fuel_cost_[i];}
    ///get summary information
    double getNEdge() const {return n_edge_;}
    double getTotalTime() const {return total_time_;}
    double getTotalDistance() const {return total_distance_;}
    double getTotalFuelCost() const {return total_fuel_cost_;}
    
    ///some set function
    ///set the vector
    void setPath(const std::vector<int>& path) { path_ = path;}
    void setTime(const std::vector<double>& time) {time_ = time;}
    void setSpeed(const std::vector<double>& speed) {speed_ = speed;}
    void setDistance(const std::vector<double>& distance) {distance_ = distance;}
    void setFuelCost(const std::vector<double>& fuel_cost) {fuel_cost_ = fuel_cost;}
    ///set the individual element of any vector
    void setPathI(int i, int val) { path_[i] = val;}
    void setTimeI(int i, double val) { time_[i] = val;}
    void setSpeedI(int i, double val) { speed_[i] = val;}
    void setDistanceI(int i, double val) { distance_[i] = val;}
    void setFuelCostI(int i, double val) { fuel_cost_[i] = val;}
    ///set some summary information
    void setNEdge(int n_edge) {n_edge_ = n_edge;}
    void setTotalTime(double total_time) {total_time_ = total_time;}
    void setTotalDistance(double total_distance) {total_distance_ = total_distance;}
    void setTotalFuelCost(double total_fuel_cost) {total_fuel_cost_ = total_fuel_cost;}
    
    ///path and time should be pre-set, and we can update speed, distance, fuel_cost according to PNet
    void updateSpeedDistanceFuelCost(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet);
    
    ///calculate the summary information
    void calcAll();
    void calcTotalTime();
    void calcTotalDistance();
    void calcTotalFuelCost();
    
    ///when working outside, we only need to invoke update() function, which will invoke updateSpeedDistanceFuelCost() and calcAll()
    void update(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet);
    
    friend std::ostream& operator << (std::ostream& os, const PASOSolution& s);
    
    private:
    
    ///size: n_edge_ + 1
    std::vector<int> path_;
    ///size: n_edge_
    std::vector<double> time_;
    std::vector<double> speed_;
    std::vector<double> distance_;
    std::vector<double> fuel_cost_;
    ///n_edge_ = path_.size() - 1
    int n_edge_;
    double total_time_;
    double total_distance_;
    double total_fuel_cost_;
};

#endif


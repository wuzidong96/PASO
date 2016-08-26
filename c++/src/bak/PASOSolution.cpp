#include "Snap.h"
#include "PASONodeData.h"
#include "PASOEdgeData.h"
#include "PASOSolution.h"
#undef min
#undef max
#include <string>
#include <vector>
#include <numeric>
#include <iostream>

    
PASOSolution::PASOSolution()
: n_edge_(0), total_time_(0), total_distance_(0), total_fuel_cost_(0)
{
}

PASOSolution::PASOSolution(int n_edge)
: n_edge_(n_edge), total_time_(0), total_distance_(0), total_fuel_cost_(0)
{
    path_ = std::vector<int>(n_edge_+1, -1);
    time_ = std::vector<double>(n_edge_, -1);
    speed_ = std::vector<double>(n_edge_, -1);
    distance_ = std::vector<double>(n_edge_, -1);
    fuel_cost_ = std::vector<double>(n_edge_, -1);
}

PASOSolution::PASOSolution(const std::vector<int>& path)
{
    n_edge_ = path.size()-1;
    path_ = path;
    time_ = std::vector<double>(n_edge_, -1);
    speed_ = std::vector<double>(n_edge_, -1);
    distance_ = std::vector<double>(n_edge_, -1);
    fuel_cost_ = std::vector<double>(n_edge_, -1);    
}
    
void
PASOSolution::calcAll()
{
    calcTotalTime();
    calcTotalDistance();
    calcTotalFuelCost();
}
    
void
PASOSolution::calcTotalTime()
{
    ///must use 0.0, see definition http://en.cppreference.com/w/cpp/algorithm/accumulate
    total_time_ = std::accumulate(time_.begin(), time_.end(), 0.0);
}


void
PASOSolution::calcTotalDistance()
{
    ///must use 0.0
    total_distance_ = std::accumulate(distance_.begin(), distance_.end(), 0.0);
}

void
PASOSolution::calcTotalFuelCost()
{
    ///must use 0.0
    total_fuel_cost_ = std::accumulate(fuel_cost_.begin(), fuel_cost_.end(), 0.0);
}

void
PASOSolution::updateSpeedDistanceFuelCost(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet)
{
    for(int i=0; i < time_.size(); i++)
    {
        int src = path_[i];
        int des = path_[i+1];
        double time = time_[i];
        PASOEdgeData& edge_data = PNet->GetEDat(src, des);
        distance_[i] = edge_data.getDistance();
        speed_[i] = distance_[i]/time;
        fuel_cost_[i] = edge_data.fuelTimeFun(time);
    }
}

void
PASOSolution::update(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet)
{
    updateSpeedDistanceFuelCost(PNet);
    calcAll();
}

std::ostream& operator << (std::ostream& os, const PASOSolution& s)
{
    os << s.total_time_ << "," << s.total_distance_ << "," << s.total_fuel_cost_;
    return os;
}
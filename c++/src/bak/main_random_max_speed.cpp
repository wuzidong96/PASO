#include "Snap.h"
#include "PASONodeData.h"
#include "PASOEdgeData.h"
#include "PASOUtil.h"
#undef min
#undef max
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <map>
using namespace std;

int main(int argc, char* argv[])
{
    if(argc != 4)
    {
        cout << "usage: " << argv[0] 
             << " <source id> <sink id> <T>"
             << endl;
        return -1;
    }
    
    //int source = 941;
    //int sink = 17166;
    //read the input (src, des ,T)
    int source = atoi(argv[1]); 
    int sink = atoi(argv[2]);
    double T = atof(argv[3]);
    
    //several input files
    string coef_file = "data/coef_file_gp100m.txt";
    string grade_max_speed_file = "data/grade_max_speed.txt";
    string node_file = "data/usa-national_node.txt";
    string edge_file = "data/usa-national_edge.txt";
    
    //several output files
    string source_sink_T = string(argv[1]) + "_" + string(argv[2]) + "_" + string(argv[3]);
    string shortest_path_distance_gra_file = "result/random_shortest_path_distance_" + source_sink_T + ".gra";
    string shortest_path_time_min_gra_file = "result/random_shortest_path_time_min_" + source_sink_T + ".gra";
    string optimal_path_gra_file = "result/random_optimal_path_" + source_sink_T + ".gra";
    //we will write some information into the info_file,
    //Currently, let us use the format: source,sink,T,shortest_path_fuel_cost_with_time_min,shortest_path_fuel_cost,optimal_path_fuel_cost
    string info_file = "result/random_info_" + source_sink_T + ".csv";
    
    map< int, vector<double> > grade_coef_m;
    map< int, double > grade_max_speed_m;
    //construct the <grade, coef_v> map from the coef file
    PASOUtil::readGradeCoefFile(grade_coef_m, coef_file);
    //read grade_max_speed file to update max_speed, construct <grade, max_sped> map
    PASOUtil::readMaxSpeedFile(grade_max_speed_m, grade_max_speed_file);
 
    vector<PASONodeData> node_data_v;
    vector<PASOEdgeData> edge_data_v;
    TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> > PNet = TNodeEDatNet< PASONodeData, PASOEdgeData >::New();
    
    //read node data firstly
    int ret = PASOUtil::readNodeFile(node_data_v, PNet, node_file);
    if(ret == -1)
    {
        cout << "read node file failed" << endl;
        return -1;
    }
    //read edge data secondly
    ret = PASOUtil::readEdgeFile(edge_data_v, PNet, edge_file);
    if(ret == -1)
    {
        cout << "read edge file failed" << endl;
        return -1;
    }
    
    //calculate the edge properties
    bool doRandomSpeedLimits = true;
    ret = PASOUtil::calEdgeProperties(PNet, grade_coef_m, grade_max_speed_m, doRandomSpeedLimits);
    
    //update speed limit
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++) 
    {
     //   int src = EI.GetSrcNId();
     //   int des = EI.GetDstNId();
        EI.GetDat().updateSpeedLimits();
        
        if(EI.GetDat().isValid())
        {
            bool val1 = EI.GetDat().isGp100mSpeedFunIncreasing();
            bool val2 = EI.GetDat().isGp100mFuelTimeFunDecrasing();
            if(!val1 || !val2)
            {
                ///only happens in the case min_speed == max_speed
                cout << "not monotonic: (val1,val2)=(" << val1 << "," << val2 << ") "
                     << EI.GetDat();
            }
        }
    }
    

    ///prune the network
    ret = PASOUtil::prunePASONet(PNet);
    
    ///we have finished to construct the graph, print infomation
    PASOUtil::printNStats(PNet);
   
   ///get the shortest path here
    vector<int> shortest_path;
    double shortest_path_cost;
    
    int hops_undir = TSnap::GetShortPath(PNet, source, sink);
    int hops_dir = TSnap::GetShortPath(PNet, source, sink, true);
    
    cout << "hops_undir=" << hops_undir 
         << ", hops_dir=" << hops_dir 
         << endl;
   

    ret = PASOUtil::getShortestPath(PNet, source, sink, "distance", shortest_path, shortest_path_cost);
    
    if(ret == -1)
    {
        cout << "cannot find a (" << source << "," << sink << ")" << "-path" << endl;
        return -1;
    }
    
    cout << "shortest_path_cost=" << shortest_path_cost << endl;
    
    PASOUtil::writeToGraFile(PNet, shortest_path, shortest_path_distance_gra_file);

    ///do not optimize the shortest path, but just use the max speed (min time) over the shortest path
    double shortest_path_fuel_cost_with_time_min = 0;
    for(int i=0; i < shortest_path.size()-1; i++)
    {
        int src = shortest_path[i];
        int des = shortest_path[i+1];
        PASOEdgeData& edge_data = PNet->GetEDat(src, des);
        double time_min = edge_data.getTimeMin();
        double cost = edge_data.gp100mFuelTimeFun(time_min);
        shortest_path_fuel_cost_with_time_min += cost;
        cout << "(" << src << "," << des
             << ") " << time_min 
             << " " << cost << endl;
    }
    cout << "shortest_path_fuel_cost_with_time_min=" << shortest_path_fuel_cost_with_time_min << endl;
    
    
    ///optimize the shortest path
    std::vector<double> shortest_path_time;
    double shortest_path_fuel_cost;
    ret = PASOUtil::optimizeSinglePath(PNet, shortest_path, source, sink, T, shortest_path_time, shortest_path_fuel_cost);
    if(ret == -1)
    {
        cout << "optimizeSinglePath failed" << endl;
        return -1;
    }
    
    cout << "shortest_path_fuel_cost=" << shortest_path_fuel_cost << endl;
    
    for(int i=0; i < shortest_path_time.size(); i++)
    {
        int src = shortest_path[i];
        int des = shortest_path[i+1];
        PASOEdgeData& edge_data = PNet->GetEDat(src, des);
        double cost = edge_data.gp100mFuelTimeFun(shortest_path_time[i]);
        cout << "(" << src << "," << des
             << ") " << shortest_path_time[i] 
             << " " << cost << endl;
    }
   
    ///get the optimal path via dual solution
    vector<int> optimal_path;
    vector<double> optimal_time;
    double optimal_fuel_cost;
    ret = PASOUtil::optimizeNetworkDual(PNet, source, sink, T, optimal_path, optimal_time, optimal_fuel_cost);
    if(ret == -1)
    {
        cout << "optimizeNetworkDual failed" << endl;
        return -1;
    }
    
    
    cout << "optimal_fuel_cost=" << optimal_fuel_cost << endl;
    PASOUtil::writeToGraFile(PNet, optimal_path, optimal_path_gra_file);
  
    cout << "shortest_path_fuel_cost_with_time_min=" << shortest_path_fuel_cost_with_time_min
         << ", shortest_path_fuel_cost=" << shortest_path_fuel_cost <<", optimal_fuel_cost=" << optimal_fuel_cost << endl;
    
    ///write source,sink,T,shortest_path_fuel_cost_with_time_min,shortest_path_fuel_cost,optimal_path_fuel_cost into the info file
    
    ofstream ofs(info_file.c_str(), fstream::trunc);
    cout <<"write info to file " << info_file << endl;
    if(!ofs.is_open())
    {
        cout << "cannot open the file " << info_file << endl;
        return -1;
    }
    
    ofs << source << "," 
        << sink << "," 
        << T << "," 
        << shortest_path_fuel_cost_with_time_min << ","
        << shortest_path_fuel_cost << "," 
        << optimal_fuel_cost << endl;
    
    return 0;
}
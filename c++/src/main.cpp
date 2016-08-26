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

/*======================================== input and output =======================================*/    
    //int source = 941;
    //int sink = 17166;
    //read the input (src, des ,T)
    int source = atoi(argv[1]); 
    int sink = atoi(argv[2]);
    double T = atof(argv[3]);
    
    cout << "Running for instance (source,sink,T)=" << "(" << source << "," << sink << "," << T << ")" << endl;
    
    //several input files
    string node_file = "data/usa-national_node.txt";
    string edge_file = "data/usa-national_edge.txt";
    //string coef_file = "data/coef_file_gp100m.txt";
    string coef_file = "data/coef_file_gph.txt";
    string grade_max_speed_file = "data/grade_max_speed.txt";
    string avg_speed_file = "data/avg_speed_limit.txt";
    //several output files
    string source_sink_T = string(argv[1]) + "_" + string(argv[2]) + "_" + string(argv[3]);
    ///path gra file
    string path_fastest_gra_file = "result/path/path_fastest_" + source_sink_T + ".gra";
    string path_shortest_gra_file = "result/path/path_shortest_" + source_sink_T + ".gra";
    string path_lb_gra_file = "result/path/path_lb_" + source_sink_T + ".gra";
    string path_ub_gra_file = "result/path/path_ub_" + source_sink_T + ".gra";
    string path_opt_gra_file = "result/path/path_opt_" + source_sink_T + ".gra";
    ///solution file
    string sol_fastest_path_time_min_file = "result/sol/sol_fastest_path_time_min_" + source_sink_T + ".csv";
    string sol_fastest_path_opt_file = "result/sol/sol_fastest_path_opt_" + source_sink_T + ".csv";
    string sol_shortest_path_time_min_file = "result/sol/sol_shortest_path_time_min_" + source_sink_T + ".csv";
    string sol_shortest_path_opt_file = "result/sol/sol_shortest_path_opt_" + source_sink_T + ".csv";
    string sol_lb_file = "result/sol/sol_lb_" + source_sink_T + ".csv"; 
    string sol_ub_file = "result/sol/sol_ub_" + source_sink_T + ".csv";      
    string sol_opt_file = "result/sol/sol_opt_" + source_sink_T + ".csv";
    ///info file, we will write some information into the info_file,
    string info_file = "result/info/info_" + source_sink_T + ".csv";
    
/*================================= variables, declare here =============================================*/
    ///the network
    TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> > PNet = TNodeEDatNet< PASONodeData, PASOEdgeData >::New();  
    int ret;
/*============================================ construct the graph ======================================*/    
    PASOEdgeData::SpeedFunType type = PASOEdgeData::GPH;
    ret = PASOUtil::constructGraph(PNet, node_file, edge_file, coef_file, grade_max_speed_file,avg_speed_file, type);
    if(ret == -1)
    {
        cout << "constructGraph failed, terminate" << endl;
        return -1;
    }
   // PASOUtil::printAllNodeInfo(PNet);
  //  PASOUtil::printAllEdgeInfo(PNet);
/*============================================ prune the graph ============================================*/
    ///prune the network
    //1. some edges are invalids
    ret = PASOUtil::prunePASONet(PNet, source, sink, T);          
/*============================================ prune the graph to east============================================*/
    ///prune the network to east
    ret = PASOUtil::prunePASONetToEast(PNet, source, sink, T); 
/*============================================ merge the graph ============================================*/
    ret = PASOUtil::mergePASONet(PNet); 
  //  PASOUtil::printAllEdgeFuelFun(PNet, "data/edge_fuel_fun_info.csv");
  //  PASOUtil::printAllNodeInfo(PNet, "data/node_info.csv");
  //  PASOUtil::printAllEdgeInfo(PNet,"data/edge_info.csv");      
/* ========================================== rough check ================================================*/
    if(!PNet->IsNode(source) ||
       !PNet->IsNode(sink))
    {
        std::cout << "invalid source and sink, one of them has been merged" << std::endl;
        return -1;
    }
           
    int hops_undir = TSnap::GetShortPath(PNet, source, sink);
    int hops_dir = TSnap::GetShortPath(PNet, source, sink, true); 
    cout << "hops_undir=" << hops_undir  << ", hops_dir=" << hops_dir  << endl;    
    if(hops_dir == -1)
    {
        cout << " hopes_dir == -1, cannot find a (" << source << "," << sink << ")" << "-path" << endl;
        return -1;
    }
    
    PASOUtil::runOneInstance(PNet,
                             source,
                             sink,
                             T,
                             path_fastest_gra_file,
                             path_shortest_gra_file,
                             path_lb_gra_file,
                             path_ub_gra_file,
                             path_opt_gra_file,
                             sol_fastest_path_time_min_file,
                             sol_fastest_path_opt_file,
                             sol_shortest_path_time_min_file,
                             sol_shortest_path_opt_file,
                             sol_lb_file,
                             sol_ub_file,
                             sol_opt_file,
                             info_file);  
    return 0;
}
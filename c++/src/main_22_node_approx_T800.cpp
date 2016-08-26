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
#include <sys/time.h>
#include <unistd.h>
using namespace std;

int main(int argc, char* argv[])
{
    if(argc != 9)
    {
        cout << "usage: " << argv[0] 
             << "<source id [1-22]> <sink id [1-22]> <T> <lat_min> <lat_max> <lon_min> <lon_max> <epsilon>"
             << endl;
        return -1;
    }
    
    
/*********************************** time and memory usage ****************************/    
    struct timeval time_start, time_end;
	long elapsed_seconds;
	gettimeofday(&time_start, NULL);
    
    //add variables
	struct rusage usage;
	getrusage(RUSAGE_SELF, &usage);
	long memory_usage1 = usage.ru_maxrss;
	std::cout << "before main: ru_maxrss: " << memory_usage1 << "KB="
              << memory_usage1/1024.0/1024.0
              << "GB" << std::endl;
/*********************************** time and memory usage ****************************/
    
    
    
/*======================================== input and output =======================================*/    
    //int source = 1;
    //int sink = 2;
    //read the input (src, des ,T)
    int source_id = atoi(argv[1]); 
    int sink_id = atoi(argv[2]);
    double T = atof(argv[3]);
    double lat_min = atof(argv[4]);
    double lat_max = atof(argv[5]);
    double lon_min = atof(argv[6]);
    double lon_max = atof(argv[7]);
    double epsilon = atof(argv[8]);
    
    cout << "source_id=" << source_id
         << ", sink_id=" << sink_id
         << ", T=" << T
         << ", lat_min=" << lat_min
         << ", lat_max=" << lat_max
         << ", lon_min=" << lon_min
         << ", lon_max=" << lon_max
         << ", epsilon=" << epsilon
         << endl;
    
    if(source_id < 1 || source_id > 22 || sink_id < 1 || sink_id > 22)
    {
        cout << "usage: " << argv[0] 
             << "<source id [1-22]> <sink id [1-22]> <T> <lat_min> <lat_max> <lon_min> <lon_max>"
             << endl;
        cout << "source id and sink  id must in [1,22]" << endl;
        return -1;
    }
    cout << "Running for instance (source_id,sink_id)=" << "(" << source_id << "," << sink_id << ","  << ")" << endl;
    
    //several input files
    string node_22_file = "data/22_nodes.txt";
    int source = PASOUtil::getNodeFrom22NodeFile(source_id, node_22_file);
    int sink = PASOUtil::getNodeFrom22NodeFile(sink_id, node_22_file);
    if(source == -1 || sink == -1)
    {
        cout << "something wrong" << endl;
        return -1;
    }
    cout << "source=" << source << ", sink=" << sink << endl;
   
   
    //several input files
    string node_file = "data/usa-national_node.txt";
    string edge_file = "data/usa-national_edge.txt";
    //string coef_file = "data/coef_file_gp100m.txt";
    string coef_file = "data/coef_file_gph_T800.txt";
    string grade_max_speed_file = "data/grade_max_speed_T800.txt";
    string avg_speed_file = "data/avg_speed_limit.txt";
    //several output files
    string sourceid_sinkid_T = string(argv[1]) + "_" + string(argv[2]) + "_" + string(argv[3]);
    ///path gra file
    string path_fastest_gra_file = "result/T800/approx/path/path_fastest_" + sourceid_sinkid_T + ".gra";
    string path_shortest_gra_file = "result/T800/approx/path/path_shortest_" + sourceid_sinkid_T + ".gra";
    string path_lb_gra_file = "result/T800/approx/path/path_lb_" + sourceid_sinkid_T + ".gra";
    string path_ub_gra_file = "result/T800/approx/path/path_ub_" + sourceid_sinkid_T + ".gra";
    string path_opt_gra_file = "result/T800/approx/path/path_opt_" + sourceid_sinkid_T + ".gra";
    ///solution file
    string sol_fastest_path_time_min_file = "result/T800/approx/sol/sol_fastest_path_time_min_" + sourceid_sinkid_T + ".csv";
    string sol_fastest_path_opt_file = "result/T800/approx/sol/sol_fastest_path_opt_" + sourceid_sinkid_T + ".csv";
    string sol_shortest_path_time_min_file = "result/T800/approx/sol/sol_shortest_path_time_min_" + sourceid_sinkid_T + ".csv";
    string sol_shortest_path_opt_file = "result/T800/approx/sol/sol_shortest_path_opt_" + sourceid_sinkid_T + ".csv";
    string sol_lb_file = "result/T800/approx/sol/sol_lb_" + sourceid_sinkid_T + ".csv"; 
    string sol_ub_file = "result/T800/approx/sol/sol_ub_" + sourceid_sinkid_T + ".csv";      
    string sol_opt_file = "result/T800/approx/sol/sol_opt_" + sourceid_sinkid_T + ".csv";
    string sol_approx_file = "result/T800/approx/sol/sol_approx_" + sourceid_sinkid_T + ".csv";
    ///info file, we will write some information into the info_file,
    string info_file = "result/T800/approx/info/info_" + sourceid_sinkid_T + ".csv";
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

/*============================================ prune the graph within the region============================================*/
    ///prune the network to east
    ret = PASOUtil::prunePASONetWithinLatLon(PNet, lat_min, lat_max, lon_min, lon_max, source, sink, T); 
    
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
   
    //print edge infomation
    PASOUtil::printAllEdgeInfo(PNet, "data/edge_22_approx_T800_" + sourceid_sinkid_T + ".csv");
#if 0        
    string delta_file = "result/T800/approx/delta/delta_fun_" + sourceid_sinkid_T + ".csv";
    PASOUtil::getDeltaLambdaFun(PNet,
                      source,
                      sink,
                      delta_file);   
#endif   
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
#if 1 //temp just to test time/space of heuristic   
    double lb = 1;
    double ub = 1000;
    PASOSolution sol_approx;
    PASOUtil::approximationScheme(PNet,
                                  source,
                                  sink,
                                  T,    
                                  lb,
                                  ub,
                                  epsilon,
                                  sol_approx);   
    
    PASOUtil::writeSolutionToFile(PNet, sol_approx, sol_approx_file);
    cout << "sol_approx: " << sol_approx << endl;
#endif    
    /*********************************** time and memory usage ****************************/     
    getrusage(RUSAGE_SELF, &usage);
	long memory_usage2 = usage.ru_maxrss;
	std::cout << "after main: ru_maxrss: " << memory_usage2 << "KB="
     	      << memory_usage2/1024.0/1024.0 << "GB" << std::endl;
    std::cout << "during main: delta_ru_maxrss: " << memory_usage2-memory_usage1 << "KB="
     	      << (memory_usage2-memory_usage1)/1024.0/1024.0 << "GB" << std::endl;    
    gettimeofday(&time_end ,NULL);
	elapsed_seconds = time_end.tv_sec - time_start.tv_sec;
	std::cout << "Elapsed Time for main: " << elapsed_seconds << std::endl; 
/*********************************** time and memory usage ****************************/  
    
    
    
    
    return 0;
}
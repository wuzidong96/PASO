// For each source destination pair (s,d), 
// We first get the fastest travel time T^f. Then we 
// evaluate the fuel consumption of T^f, (1+10%)T^f, (1+20%)^Tf, ..., (1+100%)^Tf
#include "Snap.h"
#include "PASONodeData.h"
#include "PASOEdgeData.h"
#include "PASOUtil.h"
#undef min
#undef max
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <map>
#include <sys/time.h>
#include <unistd.h>
using namespace std;

int main(int argc, char* argv[])
{
    if(argc != 3)
    {
        cout << "usage: " << argv[0] 
             << " <source id [1-22]> <sink id [1-22]>"
             << endl;
        return -1;
    }
    
/*======================================== input and output =======================================*/    
    //int source = 1;
    //int sink = 2;
    int source_id = atoi(argv[1]); 
    int sink_id = atoi(argv[2]);
    
    
    if(source_id < 1 || source_id > 22 || sink_id < 1 || sink_id > 22)
    {
        cout << "usage: " << argv[0] 
             << " <source id [1-22]> <sink id [1-22]>"
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
    ret = PASOUtil::prunePASONet(PNet, source, sink, 100);          
/*============================================ prune the graph to east============================================*/
    ///prune the network to east
    ret = PASOUtil::prunePASONetToEast(PNet, source, sink, 100); 
/*============================================ merge the graph ============================================*/
    ret = PASOUtil::mergePASONet(PNet); 
  //  PASOUtil::printAllEdgeFuelFun(PNet, "data/edge_fuel_fun_info.csv");
  //  PASOUtil::printAllNodeInfo(PNet, "data/node_info_T800.csv");
   // PASOUtil::printAllEdgeInfo(PNet,"data/edge_info_T800.csv");      
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
    
	std::vector<int> path_fastest;
	double minimal_path_hours;
	///get the fastest path here
    ret = PASOUtil::getShortestPath(PNet, source, sink, "time_min", path_fastest, minimal_path_hours);
	cout << "minimal_path_hours=" << minimal_path_hours << endl;
	
	string log_file = "result/T800/delay-perc/" + string(argv[1]) + "_" + string(argv[2]) + "_delay_perc.txt";
	std::ofstream log_ofs(log_file.c_str(), std::ofstream::trunc);
	
	for (int perc=0; perc <= 100; perc = perc + 5)
	{
		double T=minimal_path_hours*(1+perc/100.0); //stepsize 5%
		if(perc == 0)
		{
			T += 1e-7; //such that T > minimal_path_hours
		}
		double initial_fuel_opt;
		cout << "percentage: " << perc*10 << ", T=" << T << endl;
		
		std::ostringstream sstream;
		sstream << T;
		std::string T_str = sstream.str();

		//several output files
		string sourceid_sinkid_T = string(argv[1]) + "_" + string(argv[2]) + "_" + T_str;
		///path gra file
		string path_fastest_gra_file = "result/T800/path/path_fastest_" + sourceid_sinkid_T + ".gra";
		string path_shortest_gra_file = "result/T800/path/path_shortest_" + sourceid_sinkid_T + ".gra";
		string path_lb_gra_file = "result/T800/path/path_lb_" + sourceid_sinkid_T + ".gra";
		string path_ub_gra_file = "result/T800/path/path_ub_" + sourceid_sinkid_T + ".gra";
		string path_opt_gra_file = "result/T800/path/path_opt_" + sourceid_sinkid_T + ".gra";
		///solution file
		string sol_fastest_path_time_min_file = "result/T800/sol/sol_fastest_path_time_min_" + sourceid_sinkid_T + ".csv";
		string sol_fastest_path_opt_file = "result/T800/sol/sol_fastest_path_opt_" + sourceid_sinkid_T + ".csv";
		string sol_shortest_path_time_min_file = "result/T800/sol/sol_shortest_path_time_min_" + sourceid_sinkid_T + ".csv";
		string sol_shortest_path_opt_file = "result/T800/sol/sol_shortest_path_opt_" + sourceid_sinkid_T + ".csv";
		string sol_lb_file = "result/T800/sol/sol_lb_" + sourceid_sinkid_T + ".csv"; 
		string sol_ub_file = "result/T800/sol/sol_ub_" + sourceid_sinkid_T + ".csv";      
		string sol_opt_file = "result/T800/sol/sol_opt_" + sourceid_sinkid_T + ".csv";
		///info file, we will write some information into the info_file,
		string info_file = "result/T800/info/info_" + sourceid_sinkid_T + ".csv";
		
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
								 
		///Unfortunately, runOneInstance does not provide interface for the solution,
		///so we must read the info_file to get the fuel consumption of the optimal solution
		std::ifstream ifs(info_file.c_str());
		string result;
		int i=0;
		while(getline(ifs, result, ','))
		{
			i++;
			if(i==18)
			{
				double fuel_opt = atof(result.c_str());
				cout << "fuel_opt=" << fuel_opt << endl;
				if(perc==0)
				{
					initial_fuel_opt = fuel_opt;
				}
				log_ofs << T << " " << fuel_opt << endl;
				log_ofs << perc << "% " << (fuel_opt-initial_fuel_opt)/initial_fuel_opt << endl;
			}
		}
		ifs.close();
	}							 
   
    return 0;
}
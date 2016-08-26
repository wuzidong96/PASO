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
    if(argc != 3)
    {
        cout << "usage: " << argv[0] 
             << " <source id> <sink id>"
             << endl;
        return -1;
    }

/*======================================== input and output =======================================*/    
    //int source = 941;
    //int sink = 17166;
    //read the input (src, des ,T)
    int source = atoi(argv[1]); 
    int sink = atoi(argv[2]);
    
    cout << "Get delta function for instance (source,sink)=" << "(" << source << "," << sink << ")" << endl;
    
    //several input files
    string node_file = "data/usa-national_node.txt";
    string edge_file = "data/usa-national_edge.txt";
    //string coef_file = "data/coef_file_gp100m.txt";
    string coef_file = "data/coef_file_gph.txt";
    string grade_max_speed_file = "data/grade_max_speed.txt";
    string avg_speed_file = "data/avg_speed_limit.txt";
    //several output files
    string source_sink = string(argv[1]) + "_" + string(argv[2]);
    ///path gra file
    string delta_fun_file = "result/delta/delta_fun_" + source_sink + ".csv";

    
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
    //2. any node v if shortest_time(source,v) + shortest_time(sink,v), we should delete it (Do not do this now!)
    ret = PASOUtil::prunePASONet(PNet, source, sink, 0);    
/*============================================ merge the graph ============================================*/
    ret = PASOUtil::mergePASONet(PNet); 
  //  PASOUtil::printAllNodeInfo(PNet);
  //  PASOUtil::printAllEdgeInfo(PNet);    
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
 
/* ========================================= get delta(lambda) function ===================================================*/        
    ret = PASOUtil::getDeltaLambdaFun(PNet, source, sink, delta_fun_file);
   
    return 0;
}
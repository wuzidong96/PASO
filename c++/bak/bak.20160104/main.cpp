#include "Snap.h"
#include "PASONodeData.h"
#include "PASOEdgeData.h"
#include "PASOUtil.h"
#undef min
#undef max
#include <iostream>
#include <vector>
#include <string>
#include <map>
using namespace std;

// Print network statistics
void PrintNStats(const char s[], TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> > Net) {
  printf("network %s, nodes %d, edges %d, empty %s\n",
      s, Net->GetNodes(), Net->GetEdges(),
      Net->Empty() ? "yes" : "no");
}


int main(int argc, char* argv[])
{
    map< int, vector<double> > grade_coef_m;
    //construct the <grade, coef_v> map from the coef file
    PASOUtil::readGradeCoefFile(grade_coef_m, "data/coef_file.txt");
 
#if 0 
    for(map< int, vector<double> >::iterator mi=grade_coef_m.begin(); mi != grade_coef_m.end(); mi++)
    {
        int grade_key = mi->first;
        vector<double> coef_v = mi->second;
        double coefa = coef_v[0];
        double coefb = coef_v[1];
        double coefc = coef_v[2];
        double coefd = coef_v[3];

        cout << "(grade_key,coefa,coefb,coefc,coefd)=(" 
             << grade_key << ","
             << coefa << ","
             << coefb << ","
             << coefc << ","
             << coefd << ")" 
             << endl;
    }
#endif  
 
    vector<PASONodeData> node_data_v;
    vector<PASOEdgeData> edge_data_v;
    TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> > PNet = TNodeEDatNet< PASONodeData, PASOEdgeData >::New();
    
    //read node data firstly
//    int ret = PASOUtil::readNodeFile(node_data_v, PNet, "data/usai_node.txt");
    int ret = PASOUtil::readNodeFile(node_data_v, PNet, "data/usa-national_node.txt");
    if(ret == -1)
    {
        cout << "read node file failed" << endl;
    }
    //read edge data secondly
//    ret = PASOUtil::readEdgeFile(edge_data_v, PNet, "data/usai_edge.txt");
     ret = PASOUtil::readEdgeFile(edge_data_v, PNet, "data/usa-national_edge.txt");
    if(ret == -1)
    {
        cout << "read edge file failed" << endl;
    }
    //calculate the edge properties
    ret = PASOUtil::calEdgeProperties(PNet, grade_coef_m);
    
    ///prune the network
  //  ret = PASOUtil::prunePASONet(PNet);
    
#if 0  
    for(TNodeEDatNet< PASONodeData, PASOEdgeData >::TNodeI NI = PNet->BegNI(); NI < PNet->EndNI(); NI++)
    {
        cout << "node_id=" << NI.GetId() << endl;
        cout << "NI.GetDat():" << NI.GetDat();
        cout << "PNet->GetNDat():" << PNet->GetNDat(NI.GetId());
        for (int e = 0; e < NI.GetOutDeg(); e++) 
        {
           cout << e << "-th out node id=" << NI.GetOutNId(e) << endl;
           cout << "Edge Data" << PNet->GetEDat(NI.GetId(), NI.GetOutNId(e));
        }
    }
    
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++) 
    {
        int src = EI.GetSrcNId();
        int des = EI.GetDstNId();
        cout <<  EI.GetDat().getGrade() << " " 
             <<  EI.GetDat().getDistance() << " " 
             << src << " " << des << endl;;
    }
#endif
   
    PrintNStats("Test", PNet);
    
  
    int source = 941; 
    int sink = 17166;
    list<int> shortest_path;
    double shortest_path_cost;
    
    int hops_undir = TSnap::GetShortPath(PNet, source, sink);
    int hops_dir = TSnap::GetShortPath(PNet, source, sink, true);
    
    cout << "hops_undir=" << hops_undir 
         << ", hops_dir=" << hops_dir 
         << endl;
   
#if 1   
    ret = PASOUtil::getShortestPath(PNet, source, sink, shortest_path, shortest_path_cost);
    
    cout << "shortest_path_cost=" << shortest_path_cost << endl;
    int idx = 0;
    for(list<int>::iterator li=shortest_path.begin(); li != shortest_path.end(); li++)
    {
        cout << "idx=" << idx << ", node=" << *li << endl;
        idx++;
    }
    PASOUtil::writeToGraFile(PNet, shortest_path, "shortest_path.gra");
#endif    
    return 0;
}
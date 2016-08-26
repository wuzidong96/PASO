#include "Snap.h"
#include "PASONodeData.h"
#include "PASOEdgeData.h"
#include "PASOUtil.h"
#undef min
#undef max
#include <iostream>
#include <vector>
using namespace std;

// Print network statistics
void PrintNStats(const char s[], TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> > Net) {
  printf("network %s, nodes %d, edges %d, empty %s\n",
      s, Net->GetNodes(), Net->GetEdges(),
      Net->Empty() ? "yes" : "no");
}


int main(int argc, char* argv[])
{
    vector<PASONodeData> node_data_v;
    vector<PASOEdgeData> edge_data_v;
    TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> > PNet = TNodeEDatNet< PASONodeData, PASOEdgeData >::New();
    
    //read node data firstly
    int ret = PASOUtil::readNodeFile(node_data_v, PNet, "usa-national_node.txt");
    if(ret == -1)
    {
        cout << "read node file failed" << endl;
    }
    //read edge data secondly
    ret = PASOUtil::readEdgeFile(edge_data_v, PNet, "usa-national_edge.txt");
    if(ret == -1)
    {
        cout << "read edge file failed" << endl;
    }
    //calculate the edge properties
    ret = PASOUtil::calEdgeProperties(PNet);
    
    
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
    
    PrintNStats("Test", PNet);
    
    return 0;
}
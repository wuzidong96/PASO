#ifndef _PASO_UTIL_H
#define _PASO_UTIL_H

#include "Snap.h"
#include "PASONodeData.h"
#include "PASOEdgeData.h"
#undef min
#undef max
#include <vector>
#include <string>
#include <map>
#include <list>

///PASOUtil contains some functions
class PASOUtil
{
    public:
    
    static int readNodeFile(std::vector<PASONodeData>& node_data_v,
                            TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                            const std::string &file_name);
    static int readEdgeFile(std::vector<PASOEdgeData>& edge_data_v,
                            TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                            const std::string &file_name);
                            
    static int calEdgeProperties(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                 const std::map< int, std::vector<double> > &grade_coef_m);
    
    ///read the grade_coeff file and construct a map where the key is 10*grade (change it to int type)
    ///and the value is a double vector (coefa, coefb, coefc, coefd)
    static int readGradeCoefFile(std::map< int, std::vector<double> > &grade_coef_m,
                                 const std::string &file_name);
    
    ///prune the transportation network
    static int prunePASONet(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet);
    
    static int getShortestPath(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                               int source,
                               int sink,
                               std::list<int>& path_o,
                               double& path_cost_o);
    static int writeToGraFile(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                              const std::list<int>& path,
                              const std::string& file_name);
};

#endif
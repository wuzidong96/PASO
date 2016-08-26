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
                            
    static int calEdgeProperties(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet);
    
    static int readGradeCoefFile(std::map< int, std::vector<double> > &grade_coef_m,
                                 const std::string&file_name);
                                           
};

#endif
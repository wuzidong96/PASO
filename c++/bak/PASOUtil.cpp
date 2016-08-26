#include "Snap.h"
#include "PASONodeData.h"
#include "PASOEdgeData.h"
#include "PASOUtil.h"
#undef min
#undef max
#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <sstream>
#include <cmath>

int 
PASOUtil::readNodeFile(std::vector<PASONodeData>& node_data_v,
                       TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                       const std::string &file_name)
{
    std::ifstream ifs;
    ifs.open(file_name.c_str(), std::ifstream::in);
    int idx = 0;
    while(ifs.good())
    {
        std::string one_line;
        std::getline(ifs, one_line);
        std::cout << "get line: " << one_line << std::endl;
        
        if(one_line.empty())
        {
            std::cout << "get an empty line" << std::endl;
            continue;
        }
        
        std::istringstream iss(one_line); 
        double lat, lon, x, y, ele = 0;
        std::string label;
        iss >> label >> lat >> lon >> x >> y >> ele;
        PASONodeData node_data = PASONodeData(lat, lon, x, y, ele, label);
        std::cout << "node_id=" << idx << ": " << node_data;
        node_data_v.push_back(node_data);
        PNet->AddNode(idx, node_data_v[idx]);
        idx++;
    }
    return 0;
}

int 
PASOUtil::readEdgeFile(std::vector<PASOEdgeData>& edge_data_v,
                       TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                       const std::string &file_name)
{
    std::ifstream ifs;
    ifs.open(file_name.c_str(), std::ifstream::in);
    while(ifs.good())
    {
        std::string one_line;
        std::getline(ifs, one_line);
        std::cout << "get line: " << one_line << std::endl;
        
        if(one_line.empty())
        {
            std::cout << "get an empty line" << std::endl;
            continue;
        }
        
        std::istringstream iss(one_line); 
        int src, des = -1;
        std::string label;
        iss >> src >> des >> label;
        
        
        PASOEdgeData edge_data_L = PASOEdgeData(src, des, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, label+'L');
        std::cout << edge_data_L;
        edge_data_v.push_back(edge_data_L);
        PNet->AddEdge(src, des, edge_data_v[edge_data_v.size()-1]);
 
#if 0 
        PASOEdgeData edge_data_R = PASOEdgeData(des, src, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, label+'R');
        std::cout << edge_data_R;
        edge_data_v.push_back(edge_data_R);
        PNet->AddEdge(des, src, edge_data_v[edge_data_v.size()-1]);
#endif
    }
    return 0;
}

int 
PASOUtil::calEdgeProperties(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet)
{    
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++) 
    {
        int src = EI.GetSrcNId();
        int des = EI.GetDstNId();
        const PASONodeData& src_node_data = PNet->GetNDat(src);
        const PASONodeData& des_node_data = PNet->GetNDat(des);
        std::cout << "EI.GetEDat():" << EI.GetDat();
        std::cout << "PNet->GetEDat(" << src << "," << des
                  << "):" << PNet->GetEDat(src, des);
        std::cout << "src_node_data: " << src_node_data;
        std::cout << "des_node_data: " << des_node_data;
        
        double src_x = src_node_data.getX();
        double src_y = src_node_data.getY();
        double src_ele = src_node_data.getEle();
        double des_x = des_node_data.getX();
        double des_y = des_node_data.getY();
        double des_ele = des_node_data.getEle();
        double delta_x = des_x - src_x;
        double delta_y = des_y - src_y;
        double delta_ele = des_ele - src_ele;
        double distance = std::sqrt(std::pow(delta_x,2) + std::pow(delta_y,2));
        
#if 0
        ///delete very short road
        ///@warning Generally we cannot delete elements during the iteration with
        /// iterators, but from the testing, it seems work. Let me change it later.
        if(distance <= 2000) 
        {  
            PNet->DelEdge(src, des);
            std::cout << "distance=" << distance << " < 2000, delete edge(" << src << "," << des << ")" << std::endl;
            continue;
        }
#endif        
        double grade = 100.0*delta_ele/distance;
        EI.GetDat().setDistance(distance);
        EI.GetDat().setGrade(grade);
        std::cout << "EI.GetDat():" << EI.GetDat();
    }
    
    return 0;
}
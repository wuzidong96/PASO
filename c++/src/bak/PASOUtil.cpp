#include "Snap.h"
#include "PASONodeData.h"
#include "PASOEdgeData.h"
#include "PASOUtil.h"
#include "GeographicLib/Geodesic.hpp" //to compute distance between two wgs84 coordinates
#undef min
#undef max
#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <sstream>
#include <cmath>
#include <limits>
#include <algorithm>
#include <list>


int
PASOUtil::constructGraph(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                         const std::string& node_file,
                         const std::string& edge_file,
                         const std::string& coef_file,
                         const std::string& grade_max_speed_file,
                         const std::string& avg_speed_file,
                         const PASOEdgeData::SpeedFunType& type)
{  
    std::map< int, std::vector<double> > grade_coef_m;
    std::map< int, double > grade_max_speed_m;
    //construct the <grade, coef_v> map from the coef file
    PASOUtil::readGradeCoefFile(grade_coef_m, coef_file);
    //read grade_max_speed file to update max_speed, construct <grade, max_sped> map
    PASOUtil::readMaxSpeedFile(grade_max_speed_m, grade_max_speed_file);
 
    std::vector<PASONodeData> node_data_v;
    std::vector<PASOEdgeData> edge_data_v;
    
    //read node data firstly
    int ret = PASOUtil::readNodeFile(node_data_v, PNet, node_file);
    if(ret == -1)
    {
        std::cout << "read node file failed" << std::endl;
        return -1;
    }
    //read edge data secondly
    ret = PASOUtil::readEdgeFile(edge_data_v, PNet, edge_file, type);
    if(ret == -1)
    {
        std::cout << "read edge file failed" << std::endl;
        return -1;
    }
    
    //calculate the edge properties
    ret = PASOUtil::calEdgeProperties(PNet, grade_coef_m, grade_max_speed_m);
    
    //update speed limit according to average speed
    ret = PASOUtil::readAvgSpeedFileAndUpdateMaxSpeed(PNet, avg_speed_file);
    
    //update speed limit, this is the pre-processing
    int n_edge_not_monotonic = 0;
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++) 
    {
     //   int src = EI.GetSrcNId();
     //   int des = EI.GetDstNId();
        EI.GetDat().updateSpeedLimits();
        
        if(EI.GetDat().isValid())
        {
            bool val = EI.GetDat().isFuelTimeFunDecrasing();
            if(!val)
            {
                ///only happens in the case min_speed == max_speed
                n_edge_not_monotonic++;
                //std::cout << "not monotonic: " << EI.GetDat();
            }
        }
    }
    
    std::cout << "constructGraph: n_edge_not_monotonic=" << n_edge_not_monotonic << std::endl;
    
    ///we have finished to construct the graph, print information
    PASOUtil::printNStats(PNet);    
    return 0;
}



int 
PASOUtil::readGradeCoefFile(std::map< int, std::vector<double> > &grade_coef_m,
                            const std::string &file_name)
{
    std::ifstream ifs;
    ifs.open(file_name.c_str(), std::ifstream::in);
    if(!ifs.good())
    {
        std::cout <<"cannot open " << file_name << std::endl;
        return -1;
    }
    std::cout << "readGradeCoefFile " << file_name << std::endl;
    while(ifs.good())
    {
        std::string one_line;
        std::getline(ifs, one_line);
        //std::cout << "get line: " << one_line << std::endl;
        
        if(one_line.empty())
        {
            std::cout << "get an empty line" << std::endl;
            continue;
        }
        
        std::istringstream iss(one_line); 
        double grade, coefa, coefb, coefc, coefd = 0;
        iss >> grade >> coefa >> coefb >> coefc >> coefd;
        int grade_key = grade*10;
        std::vector< double > coef_v;
        coef_v.push_back(coefa);
        coef_v.push_back(coefb);
        coef_v.push_back(coefc);
        coef_v.push_back(coefd);
        grade_coef_m[grade_key] = coef_v;
    }
    return 0;
}
                                           
int 
PASOUtil::readMaxSpeedFile(std::map< int, double >& grade_max_speed_m,
                           const std::string &file_name)
{
    std::ifstream ifs;
    ifs.open(file_name.c_str(), std::ifstream::in);
    if(!ifs.good())
    {
        std::cout <<"cannot open " << file_name << std::endl;
        return -1;
    }
   // std::cout << "readMaxSpeedFile " << file_name << std::endl;
    while(ifs.good())
    {
        std::string one_line;
        std::getline(ifs, one_line);
       // std::cout << "get line: " << one_line << std::endl;

        if(one_line.empty())
        {
            std::cout << "get an empty line" << std::endl;
            continue;
        }
        
        std::istringstream iss(one_line); 
        double grade, max_speed = 0;
        iss >> grade >> max_speed;
        int grade_key = grade*10;
        grade_max_speed_m[grade_key] = max_speed;
    }
    return 0;    
}
                               
                                

int 
PASOUtil::readNodeFile(std::vector<PASONodeData>& node_data_v,
                       TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                       const std::string &file_name)
{
    std::ifstream ifs;
    ifs.open(file_name.c_str(), std::ifstream::in);
    if(!ifs.good())
    {
        std::cout <<"cannot open " << file_name << std::endl;
        return -1;
    }
    std::cout << "readNodeFile " << file_name << std::endl;
    int idx = 0;
    while(ifs.good())
    {
        std::string one_line;
        std::getline(ifs, one_line);
        //std::cout << "get line: " << one_line << std::endl;
        
        if(one_line.empty())
        {
            std::cout << "get an empty line" << std::endl;
            continue;
        }
        
        std::istringstream iss(one_line); 
        double lat, lon, ele = 0;
        std::string label;
        iss >> label >> lat >> lon >> ele;
        PASONodeData node_data = PASONodeData(lat, lon, ele, label);
        //std::cout << "node_id=" << idx << ": " << node_data;
        node_data_v.push_back(node_data);
        PNet->AddNode(idx, node_data_v[idx]);
        idx++;
    }
    return 0;
}

int 
PASOUtil::readEdgeFile(std::vector<PASOEdgeData>& edge_data_v,
                       TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                       const std::string& file_name,
                       const PASOEdgeData::SpeedFunType& type)
{
    std::ifstream ifs;
    ifs.open(file_name.c_str(), std::ifstream::in);
    if(!ifs.good())
    {
        std::cout <<"cannot open " << file_name << std::endl;
        return -1;
    }
    std::cout << "readEdgeFile " << file_name << std::endl;
    while(ifs.good())
    {
        std::string one_line;
        std::getline(ifs, one_line);
        //std::cout << "get line: " << one_line << std::endl;
        if(one_line.empty())
        {
            std::cout << "get an empty line" << std::endl;
            continue;
        }
        
        std::istringstream iss(one_line); 
        int src, des = -1;
        std::string label;
        iss >> src >> des >> label;
        
        
        PASOEdgeData edge_data_L = PASOEdgeData(false, src, des, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, label+'L',type);
        //std::cout << edge_data_L;
        edge_data_v.push_back(edge_data_L);
        PNet->AddEdge(src, des, edge_data_v[edge_data_v.size()-1]);
 
#if 1 
        PASOEdgeData edge_data_R = PASOEdgeData(false, des, src, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, label+'R',type);
        //std::cout << edge_data_R;
        edge_data_v.push_back(edge_data_R);
        PNet->AddEdge(des, src, edge_data_v[edge_data_v.size()-1]);
#endif
    }
    return 0;
}

int 
PASOUtil::getNodeFrom22NodeFile(int idx, 
                                const std::string& file_name)
{
    if(idx < 1 || idx > 22)
    {
        std::cout << "invalid idx, should be in [1,22]" << std::endl;
        return -1;
    }
    std::ifstream ifs;
    ifs.open(file_name.c_str(), std::ifstream::in);
    if(!ifs.good())
    {
        std::cout <<"cannot open " << file_name << std::endl;
        return -1;
    }
    std::cout << "getNodeFrom22NodeFile " << file_name << std::endl;
    while(ifs.good())
    {
        std::string one_line;
        std::getline(ifs, one_line);
        //std::cout << "get line: " << one_line << std::endl;
        
        if(one_line.empty())
        {
            std::cout << "get an empty line" << std::endl;
            continue;
        }
        
        std::istringstream iss(one_line); 
        int input_idx = 0, node_idx = 0;
        double lat=0, lon = 0;
        iss >> input_idx >> node_idx >> lat >> lon;
        if(input_idx == idx)
        {
            return node_idx;
        }     
    }
    return 0;    
}

int 
PASOUtil::calEdgeProperties(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                            const std::map< int, std::vector<double> > &grade_coef_m,
                            const std::map< int, double >& grade_max_speed_m,
                            bool doRandomSpeedLimits)
{    
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++) 
    {
        int src = EI.GetSrcNId();
        int des = EI.GetDstNId();
        const PASONodeData& src_node_data = PNet->GetNDat(src);
        const PASONodeData& des_node_data = PNet->GetNDat(des);
#if 0
        std::cout << "EI.GetEDat():" << EI.GetDat();
        std::cout << "PNet->GetEDat(" << src << "," << des
                  << "):" << PNet->GetEDat(src, des);
        std::cout << "src_node_data: " << src_node_data;
        std::cout << "des_node_data: " << des_node_data;
#endif    
        ///all of here are in units of meters
        double src_ele = src_node_data.getEle();
        double des_ele = des_node_data.getEle();
        double delta_ele = des_ele - src_ele;
        
        double src_lat = src_node_data.getLat();
        double src_lon = src_node_data.getLon();
        double des_lat = des_node_data.getLat();
        double des_lon = des_node_data.getLon();
        //distance in xy-plane in meters
        double xy_distance;
        const GeographicLib::Geodesic& geod = GeographicLib::Geodesic::WGS84();
        geod.Inverse(src_lat, src_lon, des_lat, des_lon, xy_distance);
        
        double grade = 100.0*delta_ele/xy_distance;
        ///we should set distance in xyz-plane in units of miles
        double distance_meters = std::sqrt( std::pow(xy_distance,2.0) + std::pow(delta_ele, 2.0));
        double distance_miles = distance_meters/1609.34;
        ///we consider speed in untis of mph
        ///we should set it later!!
        double speed_min = 30.0;
        double speed_max = 70.0;
        
        ///get speed limits randomly
        if(doRandomSpeedLimits)
        {
            setRandomSpeedLimits(speed_min, speed_max);
        }
        
        ///travel time is in units of hours
        double time_min = distance_miles/speed_max;
        double time_max = distance_miles/speed_min;
       
        EI.GetDat().setDistance(distance_miles);
        EI.GetDat().setSpeedMin(speed_min);
        EI.GetDat().setSpeedMax(speed_max);
        EI.GetDat().setTimeMin(time_min);
        EI.GetDat().setTimeMax(time_max);
        //will automatically set grade_key
        EI.GetDat().setGrade(grade);
        
        ///round grade to the earliest level
        ///Note that grade is in percentage, e.g., grade=6 means 6% slope.
        ///But in our <grade, coef_v> map, each grade_key is 10*grade, an int type.
        int grade_key = EI.GetDat().getGradeKey();
         
        std::map< int, std::vector<double> >::const_iterator mi = grade_coef_m.find(grade_key);
        
        if(mi == grade_coef_m.end())
        {
          //  std::cout << "cannot find grade key=" << grade_key << " for grade=" 
          //            << grade << std::endl;
            EI.GetDat().setValid(false);
            double inf = std::numeric_limits<double>::infinity();
            EI.GetDat().setCoefA(inf);
            EI.GetDat().setCoefB(inf);
            EI.GetDat().setCoefC(inf);
            EI.GetDat().setCoefD(inf);
            continue;
        }
        else
        {   
            std::vector<double> coef_v = mi->second;
            double coef_a = coef_v[0];
            double coef_b = coef_v[1];
            double coef_c = coef_v[2];
            double coef_d = coef_v[3];
            EI.GetDat().setValid(true); 
            EI.GetDat().setCoefA(coef_a);
            EI.GetDat().setCoefB(coef_b);
            EI.GetDat().setCoefC(coef_c);
            EI.GetDat().setCoefD(coef_d);             
        }
        
        ///update the max speed here
        std::map< int, double >::const_iterator grade_mi = grade_max_speed_m.find(grade_key);
        if(grade_mi != grade_max_speed_m.end())
        {
            double grade_max_speed = grade_mi->second;
            if(grade_max_speed < EI.GetDat().getSpeedMax())
            {
                if(grade_max_speed < EI.GetDat().getSpeedMin()) //speed_min > grade_max_speed
                {
                    EI.GetDat().setValid(false);
                }
                else //speed_min <= grade_max_speed <= speed_max
                {
                    ///update the max speed
                    EI.GetDat().setSpeedMax(grade_max_speed);
                    EI.GetDat().setTimeMin(EI.GetDat().getDistance()/grade_max_speed);
                //    std::cout << "update (grade_key, speed_max)=(" << grade_key 
                //              << ", " << grade_max_speed << ")" << std::endl;
                }
            }
        }

    //    std::cout << "EI.GetDat():" << EI.GetDat();
    }
    
    return 0;
}


int 
PASOUtil::prunePASONet(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                       int source,
                       int sink,
                       double T)
{
    ///first prune all invalid edges
    int n_edge_invalid = 0;
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++)
    {
        int src = EI.GetSrcNId();
        int des = EI.GetDstNId();
        if(EI.GetDat().isValid() == false)
        {
            PNet->DelEdge(src, des);
            n_edge_invalid++;
            //std::cout << " not valid, thus delete edge(" << src << "," << des << ")" << std::endl;
            continue;
        }  
    }
    std::cout << "prunePASONet: n_edge_invalid=" << n_edge_invalid << std::endl;
/*** Do not prune nodes, it takes a lot of time!
    int n_node_not_feasible_in_time = 0;
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TNodeI NI = PNet->BegNI(); NI < PNet->EndNI(); NI++)
    {
        int node_id = NI.GetId();
        std::vector<int> path_1;
        std::vector<int> path_2;
        double minimal_time_1 = std::numeric_limits<double>::infinity();
        double minimal_time_2 = std::numeric_limits<double>::infinity();
        int ret1 = getShortestPath(PNet, source, node_id, "time_min",path_1,minimal_time_1);
        if(ret1 == -1 || minimal_time_1 > T)
        {
            PNet->DelNode(node_id);
            n_node_not_feasible_in_time++;
            continue;
        }
        int ret2 = getShortestPath(PNet, node_id, sink,"time_min",path_2,minimal_time_2);
        if(ret2 == -1 || minimal_time_1 + minimal_time_2 > T)
        {
            PNet->DelNode(node_id);
            n_node_not_feasible_in_time++;
        }  
    }
    std::cout << "prunePASONet: n_node_not_feasible_in_time=" << n_node_not_feasible_in_time << std::endl;
***/   
    printNStats(PNet);
    return 0;
}


int 
PASOUtil::prunePASONetToEast(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                       int source,
                       int sink,
                       double T)
{
    int n_node_west = 0;
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TNodeI NI = PNet->BegNI(); NI < PNet->EndNI(); NI++)
    {
        int node_id = NI.GetId();
        double lon = NI.GetDat().getLon();
        if(lon <= -100.0)
        {
            PNet->DelNode(node_id);
            n_node_west++;
        }  
    }
    std::cout << "prunePASONetToEast: n_node_west=" << n_node_west << std::endl;
    printNStats(PNet);
    return 0;
}

int
PASOUtil::prunePASONetWithinLatLon(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                   double lat_min,
                                   double lat_max,
                                   double lon_min,
                                   double lon_max,
                                   int source,
                                   int sink,
                                   double T)
{
    int n_node_not_in_region = 0;
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TNodeI NI = PNet->BegNI(); NI < PNet->EndNI(); NI++)
    {
        int node_id = NI.GetId();
        double lat = NI.GetDat().getLat();
        double lon = NI.GetDat().getLon();
        if(lat < lat_min || lat > lat_max ||
           lon < lon_min || lon > lon_max)
        {
            PNet->DelNode(node_id);
            n_node_not_in_region++;
        }  
    }
    std::cout << "prunePASONetWithinLatLon: n_node_not_in_region=" << n_node_not_in_region << std::endl;
    printNStats(PNet);
    return 0;
    
}    


int 
PASOUtil::mergePASONet(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet)
{
    ///remember first prune all invalid edges
    int n_node_merged = 0;
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++)
    {
        ///edge (src, des)
        int src = EI.GetSrcNId();
        int des = EI.GetDstNId();
        int effective_out_degree = 0;
        int effective_out_node = -1;
        for (int e = 0; e < PNet->GetNI(des).GetOutDeg(); e++)
        {
            int nbr = PNet->GetNI(des).GetOutNId(e);
            if(nbr != src)
            {
                effective_out_degree++;
                effective_out_node = nbr;
            }
        }
        if(effective_out_degree == 1)
        {
            const PASOEdgeData& edge_data_1 = PNet->GetEDat(src,des);
            const PASOEdgeData& edge_data_2 = PNet->GetEDat(des,effective_out_node);  
            ///same grade key
            if(edge_data_1.getGradeKey() == edge_data_2.getGradeKey())
            {   
                ///the forward direction
                PASOEdgeData edge_data_merge_1 = edge_data_1 + edge_data_2;     
                if(!edge_data_merge_1.isValid()) 
                {
                    std::cout << "edge_data_1=" << edge_data_1 << std::endl;
                    std::cout << "edge_data_2=" << edge_data_2 << std::endl;
                    std::cout << "edge_data_merge_1=" << edge_data_merge_1 << std::endl;        
                    std::cout << "mergePASONet: merge failed" << std::endl;
                    return -1;
                }
                //add new edges
                PNet->AddEdge(src, effective_out_node, edge_data_merge_1);
                
                /// the reverse direction           
                bool is_reverse_valid = (PNet->IsEdge(effective_out_node,des) && 
                                        PNet->IsEdge(des,src));
                if(is_reverse_valid)
                {
                    const PASOEdgeData& edge_data_3 = PNet->GetEDat(effective_out_node,des);
                    const PASOEdgeData& edge_data_4 = PNet->GetEDat(des,src);
                    PASOEdgeData edge_data_merge_2 = edge_data_3 + edge_data_4;
                    if(!edge_data_merge_2.isValid()) 
                    {
                        std::cout << "edge_data_3=" << edge_data_3 << std::endl;
                        std::cout << "edge_data_4=" << edge_data_4 << std::endl;
                        std::cout << "edge_data_merge_2=" << edge_data_merge_2 << std::endl;        
                        std::cout << "mergePASONet: merge failed" << std::endl;
                        return -1;
                    }
                    PNet->AddEdge(effective_out_node, src, edge_data_merge_2); 
                }  
                
                //delete the node des
                PNet->DelNode(des);
                n_node_merged++;
                //std::cout << "mergePASONet: delete node=" << des << std::endl;
                //sanity check
                if( PNet->IsNode(des) ||
                    PNet->IsEdge(src,des) ||
                    PNet->IsEdge(des,src) ||
                    PNet->IsEdge(des,effective_out_node) ||
                    PNet->IsEdge(effective_out_node,des))
                {
                    std::cout << "mergePASONet: sanity check failed" << std::endl;
                    return -1;
                }       
            }
        }
    }
    std::cout << "mergePASONet: n_node_merged=" << n_node_merged << std::endl;
    printNStats(PNet);
    return 0;
}

///We follow the pseudocode here 
// https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
/**
 1  function Dijkstra(Graph, source):
 2
 3      create vertex set Q
 4
 5      for each vertex v in Graph:             // Initialization
 6          dist[v] ← INFINITY                  // Unknown distance from source to v
 7          prev[v] ← UNDEFINED                 // Previous node in optimal path from source
 8          add v to Q                          // All nodes initially in Q (unvisited nodes)
 9
10      dist[source] ← 0                        // Distance from source to source
11      
12      while Q is not empty:
13          u ← vertex in Q with min dist[u]    // Source node will be selected first
14          remove u from Q 
15          
16          for each neighbor v of u:           // where v is still in Q.
17              alt ← dist[u] + length(u, v)
18              if alt < dist[v]:               // A shorter path to v has been found
19                  dist[v] ← alt 
20                  prev[v] ← u 
21
22      return dist[], prev[]

If we are only interested in a shortest path between vertices source and target, 
we can terminate the search after line 13 if u = target. 
Now we can read the shortest path from source to target by reverse iteration:
**/
int 
PASOUtil::getShortestPath(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                          int source,
                          int sink,
                          const std::string& type,
                          std::vector<int>& path_o,
                          double& path_cost_o,
                          double lambda)
{
    if(!PNet->IsNode(source))
    {
        std::cout << "not node for source=" << source << std::endl;
        path_cost_o = std::numeric_limits<double>::infinity();
        return -1;
    }
    else if(!PNet->IsNode(sink))
    {
        std::cout << "not node for sink="<< sink << std::endl;
        path_cost_o = std::numeric_limits<double>::infinity();
        return -1;
    }
    
    ///initialize. Note that node id is not required
    // to be consecutive for SNAP. Thus we get the max_node_id
    int max_node_id = PNet->GetMxNId();
    std::vector<double> dist_v(max_node_id,std::numeric_limits<double>::infinity());
    std::vector<int> prev_v(max_node_id,-1);
    ///TODO: we can implement not_visited_l as a priority queue 
    std::list<int> not_visited_l;
    for(TNodeEDatNet<PASONodeData, PASOEdgeData>::TNodeI ni = PNet->BegNI(); ni != PNet->EndNI(); ni++)
    {
        int node_id = ni.GetId();
        dist_v[node_id] = std::numeric_limits<double>::infinity();
        prev_v[node_id] = -1;
        not_visited_l.push_back(node_id);
    }
    dist_v[source] = 0;
    
    ///main loop
    while(!not_visited_l.empty())
    {
        //std::cout << "not_visited_l.size()=" << not_visited_l.size() << std::endl; 
        ///find the node with minimal weight
        int u = -1;
        double dist_min = std::numeric_limits<double>::infinity();
        std::list<int>::iterator li_min = not_visited_l.end();
        for(std::list<int>::iterator li=not_visited_l.begin(); li != not_visited_l.end(); li++)
        {
            double dist_temp = dist_v[*li];
            if( dist_temp < dist_min)
            {
                dist_min = dist_temp;
                u = *li;
                li_min = li;
               // std::cout << "find u=" << u << std::endl;
            }
        }
        
        if(li_min == not_visited_l.end())
        {
            std::cout << "cannot find a path from source=" << source
                      << " to sink=" << sink << std::endl;
            path_cost_o = std::numeric_limits<double>::infinity();
            return -1;
        }
        //remove node u from not_visited_l
        not_visited_l.erase(li_min);
        //terminate if u is the sink
        if(u==sink)
        {
            std::cout << "visit sink=" << sink 
                      << ", with dist[sink]=" << dist_v[sink] 
                      << " with prev[sink]=" << prev_v[sink] << std::endl;
            break;
        }
        //update the distance of each outgoing neighbour of u
        TNodeEDatNet<PASONodeData, PASOEdgeData>::TNodeI ni = PNet->GetNI(u);
        for (int e = 0; e < ni.GetOutDeg(); e++) 
        {
            int v= ni.GetOutNId(e);
            double cost;
            if(type == "distance")
            {
                cost = PNet->GetEDat(u,v).getDistance();
            }
            else if(type == "time_min")
            {
                cost = PNet->GetEDat(u,v).getTimeMin();
            }
            else if(type == "new_weight")
            {
                cost = PNet->GetEDat(u,v).newWeightGivenLambda(lambda);
            }
            else
            {
                std::cout << "wrong type" << std::endl;
                path_cost_o = std::numeric_limits<double>::infinity();
                return -1;
            }
            double new_dist = cost + dist_v[u];
            if( new_dist< dist_v[v])
            {
                dist_v[v] = new_dist;
                prev_v[v] = u;
                
                //std::cout << "update v=" << v << " with dist[v]=" << dist_v[v]
                //          << ", with prev[v]=" << prev_v[v] << std::endl;
            }
        }
    }
    
    ///output result
    if(dist_v[sink] == std::numeric_limits<double>::infinity())
    {
        std::cout << "cannot find a path from source=" << source
                  << " to sink=" << sink << std::endl;
        path_cost_o = std::numeric_limits<double>::infinity();
        return -1;
    }
    
    
    path_cost_o = dist_v[sink];
    
    std::list<int> path_list;
    int u = sink;
    while(u != source)
    {
        path_list.push_front(u);
        u = prev_v[u];    
    }
    ///remember to push source  into the list!!!
    path_list.push_front(u);
    
    path_o.clear();
    for(std::list<int>::iterator li=path_list.begin(); li != path_list.end(); li++)
    {
        path_o.push_back(*li);
    }
    return 0;
}

///write a path (which consists a sequence of nodes) into a gra file
int 
PASOUtil::writeToGraFile(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                         const std::vector<int>& path,
                         const std::string& file_name)
{
    int n_node = path.size();
    int n_edge = n_node-1;
    std::ofstream ofs(file_name.c_str(), std::ofstream::trunc);
    std::cout <<"writeToGraFile " << file_name << std::endl;
    if(!ofs.is_open())
    {
        std::cout << "cannot open the file " << file_name << std::endl;
        return -1;
    }
    ofs << n_node << " " << n_edge << std::endl;
    for(size_t i=0; i < path.size(); i++)
    {
        int node_id = path[i];
        TNodeEDatNet<PASONodeData, PASOEdgeData>::TNodeI ni = PNet->GetNI(node_id);
        std::string label = ni.GetDat().getLabel();
        double lat = ni.GetDat().getLat();
        double lon = ni.GetDat().getLon();
        ofs << label << " " << lat << " " << lon << std::endl;
    }
    

    for(size_t i=0; i < path.size()-1; i++)
    {
        int src_id = path[i];
        int des_id = path[i+1]; 
        TNodeEDatNet<PASONodeData, PASOEdgeData>::TEdgeI ei = PNet->GetEI(src_id, des_id);
        std::string label = ei.GetDat().getLabel();
        ///note that we increment idx here!!
        ofs << i << " " << i+1 << " " << label << std::endl;
    }
    
    return 0;
}


///wirte the solution into file 
int 
PASOUtil::writeSolutionToFile(const PASOSolution& sol,
                              const std::string& file_name)
{
    std::ofstream ofs(file_name.c_str(), std::ofstream::trunc);
    std::cout <<"writeSolutionToFile " << file_name << std::endl;
    if(!ofs.is_open())
    {
        std::cout << "cannot open the file " << file_name << std::endl;
        return -1;
    }
    
    const std::vector<int>& path = sol.getPath();
    for(int i=0; i < path.size()-1; i++)
    {
        int src = path[i];
        int des = path[i+1];
        //formate: src,des,time,speed,cost
        ofs << src  << ","
            << des  << ","
            << sol.getTimeI(i) << "," 
            << sol.getSpeedI(i) << ","
            << sol.getFuelCostI(i) << std::endl;
    }
    return 0;
}

int 
PASOUtil::getSinglePathWithTimeMin(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                   const std::vector<int>& path,
                                   int source,
                                   int sink,
                                   double T,
                                   PASOSolution& sol_o)
{
    ///number of nodes in the path
    int n = path.size(); 
    if(path[0] != source || path[n-1] != sink) 
    {
        std::cout << "wrong path" << std::endl;
        return -1;
    }
    
    sol_o = PASOSolution(path);
    
    ///number of edges/links over the path
    int m = n - 1;    
    double sum_time_min = 0;
    for(int i=0; i < m; i++)
    {
        int src = path[i];
        int des = path[i+1];
        PASOEdgeData& edge_data = PNet->GetEDat(src, des);
        double time = edge_data.getTimeMin();
        sol_o.setTimeI(i, time);
        sum_time_min += time;
    }
    
    sol_o.update(PNet);
    
    if(T < sum_time_min)
    {
        std::cout << "T < sum_time_min, infeasible" << std::endl;
        return -1;
    }
    return 0;
}


int 
PASOUtil::optimizeSinglePath(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                             const std::vector<int>& path,
                             int source,
                             int sink,
                             double T,
                             PASOSolution& sol_o)
{
    ///number of nodes in the path
    int n = path.size(); 
    if(path[0] != source || path[n-1] != sink) 
    {
        std::cout << "wrong path" << std::endl;
        return -1;
    }
    
    sol_o = PASOSolution(path);
    
    ///number of edges/links over the path
    int m = n - 1;
    
    ///pre-processing
    double sum_time_min = 0;
    double sum_time_max = 0;
    std::vector<double> time_max_v(m, 0.0);
    for(size_t i=0; i < m; i++)
    {
        int src = path[i];
        int des = path[i+1];
        if(!PNet->IsEdge(src,des))
        {
            std::cout << "not an edge, wrong path" << std::endl;
            return -1;
        }
        
        PASOEdgeData& edge_data = PNet->GetEDat(src, des);
        sum_time_min += edge_data.getTimeMin();
        sum_time_max += edge_data.getTimeMax();
        time_max_v[i] = edge_data.getTimeMax();  
    }
    
    if(T < sum_time_min)
    {
        std::cout << "T < sum_time_min, infeasible" << std::endl;
        return -1;
    }
    
    if(T >= sum_time_max)
    {
        std::cout << "T >= sum_time_max, take the maximal time as the solution" << std::endl;
        sol_o.setTime(time_max_v);
        sol_o.update(PNet);
        return 0;
    }
    
    ///here sum_time_min < T < sum_time_max
    ///we use binary search to find a lambda such that delta(lambda) = 0
    double lambda_lb = 0;
    ///initialize a sufficiently large lambda_ub
    double lambda_ub = 1024;
    ///begin at any one side
    double lambda = lambda_lb;
    double delta = sum_time_max;
    double tol = 1e-6;
    int max_iter = 40;
    int iter = 0;
    ///do not use std::fabs, which will convert double to float!!
    while(std::abs(delta-T) > tol && iter <= max_iter)
    {
        iter++;
        std::cout << "iter=" << iter << std::endl;
        if(delta - T > tol)
        {
            lambda_lb = lambda;
        }
        else if(delta - T < -tol)
        {
            lambda_ub = lambda;
        }
        lambda = (lambda_lb + lambda_ub)/2.0;
        ///get delta, and keep update time_o
        delta = 0;
        for(size_t i=0; i < m; i++)
        {
            int src = path[i];
            int des = path[i+1];
            PASOEdgeData& edge_data = PNet->GetEDat(src, des);
            double time = edge_data.bestTravelTimeGivenLambda(lambda);
            sol_o.setTimeI(i, time);
            delta += time;
        }
        std::cout << "lambda=" << lambda << ", delta=" <<delta 
                  << ", std::abs(delta-T)=" << std::abs(delta-T) 
                  << ", tol=" << tol << std::endl;
    }
    
    sol_o.update(PNet);
    return 0;
}

int 
PASOUtil::optimizeNetworkDual(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                              int source,
                              int sink,
                              double T,
                              PASOSolution& sol_lb_o,
                              PASOSolution& sol_ub_o) 
{
    ///here sum_time_min < T < sum_time_max
    ///we use binary search to find a lambda such that delta(lambda) = 0
    double lambda_lb = 0;
    ///initialize a sufficiently large lambda_ub
    double lambda_max = 0;
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++) 
    {
        double val = EI.GetDat().minimalLambda();
        if(val > lambda_max)
        {
            lambda_max = val;
        }
    }
    double lambda_ub = lambda_max;
    ///begin at any one side
    double lambda = lambda_lb;
    double delta = T+10;
    double tol = 1e-5;
    ///do not use std::fabs, which will convert double to float!!
    int max_iter = 40;
    int iter = 0;
    std::vector<int> path_v;
    std::vector<double> time_v;
    double new_weight_cost = 0;
    PASOSolution sol;
    while(std::abs(delta-T) > tol && iter <= max_iter)
    {
        iter++;
        std::cout << "iter=" << iter << std::endl;
        if(delta - T > tol)
        {
            lambda_lb = lambda;
            sol_lb_o = sol;
            std::cout << "sol_lb_o=" << sol_lb_o << std::endl;
        }
        else if(delta - T < -tol)
        {
            lambda_ub = lambda;
            sol_ub_o = sol;
            std::cout << "sol_ub_o=" << sol_ub_o << std::endl;
        }
        lambda = (lambda_lb + lambda_ub)/2.0;

        int ret = PASOUtil::getShortestPath(PNet, source, sink, "new_weight", path_v, new_weight_cost, lambda);
        if(ret == -1)
        {
            std::cout << "cannot find a path" << std::endl;
            return -1;
        }

        ///get delta
        delta = 0;
        time_v = std::vector<double>(path_v.size()-1, 0);
        for(size_t i=0; i < path_v.size()-1; i++)
        {
            int src = path_v[i];
            int des = path_v[i+1];
            PASOEdgeData& edge_data = PNet->GetEDat(src, des);
            double time = edge_data.bestTravelTimeGivenLambda(lambda);
            time_v[i] = time;
            delta += time;
        }
        sol = PASOSolution(path_v);
        sol.setTime(time_v);
        sol.update(PNet);
    
        std::cout << "lambda=" << lambda << ", delta=" <<delta 
                  << ", std::abs(delta-T)=" << std::abs(delta-T) 
                  << ", tol=" << tol << std::endl;
        
        ///T is very large can be satisfied now and get the optimal solution,
        ///which is the delay-unconstrained optimal solution
        if(lambda < tol && delta < T+tol)
        {
            std::cout << "T=" << T << " is very large, satisfied, lambda is near 0, delta < T, terminate" << std::endl; 
            break;          
        }
        ///T is very small, cannot achieve such delay, infeasible
        if(lambda > lambda_max-tol && delta > T-tol)
        {
            std::cout <<"T=" << T << " is very small, cannot be achieved, delta > T, terminate" << std::endl;
            return -1;
        }
        
    }
    return 0;
}


int 
PASOUtil::getDeltaLambdaFun(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                            int source,
                            int sink,
                            const std::string& file_name)   
{
    std::ofstream ofs(file_name.c_str(), std::ofstream::trunc);
    std::cout <<"getDeltaLambdaFun, write to file " << file_name << std::endl;
    if(!ofs.is_open())
    {
        std::cout << "cannot open the file " << file_name << std::endl;
        return -1;
    }
  

    for(double lambda = 0.0; lambda <= 70.0; lambda = lambda + 0.1)
    {
        std::vector<int> path_v;
        std::vector<double> time_v;
        double new_weight_cost = 0.0;
        int ret = PASOUtil::getShortestPath(PNet, source, sink, "new_weight", path_v, new_weight_cost, lambda);
        if(ret == -1)
        {
            std::cout << "cannot find a path" << std::endl;
            return -1;
        }

        ///get delta
        double delta = 0;
        time_v = std::vector<double>(path_v.size()-1, 0);
        for(size_t i=0; i < path_v.size()-1; i++)
        {
            int src = path_v[i];
            int des = path_v[i+1];
            PASOEdgeData& edge_data = PNet->GetEDat(src, des);
            double time = edge_data.bestTravelTimeGivenLambda(lambda);
            time_v[i] = time;
            delta += time;
        }
        ofs << lambda << "," << delta << std::endl;
    }
    return 0;
}




void 
PASOUtil::printGradeCoef(const std::map< int, std::vector<double> >& grade_coef_m)
{
    for(std::map< int, std::vector<double> >::const_iterator mi=grade_coef_m.begin(); mi != grade_coef_m.end(); mi++)
    {
        int grade_key = mi->first;
        std::vector<double> coef_v = mi->second;
        double coefa = coef_v[0];
        double coefb = coef_v[1];
        double coefc = coef_v[2];
        double coefd = coef_v[3];

        std::cout << "(grade_key,coefa,coefb,coefc,coefd)=(" 
                  << grade_key << ","
                  << coefa << ","
                  << coefb << ","
                  << coefc << ","
                  << coefd << ")" 
                  << std::endl;
    }
}

void 
PASOUtil::printGradeMaxSpeed(const std::map< int, double >& grade_max_speed_m)
{
    for(std::map<int, double>::const_iterator mi=grade_max_speed_m.begin(); mi != grade_max_speed_m.end(); mi++)
    {
        int grade_key = mi->first;
        double max_speed = mi->second;
        std::cout << "(grade_key, max_speed)=("
                  << grade_key << ","
                  << max_speed << ")"
                  << std::endl;
    }
}

void
PASOUtil::printAllEdgeFuelFun(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                              const std::string& file_name)
{   
    std::ofstream ofs(file_name.c_str(), std::ofstream::trunc);
    std::cout <<"printAllEdgeFuelFun, write to file " << file_name << std::endl;
    if(!ofs.is_open())
    {
        std::cout << "cannot open the file " << file_name << std::endl;
        return;
    }
  
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++) 
    {
        int src = EI.GetSrcNId();
        int des = EI.GetDstNId();
        double distance = EI.GetDat().getDistance();
        double speed_min = EI.GetDat().getSpeedMin();
        double speed_max = EI.GetDat().getSpeedMax();
        double time_min = EI.GetDat().getTimeMin();
        double time_max = EI.GetDat().getTimeMax();
        
        ofs << "(" << src << "," << des << "): (distance, speed_min, speed_max, time_min, time_max)=("
             << distance << "," << speed_min << ", " << speed_max << "," 
             << time_min << "," << time_max  << ")" << std::endl;
        for(double speed = speed_min; speed <= speed_max + 1e-10; speed++)
        {
            double time = distance/speed;
            double fuel = EI.GetDat().fuelTimeFun(time);
            ofs << speed << " " << time << " " << fuel << std::endl;
        }
    }
}

// Print network statistics
void 
PASOUtil::printNStats(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet) 
{
    double avg_distance = 0.0;
    double avg_speed_min = 0.0;
    double avg_speed_max = 0.0;
    double avg_abs_grade = 0.0;
    int n_valid_edges = 0;
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++) 
    {
        if(EI.GetDat().isValid())
        {
            n_valid_edges++;
            avg_distance += EI.GetDat().getDistance();
            avg_speed_min += EI.GetDat().getSpeedMin();
            avg_speed_max += EI.GetDat().getSpeedMax();
            avg_abs_grade += std::abs(EI.GetDat().getGrade());
        }
    }
    avg_distance = avg_distance/(double) n_valid_edges;
    avg_speed_min = avg_speed_min/(double) n_valid_edges;
    avg_speed_max = avg_speed_max/(double) n_valid_edges;
    avg_abs_grade = avg_abs_grade/(double) n_valid_edges;
    std::cout << "network with nodes " << PNet->GetNodes()
              << ", edges " << PNet->GetEdges() 
              << ", n_valid_edges " << n_valid_edges 
              << ", avg_distance " << avg_distance
              << ", avg_speed_min " << avg_speed_min
              << ", avg_speed_max " << avg_speed_max
              << ", avg_abs_grade " << avg_abs_grade
              << std::endl;
}


int
PASOUtil::setRandomSpeedLimits(double& speed_min, double& speed_max)
{
    //std::srand(std::time(0)); // use current time as seed for random generator
    int rv = std::rand();
    //at least 30mph
    speed_max = std::max(100.0*(rv/double(RAND_MAX)), 30.0);
    //at most 70mph
    speed_max = std::min(speed_max, 70.0);
    //at least 30mph
    speed_min = std::max(speed_max/2.0, 30.0);
    
 //   std::cout  << "speed_max=" << speed_max  << " "
 //              << "speed_min=" << speed_min << std::endl;
    return 0;
}




void 
PASOUtil::printAllNodeInfo(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                           const std::string& file_name)
{
    std::ofstream ofs(file_name.c_str(), std::ofstream::trunc);
    std::cout <<"printAllEdgeFuelFun, write to file " << file_name << std::endl;
    if(!ofs.is_open())
    {
        std::cout << "cannot open the file " << file_name << std::endl;
        return;
    }
    ofs << "id,lat,lon,ele,label" << std::endl;
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TNodeI NI = PNet->BegNI(); NI < PNet->EndNI(); NI++) 
    {
        ofs << NI.GetId() << ","
                  << NI.GetDat().getLat() << ","
                  << NI.GetDat().getLon() << ","
                  << NI.GetDat().getEle() << ","
                  << NI.GetDat().getLabel() 
                  << std::endl;
    }    
    
}


void 
PASOUtil::printAllEdgeInfo(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                           const std::string& file_name)
{
    std::ofstream ofs(file_name.c_str(), std::ofstream::trunc);
    std::cout <<"printAllEdgeFuelFun, write to file " << file_name << std::endl;
    if(!ofs.is_open())
    {
        std::cout << "cannot open the file " << file_name << std::endl;
        return;
    }
    ofs << "src, des, distance, speed_min, speed_max, time_min, time_max, grade, grade_key, label" << std::endl;
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++) 
    {
        int src = EI.GetSrcNId();
        int des = EI.GetDstNId();
        double distance = EI.GetDat().getDistance();
        double speed_min = EI.GetDat().getSpeedMin();
        double speed_max = EI.GetDat().getSpeedMax();
        double time_min = EI.GetDat().getTimeMin();
        double time_max = EI.GetDat().getTimeMax();
        double grade = EI.GetDat().getGrade();
        int grade_key = EI.GetDat().getGradeKey();
        std::string label = EI.GetDat().getLabel();
        ofs << src << "," 
                  << des << ","
                  << distance << "," 
                  << speed_min << ","
                  << speed_max << ","
                  << time_min << ","
                  << time_max << ","
                  << grade  << ","
                  << grade_key << ","
                  << label 
                  << std::endl;
    }    
    
}



int 
PASOUtil::readAvgSpeedFileAndUpdateMaxSpeed(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                            const std::string &file_name)
{
    std::ifstream ifs;
    ifs.open(file_name.c_str(), std::ifstream::in);
    if(!ifs.good())
    {
        std::cout <<"cannot open " << file_name << std::endl;
        return -1;
    }
    std::cout << "readAvgSpeedFileAndUpdateMaxSpeed " << file_name << std::endl;
    while(ifs.good())
    {
        std::string one_line;
        std::getline(ifs, one_line);
        //std::cout << "get line: " << one_line << std::endl;
        
        if(one_line.empty())
        {
            std::cout << "get an empty line" << std::endl;
            continue;
        }
        
        std::istringstream iss(one_line); 
        int src, des, avg_speed_pos, avg_speed_neg = 0;
        std::string label;
        iss >> src >> des >> label >> avg_speed_pos >> avg_speed_pos;
        if(avg_speed_pos > 0)
        {
            ///keep in mind that we only update when the original max speed is larger than the avg speed!!
            double orig_max_speed = PNet->GetEDat(src, des).getSpeedMax();
            if(avg_speed_pos < orig_max_speed)
            {
                PNet->GetEDat(src, des).updateSpeedMax(avg_speed_pos);
            }
        }
        if(avg_speed_neg > 0)
        {
            double orig_max_speed = PNet->GetEDat(des, src).getSpeedMax();
            if(avg_speed_neg < orig_max_speed)
            {
                PNet->GetEDat(des, src).updateSpeedMax(avg_speed_neg);
            }
        }
        
    }
    return 0;    
}


bool 
PASOUtil::testProcedure(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                        int source,
                        int sink,
                        double T,  
                        double L,
                        double U,
                        double delta,
                        PASOSolution& sol_o,
                        long elapsed_time_second_o,
                        double memory_usage_GB_o)
{
/*********************************** time and memory usage ****************************/    
    struct timeval time_start, time_end;
	gettimeofday(&time_start, NULL);
    
    //add variables
	struct rusage usage;
	getrusage(RUSAGE_SELF, &usage);
	long memory_usage1 = usage.ru_maxrss;
	std::cout << "before testProcedure: ru_maxrss: " << memory_usage1 << "KB="
              << memory_usage1/1024.0/1024.0
              << "GB" << std::endl;
/*********************************** time and memory usage ****************************/

    std::cout << "source=" << source << ", sink=" << sink << ", T=" << T 
         << ", L=" << L
         << ", U=" << U
         << ", delta=" << delta
         << std::endl;
         
    int n_node = PNet->GetNodes();
    double V = L*delta/double(n_node+1);
    int N = std::floor(U/V) + n_node + 1;
    
    std::cout << "n_node=" << n_node 
               << ", V=" << V
               << ", N=" << N 
               << std::endl;
    
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++) 
    {
       int src = EI.GetSrcNId();
       int des = EI.GetDstNId();
      // std::cout << "quantize (" << src << "," << des <<")" << std::endl;
       EI.GetDat().quantizeFuelTimeFun(V,N+1);
      // EI.GetDat().printQuantizedValueAndRepresentativeTime();
    }
    std::cout << "finish quantize" << std::endl;
    // we use the node id (int) to be the index of g, g[v] is a vector of size N+1
    // Note that the node id is not necessary contiguous, we should use the size mad_node_id 
    // g[v][c] is the minimal s-v path travel time whose path cost is within c=0,1,...,N 
    int max_node_id = PNet->GetMxNId ();
    std::vector< std::vector<double> > g(max_node_id);
    std::vector<int> prev_node_v(max_node_id,-1);
    std::vector<double> prev_time_v(max_node_id,-1);
    bool doFind = false;
    for(TNodeEDatNet<PASONodeData, PASOEdgeData>::TNodeI ni = PNet->BegNI(); ni != PNet->EndNI(); ni++)
    {
        int node_id = ni.GetId();
        if(node_id == source)
        {
            g[node_id] = std::vector<double>(N+1, 0.0);
        }
        else
        {
            g[node_id] = std::vector<double>(N+1, std::numeric_limits<double>::infinity());
        }
    }
    for (int c=1; c<= N; c++)
    {
        //std::cout << "c=" << c << std::endl;
        for(TNodeEDatNet<PASONodeData, PASOEdgeData>::TNodeI ni = PNet->BegNI(); ni != PNet->EndNI(); ni++)
        {
            int node_id = ni.GetId();
  //          std::cout << "node_id=" << node_id << std::endl;
            g[node_id][c] = g[node_id][c-1];
            for(int n=0; n < ni.GetInDeg(); n++)
            {
                    
                //get the previous incoming edge
                int prev_node_id = ni.GetInNId(n);
                //get the quantized information
                const std::vector<int>& quantized_value = PNet->GetEDat(prev_node_id, node_id).getQuantizedValue();
                const std::vector<double>& representative_time = PNet->GetEDat(prev_node_id, node_id).getRepresentativeTime();
                for(int i=0; i < quantized_value.size(); i++)
                {

                    int value = quantized_value[i];
                    double time = representative_time[i];
                    
                    if(node_id == 59399)
                    {            
                        std::cout << "come to 59399 c=" << c << ", i=" << i << ", quantized_value[i]=" << quantized_value[i] << std::endl;
                        std::cout << "value=" << value << ", time=" << time << std::endl;
                    }
                  
                    if(value <= c)
                    {
                        if( g[prev_node_id][c-value]+time < g[node_id][c])
                        {
                            std::cout << "update for c=" << c 
                                      << ", i=" << i
                                      << ", value=" << value 
                                      << ", time=" << time
                                      << ", node_id=" << node_id
                                      << ", prev_node_id=" << prev_node_id
                                      <<", g[prev_node_id][c-value]+time=" << g[prev_node_id][c-value]+time
                                      << ", g[node_id][c]=" << g[node_id][c] 
                                      << std::endl;
                            prev_node_v[node_id] = prev_node_id;
                            prev_time_v[node_id] = time;
                            g[node_id][c] = g[prev_node_id][c-value]+time;
                        }            
                    }
                }
            }
        }
        std::cout << "g[sink][c]=" << g[sink][c] << std::endl;
        if(g[sink][c] <= T)
        {
            std::cout << "Find a path ..., c=" << c << ", g[sink][c]=" << g[sink][c] << std::endl;
            
            std::list<int> path_list;
            std::list<double> time_list;
            int u = sink;
            double time = prev_time_v[sink];
            while(u != source)
            {
                path_list.push_front(u);
                time_list.push_front(time);
                u = prev_node_v[u];
                time = prev_time_v[u];                
            }
            ///remember to push source  into the list!!!
            path_list.push_front(u);
            std::vector<int> path_v;
            std::vector<double> time_v;
            for(std::list<int>::iterator li=path_list.begin(); li != path_list.end(); li++)
            {
                path_v.push_back(*li);
            }
            for(std::list<double>::iterator li=time_list.begin(); li != time_list.end(); li++)
            {
                time_v.push_back(*li);
            }
            
            sol_o = PASOSolution(path_v);
            sol_o.setTime(time_v);
            sol_o.update(PNet);
            doFind = true;
            break;
        }
    }
/*********************************** time and memory usage ****************************/     
    getrusage(RUSAGE_SELF, &usage);
	long memory_usage2 = usage.ru_maxrss;
	std::cout << "after setting testProcedure: ru_maxrss: " << memory_usage2 << "KB="
     	      << memory_usage2/1024.0/1024.0 << "GB" << std::endl;
    std::cout << "during testProcedure: delta_ru_maxrss: " << memory_usage2-memory_usage1 << "KB="
     	      << (memory_usage2-memory_usage1)/1024.0/1024.0 << "GB" << std::endl;  
    memory_usage_GB_o = (memory_usage2-memory_usage1)/1024.0/1024.0; 
    gettimeofday(&time_end ,NULL);
	elapsed_time_second_o = time_end.tv_sec - time_start.tv_sec;
	std::cout << "Elapsed Time for testProcedure: " << elapsed_time_second_o << std::endl; 
/*********************************** time and memory usage ****************************/ 

    return doFind;
}



int 
PASOUtil::approximationScheme(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                              int source,
                              int sink,
                              double T,  
                              double lb,
                              double ub,
                              double epsilon,
                              PASOSolution& sol_o)
{
/*********************************** time and memory usage ****************************/    
    struct timeval time_start, time_end;
	long elapsed_seconds;
	gettimeofday(&time_start, NULL);
    
    //add variables
	struct rusage usage;
	getrusage(RUSAGE_SELF, &usage);
	long memory_usage1 = usage.ru_maxrss;
	std::cout << "before approximationScheme: ru_maxrss: " << memory_usage1 << "KB="
              << memory_usage1/1024.0/1024.0
              << "GB" << std::endl;
/*********************************** time and memory usage ****************************/

    double bl = lb;
    double bu = ub;
    double max_memory_usage_GB = 0.0;
    double sum_elapsed_time_second = 0.0;
    
    std::cout << "Begin step 2" << std::endl;
    while (bu/bl > 16)
    {
        double V = std::sqrt(bl*bu);
        std::cout << "bl=" << bl
                  << ", bu=" << bu
                  << ", V=" << V << std::endl;
        PASOSolution sol;
        long elapsed_time_second_temp = 0.0;
        double memory_usage_GB_temp = 0.0;
        bool ret = testProcedure(PNet, source, sink, T, V, V, 1.0, sol,elapsed_time_second_temp,memory_usage_GB_temp);
        sum_elapsed_time_second += elapsed_time_second_temp;
        if(memory_usage_GB_temp > max_memory_usage_GB)
        {
            max_memory_usage_GB = memory_usage_GB_temp;
        }
        if( ret == false)
        {
            bl = V;
        }
        else
        {
            bu = 2.0*V;
        }
        std::cout << "bl=" << bl
                  << ", bu=" << bu
                  << ", V=" << V << std::endl;
    }
    
    std::cout << "Begin step 3" << std::endl;
    long elapsed_time_second_step_3 = 0.0;
    double memory_usage_GB_step_3 = 0.0;
    testProcedure(PNet, source, sink, T, bl, bu, epsilon, sol_o,elapsed_time_second_step_3,memory_usage_GB_step_3);
    sum_elapsed_time_second += elapsed_time_second_step_3;
    if(memory_usage_GB_step_3 > max_memory_usage_GB)
    {
        max_memory_usage_GB = memory_usage_GB_step_3;
    }
    
/*********************************** time and memory usage ****************************/     
    getrusage(RUSAGE_SELF, &usage);
	long memory_usage2 = usage.ru_maxrss;
	std::cout << "after setting approximationScheme: ru_maxrss: " << memory_usage2 << "KB="
     	      << memory_usage2/1024.0/1024.0 << "GB" << std::endl;
    std::cout << "during approximationScheme: delta_ru_maxrss: " << memory_usage2-memory_usage1 << "KB="
     	      << (memory_usage2-memory_usage1)/1024.0/1024.0 << "GB" << std::endl;    
    gettimeofday(&time_end ,NULL);
	elapsed_seconds = time_end.tv_sec - time_start.tv_sec;
	std::cout << "Elapsed Time for approximationScheme: " << elapsed_seconds << std::endl; 
    std::cout << "sum_elapsed_time_second: " << sum_elapsed_time_second << std::endl;
    std::cout << "memory_usage_GB_step_3: " << memory_usage_GB_step_3 << std::endl;
/*********************************** time and memory usage ****************************/       
    return 0;    
}

int 
PASOUtil::runOneInstance(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                         int source,
                         int sink,
                         double T,
                         const std::string& path_fastest_gra_file,
                         const std::string& path_shortest_gra_file,
                         const std::string& path_lb_gra_file,
                         const std::string& path_ub_gra_file,
                         const std::string& path_opt_gra_file,
                         const std::string& sol_fastest_path_time_min_file,
                         const std::string& sol_fastest_path_opt_file,
                         const std::string& sol_shortest_path_time_min_file,
                         const std::string& sol_shortest_path_opt_file,
                         const std::string& sol_lb_file,
                         const std::string& sol_ub_file,
                         const std::string& sol_opt_file,
                         const std::string& info_file)
{
/*********************************** time and memory usage ****************************/    
    struct timeval time_start, time_end;
	long elapsed_seconds;
	gettimeofday(&time_start, NULL);
    
    //add variables
	struct rusage usage;
	getrusage(RUSAGE_SELF, &usage);
	long memory_usage1 = usage.ru_maxrss;
	std::cout << "before runOneInstance: ru_maxrss: " << memory_usage1 << "KB="
              << memory_usage1/1024.0/1024.0
              << "GB" << std::endl;
/*********************************** time and memory usage ****************************/
 
    
    std::cout << "runOneInstance (source,sink,T)=" << "(" << source << "," << sink << "," << T << ")" << std::endl;
    ///fastest path and shortest path and optimal path
    std::vector<int> path_fastest;
    std::vector<int> path_shortest;
    std::vector<int> path_lb;
    std::vector<int> path_ub;
    std::vector<int> path_opt;
    ///minimal travel time
    double minimal_path_hours;
    ///minimal travel distance
    double minimal_path_miles;
    ///five solutions
    PASOSolution sol_fastest_path_time_min;
    PASOSolution sol_fastest_path_opt;
    PASOSolution sol_shortest_path_time_min;
    PASOSolution sol_shortest_path_opt;
    PASOSolution sol_lb;
    PASOSolution sol_ub;
    PASOSolution sol_opt; 
    PASOSolution sol_approx;
    ///epsilon
    double epsilon = 0.01;
    ///lb and ub for OPT, should be determined by optimizeNetworkDual()
    double lb;
    double ub;
    int ret;
/* ========================================= fastest path ===================================================*/   
    ///get the fastest path here
    ret = PASOUtil::getShortestPath(PNet, source, sink, "time_min", path_fastest, minimal_path_hours);
    if(ret == -1)
    {
        std::cout << "cannot find a (" << source << "," << sink << ")" << "-path" << std::endl;
        return -1;
    }
    std::cout << "minimal_path_hours=" << minimal_path_hours << std::endl;
    
    ///terminate if sum_time_min is larger than T
    if(minimal_path_hours > T - 1e-5)
    {
        std::cout << "minimal_path_hours > T, terminate" << std::endl; 
        return -1;
    }
    ///terminate if T is larger than sum_time_min+10
    if(T > minimal_path_hours + 10.0 - 1e-5)
    {
        std::cout << "T > minimal_path_hours + 10.0, terminate" << std::endl; 
        return -1;
    }    

    ///do not optimize the fastest path, but just use the max speed (min time) over the fastest path
    ret = PASOUtil::getSinglePathWithTimeMin(PNet, path_fastest, source, sink, T, sol_fastest_path_time_min);
    std::cout << "sol_fastest_path_time_min: " << sol_fastest_path_time_min << std::endl;
    PASOUtil::writeSolutionToFile(sol_fastest_path_time_min, sol_fastest_path_time_min_file); 
   
    ///optimize the fastest path
    ret = PASOUtil::optimizeSinglePath(PNet, path_fastest, source, sink, T, sol_fastest_path_opt);
    if(ret == -1)
    {
        std::cout << "optimizeSinglePath failed" << std::endl;
        //return -1;
    }
    std::cout << "sol_fastest_path_opt: " << sol_fastest_path_opt << std::endl;
    PASOUtil::writeSolutionToFile(sol_fastest_path_opt, sol_fastest_path_opt_file);

    ///write to fastest path into gra file
    PASOUtil::writeToGraFile(PNet, path_fastest, path_fastest_gra_file);
/* ========================================= shortest path ===================================================*/   
   ///get the shortest path here
    ret = PASOUtil::getShortestPath(PNet, source, sink, "distance", path_shortest, minimal_path_miles);
    if(ret == -1)
    {
        std::cout << "cannot find a (" << source << "," << sink << ")" << "-path" << std::endl;
        return -1;
    }
    std::cout << "minimal_path_miles=" << minimal_path_miles << std::endl;
    
    ///do not optimize the shortest path, but just use the max speed (min time) over the shortest path
    ret = PASOUtil::getSinglePathWithTimeMin(PNet, path_shortest, source, sink, T, sol_shortest_path_time_min);
    std::cout << "sol_shortest_path_time_min: " << sol_shortest_path_time_min << std::endl; 
    PASOUtil::writeSolutionToFile(sol_shortest_path_time_min, sol_shortest_path_time_min_file);  
    
    ///optimize the shortest path
    ret = PASOUtil::optimizeSinglePath(PNet, path_shortest, source, sink, T, sol_shortest_path_opt);
    if(ret == -1)
    {
        std::cout << "optimizeSinglePath failed" << std::endl;
        //return -1;
    }
    std::cout << "sol_shortest_path_opt: " << sol_shortest_path_opt << std::endl;      
    PASOUtil::writeSolutionToFile(sol_shortest_path_opt, sol_shortest_path_opt_file);
    
    ///write to shortest path into gra file
    PASOUtil::writeToGraFile(PNet, path_shortest, path_shortest_gra_file);   
/* ========================================= optimal path ===================================================*/      
    ///get the optimal path via dual solution 
    ret = PASOUtil::optimizeNetworkDual(PNet, source, sink, T, sol_lb, sol_ub);
    lb = sol_lb.getTotalFuelCost();
    ub = sol_ub.getTotalFuelCost();
    std::cout << "lb=" << lb << ", ub=" << ub << std::endl;
    if(ret == -1)
    {
        std::cout << "optimizeNetworkDual failed" << std::endl;
        //return -1;
    }
    sol_opt = sol_ub;
    std::cout << "sol_opt: " << sol_opt << std::endl;
    PASOUtil::writeSolutionToFile(sol_lb, sol_lb_file);
    PASOUtil::writeSolutionToFile(sol_ub, sol_ub_file);
    PASOUtil::writeSolutionToFile(sol_opt, sol_opt_file);
    
    path_lb = sol_lb.getPath();
    path_ub = sol_ub.getPath();
    path_opt = sol_opt.getPath();
    ///write to optimal path into gra file
    PASOUtil::writeToGraFile(PNet, path_lb, path_lb_gra_file);
    PASOUtil::writeToGraFile(PNet, path_ub, path_ub_gra_file);
    PASOUtil::writeToGraFile(PNet, path_opt, path_opt_gra_file);   
/* ===================================== approximation scheme ==========================================*/
    ///get the approximate scheme
    //lb = 1; ub = 100;
    if( ub <= lb*(1.0+epsilon))
    {
        std::cout << "we get an epsilon-approximation sol by using the heuristic algorithm" << std::endl;
    }
    else
    {
        //do nothing first
        // PASOUtil::approximationScheme(PNet,source,sink, T, lb, ub, epsilon, sol_approx);
        std::cout << "do nothing..." << std::endl;
    }
/*============================================ result summary ===================================*/
    ///write into csv file, with the following items
    
    /*******************************************************
    1 source
    2 sink
    3 T
    4 fastest_path_time_min: time (hours)
    5 fastest_path_time_min: distance (miles)
    6 fastest_path_time_min: fuel (gallons)
    7 fastest_path_opt: time (hours)
    8 fastest_path_opt: distance (miles)
    9 fastest_path_opt: fuel (gallons)
    10 shortest_path_time_min: time (hours)
    11 shortest_path_time_min: distance (miles)
    12 shortest_path_time_min: fuel (gallons)
    13 shortest_path_opt: time (hours)
    14 shortest_path_opt: distance (miles)
    15 shortest_path_opt: fuel (gallons)
    16 optimal_solution: time (hours)
    17 optimal_solution: distance (miles)
    18 optimal_solution: fuel (gallons)
    ********************************************************/   
    std::ofstream ofs(info_file.c_str(), std::fstream::trunc);
    std::cout <<"write info to file " << info_file << std::endl;
    if(!ofs.is_open())
    {
        std::cout << "cannot open the file " << info_file << std::endl;
        return -1;
    }
    
    ofs << source << "," 
        << sink << "," 
        << T << "," 
        << sol_fastest_path_time_min << ","
        << sol_fastest_path_opt << ","
        << sol_shortest_path_time_min << ","
        << sol_shortest_path_opt << ","
        << sol_lb << ","
        << sol_ub << ","
        << sol_opt << std::endl;
        
    ///output to std::cout for checking
    std::cout << source << "," << sink << "," << T << std::endl;
    std::cout << "sol_fastest_path_time_min: " << sol_fastest_path_time_min << std::endl;
    std::cout << "sol_fastest_path_opt: " << sol_fastest_path_opt << std::endl;
    std::cout << "sol_shortest_path_time_min: " << sol_shortest_path_time_min << std::endl;
    std::cout << "sol_shortest_path_opt: " << sol_shortest_path_opt << std::endl;
    std::cout << "sol_lb: " << sol_lb << std::endl;
    std::cout << "sol_ub: " << sol_ub << std::endl;
    std::cout << "sol_opt: " << sol_opt << std::endl;  
    
    
/*********************************** time and memory usage ****************************/     
    getrusage(RUSAGE_SELF, &usage);
	long memory_usage2 = usage.ru_maxrss;
	std::cout << "after setting runOneInstance: ru_maxrss: " << memory_usage2 << "KB="
     	      << memory_usage2/1024.0/1024.0 << "GB" << std::endl;
    std::cout << "during runOneInstance: delta_ru_maxrss: " << memory_usage2-memory_usage1 << "KB="
     	      << (memory_usage2-memory_usage1)/1024.0/1024.0 << "GB" << std::endl;    
    gettimeofday(&time_end ,NULL);
	elapsed_seconds = time_end.tv_sec - time_start.tv_sec;
	std::cout << "Elapsed Time for approximationScheme: " << elapsed_seconds << std::endl; 
/*********************************** time and memory usage ****************************/     
    
    return 0;
}
                                  
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
#include <limits>
#include <algorithm>
#include <list>

int 
PASOUtil::readGradeCoefFile(std::map< int, std::vector<double> > &grade_coef_m,
                            const std::string &file_name)
{
    std::ifstream ifs;
    ifs.open(file_name.c_str(), std::ifstream::in);
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
        //std::cout << "get line: " << one_line << std::endl;
        
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
                       const std::string &file_name)
{
    std::ifstream ifs;
    ifs.open(file_name.c_str(), std::ifstream::in);
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
        
        
        PASOEdgeData edge_data_L = PASOEdgeData(false, src, des, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, label+'L');
        //std::cout << edge_data_L;
        edge_data_v.push_back(edge_data_L);
        PNet->AddEdge(src, des, edge_data_v[edge_data_v.size()-1]);
 
#if 1 
        PASOEdgeData edge_data_R = PASOEdgeData(false, des, src, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, label+'R');
        //std::cout << edge_data_R;
        edge_data_v.push_back(edge_data_R);
        PNet->AddEdge(des, src, edge_data_v[edge_data_v.size()-1]);
#endif
    }
    return 0;
}

int 
PASOUtil::calEdgeProperties(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                            const std::map< int, std::vector<double> > &grade_coef_m)
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
        
        double grade = 100.0*delta_ele/distance;
        
        ///round grade to the earliest level
        ///Note that grade is in percentage, e.g., grade=6 means 6% slope.
        ///But in our <grade, coef_v> map, each grade_key is 10*grade, an int type.
        int grade_key = std::floor(grade*10+0.5);
         
        std::map< int, std::vector<double> >::const_iterator mi = grade_coef_m.find(grade_key);
        
        if(mi == grade_coef_m.end())
        {
            std::cout << "cannot find grade key=" << grade_key << " for grade=" 
                      << grade << std::endl;
            EI.GetDat().setValid(false);
            continue;
        }
        
        std::vector<double> coef_v = mi->second;
        double coef_a = coef_v[0];
        double coef_b = coef_v[1];
        double coef_c = coef_v[2];
        double coef_d = coef_v[3];
        
        
        ///we should set distance in units of miles
        double distance_miles = distance/1609.34;
        ///we consider speed in untis of mph
        ///we should set it later!!
        double speed_min = 30.0;
        double speed_max = 70.0;
        ///travel time is in units of hours
        double time_min = distance_miles/speed_max;
        double time_max = distance_miles/speed_min;
       
        EI.GetDat().setValid(true);  
        EI.GetDat().setDistance(distance_miles);
        EI.GetDat().setSpeedMin(speed_min);
        EI.GetDat().setSpeedMax(speed_max);
        EI.GetDat().setTimeMin(time_min);
        EI.GetDat().setTimeMax(time_max);
        EI.GetDat().setGrade(grade);
        EI.GetDat().setCoefA(coef_a);
        EI.GetDat().setCoefB(coef_b);
        EI.GetDat().setCoefC(coef_c);
        EI.GetDat().setCoefD(coef_d);
    //    std::cout << "EI.GetDat():" << EI.GetDat();
    }
    
    return 0;
}


int 
PASOUtil::prunePASONet(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet)
{
    for (TNodeEDatNet< PASONodeData, PASOEdgeData >::TEdgeI EI = PNet->BegEI(); EI < PNet->EndEI(); EI++)
    {
        int src = EI.GetSrcNId();
        int des = EI.GetDstNId();
        if(EI.GetDat().isValid() == false)
        {
            PNet->DelEdge(src, des);
            std::cout << " not valid, thus delete edge(" << src << "," << des << ")" << std::endl;
            continue;
        }
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
    }
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
                          std::list<int>& path,
                          double& path_cost)
{
    if(!PNet->IsNode(source))
    {
        std::cout << "not node for source=" << source << std::endl;
        return -1;
    }
    else if(!PNet->IsNode(sink))
    {
        std::cout << "not node for sink="<< sink << std::endl;
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
        std::cout << "not_visited_l.size()=" << not_visited_l.size() << std::endl; 
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
            path_cost = std::numeric_limits<double>::infinity();
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
            double cost = PNet->GetEDat(u,v).getDistance();
            double new_dist = cost + dist_v[u];
            if( new_dist< dist_v[v])
            {
                dist_v[v] = new_dist;
                prev_v[v] = u;
                std::cout << "update v=" << v << " with dist[v]=" << dist_v[v]
                          << ", with prev[v]=" << prev_v[v] << std::endl;
            }
        }
    }
    
    ///output result
    if(dist_v[sink] == std::numeric_limits<double>::infinity())
    {
        std::cout << "cannot find a path from source=" << source
                  << " to sink=" << sink << std::endl;
        path_cost = std::numeric_limits<double>::infinity();
        return -1;
    }
    
    path_cost = dist_v[sink];
    int u = sink;
    while(u != source)
    {
        path.push_front(u);
        u = prev_v[u];    
    }
    return 0;
}

///write a path (which consists a sequence of nodes) into a gra file
int 
PASOUtil::writeToGraFile(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                         const std::list<int>& path,
                         const std::string& file_name)
{
    int n_node = path.size();
    int n_edge = n_node-1;
    std::ofstream ofs(file_name.c_str(), std::ofstream::trunc);
    if(!ofs.is_open())
    {
        std::cout << "cannot open the file " << file_name << std::endl;
        return -1;
    }
    ofs << n_node << " " << n_edge << std::endl;
    for(std::list<int>::const_iterator li=path.begin(); li != path.end(); li++)
    {
        int node_id = *li;
        TNodeEDatNet<PASONodeData, PASOEdgeData>::TNodeI ni = PNet->GetNI(node_id);
        std::string label = ni.GetDat().getLabel();
        double lat = ni.GetDat().getLat();
        double lon = ni.GetDat().getLon();
        ofs << label << " " << lat << " " << lon << std::endl;
    }
    
    std::list<int>::const_iterator li=path.begin();
    int idx = 0;
    while(1)
    {
        int src_id = *li;
        ///note that we have increment li here!
        int des_id = *(++li);
        
        if(li == path.end())
        {
            break;
        }
        
        TNodeEDatNet<PASONodeData, PASOEdgeData>::TEdgeI ei = PNet->GetEI(src_id, des_id);
        std::string label = ei.GetDat().getLabel();
        ///note that we increment idx here!!
        ofs << idx << " " << idx+1 << " " << label << std::endl;
        
        double distance = ei.GetDat().getDistance();
        std::cout << idx << " " << idx+1 << " " << distance << std::endl;
        
        idx++;
    }
    
    return 0;
}
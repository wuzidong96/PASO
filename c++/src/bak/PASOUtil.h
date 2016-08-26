#ifndef _PASO_UTIL_H
#define _PASO_UTIL_H

#include "Snap.h"
#include "PASONodeData.h"
#include "PASOEdgeData.h"
#include "PASOSolution.h"
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
    
    ///put all stuff here to construct the graph, including setting all parameters
    static int constructGraph(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                              const std::string& node_file,
                              const std::string& edge_file,
                              const std::string& coef_file,
                              const std::string& grade_max_speed_file,
                              const std::string& avg_speed_file,
                              const PASOEdgeData::SpeedFunType& type);
    
    
    
    static int readNodeFile(std::vector<PASONodeData>& node_data_v,
                            TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                            const std::string &file_name);
    static int readEdgeFile(std::vector<PASOEdgeData>& edge_data_v,
                            TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                            const std::string &file_name,
                            const PASOEdgeData::SpeedFunType& type);
                            
    static int calEdgeProperties(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                 const std::map< int, std::vector<double> > &grade_coef_m,
                                 const std::map< int, double >& grade_max_speed_m,
                                 bool doRandomSpeedLimits = false);
    
    ///read the average speed limit file and update the max speed
    static int readAvgSpeedFileAndUpdateMaxSpeed(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                                 const std::string &file_name);
                                                 
    ///read the grade_coeff file and construct a map where the key is 10*grade (change it to int type)
    ///and the value is a double vector (coefa, coefb, coefc, coefd)
    static int readGradeCoefFile(std::map< int, std::vector<double> > &grade_coef_m,
                                 const std::string &file_name);
    
    ///read the grade_max_speed file to update the max_speed
    static int readMaxSpeedFile(std::map< int, double >& grade_max_speed_m,
                                const std::string &file_name); 
    
    ///merge the PASO network according to the edge grade_key
    ///For any edge (u,v), when v has only one outgoing edge, say (v,w), except (v,u),
    ///we will merge (u,v) and (v,w) into (u,w) and delete node v.
    ///Note that we also need to construct edge (w,u)
    ///The grade will be set as the average of them.
    ///The min/max speed will also be set as the average of them. 
    static int mergePASONet(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet);
    
    ///prune the transportation network
    static int prunePASONet(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                            int source = 0,
                            int sink = 0,
                            double T = 0.0);
                            
    ///prune the transportation network to eastern US
    static int prunePASONetToEast(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                  int source = 0,
                                  int sink = 0,
                                  double T = 0.0);     
                                  
    ///prune the transportation network within given lat lon such that all nodes
    ///are in the region [lat_min, lat_max]x[lon_min, lon_max]
    static int prunePASONetWithinLatLon(TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                        double lat_min,
                                        double lat_max,
                                        double lon_min,
                                        double lon_max,
                                        int source = 0,
                                        int sink = 0,
                                        double T = 0.0);                                       
    
    ///find a shortest path
    //@param source source node id
    //@param sink sink node id
    //@param type cost type
    //  - type = "distance", path distance
    //  - type = "time_min", path minimal travel time
    //  - type = "new_weight", h(t)= c(t) + lambda t, where t is the best travel time, must give a lambda
    //@param path_o, output shortest path which consists of a sequence of node ids
    //@param path_cost_o, the cost of shortest path
    static int getShortestPath(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                               int source,
                               int sink,
                               const std::string& type,
                               std::vector<int>& path_o,
                               double& path_cost_o,
                               double lambda = 0);
     
     
    ///return the cost over a given path where each path use max speed/min time, say path.size() = n
    //@param path  given path, a sequence of node ids, must have path[0] = source, path[n-1] = sink  
    //@param source source node id
    //@param sink sink node id
    //@param T total delay
    //@param sol_o  the output solution
    static int getSinglePathWithTimeMin(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                        const std::vector<int>& path,
                                        int source,
                                        int sink,
                                        double T,
                                        PASOSolution& sol_o);                               
                               
                               
                               
    ///optimize over a given path, say path.size() = n
    //@param path  given path, a sequence of node ids, must have path[0] = source, path[n-1] = sink  
    //@param source source node id
    //@param sink sink node id
    //@param T total delay
    //@param sol_o  the output solution
    static int optimizeSinglePath(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                  const std::vector<int>& path,
                                  int source,
                                  int sink,
                                  double T,
                                  PASOSolution& sol_o);
                                  
    ///optimize over the whole graph, say path_o = n
    //@param source source node id
    //@param sink sink node id
    //@param T total delay
    //@param sol_lb_o  the output lower bound solution (T is violated, travel time > T)
    //@param sol_ub_o  the output upper bound solution (T is respected, travel time < T)
    //@NOTE  sol_lb_o = sol_ub_o if  T is achieved, i.e., T is respected, travel time = T.
    static int optimizeNetworkDual(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                   int source,
                                   int sink,
                                   double T,
                                   PASOSolution& sol_lb_o,
                                   PASOSolution& sol_ub_o);
    
    ///get the delta(lambda) function and write into file_name
    static int getDeltaLambdaFun(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                 int source,
                                 int sink,
                                 const std::string& file_name);   
         
    ///write the path into gra file
    static int writeToGraFile(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                              const std::vector<int>& path,
                              const std::string& file_name);
    
    ///wirte the solution into file
    static int writeSolutionToFile(const PASOSolution& sol,
                                   const std::string& file_name);
                                    
    ///print out some informations
    static void printGradeCoef(const std::map< int, std::vector<double> >& grade_coef_m);
    static void printGradeMaxSpeed(const std::map< int, double >& grade_max_speed_m);
    static void printAllEdgeFuelFun(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                    const std::string& file_name);
    static void printAllEdgeInfo(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                 const std::string& file_name);
    static void printAllNodeInfo(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                 const std::string& file_name);
    static void printNStats(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet);
    
    
    
    ///randomly set the speed limits
    static int setRandomSpeedLimits(double& speed_min, double& speed_max);
    
    /// the test procedure
    //  @param PNet  the underlying network instance
    //  @param source, sink, T is the input instance
    //  @param lb the input lower bound for OPT of PASO problem
    //  @param ub the input upper bound for OPT of PASO problem
    //  @param delta the input parameter to control quantization accuracy
    //  @param sol_o the output solution if it return true
    //  @param elapsed_time_second_o output the running time in seconds during one invoke
    //  @param memory_usage_GB_o output the memory usage in KB during  one invoke
    //  @return return true if it can find a solution, return false (fail) otherwise.
    static bool testProcedure(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                              int source,
                              int sink,
                              double T,    
                              double lb,
                              double ub,
                              double delta,
                              PASOSolution& sol_o,
                              long elapsed_time_second_o,
                              double memory_usage_GB_o);
                              
    /// the approximation scheme
    //  @param PNet  the underlying network instance
    //  @param source, sink, T is the input instance
    //  @param lb the input initial lower bound for OPT of PASO problem
    //  @param ub the input initial upper bound for OPT of PASO problem
    //  @param epsilon the input parameter to ensure (1+epsilon)-approximation ratio
    //  @param sol_o the output solution 
    //  @note normally we should first use optimizeNetworkDual to get a lb and ub for OPT
    static int approximationScheme(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
                                   int source,
                                   int sink,
                                   double T,    
                                   double lb,
                                   double ub,
                                   double epsilon,
                                   PASOSolution& sol_o);
    
    ///get the real node id from the idx [1 to 22] 
    //from the input finename
    static int getNodeFrom22NodeFile(int idx, 
                                     const std::string& file_name);
    
    ///one instance, running a (source, sink T) instance and write the result to the input files
    static int runOneInstance(const TPt <TNodeEDatNet<PASONodeData, PASOEdgeData> >& PNet,
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
                              const std::string& info_file);
};

#endif
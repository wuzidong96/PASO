classdef DataInstance < handle
    %DataInstance Class for transportation network topology
    %used to collect data through ADVISOR
    
    properties (SetAccess = public, GetAccess = public)
        %Input Data
        
        % vehicle data
        %vehecile file name, e.g., input_veh_file = 'HeavyTruck_in'
        input_veh_file;
        
        % road data
        %constant road grade, e.g., input_grade = 0.2;
        input_grade;
        
        % driving cycle data
        %driving cycle constant speed (units: mph), e.g. input_speed = 20
        input_speed;
        %driving cycle time (units: second)
        input_time;
        
        %Output Data
        
        %total distance traveled, (units: mile)
        output_dist;
        %total gallons of fuel consumed (units: gallon)
        output_gal;
        %average fuel economy for the drive cycle (for the type of fuel
        %used) (units: mile/gallon)
        output_mpg;
        %drive cycle miles per gallon gasoline equivalent (units: mile/gallon)
        output_mpgge;
        %average fuel economy (units: gallon/hour)
        output_gph; 
        
        %corrected values when deleting the accelarating process but just
        %keeping the interval with constant speed
        output_dist_c;
        output_gal_c;
        output_mpg_c;
        output_mpgge_c;
        output_gph_c;
    end
    
    methods
        
        function obj = DataInstance()
        end
        
        function writeToFile(obj, filename)  
            fid = fopen(filename, 'a');
            if(fid == -1)
                disp('cannot open the file CYC_MY.m');
                return;
            end
            fprintf(fid, '%s,', obj.input_veh_file);
            fprintf(fid, '%f,', obj.input_grade);
            fprintf(fid, '%f,', obj.input_speed);
            fprintf(fid, '%f,', obj.input_time);
            fprintf(fid, '%f,', obj.output_dist);
            fprintf(fid, '%f,', obj.output_mpg);
            fprintf(fid, '%f,', obj.output_mpgge);
            fprintf(fid, '%f,', obj.output_gph);
            fprintf(fid, '%f,', obj.output_dist_c);
            fprintf(fid, '%f,', obj.output_mpg_c);
            fprintf(fid, '%f,', obj.output_mpgge_c);
            fprintf(fid, '%f\n', obj.output_gph_c);
            fclose(fid);
        end
    end
    
end


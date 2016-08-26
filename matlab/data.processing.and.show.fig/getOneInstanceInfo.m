function [ one_instance_info_data ] = getOneInstanceInfo(info_csv_file, source, sink, T)
%getOneInstanceInfo get the infomation of one instance (source, sink, T)
%   Detailed explanation goes here
    all_info_data = csvread(info_csv_file);
    %from here http://stackoverflow.com/questions/20293118/find-corresponding-rows-if-it-has-some-missing-elements
    key = [source sink T NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
    pos = ~isnan(key); %// positions of actual values
    idx = ismember(all_info_data(:,pos),key(pos),'rows'); %// select columns and apply ismember
    one_instance_info_data = all_info_data(idx,:);
end


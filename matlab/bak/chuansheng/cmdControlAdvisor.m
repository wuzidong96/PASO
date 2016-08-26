input.init.saved_veh_file='CONVENTIONAL_defaults_in';
[a,b]=adv_no_gui('initialize',input);

input.cycle.param={'cycle.name'};
input.cycle.value={'CYC_NEDC1'};
[a,b]=adv_no_gui('drive_cycle',input);

%metersPerMile = 2835;
%gramsPerGallon = 4404;
metersPerMile = 1609;
gramsPerGallon = 2835;

fuelCost = dist / b.cycle.mpgge * gramsPerGallon;
timeCost = length(cyc_mph_r);
avgSpeed = dist * metersPerMile / timeCost;
dist = dist * metersPerMile;

timeCost
%run_testcase('EcoSIM3_P2_C2_WIP','TestCase_12_MIL')
%% TestCase_12_MIL.m
% SoftECU, GMLAN/Driver MIL TEST
% 
%%
%--------------------------------------------------------------------------
% Date:         User:              Changes:
%--------------------------------------------------------------------------
% 11/13/2016    Ullekh                Initial 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% [TestID: 12] Torque Security in Park

%yofyyg

% init model params
run('Startup_EcoSIM_P2.m');

% open model to set params
open_system(model_name);

% Model Version
fprintf('Req 231 : The powertrain shall not transmit any torque to the wheels or allow the vehicle to roll when the PRNDL is in the "Park" position.')
%fprintf('');
%fprintf('');

% set desired params
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_trigger'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_trigger'],'rep_seq_y','[1 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_value'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_value'],'rep_seq_y','[1 1]')

set_param([model_name '/Fault Insertion/Driver_Triggers/Alpha_trigger'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Alpha_trigger'],'rep_seq_y','[1 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Alpha_percentage_value'],'rep_seq_t','[0 20 30 40]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Alpha_percentage_value'],'rep_seq_y','[0 99 0 0]')

set_param([model_name '/Fault Insertion/Driver_Triggers/Beta_trigger'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Beta_trigger'],'rep_seq_y','[1 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Beta_percentage_value'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Beta_percentage_value'],'rep_seq_y','[0 0]')

% sim model
sim([model_name],40);
warning('off');

% get results
Data.PRNDL  = logsout.get('<PRNDL>').Values.Data;
Data.Driver_Torque_Request = logsout.get('Driver Torque Request').Values.Data;
Data.Torque_Command = logsout.get('<Torque_Command>').Values.Data;
Data.ICE_Torque_Request_Nm = logsout.get('<ICE_Torque_Request_Nm>').Values.Data;
Data.Vehicle_Speed_meter_per_s = logsout.get('Vehicle_Speed_meter_per_s').Values.Data;
Data.sim_time = logsout.get('sim_time').Values.Data;

% generate verdict
if  mean(Data.Torque_Command(Data.sim_time>=0 & Data.sim_time<40))==0 &...
    mean(Data.Vehicle_Speed_meter_per_s(Data.sim_time>=0 & Data.sim_time<40))==0 
    status = 'Pass';
else   
    status = 'Fail';
end 

% mean(Data.Mode(DATA.sim_time>=19 & DATA.sim_time<=20))>6
% mean(Data.Mode(DATA.sim_time>=9 & DATA.sim_time<19))==5 &...
% mean(Data.Mode(DATA.sim_time>=0 & DATA.sim_time<9))==2 &...

% Replace the original blocks back.
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_trigger'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_trigger'],'rep_seq_y','[0 0]')
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_value'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_value'],'rep_seq_y','[0 0]')

set_param([model_name '/Fault Insertion/Driver_Triggers/Alpha_trigger'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Alpha_trigger'],'rep_seq_y','[0 0]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Alpha_percentage_value'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Alpha_percentage_value'],'rep_seq_y','[0 0]')

set_param([model_name '/Fault Insertion/Driver_Triggers/Beta_trigger'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Beta_trigger'],'rep_seq_y','[0 0]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Beta_percentage_value'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/Beta_percentage_value'],'rep_seq_y','[0 0]')

% Simulation Results

scarlet = [0.78 0 0];

figure

subplot (2,2,1)
plot(logsout.get('<PRNDL>').Values.Time,Data.PRNDL,'linewidth',1.5,'color',scarlet)
ylabel('PRNDL')
title('PRNDL')
axis([0 40 0 4])
%set(gca,'xtick',0:25:150)

subplot (2,2,2)
plot(logsout.get('Driver Torque Request').Values.Time,Data.Driver_Torque_Request,'linewidth',1.5,'color',scarlet)
ylabel('Driver Torque Request')
title('Driver Torque Request')
axis([0 40 0 3000])

subplot (2,2,3)
plot(logsout.get('<Torque_Command>').Values.Time,Data.Torque_Command,'linewidth',1.5,'color',scarlet)
ylabel('EM Torque Command')
title('EM Torque Command')
axis([0 40 -300 300])
xlabel('Time [s]')

subplot (2,2,4)
plot(logsout.get('<ICE_Torque_Request_Nm>').Values.Time,Data.ICE_Torque_Request_Nm,'linewidth',1.5,'color',scarlet)
ylabel('ICE Torque Request (Nm)')
title('ICE Torque Request (Nm)')
axis([0 40 0 300])
xlabel('Time [s]')


figure
plot(logsout.get('Vehicle_Speed_meter_per_s').Values.Time,Data.Vehicle_Speed_meter_per_s,'linewidth',1.5,'color',scarlet)
xlabel('Time [s]')
ylabel('Vehicle Speed (m/s)')
title('Vehicle Speed (m/s)')
axis([0 40 0 60])
%clear Data

j = figure;
imshow(imread(['Images/' status '.PNG']));
truesize(j,[40 40]);

if strcmp(status,'Pass')
    fprintf('Pass: When the gear selector is in "Park" position, supervisory controller does not request any wheel torque irrespective of the driver requested torque.')
else
    fprintf('Fail')
end

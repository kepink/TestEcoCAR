%run_testcase('EcoSIM3_P2_C2','Test_Requirement_1143')
%% TestCase_100_MIL.m
% SoftECU, GMLAN/Driver MIL TEST
% 
%%
%--------------------------------------------------------------------------
% Date:         User:              Changes:
%--------------------------------------------------------------------------
% 04/02/2016    Zhu                Initial 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% --- PRE-CONDITION --- %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init model params
run('Startup_EcoSIM.m')

% open model to set params
open_system(model_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% --- MAIN TEST --- %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% [ReqID: 1143] The GMLAN shall power on the GCM either when the start button is pressed or when the battery charger is connected. 

% Model Version
fprintf(model_name)

% replace desired simulink blocks
replace_block([model_name '/Driver/Startup Dummy'],'Name','Start Button','Simulink/Sources/Repeating Sequence')
replace_block([model_name '/Powertrain'],'Name','Charger Plug In','Simulink/Sources/Repeating Sequence')
% set desired params
set_param([model_name '/Driver/PI Controller/Ac Pedal Override'],'Value','1')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'rep_seq_t','[0 9 10 19 20 29 30 39]')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'rep_seq_y','[0 0 0 0 1 1 1 1]')
set_param([model_name '/Powertrain/Charger Plug In'],'rep_seq_t','[0 9 10 19 20 29 30 39]')
set_param([model_name '/Powertrain/Charger Plug In'],'rep_seq_y','[0 0 1 1 0 0 1 1]')

% sim model
warning('off')
sim('EcoSIM3_P2_C2.slx',40)

% get results
Data.Charger_Plug_In = logsout.get('Charger_Plug_In').Values.Data;
Data.Key_State  = logsout.get('Key_State').Values.Data;
Data.Relay_Charge = logsout.get('Relay_Charge').Values.Data;
Data.Relay_Vehicle = logsout.get('Relay_Vehicle').Values.Data;
Data.ChargeModeRequest = logsout.get('ChargeModeRequest').Values.Data;
DATA.sim_time = logsout.get('sim_time').Values.Data;

% generate verdict
if  mean(Data.Relay_Charge(DATA.sim_time>=0 & DATA.sim_time<9))==0 &...
    mean(Data.Relay_Vehicle(DATA.sim_time>=0 & DATA.sim_time<9))==0 &...
    mean(Data.Relay_Charge(DATA.sim_time>=10 & DATA.sim_time<19))>0.99 &...
    mean(Data.Relay_Vehicle(DATA.sim_time>=10 & DATA.sim_time<19))==0 &...
    mean(Data.Relay_Charge(DATA.sim_time>=20 & DATA.sim_time<29))>0/99 &...
    mean(Data.Relay_Vehicle(DATA.sim_time>=20 & DATA.sim_time<29))>0/99
    status = 'Pass';
else   
    status = 'Fail';   
end 

imshow(imread(['Images/' status '.PNG'])); 

% Replace the original blocks back.
% replace_block([model_name '/Powertrain'],'Name','Charger Plug In','Simulink/Commonly Used Blocks/Constant')
% set_param([model_name '/Powertrain/Charger Plug In'],'value','0')

% Simulation Results
figure(1)
subplot (4,1,1)
plot(logsout.get('Key_State').Values.Time,Data.Key_State,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Key State [boolean]')
title('Key State')

subplot (4,1,2)
plot(logsout.get('Charger_Plug_In').Values.Time,Data.Charger_Plug_In,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Charger State[boolean]')
title('Charger State')

subplot (4,1,3)
plot(logsout.get('Key_State').Values.Time,Data.Relay_Vehicle,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Relay Vehicle [boolean]')
title('Vehicle Relay')

subplot (4,1,4)
plot(logsout.get('Key_State').Values.Time,Data.Relay_Charge,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Relay Charger [boolean]')
title('Charger Relay')

clear Data

%% [ReqID: 1145] The GMLAN shall set SysPwrMd to 1 when the PRND is in Park and the start button is pressed without the brake pedal being pressed at least 20%. 
 % [ReqID: 1146] The GMLAN shall set SysPwrMd to 2 when the PRND is in Park and the start button is pressed with the brake pedal pressed at least 20%.     
 % [ReqID: 1147] The GMLAN shall set Key_State to 1 when the start button is pressed.
 
% replace desired simulink blocks
replace_block([model_name '/Driver/Startup Dummy'],'Name','Start Button','Simulink/Sources/Repeating Sequence')
replace_block([model_name '/Driver'],'Name','PRNDL_Input','Simulink/Commonly Used Blocks/Constant')
replace_block([model_name '/Driver/Startup Dummy'],'Name','Beta','simulink/Sources/Repeating Sequence')
replace_block([model_name '/Driver/Startup Dummy/Vehicle Start'],'Name','Step','Simulink/Commonly Used Blocks/Constant')

% set desired params
set_param([model_name '/Driver/PI Controller/Ac Pedal Override'],'Value','1')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'rep_seq_t','[0 9 10 19 20 29 30 39]')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'rep_seq_y','[0 0 1 1 0 0 1 1]')
set_param([model_name '/Driver/PRNDL_Input'],'value','1')
set_param([model_name '/Driver/Startup Dummy/Beta'],'rep_seq_t','[0 9 10 19 20 29 30 39]')
set_param([model_name '/Driver/Startup Dummy/Beta'],'rep_seq_y','[0 0 19 19 21 21 21 21]')
set_param([model_name '/Driver/Startup Dummy/Vehicle Start/Step'],'value','0')

% sim model
warning('off')
sim('EcoSIM3_P2_C2.slx',40)
% get results
Data.Beta = logsout.get('Beta').Values.Data;
Data.Key_State  = logsout.get('Key_State').Values.Data;
Data.SysPwrMd = logsout.get('SysPwrMd').Values.Data;
Data.StartButton = logsout.get('Start_Button').Values.Data;
DATA.sim_time = logsout.get('sim_time').Values.Data;

% generate verdict
if  mean(Data.StartButton(DATA.sim_time>=0 & DATA.sim_time<9))==0 &...
    mean(Data.SysPwrMd(DATA.sim_time>=0 & DATA.sim_time<9))==0 &...
    mean(Data.SysPwrMd(DATA.sim_time>=10 & DATA.sim_time<19))==1 &...
    mean(Data.SysPwrMd(DATA.sim_time>=30 & DATA.sim_time<39))==2
    status = 'Pass';
else   
    status = 'Fail';   
end 

imshow(imread(['Images/' status '.PNG'])); 

% Replace the original blocks back.
replace_block([model_name '/Driver/Startup Dummy'],'Name','Start Button','Simulink/Sources/Step')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'Time','1')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'Before','1')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'After','0')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'SampleTime','0')

% Simulation Results
figure(2)
subplot (4,1,1)
plot(logsout.get('Start_Button').Values.Time,Data.StartButton,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Start Button [boolean]')
title('Start Button')

subplot (4,1,2)
plot(logsout.get('Start_Button').Values.Time,Data.Key_State,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Key State[boolean]')
title('Key State')

subplot (4,1,3)
plot(logsout.get('Start_Button').Values.Time,Data.Beta,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Beta [%]')
title('Beta')

subplot (4,1,4)
plot(logsout.get('Start_Button').Values.Time,Data.SysPwrMd,'linewidth',1.5)
xlabel('Time [s]')
ylabel('System Power Mode')
title('System Power Mode')

%% [ReqID: 1144] The GMLAN shall allow PRND shifting into or out of Park only when the brake pedal is pressed at least 20%. 
 
% replace desired simulink blocks
replace_block([model_name '/Driver'],'Name','PRNDL_Input','Simulink/Sources/Repeating Sequence')
replace_block([model_name '/Driver/Startup Dummy'],'Name','Beta','Simulink/Sources/Repeating Sequence')
replace_block([model_name '/Driver/Startup Dummy/Vehicle Start'],'Name','Step','Simulink/Commonly Used Blocks/Constant')

% set desired params
set_param([model_name '/Driver/PI Controller/Ac Pedal Override'],'Value','1')
set_param([model_name '/Driver/PRNDL_Input'],'rep_seq_t','[0 9 10 19 20 29 30 39]')
set_param([model_name '/Driver/PRNDL_Input'],'rep_seq_y','[1 1 4 4 1 1 4 4]')
set_param([model_name '/Driver/Startup Dummy/Beta'],'rep_seq_t','[0 9 10 19 20 29 30 39]')
set_param([model_name '/Driver/Startup Dummy/Beta'],'rep_seq_y','[19 19 19 19 21 21 21 21]')
set_param([model_name '/Driver/Startup Dummy/Vehicle Start/Step'],'value','0')

% sim model
warning('off')
sim('EcoSIM3_P2_C2.slx',40)
% get results
Data.Beta = logsout.get('Beta').Values.Data;
Data.PRNDL_position  = logsout.get('PRNDL_position').Values.Data;
DATA.sim_time = logsout.get('sim_time').Values.Data;

% generate verdict
if  mean(Data.PRNDL_position(DATA.sim_time>=0 & DATA.sim_time<9))==1 &...
    mean(Data.PRNDL_position(DATA.sim_time>=10 & DATA.sim_time<19))==1 &...
    mean(Data.PRNDL_position(DATA.sim_time>=20 & DATA.sim_time<29))==1 &...
    mean(Data.PRNDL_position(DATA.sim_time>=30 & DATA.sim_time<39))==4
    status = 'Pass';
else   
    status = 'Fail';   
end 

imshow(imread(['Images/' status '.PNG'])); 

% Replace the original blocks back.
replace_block([model_name '/Driver/Startup Dummy'],'Name','Start Button','Simulink/Sources/Step')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'Time','1')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'Before','1')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'After','0')
set_param([model_name '/Driver/Startup Dummy/Start Button'],'SampleTime','0')

% Simulation Results
figure(3)
subplot (2,1,1)
plot(logsout.get('Beta').Values.Time,Data.Beta,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Beta [%]')
title('Brake Pedal')

subplot (2,1,2)
plot(logsout.get('Beta').Values.Time,Data.PRNDL_position,'linewidth',1.5)
xlabel('Time [s]')
ylabel('PRNDL Position')
title('PRNDL Position')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% --- POST-CONDITION --- %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save_system
bdclose('all')

%clear all
clc
%% [ReqID: xx] Disabling Inverter before changing direction and then re-enabling it 

% init model params
run('Startup_EcoSIM_P2.m')

% open model to set params
open_system(model_name)

% Model Version
fprintf(model_name)

% replace desired simulink blocks
%replace_block([model_name '/Driver'],'Name','PRNDL_Input','Simulink/Sources/Repeating Sequence')

% set desired params
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_trigger'],'rep_seq_t','[0 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_trigger'],'rep_seq_y','[1 1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_value'],'rep_seq_t','[0 15 15.1 20 20.1 30 30.1 35 35.1]')
set_param([model_name '/Fault Insertion/Driver_Triggers/PRNDL_value'],'rep_seq_y','[1 1 2 2 1 1 2 2 1]')

% sim model
warning('off')
sim([model_name],40)

% get results
Data.PRNDL  = logsout.get('<PRNDL>').Values.Data;
Data.Inverter_Enable = logsout.get('<Inverter_Enable>').Values.Data;
Data.Inverter_Enable_Lockout = logsout.get('Inverter_Enable_Lockout').Values.Data;
Data.Rotation_Direction = logsout.get('<Rotation_Direction>').Values.Data;
Data.VSM_State = logsout.get('VSM_State').Values.Data;
Data.sim_time = logsout.get('sim_time').Values.Data;
Data.abc  = logsout.get('abc').Values.Data;

% generate verdict
% if  mean(Data.Fault_Code(DATA.sim_time>=0 & DATA.sim_time<9))==0 &...
%     mean(Data.Fault_Code(DATA.sim_time>=9 & DATA.sim_time<19))>1.9 &...
%     mean(Data.Fault_Code(DATA.sim_time>=19 & DATA.sim_time<=29))>2.9
%     status = 'Pass';
% else   
%     status = 'Fail';
% end 

% mean(Data.Mode(DATA.sim_time>=19 & DATA.sim_time<=20))>6
% mean(Data.Mode(DATA.sim_time>=9 & DATA.sim_time<19))==5 &...
% mean(Data.Mode(DATA.sim_time>=0 & DATA.sim_time<9))==2 &...
    
%imshow(imread(['Images/' status '.PNG']));

% Replace the original blocks back.
% replace_block([model_name '/Powertrain'],'Name','Charger Plug In','Simulink/Commonly Used Blocks/Constant')
% set_param([model_name '/Powertrain/Charger Plug In'],'value','0')

% Simulation Results

figure
subplot (2,2,1)
plot(logsout.get('<PRNDL>').Values.Time,Data.PRNDL,'linewidth',1.5)
xlabel('Time [s]')
ylabel('PRNDL')
title('PRNDL')

subplot (2,2,2)
plot(logsout.get('<Inverter_Enable>').Values.Time,Data.Inverter_Enable,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Inverter_Enable')
title('Inverter_Enable')

subplot (2,2,3)
plot(logsout.get('Inverter_Enable_Lockout').Values.Time,Data.Inverter_Enable_Lockout,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Inverter_Enable_Lockout')
title('Inverter_Enable_Lockout')

subplot (2,2,4)
plot(logsout.get('<Rotation_Direction>').Values.Time,Data.Rotation_Direction,'linewidth',1.5)
xlabel('Time [s]')
ylabel('Rotation_Direction')
title('Rotation_Direction')

figure
plot(logsout.get('abc').Values.Time,Data.abc,'linewidth',1.5)
xlabel('Time [s]')
ylabel('abc')
title('abc')

%clear Data

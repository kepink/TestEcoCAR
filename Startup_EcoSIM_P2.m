%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filename: Startup_EcoSIM3
% Description: Initialization script for EcoSIM3 model
%--------------------------------------------------------------------------
% Date:         User:              Changes:
%--------------------------------------------------------------------------
% 9/27/2015     syacinthe          Initial Development for PHEV model
% 10/16/2015    Arjun Khanna       MIL-SIL-HIL trasitions capability added
%                                  Added configuration setting (can be
%                                  switched in the Model Explorer from
%                                  Simulink.
%                                  Added CAN configuration variant
%                                  subsystem to change between dSPACE and
%                                  VNT configuration
%                                  Converted the Supervisory block to an
%                                  atomic sub-system
%                                  Added folders (DBC to place all the dbc files in it
%                                  and RTI_Build as a target folder for all
%                                  the c-code developed during the model
%                                  build.
% 2/16/2016    M.J. Yatsko         Added new maps for series mode - will be
%                                  better integrated later
% 3/22/2016     Aditya Modak       Separated Drive Cycle Selection for
%                                  HIL implementation
% 8/19/2016     Aditya Modak       Created variants for dyno data
%                                  comparison
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
%clear all

%% Add relevant folder paths to directory

addpath Images;
addpath Initialization_Files;
%addpath Libraries;
addpath Velocity_Profiles;
%addpath Test_Scripts;


%Select Sim-type 1-Form and Goto Blocks 2-Vehicle Network Toolbox 3- RTI-blocks(We
%might be able to include this into the Simulation Parameters block
Sim_type = 1;
Controls.EM_gain = 1; %gain block value for torque split b/w EM and ICE
% if Sim_type == 3
%     setActiveConfigSet(EcoSIM3_P1_0_PHEV_2014b_with_inertia, 'Configuration_RTI');
% else
%     setActiveConfigSet(EcoSIM3_P1_0_PHEV_2014b_with_inertia, 'Configuration_MIL_SIL');
% end

%% Run relevant m-files 

% MISC.
run Initialization_Files/Global_Environment.m; 
run Initialization_Files/Driver_PI.m;
run Initialization_Files/Vehicle_Dynamics_Camaro_2016.m;

% Accessories
run Initialization_Files/DCDC_Converter_APM.m;

% Energy Storage
run Initialization_Files/HV_Battery_A123_18_9_kWh.m;
run Initialization_Files/Fuel_Tank_8_2.m;

% Torque Producers
run Initialization_Files/Electric_Motor_GVM210_150R6_318VDC_550ARMS.m;
run Initialization_Files/ICE_2_0L_Ford.m;
run Initialization_Files/Electric_Motor_BAS.m;

% Torque Couplers
run Initialization_Files/Mechanical_Coupler_GR2_77.m;
run Initialization_Files/Rear_Differential_GR2_77.m;
run Initialization_Files/Belt_3_and_Clutch.m;
run Initialization_Files/Trans_Tremec_T5.m;

% Brakes & wheels
run Initialization_Files/Brakes_Wheels_Camaro_2016.m;

% Series Maps 
run Series_Maps.m;

%% Load Velocity Profiles

DriveCycles.FUDS=load('Velocity_Profiles/FUDS.mat');
DriveCycles.FHDS=load('Velocity_Profiles/FHDS.mat');
DriveCycles.US06=load('Velocity_Profiles/US06_mph.mat');
DriveCycles.US06_City=load('Velocity_Profiles/US06_City_cycle.mat');
DriveCycles.US06_Highway=load('Velocity_Profiles/US06_Highway_Cycle.mat');
DriveCycles.Gradeability=load('Velocity_Profiles/Gradeability_Cycle.mat');
DriveCycles.Acceleration=load('Velocity_Profiles/0_60_Accel.mat');
DriveCycles.Cycle_505=load('Velocity_Profiles/Drive_Cycle_505.mat');
DriveCycles.Ecocar3Y2Demo = load ('EcoCAR3_Y2_Demo.mat');
DriveCycles.EC3Y3Fall=load('Velocity_Profiles/EcoCAR3_Y3_FallReport.mat');

%% Mechanical Parameters

%Diff_ratio = 3.421; % from Honda website

%tire.rollrad = .3162; % m

%clutch.J = 0.001; %kg-m^2
%clutch.damp = 1e-4; %Nm/rad/s
%diff.damp = [1e-4 1e-4]; %Nm/rad/s

%HEV_Param.Vehicle.Distance_CG_RearAxle = 1.22; % m
%HEV_Param.Vehicle.Distance_CG_FrontAxle = 1.56; % m
%HEV_Param.Vehicle.Mass = 1723.2; % kg
%HEV_Param.Vehicle.Distance_CG_Ground = 0.5; % m
%HEV_Param.Vehicle.Frontal_Area = 2.27; % m^2, est of 24.5 ft^2
%HEV_Param.Vehicle.Aero_Drag_Coeff = 0.29; 
%HEV_Param.Vehicle.Diff.Inertia = 0.1; 
%HEV_Param.Vehicle.Diff.Friction = 0.0001;
%HEV_Param.Vehicle.Wheel_Inertia = 0.7; 


%HEV_Param.Vehicle.Tire.Slip_Calculation_Velocity_Threshold = .1; 

decimation = 10;

Comparison_Acceleration = Simulink.Variant('dynocycle==1');
Comparison_US06 = Simulink.Variant('dynocycle==2');
Comparison_Coastdown = Simulink.Variant('dynocycle==3');
Comparison_HWFET = Simulink.Variant('dynocycle==4');


%% Launch/open vehicle model
%open EcoSIM3_P1_0_PHEV_2014b.slx

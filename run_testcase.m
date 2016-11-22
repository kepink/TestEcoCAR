%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filename: run_testcase.m
% Description: function to publish test case
%--------------------------------------------------------------------------
% Date:         User:              Changes:
%--------------------------------------------------------------------------
% 03/14/2016    syacinthe          Initial 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% i.e. run_testcase('EcoSIM3_P2_C2','Test_Requirement_1143')

function  run_testcase(model_filename,testcase_filename)

addpath TestCase_Scripts_MIL/Images
% addpath(genpath('Users/zhaoxuanzhu/Desktop/EcoCAR/EcoSIM3'))

clc
% clearvars -except model_filename testcase_filename
close all

% send model name to workspace
assignin('base','model_name',model_filename)

%h = msgbox('#KeepCalm ...things are happening');

tic
% publish 
options = struct('format','doc','showCode',false,'catchError',false,'outputDir',[pwd '/TestCase_MIL_Results_' datestr(now,'mmddyy')]);
publish(testcase_filename,options);
toc

%close(h)
%close all
%msgbox({'Operation Complete! #BuckeyeNation'}) 

end 




function [jobID ] = submitJob(mfilename, varargin )
% Submit a matlab computation task to cluster without distributed
% computation toolbox
% use "clusterSetup" to set up the cluster: host, username, password
% useage: jobID = submitJob(mfile)
%         jobID = submitJob(mfile, numberOfNodes, procsPerNode,
%         totalMemory);
%mfilename = '../3DMM/func.m';
load('clust.mat');
hostname = clust.hostname; 
username = clust.username;
password = clust.password;
localJobStorageLocation = clust.localJobStorageLocation;
remoteJobStorageLocation = clust.remoteJobStorageLocation;
mfilepath = GetFullPath(mfilename);
[pathstr,funname,~] = fileparts(mfilepath); 
localJobDirectory = pathstr;
pathFolder = strsplit(localJobDirectory, '\');
currentFolder = pathFolder{end};
quote = '''';
fileSeparator = '/';
remoteJobDirectory  = sprintf('%s%s%s', remoteJobStorageLocation, fileSeparator, currentFolder);
clust.localJobDirectory = localJobDirectory;
clust.remoteJobDirectory= remoteJobDirectory;
save('clust.mat','clust');

if isempty(varargin)
    walltime = '03:00:00';
    numberOfNodes = 1;
    procsPerNode = 1;
    totalMemory = 3; % GB
else
    walltime = varargin{1};
    numberOfNodes = varargin{2};
    procsPerNode = varargin{3};
    totalMemory = varargin{4}; % GB
end 
% construct commmand file

PBSpara = sprintf('-l walltime=%s -m abe -M w.liang@griffith.edu.au -q workq -l select=%d:ncpus=%d:mem=%dg', ...,
    walltime, numberOfNodes, procsPerNode,totalMemory);

% environmental variables
environmentVariables = { 'MATLAB_WORKDIR', remoteJobDirectory; ...
    'MATLAB_FUN', funname;};

varsToForward = environmentVariables(:,1);
envString = sprintf('%s,', varsToForward{:});
% Remove the final ','
envString = envString(1:end-1);

% logfile
%logFile = sprintf('%s%s%s', remoteJobStorageLocation, fileSeparator, 'Task.log');
%quotedLogFile = sprintf('%s%s%s', quote, logFile, quote); % need to improve in the future

% task command script
% The script name is JobWrapper.sh
jobsScriptName = 'JobWrapper.sh';
localjobScript = fullfile(localJobStorageLocation, jobsScriptName);
remoteJobScript = sprintf('%s%s%s', remoteJobStorageLocation, fileSeparator, jobsScriptName);
quotedjob = sprintf('%s%s%s', quote, remoteJobScript, quote);
localScriptName = tempname(localJobStorageLocation);
[~, scriptName] = fileparts(localScriptName);
remoteScriptLocation = sprintf('%s%s%s', remoteJobStorageLocation, fileSeparator, scriptName);

fid = fopen(localScriptName, 'w');
if fid < 0
    error('Failed to open file %s for writing', outputFilename);
end
% Specify Shell to use
fprintf(fid, '#!/bin/sh\n');
% write PBS parameters
% Generate the command to run and write it.
% to qsub
for ii = 1:size(environmentVariables, 1)
    fprintf(fid, '%s=%s\n', environmentVariables{ii,1}, environmentVariables{ii,2});
    fprintf(fid, 'export %s\n', environmentVariables{ii,1});
end
jobName = funname;
% PBS jobs names must not exceed 15 characters
maxJobNameLength = 15;
if length(jobName) > maxJobNameLength
     jobName = jobName(1:maxJobNameLength);
end
commandToRun = sprintf( 'qsub -N %s -v %s %s %s', ...
    jobName, envString, PBSpara, quotedjob);  
fprintf(fid, '%s\n', commandToRun);
% Close the file
fclose(fid);

% copy local function and command file to cluster
ssh2_conn = ssh2_config(hostname, username, password);
% job script
ssh2_conn = scp_put(ssh2_conn, {jobsScriptName, scriptName}, remoteJobStorageLocation);
% mfile script
ssh2_conn = scp_put(ssh2_conn, mfilename, remoteJobDirectory, pathstr);
% submit job to cluster using sh file
commandtorun = sprintf('sh %s',remoteScriptLocation); 
[ssh2_conn, jobID] = ssh2_command(ssh2_conn, commandtorun);
ssh2_conn = ssh2_close(ssh2_conn);
delete(scriptName);
end


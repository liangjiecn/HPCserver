%cluster setup
%ssh2 toolbox
clear;
addpath('../tools/ssh2_v2_m1_r6');
hostname = 'gowonda.rcs.griffith.edu.au';
remoteJobStorageLocation = '/scratch/s2882161/matlab';
localJobStorageLocation = pwd;
username = 's2882161';
password = ''; % need password autheration 
dlgTitle = 'User Credentials';
numlines = 1;
dlgMessage = sprintf('Enter the password of user "%s" for %s', username, hostname);
usernameResponse = inputdlg(dlgMessage, dlgTitle, numlines);
% Hitting cancel gives an empty cell array, but a user providing an empty string gives
% a (non-empty) cell array containing an empty string
if isempty(usernameResponse)
    % User hit cancel
    error('User cancelled operation.');
end
password = char(usernameResponse);
command =  'pwd';
%% SIMPLE CONNECTION TEST
% Basic Connection: to make a simple, one-time use, connection.
try 
    command_output = ssh2_simple_command(hostname,username,password,command);
catch exception
    throw(exception); 
end
msg = sprintf('Connect cluter successfully. The remote home path is %s',command_output{1});
disp(msg);
global clust;
clust = struct('hostname', hostname, 'username', username, 'password', password, 'remoteJobStorageLocation', remoteJobStorageLocation, 'localJobStorageLocation', localJobStorageLocation);
save('clust.mat', 'clust');



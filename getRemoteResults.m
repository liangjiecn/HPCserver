function [ output_args ] = getRemoteResults( filename )
% Get results from cluster after the task is finished 
% specify the results filename and location, load it into workspace and
% copy to working directionary
filename = 'a.mat';
load('clust.mat');
hostname = clust.hostname; 
username = clust.username;
password = clust.password;
localPath = clust.localJobDirectory;
remotePath = clust.remoteJobDirectory;
remoteFilename = filename;
ssh2_conn = ssh2_config(hostname, username, password);
ssh2_conn = scp_get(ssh2_conn, remoteFilename,localPath,remotePath);
ssh2_conn = ssh2_close(ssh2_conn);
output_args = importdata(fullfile(localPath, filename));
end


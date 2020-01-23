function [out, toParse] = writeReadZC706(cmd,verbose)
% Eridan MIRACLE DevKit 1.1
%     Writes command to ZC706 and reads the response

if nargin < 2
    verbose = 0;
end

readInBuffZC706; % clear buffer if anything
writeZC706(cmd); % write command

toParse = readZC706; % readback response

out = parseCmdLineZC706(cmd,toParse); % parse string for MATLAB friendly environment

% Print output if desired
if (verbose)
    fprintf(out);
end
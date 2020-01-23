function out = readInBuffZC706(verbose)
% Eridan MIRACLE DevKit 1.1
%     Reads data from the ZC706 in the input buffer, if any
global ZC706


if nargin < 1
        verbose = 0;
end
out = [];

% Continuously read input buffer until ZC706 stops transmitting data
while get(ZC706, 'BytesAvailable')
    temp = fscanf(ZC706);
    if (verbose)
        fprintf(temp);
    end
    out = [out temp];
end

if (verbose)
    fprintf('\n');
end
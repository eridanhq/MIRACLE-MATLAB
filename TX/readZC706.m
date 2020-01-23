function out = readZC706(verbose)
% Eridan MIRACLE DevKit 1.1
%     Reads terminal lines from ZC706, and prints it to command window.
%     Effectively emmulates the Linux shell prompt.  Command finishes once
%     the command line string "analong:~#" is found in the response

if nargin < 1
        verbose = 0;
end

out = [];
done = 0;
cmdLineStr = 'analog:~#';

while (~done)
    temp = readInBuffZC706; % read the input buffer
    if ~isempty(temp)
        temp = regexprep(temp, {'\r', '\n\n+'}, {'', '\n'}); % remove extra lines
        out = [out temp];
        if any(strfind(out,cmdLineStr)) % look for the command line string
            done = 1;
        end
        if (verbose) % Print if verbose
            fprintf(temp);
        end
    end
end

if (verbose)
    fprintf('\n');
end
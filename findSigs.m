function out = findSigs(str)
% Finds all available signals that contain string 'str'

sigs = getSigs;
i = contains(sigs, str,'IgnoreCase',true);
out = sigs(i);
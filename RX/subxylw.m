function fxylw = subxylw(i,r,c)
% Returns vector of subplot position
% i: subplot index
% r: subplot total rows
% c: subplot total columns
% fxylw: figure position vector

fxylw = [.1/(c)+ mod(i-1,c)/c ...
    .15/(r)+(1-(1/r)*ceil(i/c)) ...
    .8/c ...
    .75/r];
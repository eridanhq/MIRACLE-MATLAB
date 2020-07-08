function [str, scale, prefix] = eenot(val, numDec)
% Returns string of input numeric in "electrical engineering" notation
% Must manually append unit to end of return string
%    val: input numeric value
% numDec: number of decimal points in return string
%    str: output string of VAL in EE notation

if nargin < 2
    numDec = 1;
end

decStr = sprintf('%%0.%gf', numDec);

valMag = abs(val);

if (valMag == 0)
    scale = 1;
    prefix = '';
elseif (valMag < 1e-12)
    scale = 1e-15;
    prefix = 'f';
elseif (valMag < 1e-9)
    scale = 1e-12;
    prefix = 'p';
elseif (valMag < 1e-6)
    scale = 1e-9;
    prefix = 'n';
elseif (valMag < 1e-3)
    scale = 1e-6;
    prefix = 'u';
elseif (valMag < 1)
    scale = 1e-3;
    prefix = 'm';
elseif (valMag < 1e3)
    scale = 1;
    prefix = '';
elseif (valMag < 1e6)
    scale = 1e3;
    prefix = 'k';
elseif (valMag < 1e9)
    scale = 1e6;
    prefix = 'M';
elseif (valMag < 1e12)
    scale = 1e9;
    prefix = 'G';
else
    scale = 1e12;
    prefix = 'T';
end

str = sprintf('%s%s',sprintf(decStr,val/scale),prefix);
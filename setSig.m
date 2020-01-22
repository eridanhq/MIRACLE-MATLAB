function setSig(sigIn,Fs)
% Eridan MIRACLE DevKit 1.1
%     Loads a signal in from ZC706 into MIRACLE TX.  Optionally set the
%     data rate as well by specifying the second argument FS in Hz

if nargin >=2
    setDataRate(Fs);
end

writeZC706(sprintf('setsig %s',upper(sigIn)));

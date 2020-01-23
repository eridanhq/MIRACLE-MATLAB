function setDataRate(Fs)
% Eridan MIRACLE DevKit 1.1
%    Sets sampling rate of TX signal.  Enter Fs in Hz

writeZC706(sprintf('setdatarate %.0f',Fs));

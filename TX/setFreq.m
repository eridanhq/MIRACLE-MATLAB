function setFreq(f)
% Eridan MIRACLE DevKit 1.1
%     Sets TX carrier frequency in Hz

writeZC706(sprintf('setfreq %.0f\n', f));
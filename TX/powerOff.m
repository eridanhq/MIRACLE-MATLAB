function sysOff
% Eridan MIRACLE DevKit 1.1
%     Safely shuts down the TX, then the Linux OS so FPGA can be
%     powered off.

writeReadZC706('sysoff',1);
pause(1);
writeReadZC706('poweroff',1);
pause(3);
fprintf('Safe to turn off FPGA board now.\n');
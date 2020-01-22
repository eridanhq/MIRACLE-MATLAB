function sysOff
% Eridan MIRACLE DevKit 1.1
%     Sets power control register to 0, and turns system digitally-
%     controlled power supplies OFF

writeReadZC706('sysoff',1);
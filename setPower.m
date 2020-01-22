function setPower(p)
% Eridan MIRACLE DevKit 1.1
%     Sets power control register.  P should integer be in range [0,32767]


writeZC706(sprintf('setpwr %g',round(p)));
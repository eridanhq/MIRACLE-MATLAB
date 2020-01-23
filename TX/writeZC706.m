function writeZC706(cmd)
% Eridan MIRACLE DevKit 1.1
%     Writes string cmd to ZC706 through output buffer on serial port
global ZC706

fprintf(ZC706,cmd);
while get(ZC706, 'BytesToOutput')
    % Wait until command is written to output buffer
end
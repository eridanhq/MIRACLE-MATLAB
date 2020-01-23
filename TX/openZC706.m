% Creates ZC706 serial object and opens

global ZC706

port = 'COM14'; % Select appropriate COM port

warning('off','MATLAB:serial:fgetl:unsuccessfulRead'); % Supress timeout warnings
warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
delete(instrfind('Port', port));

ZC706 = serial(port);
set(ZC706,'BaudRate',115200,'DataBits', 8, 'StopBits', 1, 'Parity', 'none');
% set(ZC706,'InputBufferSize',65536);
% set(ZC706,'OutputBufferSize',65536);
set(ZC706,'InputBufferSize',1048576);
set(ZC706,'OutputBufferSize',1048576);
set(ZC706, 'Timeout', .05);
ZC706.ReadAsyncMode = 'continuous';
fopen(ZC706);

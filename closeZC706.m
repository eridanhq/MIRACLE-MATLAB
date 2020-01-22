function closeZC706
% closes serial port for ZC706
global ZC706

fclose(ZC706);
delete(ZC706);
clear ZC706
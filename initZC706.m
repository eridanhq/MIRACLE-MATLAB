% Eridan MIRACLE DevKit 1.1
%     Connects to ZC706 upon power on of ZC706 board

openZC706;
cmdLineStr = 'analog:~#'; % look for this string to complete connection
out = [];
cycle = 0;
emptyBuffCount = 0;
done = 0;
fprintf('WAITING ON ZC706\n');
while (~done)
    temp = readInBuffZC706;
    out = strcat(out,temp);

    if any(strfind(out,cmdLineStr))
        done = 1;
    end
    
    if isempty(temp)
        emptyBuffCount = emptyBuffCount + 1;
    else
        emptyBuffCount = 0;
    end
    
    if emptyBuffCount > 20000
        writeZC706(''); % press enter
        emptyBuffCount = 0;
    end
    
    if cycle < 16383
        cycle = cycle+1;
    else
        cycle = 0;
        fprintf('.');
    end
end

fprintf('\nCONNECTED TO ZC706\n');
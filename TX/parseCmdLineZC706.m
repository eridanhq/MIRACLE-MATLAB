function str = parseCmdLineZC706(cmd,str)
% Parses ZC706's output into a MATLAB friendly format

spclChars = {'[ ','\','^','$','.','|','?','*','+','(',')'};
spclCharsRep = {'\[ ','\\','\^','\$','\.','\|','\?','\*','\+','\(','\)'};

for i = 1:length(spclChars)
    cmd = strrep(cmd,spclChars{i},spclCharsRep{i});
end

str = regexprep(str,cmd,'');
str = regexprep(str,'root@analog:~#*','');
str = regexprep(str, {'\r', '\n\n+'}, {'', '\n'});
str = deblank(str(end:-1:1));
str = str(end:-1:1);

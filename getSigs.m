function list = getSigs
% Returns a list of signals available on the ZC706's SD card

toParse = writeReadZC706('getsigs');

toParse = regexprep(toParse, {'\r', '\n\n+'}, {'', '\n'});
toParse = regexprep(toParse, {'\r', '\n\n+'}, {'', '\n'});
list = textscan(toParse,'%s','Delimiter','\n');
list = list{1};
list = list(~cellfun('isempty',list));
function writeBinVec(IQ, fileName, normEn)
% Eridan MIRACLE DevKit 1.1
%     Writes vector in binary format, for ZC706.  First input IQ is single
%     column or single row or complex waveform vector.  Second input
%     FILENAME is the name of the file to be saved.  Option third input
%     NORMEN enabled normalization of vector to unit magnitude (default).
%     Recommended that the name of the signal vector be all capitalized to
%     match Eridan's naming convention of the provided signals.

% Transpose if row vector to make column vector
if isrow(IQ)
    IQ = IQ.';
end

% Normalize vector to unit magnitude
if nargin < 3
    normEn = 1;
end

amp = 2048; % for 12-bit vectors
if normEn
    IQNorm = normalize(IQ); % normalize by default
else
    IQNorm = IQ;
end

scale = 1; % adjust scaling of signal after normalization

% interleave I and Q into single column vector
IQFPGA = zeros(2*length(IQNorm),1);
IQFPGA(1:2:end) = real(IQNorm);
IQFPGA(2:2:end) = imag(IQNorm);

fileID = fopen(sprintf('.\\%s.bin',fileName), 'w'); % open file for write
fwrite(fileID, floor(scale*amp*IQFPGA), 'int16'); % write vector to file as int16
fclose(fileID); % safely close file

function [sig,scale] = normalize(sig,scale)
% Normalizes signal to unit magnitude
% Input must be vector complex IQ vector

if nargin<2
    scale = .9999./max(abs(sig));
    if scale == Inf % this is signal is 0
        scale = 1;
    end
end
sig = scale.*sig;
function [px, fv] =  psdc(sig,Fs,env,rbw)
% Welch transform code
% sig: input signal vector, each sample needs to be in complex IQ format
% Fs: sampling rate of sig in Hz
% env: flag to indicate envelope signal.  will only return single sided psd
% px: yvals of psd (dbm/rbw)
% fv: xvals of psd (Hz)


switch nargin
    case 4
    case 3
        rbw = 30e3;
    otherwise
        env = 0;
        rbw = 30e3;
end

% set FFT size for resolution bandwidth
rbwoffset = 10*log10(rbw);
Nfft = 2^nextpow2(Fs / rbw);

% compute proper PSD
[px,fv] = pwelch(sig, hanning(Nfft), Nfft/2, Nfft, Fs);
px = 10*log10(px);  % convert to dB
%px = px - px(1);   % peak up
if (~env)
    % make so frequency goes from -fs/2 to +fs/2
    px = fftshift(px);  fv = fftshift(fv);  fv(1:Nfft/2) = fv(1:Nfft/2) - Fs;
end
px = px + 30; % convert to dBm/Hz
px = px + rbwoffset; % convert to dBm/rbw
% px = px-max(px); % normalize
% -------------------------------------------------------- %
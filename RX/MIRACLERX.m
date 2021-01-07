%  Eridan DevKit 1.1
%
% MIRACLE RX controls the AD9361 

clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AD9361 starting setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = 40e6;  %** sampling frequency
fLO = 2.00e9; %** lo frequency
fIF = 5e6;    %** if frequency
rxGain = 41; %** rx gain
RFBW = 20e6; %** rx bandwidth 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AD9361 initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('s', 'var') && isa(s,'iio_sys_obj_matlab')
    s.releaseImpl(); % closes AD9361, if necessary
end

tx_buff_size = 65530;
rx_buff_size = 16384;

s = iio_sys_obj_matlab; 
s.ip_address = '192.168.1.117'; %** IP address of ZCU104 - change accordingly
s.dev_name = 'ad9361'; 
s.in_ch_no = 2; % I = chan 1, Q = chan 2
s.out_ch_no = 4; % RX1_I = chan 1, RX1_Q = chan 2, RX2_I = chan 3, RX2_Q = chan 4
s.in_ch_size = tx_buff_size; % TX data buffer size
s.out_ch_size = rx_buff_size; % RX data buffer size

s = s.setupImpl() % setup AD9361

input_AD9361 = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AD9361 configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gainMode = 'slow_attack';
% gainMode = 'fast_attack';
gainMode = 'manual'; %**
% gainMode = 'hybrid';

% calibMode = 'auto';
calibMode = 'manual'; %**
% calibMode = 'manual_tx_quad';
% calibMode = 'tx_quad';
% calibMode = 'rf_dc_offs';
% calibMode = 'rssi_gain_setup';

% configuration
% 1: RX_LO_FREQ
% 2: RX_SAMPLING_FREQ
% 3: RX_RF_BANDWIDTH
% 4: RX1_GAIN_MODE
% 5: RX1_GAIN
% 6: RX2_GAIN_MODE
% 7: RX2_GAIN
% 8: TX_LO_FREQ
% 9: TX_SAMPLING_FREQ
% 10: TX_RF_BANDWIDTH 

input_AD9361{s.in_ch_no+1} = fLO;
input_AD9361{s.in_ch_no+2} = Fs;
input_AD9361{s.in_ch_no+3} = RFBW;
input_AD9361{s.in_ch_no+4} = gainMode;
input_AD9361{s.in_ch_no+5} = rxGain;
input_AD9361{s.in_ch_no+6} = gainMode;
input_AD9361{s.in_ch_no+7} = rxGain;
input_AD9361{s.in_ch_no+8} = 2e9;
input_AD9361{s.in_ch_no+9} = Fs;
input_AD9361{s.in_ch_no+10} = RFBW;

% ---------------------------------
IQ = zeros(1,tx_buff_size); 
input_AD9361{1} = real(IQ).'; % I
input_AD9361{2} = imag(IQ).'; % Q
output_AD9361 = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AD9361 Receiver Real-Time Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up plots
plotR = 2; % plot rows
plotC = 4; % plot cols

figxylw = [0.125 0.25 .85 .8]; % x, y, l, w % 1x3
figxylwFull = [0.005 0.045 .85 .75]; % x, y, l, w % full screen

set(gcf,'units','normalized','position',figxylwFull,'PaperPositionMode','auto'); % window size

%  ------------------------- RX1 Plots 
subi = 1;
hsub(subi) = subplot('position', subxylw(subi, plotR, plotC));
hold on
hIrx = plot(nan);
hQrx = plot(nan);
title('Time Domain (RX1)');
xlabel('Sample (N)');
ylabel('Amplitude');
ylim([-2000 2000]);
legend('I','Q');
grid on

hb = uicontrol('style','togglebutton')
set(hb,'position' ,[1 1,60 20])
set(hb, 'string','STOP')


subi = 2;
hsub(subi) = subplot('position', subxylw(subi, plotR, plotC));
hold on
hpsd = plot(nan);
hMarkPeak = plot(nan,'o');
peakText = text(-10,80, 'Peak: ','FontSize', 10);
text(-18.5,95, sprintf('f_{LO}: %sHz', eenot(fLO)));
title('PSD (RX1)');
xlabel('Frequency (MHz)');
ylabel('Power Density');
axis([-20 20 0 100]);
axis square
grid on

% Marker colors
symbColor = [0.8500, 0.3250, 0.0980];
demodColor = [0.4660, 0.6740, 0.1880];

subi = 3;
hsub(subi) = subplot('position', subxylw(subi, plotR, plotC));
hIQrxraw2 = plot(nan);
text(-1800,1800, sprintf('f_{LO}: %sHz', eenot(fLO)));
IQRerr2=text(250,1800, 'IQRerr %(RX1): ','FontSize', 10);
axis([-2000 2000 -2000 2000]);
axis square
grid on
 
subi = 4;
hsub(subi) = subplot('position', subxylw(subi, plotR, plotC));
hIQrxraw = plot(nan);
text(-700,700, sprintf('f_{LO}: %sHz', eenot(fLO)));
IQRmean=text(-50,700, 'IQRmean (RX1): ','FontSize', 10);
axis([-800 800 -800 800]);
axis square
grid on

%  ------------------------- RX2 Plots 
subi = 5;
hsub(subi) = subplot('position', subxylw(subi, plotR, plotC));
hold on
hIrx_RX2 = plot(nan);
hQrx_RX2 = plot(nan);
title('Time Domain (RX2)');
xlabel('Sample (N)');
ylabel('Amplitude');
ylim([-2000 2000]);
legend('I', 'Q');
grid on

subi = 6;
hsub(subi) = subplot('position', subxylw(subi, plotR, plotC));
hold on
hpsd_RX2 = plot(nan);
hMarkPeak_RX2 = plot(nan,'o');
peakText_RX2 = text(-10,80, 'Peak: ','FontSize', 10);
text(-18.5,95, sprintf('f_{LO}: %sHz', eenot(fLO)));
title('PSD (RX2)');
xlabel('Frequency (MHz)');
ylabel('Power Density');
axis([-20 20 0 100]);
axis square
grid on

subi = 7;
hsub(subi) = subplot('position', subxylw(subi, plotR, plotC));
hIQrxraw2_RX2 = plot(nan);
text(-1800,1800, sprintf('f_{LO}: %sHz', eenot(fLO)));
IQRerr2_RX2=text(250,1800, 'IQRerr (RX2): ','FontSize', 10);
axis([-2000 2000 -2000 2000]);
axis square
grid on

subi = 8;
hsub(subi) = subplot('position', subxylw(subi, plotR, plotC));
hIQrxraw_RX2 = plot(nan);
text(-700,700, sprintf('f_{LO}: %sHz', eenot(fLO)));
IQRmean_RX2=text(-50,700, 'IQRmean (RX2): ','FontSize', 10);
axis([-800 800 -800 800]);
axis square
grid on

output_AD9361 = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch)); % output data structure

while(1)
    output_AD9361 = stepImpl(s, input_AD9361); 

    %%%RX1 
    [px, fv] =  psdc(output_AD9361{1} + 1j*output_AD9361{2},Fs); % compute PSD on raw signal[peakMarkerY, peakMarkerX] = max(px);
    [peakMarkerY, peakMarkerX] = max(px);
    peakMarkerX = fv(peakMarkerX);
    IQrawtune=(output_AD9361{1,1} + 1j*output_AD9361{1,2});
    Ival=real(IQrawtune);
    Qval=imag(IQrawtune);
    IQrad=abs(IQrawtune);
    IQradmax=max(IQrad(1:16384)); 
    IQradmin=min(IQrad(1:16384));
    IQradmean=mean(IQrad);  
    IQradmid=(IQradmax+IQradmin)/2;
    IQraddeltapp=IQradmax-IQradmin;
    IQraddelta=IQraddeltapp/2;
    IQraddeltapercent=IQraddelta/IQradmid*100;
 
    set(hIrx, 'YData', output_AD9361{1}); % I time
    set(hQrx, 'YData', output_AD9361{2}); % Q time
    set(hpsd, 'XData', fv/1e6, 'YData', px); % PSD
    set(hMarkPeak,'XData', peakMarkerX/1e6, 'YData', peakMarkerY);
    set(hIQrxraw2, 'XData', output_AD9361{1}, 'YData', output_AD9361{2});
    set(hIQrxraw, 'XData', output_AD9361{1}, 'YData', output_AD9361{2});
    set(IQRerr2,'String', sprintf('IQRerr (RX1): %.2f', IQraddeltapercent));
    set(IQRmean,'String', sprintf('IQRmean (RX1): %.1f', IQradmean));
    set(hpsd, 'XData', fv/1e6, 'YData', px); % PSD
    set(hIQrxraw, 'XData', output_AD9361{1}, 'YData', output_AD9361{2});
    set(peakText, 'String', sprintf('Peak X: %s, Peak Y:%g', eenot(peakMarkerX), peakMarkerY));
    
    %%%RX2 
    [px_RX2, fv_RX2] =  psdc(output_AD9361{3} + 1j*output_AD9361{4},Fs); % compute PSD on raw signal[peakMarkerY, peakMarkerX] = max(px);
    [peakMarkerY_RX2, peakMarkerX_RX2] = max(px_RX2);
    peakMarkerX_RX2 = fv(peakMarkerX_RX2);
    IQrawtune_RX2=(output_AD9361{1,3} + 1j*output_AD9361{1,4});
    Ival_RX2=real(IQrawtune_RX2);
    Qval_RX2=imag(IQrawtune_RX2);
    IQrad_RX2=abs(IQrawtune_RX2);
    IQradmax_RX2=max(IQrad_RX2(1:16384));  
    IQradmin_RX2=min(IQrad_RX2(1:16384));
    IQradmean_RX2=mean(IQrad_RX2);      
    IQradmid_RX2=(IQradmax_RX2+IQradmin_RX2)/2;
    IQraddeltapp_RX2=IQradmax_RX2-IQradmin_RX2;
    IQraddelta_RX2=IQraddeltapp_RX2/2;
    IQraddeltapercent_RX2=IQraddelta_RX2/IQradmid_RX2*100;
 
    set(hIrx_RX2, 'YData', output_AD9361{3}); % I time
    set(hQrx_RX2, 'YData', output_AD9361{4}); % Q time
    set(hpsd_RX2, 'XData', fv_RX2/1e6, 'YData', px_RX2); % PSD
    set(hMarkPeak_RX2,'XData', peakMarkerX_RX2/1e6, 'YData', peakMarkerY_RX2);
    set(hIQrxraw2_RX2, 'XData', output_AD9361{3}, 'YData', output_AD9361{4});
    set(hIQrxraw_RX2, 'XData', output_AD9361{3}, 'YData', output_AD9361{4});
    set(IQRerr2_RX2,'String', sprintf('IQRerr (RX2): %.2f', IQraddeltapercent_RX2));
    set(IQRmean_RX2,'String', sprintf('IQRmean (RX2): %.1f', IQradmean_RX2));
    set(hpsd_RX2, 'XData', fv_RX2/1e6, 'YData', px_RX2); % PSD
    set(hIQrxraw_RX2, 'XData', output_AD9361{3}, 'YData', output_AD9361{4});
    set(peakText_RX2, 'String', sprintf('Peak X: %s, Peak Y:%g', eenot(peakMarkerX_RX2), peakMarkerY_RX2));
    
    drawnow; 
    
    if get(hb,'value')
        close gcf;
        break;
    end
end

prompt= 'Save RX output? Y/N \n';

x = input(prompt,'s')
if (strcmp(x,'y') | strcmp(x,'Y') | strcmp(x,'yes'))
    output_AD9361_mat = [output_AD9361{1}'; output_AD9361{2}'; output_AD9361{3}'; output_AD9361{4}'];
    output_AD9361_mat = output_AD9361_mat';
    save('output_AD9361_mat','output_AD9361_mat');
end
     







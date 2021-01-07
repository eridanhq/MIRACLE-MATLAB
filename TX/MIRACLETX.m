classdef MIRACLETX < handle
    % Eridan MIRACLE DevKit.  Requires the "SSH/SFTP/SCP For Matlab (v2)"
	% library created by David Scott Freedman
    % See https://www.mathworks.com/matlabcentral/fileexchange/35409-ssh-sftp-scp-for-matlab-v2
    properties
        FPGA % FPGA object to handle serial connection
        ipAddr % IP address
        SSH % ssh connection
    end
    methods
        function obj = MIRACLETX(addr)
            % Constructor.  Must specify IP address
            
            if any(ismember(addr,'.')) % string containing periods indicates IP address
                obj.ipAddr = addr; % assign address
            else
                error('Invalid IP address input.');
            end
            
            configSSH(obj); % connect via SSH
            writeSSH(obj,'');
            fprintf('Connected.\n');
        end
        
        function obj = configSSH(obj)
            % create the SSH object
            
            obj.SSH = ssh2_config(obj.ipAddr,'root','analog');
        end
        
        function commandResponse = writeSSH(obj,cmd,verbose)
            if nargin < 3
                verbose = 0;
            end
            [obj.SSH, commandResponse] = ssh2_command(obj.SSH, cmd, verbose);
        end
        
        function list = getSigs(obj)
            % Returns a list of signals available on the FPGA's SD card
            
            toParse = writeSSH(obj,'getsigs');
            list = toParse;
        end
        
        function out = findSigs(obj,str)
            % Finds all available signals that contain string 'str'
            
            sigs = getSigs(obj);
            i = contains(sigs, str,'IgnoreCase',true);
            out = sigs(i);
        end
        
        function jesdPhase = sysInit(obj,verbose)
            % Initializes MIRACLE RF Board
            if nargin < 2
                verbose = 1;
            end
            
            out = writeSSH(obj,'sysinit',verbose);
            jesdPhase = str2double(out{end});
        end
        
        function off(obj)
            % Sets system to minimum output power.
            
            writeSSH(obj,'off');
        end
        
        function on(obj)
            % Sets system to maximum output power.  SYSON must have been
            % called already in order to call this command.
            
            writeSSH(obj,'on');
        end
        
        function setSampleRate(obj,Fs)
            % Sets sampling rate of TX signal.  Enter Fs in Hz
            
            writeSSH(obj,sprintf('setsamplerate %.0f',Fs));
            setReg(obj,21,floor(Fs/100e6*2^16)); % adjust calc_rate
        end
        
        function setFreq(obj,f)
            % Sets TX carrier frequency in Hz
            
            writeSSH(obj,sprintf('setfreq %.0f\n', f));
        end
        
        function setPower(obj,p)
            % Sets power control register.  P should integer be in range [0,32767]
            
            writeSSH(obj,sprintf('setpwr %g',round(p)));
        end
        
        function setSig(obj,sig,Fs)
            % Loads a signal in from FPGA into MIRACLE TX.  Optionally set
            % the sample rate as well by specifying the second argument FS
            % in Hz
            
            if nargin >=3
                setSampleRate(obj,Fs);
            end
            
            writeSSH(obj,sprintf('setsig %s',sig));
            
        end
        
        function sysStat(obj)
            % Reports power status of MIRACLE DevKit TX
            
            writeSSH(obj,'sysstat',1);
        end
        
        function sysOff(obj)
            %     Sets power control register to 0, and turns system
            %     digitally controlled power supplies OFF
            
            writeSSH(obj,'sysoff',1);
        end
        
        function sysOn(obj)
            %     Turns system digitally-controlled power supplies ON
            
            writeSSH(obj,'syson',1);
        end
        
        function powerOff(obj)
            % Reports power status of MIRACLE DevKit TX
            
            writeSSH(obj,'sysoff',1);
            pause(1);
            writeSSH(obj,'poweroff',1);
            pause(3);
            fprintf('Safe to turn off FPGA board now.\n');
        end
        
        function setReg(obj, regNumList, regVal)
            % Sets register using MIRACLE FPGA
            if ismember(33, regNumList) % for SPI peripheral wries, make 32-bit
                regVal = typecast(uint32(regVal),'int32');
            end
            for regNum = regNumList
                cmd = sprintf('setreg %g %.0f',regNum, regVal);
                %     fprintf([cmd '\n']);
                writeSSH(obj,cmd);
                if regNum == 33
                    pause (0.001); % pause 1ms if SPI peripheral
                end
            end
        end
        
        function ssh2_conn = moveBinFileSD(obj, fileName)
            % Moves binary file to SD card on baseband FPGA.  Requires ethernet
            % connection.
            
            filePath = [fileName '.bin'];
            ssh2_conn = scp_simple_put(obj.ipAddr,'root','analog',filePath);
            
            
            writeSSH(obj,'mount /dev/mmcblk0p1 /mnt');
            writeSSH(obj,sprintf('mv %s.bin /mnt/%s.bin',fileName,fileName));
            writeSSH(obj,'umount /mnt');
            
        end
        function writeBinFileSD(obj, wave, fileName, normEn)
            % Writes binary vector and moves it to SD card.
            
            if nargin < 4
                MIRACLETX.writeBinVec(wave,fileName);
                %     writeBinVec(wave, fileName);
            else
                MIRACLETX.writeBinVec(wave,fileName,normEn);
                %     writeBinVec(wave, fileName,normEn);
            end
            moveBinFileSD(obj,fileName);
        end
    end
    
    methods(Static)        
        function writeBinVec(IQ, fileName, normEn)
            %     Writes vector in binary format, for ZC706.  First input
            %     IQ is single column or single row or complex waveform
            %     vector.  Second input FILENAME is the name of the file to
            %     be saved.  Option third input NORMEN enabled
            %     normalization of vector to unit magnitude (default).
            %     Recommended that the name of the signal vector be all
            %     capitalized to match Eridan's naming convention of the
            %     provided signals.
            
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
            
            fileID = fopen([fileName '.bin'], 'w'); % open file for write
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
            end
        end
    end
end
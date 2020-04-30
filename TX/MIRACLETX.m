classdef MIRACLETX < handle
    % Eridan MIRACLE DevKit
    properties
        port char % Serial port for UART communication
        FPGA % FPGA object to handle serial connection
        ipAddr % IP address
        SSH % ssh connection
    end
    methods
        function obj = MIRACLETX(prt)
            % Constructor.  Must specify serial COM port
            if nargin == 1
                obj.port = prt; % assign input port
            else
                error('Must specify COM port for obj.FPGA');
            end
            %             delete(instrfind('Port', obj.port));
            
            warning('off','MATLAB:serial:fscanf:unsuccessfulRead'); % Supress timeout warnings
            delete(instrfind('Port', obj.port));
            
            % create serial object to connect to FPGA
            obj.FPGA = serial(obj.port);
            set(obj.FPGA,'BaudRate',115200,'DataBits', 8, 'StopBits', 1,...
                'Parity', 'none');
            set(obj.FPGA,'InputBufferSize',1048576); % Input buffer size
            set(obj.FPGA,'OutputBufferSize',1048576); % Output buffer size
%             set(obj.FPGA, 'Timeout', .1); % Timeout
            set(obj.FPGA, 'Timeout', .05); % Timeout
            obj.FPGA.ReadAsyncMode = 'continuous'; % Continously query device to determine if data is available to be read
            open(obj); % Open serial connection to FPGA
            
        end
        
        function open(obj)
            % Opens serial connection to FPGA
            fopen(obj.FPGA);
        end
        
        function close(obj)
            % Closes serial connection to FPGA
            fclose(obj.FPGA);
            obj.SSH = ssh2_close(obj.SSH);
        end
        
        function out = readInBuff(obj)
            % Reads data from the FPGA in the input buffer, if any
            out = []; % Initialize output structure
            
            % Continuously read input buffer until obj.FPGA stops
            % transmitting data
            while get(obj.FPGA, 'BytesAvailable')
                temp = fscanf(obj.FPGA); % Get data from buffer
                out = [out temp]; % Concatenate to final output
            end
        end
        
        function out = read(obj,verbose,cmd,connectFlag)
            % Reads terminal lines from FPGA, and prints it to command
            % window. Effectively emmulates the Linux shell prompt. Command
            % finishes once the command line string "analog:~#" is found in
            % the response
            
            if nargin < 4
                connectFlag = 0;
            end
            if nargin < 2
                verbose = 0;
            end
            
            out = []; % Initialize output structure
            done = 0; % Initialize done flag
            cmdLineStr = 'analog:~#'; % Command line string to indicate command has completed
            
            cycle = 0;
            emptyBuffCount = 0;
            if (~verbose && connectFlag)
                fprintf('WAITING ON FPGA\n');
            end
            
            while (~done)
                temp = readInBuff(obj); % read the input buffer
                if ~isempty(temp)
                    emptyBuffCount = 0; % reset empty buffer count
                    temp = regexprep(temp, {'\r', '\n\n+'}, {'', '\n'}); % remove extra lines
                    out = [out temp];
                    if any(strfind(out,cmdLineStr)) % look for the command line string
                        done = 1;
                    end
                    if (verbose)
                        if nargin==3
                            temp = MIRACLETX.parseCmdLine(cmd,temp); % parse string for MATLAB friendly environment
                        end
                        fprintf(temp); % Print if verbose flag is set
                    end
                else
                    emptyBuffCount = emptyBuffCount + 1;
                    if emptyBuffCount > 20000
                        write(obj,''); % press enter
                        emptyBuffCount = 0;
                    end
                end
                
                if (~verbose && connectFlag)
                    if cycle < 16383
                        cycle = cycle+1;
                    else
                        cycle = 0;
                        fprintf('.');
                    end
                end
            end
            
            if (verbose)
                fprintf('\n');
            elseif (~verbose && connectFlag)
                fprintf('\nCONNECTED TO FPGA\n');
            end
        end
        
        function write(obj,cmd)
            % Writes string cmd to FPGA through output buffer on serial port
            
            fprintf(obj.FPGA,cmd);
            while get(obj.FPGA, 'BytesToOutput')
                % Wait until command is written to output buffer
            end
        end
        
        function out = writeRead(obj,cmd,verbose)
            % Writes command to FPGA and reads the response
            
            if nargin < 3
                verbose = 0;
            end
            
            readInBuff(obj); % Clear buffer if anything
            write(obj,cmd); % Write command
            
            toParse = read(obj,verbose,cmd); % Readback response
            
            out = MIRACLETX.parseCmdLine(cmd,toParse); % parse string for MATLAB friendly environment
        end
        
        function ipAddr = getIP(obj)
            ipAddr = strtrim(writeRead(obj,'ifconfig eth0 | grep Mask | awk ''{print $2}''| cut -f2 -d:'));
            obj.ipAddr = ipAddr;
        end
        
        function connect(obj,verbose)
            % Silently connects to FPGA
            
            if nargin < 2
                verbose = 0;
            end
            
            read(obj,verbose,'',1);
        end
        
        function list = getSigs(obj)
            % Returns a list of signals available on the FPGA's SD card
            
            toParse = writeRead(obj,'getsigs');
            
            toParse = regexprep(toParse, {'\r', '\n\n+'}, {'', '\n'});
            toParse = regexprep(toParse, {'\r', '\n\n+'}, {'', '\n'});
            list = textscan(toParse,'%s','Delimiter','\n');
            list = list{1};
            list = list(~cellfun('isempty',list));
        end
        
        function out = findSigs(obj,str)
            % Finds all available signals that contain string 'str'
            
            sigs = getSigs(obj);
            i = contains(sigs, str,'IgnoreCase',true);
            out = sigs(i);
        end
        
        function jesdPhase = init(obj,verbose)
            % Initializes MIRACLE RF Board
            if nargin < 2
                verbose = 0;
            end
            jesdPhase = str2double(writeRead(obj,'init',verbose));
        end
        
        function off(obj)
            % Sets system to minimum output power.
            
            write(obj,'off');
        end
        
        function on(obj)
            % Sets system to maximum output power.  SYSON must have been
            % called already in order to call this command.
            
            writeRead(obj,'on',1);
        end
        
        function setSampleRate(obj,Fs)
            % Sets sampling rate of TX signal.  Enter Fs in Hz
            
            write(obj,sprintf('setsamplerate %.0f',Fs));
        end
        
        function setFreq(obj,f)
            % Sets TX carrier frequency in Hz
            write(obj,sprintf('setfreq %.0f\n', f));
        end
        
        function setPower(obj,p)
            % Sets power control register.  P should integer be in range [0,32767]
            
            write(obj,sprintf('setpwr %g',round(p)));
        end
        
        function setSig(obj,sig,Fs)
            % Loads a signal in from FPGA into MIRACLE TX.  Optionally set
            % the sample rate as well by specifying the second argument FS
            % in Hz
            
            if nargin >=3
                setSampleRate(obj,Fs);
            end
            
            write(obj,sprintf('setsig %s',upper(sig)));
            
        end
        
        function stat(obj)
            % Reports power status of MIRACLE DevKit TX
            
            writeRead(obj,'stat',1);
        end
        
        function sysOff(obj)
            %     Sets power control register to 0, and turns system
            %     digitally controlled power supplies OFF
            
            writeRead(obj,'sysoff',1);
        end
        
        function sysOn(obj)
            %     Turns system digitally-controlled power supplies ON
            
            writeRead(obj,'syson',1);
        end
        
        function powerOff(obj)
            % Reports power status of MIRACLE DevKit TX
            
            writeRead(obj,'sysoff',1);
            pause(1);
            writeRead(obj,'poweroff',1);
            pause(3);
            fprintf('Safe to turn off FPGA board now.\n');
        end
    end
    
    methods(Static)
        function str = parseCmdLine(cmd,str)
            % Parses FPGA's output into a MATLAB friendly format
            
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
        end
        
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
            
            if normEn
                amp = 2048; % for 12-bit vectors
                IQNorm = normalize(IQ); % normalize by default
            else
                amp = 1;
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
            end
        end
    end
end
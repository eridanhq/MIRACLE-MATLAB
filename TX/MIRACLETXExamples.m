% -------------------------------------------------------------------------
% -------------- Run this script to setup MIRACLE TX ----------------------
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% --                                                                     --
% --                       Power on Instructions:                        --
% --                                                                     --
% -- 1) Turn on 12V.  Current should read 700-800mA.                     --
% -- 2) Wait a few seconds.  Current should rise to ~1.3A.  LEDs on      --
% --    RF board will start blinking.                                    --
% -- 3) Turn on FPGA power switch.                                       --
% -- 4) Run initEarl script.                                             --
% --                                                                     --
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% Setup MIRACLE.  Arg needs to be correct COM port as seen by the "Silicon
% Labs CP210x USB to UART Bridge" driver in the Windows Device Manager.
% See the DevKit manual for detailed instructions.
TX = MIRACLETXDev('COM4');

setSig(TX,'LTEDL20M_256QAM_30.72MSPS',30.72e6); % Load in LTE signal
init(TX); % Initialize RF board
sysOn(TX); % Turn on the digitally controlled power supplies.
on(TX); % Shortcut for maximum output power

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% --                                                                     --
% --                        Example TX control                           --
% --                                                                     --
% -- Uncomment and run any of the following lines for various TX         --
% -- controls.                                                           --
% --                                                                     --
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% --                        Frequency Control                            --
% -------------------------------------------------------------------------
% setFreq(TX, 1600e6); % change TX center frequency to 1600 MHz

% -------------------------------------------------------------------------
% --                          Power Control                              --
% -------------------------------------------------------------------------
% setPower(TX,32767); % Sets TX to maximum output power
% on(TX); % Shortcut for maximum output power
% setPower(TX,16384); % Sets TX to -6dB of max output power
% setPower(TX,0); % Sets TX to minimum output power
% off(TX); % Shortcut for minimum output power

% -------------------------------------------------------------------------
% --                         Signal Control                              --
% -------------------------------------------------------------------------
% getSigs(TX) % lists all availalbe signals on SD card.  Do NOT add semilcolon to end of this command, or it will suppress the list
% findSigs('TX','LTE') % searches the signal list for any items containing the string 'LTE'
% setSig(TX,'LTEDL20M_256QAM_30.72MSPS',30.72e6); % set signal.  Arg 2 is a string of the signal name, Arg 3 is the sample rate


% -------------------------------------------------------------------------
% --                           Utilities                                 --
% -------------------------------------------------------------------------
% sysOn(TX); % Turns on the digitally controlled power supplies.
% sysOff(TX); % Turns off the digitally controlled power supplies.  This is effectively a "sleep" mode
% powerOff(TX); % safely shuts down the RF board and baseband FPGA.  MUST CALL THIS COMMAND BEFORE SHUTTING DOWN
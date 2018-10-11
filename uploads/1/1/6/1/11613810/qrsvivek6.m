%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% QRS Detection Example                                                   +
% shows the effect of each filter according to Pan-Tompkins algorithm.    +
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

clear all
close all

ECG1 = load('ecg4rg.dat'); % load the ECG signal from the file
fs = 200;              % Sampling rate
N = length (ECG1);       % Signal length
t = [0:N-1]/fs;        % time index

%============================FIGURE1======================================
figure(1);
subplot(2,1,1)
plot(t,ECG1)
xlabel('second');ylabel('Volts');title('Input ECG Signal')
subplot(2,1,2)
plot(t(200:600),ECG1(200:600))
xlabel('second');ylabel('Volts');title('Input ECG Signal 1-3 second')
xlim([1 3])
%========================================================================== 
gh=mean (ECG1 );
ECG1 = ECG1 - gh ;    % cancel DC conponents
ECG1 = ECG1/ max( abs(ECG1 )); % normalize to one
%============================FIGURE2======================================
figure(2);
subplot(2,1,1)
plot(t,ECG1)
xlabel('second');ylabel('Volts');title('ECG after DC drift and normalization')
subplot(2,1,2)
plot(t(200:600),ECG1(200:600))
xlabel('second');ylabel('Volts');title(' ECG Signal 1-3 second')
xlim([1 3])
%==========================================================================
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                            LOW PASS FILTER
%``````````````````````````````````````````````````````````````````````````
%:::::::::::::::::::::LPF (1-z^-6)^2/(1-z^-1)^2::::::::::::::::::::::::::::
b=[1 0 0 0 0 0 -2 0 0 0 0 0 1];
a=[1 -2 1];
h_LP=filter(b,a,[1 zeros(1,12)]); % transfer function of LPF
ECGlp = conv (ECG1 ,h_LP);
ECGlp = ECGlp/ max( abs(ECGlp )); % normalize , for convenience .
%============================FIGURE3=======================================
figure(3)
subplot(2,1,1)
plot([0:length(ECGlp)-1]/fs,ECGlp)
xlabel('second');ylabel('Volts');title(' ECG Signal after LPF')
xlim([0 max(t)])
subplot(2,1,2)
plot(t(200:600),ECGlp(200:600))
xlabel('second');ylabel('Volts');title(' ECG Signal 1-3 second')
xlim([1 3])
%==========================================================================
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                            HIGH PASS FILTER
%``````````````````````````````````````````````````````````````````````````
%:::::::: HPF = Allpass-(Lowpass) = z^-16-[(1-z^-32)/(1-z^-1)]:::::::::::::
b = [-1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 32 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
a = [1 -1];
h_HP=filter(b,a,[1 zeros(1,32)]); % impulse response iof HPF
ECGhp = conv (ECGlp ,h_HP);
ECGhp = ECGhp/ max( abs(ECGhp ));
%============================FIGURE4=======================================
figure(4)
subplot(2,1,1)
plot([0:length(ECGhp)-1]/fs,ECGhp)
xlabel('second');ylabel('Volts');title(' ECG Signal after HPF')
xlim([0 max(t)])
subplot(2,1,2)
plot(t(200:600),ECGhp(200:600))
xlabel('second');ylabel('Volts');title(' ECG Signal 1-3 second')
xlim([1 3])
%==========================================================================
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                            SIGNAL DERIVATIVE
%``````````````````````````````````````````````````````````````````````````
% Make impulse response
h = [-1 -2 0 2 1]/8;
% Apply filter
ECGdiff = conv (ECGhp ,h);
ECGdiff = ECGdiff (2+[1: N]);
ECGdiff = ECGdiff/ max( abs(ECGdiff ));
%============================FIGURE5=======================================
figure(5)
subplot(2,1,1)
plot([0:length(ECGdiff)-1]/fs,ECGdiff)
xlabel('second');ylabel('Volts');title(' ECG Signal after Derivative')
subplot(2,1,2)
plot(t(200:600),ECGdiff(200:600))
xlabel('second');ylabel('Volts');title(' ECG Signal 1-3 second')
xlim([1 3])
%==========================================================================
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                            SIGNAL SQUARING
%``````````````````````````````````````````````````````````````````````````
ECGsqr = ECGdiff .^2;
ECGsqr = ECGsqr/ max( abs(ECGsqr ));
%============================FIGURE6=======================================
figure(6)
subplot(2,1,1)
plot([0:length(ECGsqr)-1]/fs,ECGsqr)
xlabel('second');ylabel('Volts');title(' ECG Signal Squarting')
subplot(2,1,2)
plot(t(200:600),ECGsqr(200:600))
xlabel('second');ylabel('Volts');title(' ECG Signal 1-3 second')
xlim([1 3])
%==========================================================================
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                            SIGNAL AVERAGING
%``````````````````````````````````````````````````````````````````````````
% Make impulse response
h = ones (1 ,31)/31;
Delay = 15; % Delay in samples

% Apply filter
ECGfinal = conv (ECGsqr ,h);
ECGfinal = ECGfinal (15+[1: N]);
ECGfinal = ECGfinal/ max( abs(ECGfinal ));
%============================FIGURE7=======================================

figure(7)
subplot(2,1,1)
plot([0:length(ECGfinal)-1]/fs,ECGfinal)
xlabel('second');ylabel('Volts');title(' ECG Signal after Averaging')
subplot(2,1,2)
plot(t(200:600),ECGfinal(200:600))
xlabel('second');ylabel('Volts');title(' ECG Signal 1-3 second')
xlim([1 3])
%==========================================================================
max_h = max(ECGfinal);
thresh = mean (ECGfinal );
poss_reg =(ECGfinal>thresh*max_h)';
%============================FIGURE8=======================================
figure (8)
subplot(2,1,1)
hold on
plot (t(200:600),ECG1(200:600)/max(ECG1))
box on
xlabel('second');ylabel('Integrated')
xlim([1 3])
subplot(2,1,2)
plot (t(200:600),ECGfinal(200:600)/max(ECGfinal))
xlabel('second');ylabel('Integrated')
xlim([1 3])
%==========================================================================
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                            QRS Detection
%``````````````````````````````````````````````````````````````````````````
left = find(diff([0 poss_reg])==1);
right = find(diff([poss_reg 0])==-1);
left=left-(6+16);  % cancel delay because of LP and HP
right=right-(6+16);% cancel delay because of LP and HP

for i=1:length(left)
    
    [Rval(i) Rlocation(i)] = max( ECG1(left(i):right(i)) );
    Rlocation(i) = Rlocation(i)-1+left(i); % add offset

    [Qval(i) Qlocation(i)] = min( ECG1(left(i):Rlocation(i)) );
    Qlocation(i) = Qlocation(i)-1+left(i); % add offset

    [Sval(i) Slocation(i)] = min( ECG1(left(i):right(i)) );
    Slocation(i) = Slocation(i)-1+left(i); % add offset

end

% there is no selective wave
Qlocation=Qlocation(find(Qlocation~=0));
Rlocation=Rlocation(find(Rlocation~=0));
Slocation=Slocation(find(Slocation~=0));
%============================FIGURE9=======================================
figure(9)
subplot(2,1,1)
title('ECG Signal with R points');
plot (t,ECG1/max(ECG1) , t(Rlocation) ,Rval , 'r^', t(Slocation) ,Sval, '*',t(Qlocation) , Qval, 'o');
legend('ECG','R','S','Q');
subplot(2,1,2)
plot (t,ECG1/max(ECG1) , t(Rlocation) ,Rval , 'r^', t(Slocation) ,Sval, '*',t(Qlocation) , Qval, 'o');
xlim([1 3])
%==========================================================================
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                            Heart Rate Calculation
%``````````````````````````````````````````````````````````````````````````
disp('Number of QRS detected :-->');
i;
Heartrate=(60*(i/20));
disp('HeartRate =');
disp(Heartrate);disp('beats/sec');
if (Heartrate==72)
     disp('normal');

else if(Heartrate<72)
    disp('bradicardia');
   
else
    disp('tachicardiya');
    end
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                            The End.
%``````````````````````````````````````````````````````````````````````````
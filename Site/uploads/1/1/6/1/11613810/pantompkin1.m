% program for QRS detection using Pan Tompkin Algorithm:
%**************************************************************************
%**************************************************************************
clear all; % to clear the workspace window and command window% 
close all;% to close the already opened windows%
fnam = input('Enter the ECG file name :-->','s'); % to get the file name input form the user and stored in "fnam" variable%      
fid = fopen(fnam); % using fopen command to  open the file %
ecg = fscanf(fid,'%f '); % ecg variable to store the input file %
fs = 200; % sampling frequency of ecg=2*100Hz=200Hz,according to Nyquist relation
size = length(ecg); % to get the length of matrix using length()

time = [1 : size]/fs; %total time interval
hr=0;%initialise hr
 ecg=ecg/max(abs(ecg));% normalize the maximum value to unity
figure;
plot(time,ecg);
title('original signal');
axis tight;
ylabel('ECG');
xlabel('Time in seconds');

%Apply Low Pass Filter
y1(11,1)=0; 
y1(12,1)=0;
ecg(1,1)=0; 
ecg(7,1)=0;
for n=13:size
   y1(n,1)=2*y1((n-1),1)-y1((n-2),1)+((ecg(n,1)-2*ecg((n-6),1)+ecg((n-12),1))/32);
 end
y1=y1/max(abs(y1));
figure;
plot(time,y1);
title('low pass filter output');
axis tight;
ylabel('y1');
xlabel('Time in seconds');
% hpf
ecg(17,1)=0;

y2(16,1)=0;
ecg(33,1)=0;
ecg(1,1)=0;

for n=1:20
  p(n)=0;
for n=33:size
    p(n,1)= ecg((n-16),1)-(y1((n-1),1)+ecg(n,1)-ecg((n-32),1))/32;
end
end

p=p/max(abs(p));
figure;
plot(time,p);
title('highpass filter output');
axis tight;
ylabel('p');
xlabel('Time in seconds');

for n= 5:size
y3(n,1)=(2*ecg(n,1)+ecg((n-1),1)-ecg((n-3),1)-2*ecg((n-4),1))/8; 
end
y3=y3/max(abs(y3));
figure;
plot(time,y3);
title('differenciator output');
axis tight;
ylabel('y3');
xlabel('Time in seconds');
for n=1:size
   y4(n,1)=y3(n,1)*y3(n,1);
end
y4=y4/max(abs(y4));
figure;
plot(time,y4);
title('squared signal');
axis tight;
ylabel('y4');
xlabel('Time in seconds');
for n=16:size
    y5(n,1)=((y4(n,1)+y4((n-1),1)+y4((n-2),1)+y4((n-3),1)+y4((n-4),1)+y4((n-5),1)+y4((n-6),1)+y4((n-7),1)+y4((n-8),1)+y4((n-9),1)+y4((n-10),1)+y4((n-11),1)+y4((n-12),1)+y4((n-13),1)+y4((n-14),1)+y4((n-15),1))/16);
end
y5=y5/max(abs(y5));
figure;
plot(time,y5);
title('integrator output');
axis tight;
ylabel('y5');
xlabel('Time in seconds');
c=1;

n=max(y5);
n
while (c<=size)
    if (y5(c,1)>=((7/10)*max(y5)))
        t=0;
        for i=1:8
            if (y5((c+i),1)>=((7/10)*max(y5)))
                t=t+1;
            end
        end
        if (t>=7)
            hr=hr+1;
        end
        c=c+9;
   else
        c=c+1;
    end
end
hr
h=hr
heartrate= (hr*60*fs)/20;
disp(heartrate);
if (heartrate==72)
     disp('normal');
end
if(heartrate<72)
    disp('bradicardia');
else
    disp('tachicardiya');
end

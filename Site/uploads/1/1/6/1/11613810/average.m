
clear all;
close all;
file = input('Enter name of wave file as a string: ');
[x,fs,bits] = wavread(file);
n = length(x);
fprintf('\n')
fprintf('Digit Statistics \n\n')
fprintf('samples: %.0f \n',n)
fprintf('sampling frequency: %.1f \n',fs)
fprintf('bits per sample: %.0f \n',bits)
fprintf('mean: %.4f \n',mean(x))
fprintf('standard deviation: %.4f \n', std(x))
fprintf('average magnitude: %.4f \n', mean(abs(x)))
fprintf('average power: %.4f \n', mean(x.^2))
prod = x(1:n-1).*x(2:n);
crossings = length(find(prod<0));
fprintf('zero crossings: %.0f \n', crossings)
subplot(2,1,1),plot(x),axis([1 n -1.0 1.0]),
title('Data sequence of spoken digit'),xlabel('Index'), grid,subplot(2,1,2),
hist(x,linspace(-1,1,51)),axis([-0.6,0.6,0,5000]),title('Histogram of data sequence'),xlabel('Sound amplitude'),ylabel('Number of samples'),grid


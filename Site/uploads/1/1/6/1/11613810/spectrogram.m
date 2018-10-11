% get a portion of signal
[y,fs]=wavread('kateeja.wav',[2000 12000]);
%
% calculate the table of amplitudes
[B,f,t]=specgram(y,1024,fs,256,192);
%
% calculate amplitude 50dB down from maximum
bmin=max(max(abs(B)))/300;
%
% plot top 50dB as image
imagesc(t,f,20*log10(max(abs(B),bmin)/bmin));
%
% label plot
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
%
% build and use a grey scale
lgrays=zeros(100,3);
for i=1:100
    lgrays(i,:) = 1-i/100;
end
colormap(lgrays);
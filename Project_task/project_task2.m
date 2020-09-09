%% Frequency Analysis using the DFT - A practical example
% This tutorial shows how to analyse the frequency content of a
% bass guitar to determine the fundamental frequencies of the 
% notes being played.
% Youtube Video available at http://youtu.be/eg8eebQPfAo95
%
% Matlab code will be available at https://dadorran.wordpress.com
 
% First download http://eleceng.dit.ie/dorran/matlab/bass.wav
[ip,fs]=audioread('bass.wav');
%%
% Now extract a short segment from the guitar signal 
% which contains two notes being played over 0.45 seconds
seg = ip(670000:689000);
sound(seg, fs); %use this to hear the two notes being played
figure 
plot(seg);
xlabel('samples');
ylabel('Amplitude');
%%
% Annotate the figure to show where the two notes occur and 
% indicate fundamental frequencies 
annotation('doublearrow',[0.14 .45],[0.3 0.3]);
annotation('textbox',[0.14 .25 0.4 0.05],'string',...
    {'Note 1' 'Fundamental approx 72 Hz'},...
    'LineStyle', 'none', 'HorizontalAlignment','center');
annotation('doublearrow',[0.55 .85],[0.3 0.3]);
annotation('textbox',[0.55 .25 0.4 0.05],'string',...
    {'Note 2' 'Fundamental approx 86 Hz'},...
    'LineStyle', 'none', 'HorizontalAlignment','center');
 
%% Extract a frame/window of length 2000 samples from Note 1   
% Analyse the frequency content of the frame.
N = 2000;
frame = seg(1:N-1); % this is a frame associated with Note 1
ft_mags = abs(fft(frame));
num_bins_to_display = 250;
figure
plot([0:num_bins_to_display-1], ft_mags(1:num_bins_to_display))
xlabel('Frequency Bins')
ylabel('Magnitude')
%%
% This plot shows that the signal has three 'strong' frequency
% componentsi.e. the fundamental and first two harmonics
%%
% Let's try to determine the fundamental frequency by analysing 
% the DFT.
% The fundamental is the strongest frequency component present 
% i.e. the maximum. By zooming in on the plot it can be seen that 
% it is located at bin number 3. Alternatively we can use matlabs 
% built-in max function.
[max_val fundamental_location] = max(ft_mags); 
% NOTE : fundamental_location uses matlabs indexing which is 
% different to bin number by 1
%%
% Each bin is separated by fs/N Hz so the fundamental frequency 
% determined from analysis of this magnitude spectrum is 3(fs/N)
% NOTE : the fundamental_location variable obtained from the max 
% function uses matlabs indexing which is different to the bin 
% number by 1.
fundamental_frequency = (fundamental_location-1)*fs/N 
%%
% This result of 66.15 Hz is inaccurate (the fundamental 
% frequency is actually about 72 Hz). 
% The inaccuracy arises due to the limitation of the DFT frequency
% resolution. 
% We can only be sure that the result obtained using this type of 
% analysis is accurate to within fs/N = 22.05 Hz.
 
%% Extract a frame/window of length 5000 samples from Note 1
% This increases frequency resolution and improves the accuracy of
% the analysis.
N = 5000;
frame = seg(1:N-1);
ft_mags = abs(fft(frame));
num_bins_to_display = 250;
figure;
plot([0:num_bins_to_display-1], ft_mags(1:num_bins_to_display))
xlabel('Frequency Bins')
ylabel('Magnitude')
title('Magnitude of First 250 DFT bins of Note 1')
%%
% Notice that the fundamental and harmonics are separated by a 
% greater number of DFT bins than for N = 2000.
%%
% Now, determine fundamental frequency using the same technique 
% as before.
[max_val fundamental_location] = max(ft_mags);
fundamental_frequency = (fundamental_location-1)*fs/N
%%
% The result of 70.56 Hz is more accurate because the DFT 
% frequency resolution is higher. For this case we can be sure 
% that the result will be within fs/N = 8.82 Hz of the actual 
% fundamental frequency.
 
%% Extract a frame/window of length 5000 samples from Note 2
N = 5000;
%extract  samples from the end of the segment
frame = seg(end-N:end); 
ft_mags = abs(fft(frame));
num_bins_to_display = 250;
figure;
plot([0:num_bins_to_display-1], ft_mags(1:num_bins_to_display))
xlabel('Frequency Bins')
ylabel('Magnitude')
title('Magnitude of First 250  DFT bins of Note 2')
%%
% Determine fundamental frequency using the same technique as above
[max_val fundamental_location] = max(ft_mags);
fundamental_frequency_note2 = (fundamental_location-1)*fs/N
%%
% This result is close to the actual fundamental frequency of 86Hz. 
% Further improvement will be obtained if N is increased further 
% (as shown in the next section)
 
%% Analyse the DFT of the entire segment
% The resolution is higher than previous analysis
N = length(seg);
ft_mags = abs(fft(seg));
num_bins_to_display = 250;
figure;
plot([0:num_bins_to_display-1], ft_mags(1:num_bins_to_display))
xlabel('Frequency Bins')
ylabel('Magnitude')
title('Magnitude of First 250 DFT bins of both notes')
%%
% This code might be tricky to follow - I'm just highlighting
% the fundamental and first two harmonics of each note in the plot.
% don't worry if this part of the code is confusing.
note1_fund_freq = 72;
note2_fund_freq = 86;
ft1 = ones(1, length(ft_mags))*NaN;
ft2 = ones(1, length(ft_mags))*NaN;
for k = 1: 3 
   ft1(round(note1_fund_freq*k/fs*N)...
       + 1 - 3:round(note1_fund_freq*k/fs*N)+ 1+ 3)...
       = ft_mags(round(note1_fund_freq*k/fs*N)+1 - 3:...
       round(note1_fund_freq*k/fs*N)+ 1+ 3);
   ft2(round(note2_fund_freq*k/fs*N)...
       + 1 - 3:round(note2_fund_freq*k/fs*N)+ 1+ 3)...
       = ft_mags(round(note2_fund_freq*k/fs*N)+1 - 3:...
       round(note2_fund_freq*k/fs*N)+ 1+ 3);
end
hold on
plot([0:num_bins_to_display-1], ft1(1:num_bins_to_display),'r')
plot([0:num_bins_to_display-1], ft2(1:num_bins_to_display),'g')
legend('','Note 1 fundamental and harmonics',...
    'Note 2 fundamental and harmonics')
%%
%Determine fundamental frequency using the same technique
% as above.
[max_val fundamental_location] = max(ft_mags);
fundamental_frequency_note1 = (fundamental_location-1)*fs/N
%%
% From the plot it can be seen that the frequency of the 
% fundamental of the second note is associated with bin 37 
% (no need to subtract 1 in equation below because the max 
% function isn't being used).
fundamental_frequency_note2 = 37*fs/N
 
%% A 'Better' Approach to higher frequency resolution 
% 
% While improvements in results have been obtained using a longer 
% window the plot of the magnitude spectrum is becoming more 
% difficult to interpret as there is a lot of spectral energy in 
% the signal (energy from two notes rather than one). It would be 
% nicer to be able to get higher frequency resolution without the 
% problem of the magnitude spectrum becoming more difficult to 
% interpret.
%
% The way to get improved resolution without having a more 
% complicated spectrum to deal with is to 'artificially' make 
% the signal longer through a process known as zero padding 
% (see https://www.youtube.com/watch?v=V_dxWuWw8yM for a tutorial
% on zero padding and windowing).
%
% We'll go back to the case where we extracted the first 5000 
% samples of note 1 and then append 40,000 samples of zero 
% amplitude to this signal.
N = 5000;
frame = seg(1:N-1);
% Make the frame 'longer' by zero-padding 40000 samples of 
% amplitude zero
zpad_frame = [frame ;zeros(40000,1)]; 
new_frame_len = length(zpad_frame);
%%
figure
plot(zpad_frame)
xlabel('samples')
ylabel('Amplitude')
title(...
 'First 5000 samples of Note 1 zero-padded by 40000 zero samples')
%%
% Now plot the magnitude spectrum as before
ft_mags = abs(fft(zpad_frame));
num_bins_to_display = 250;
figure
plot([0:num_bins_to_display-1], ft_mags(1:num_bins_to_display))
xlabel('Frequency Bins')
ylabel('Magnitude')
title('Magnitude of First 250 DFT bins of Note 1')
%%
% Now, determine fundamental frequency using the same technique 
% as before.
% NOTICE that the frequency resolution is now fs/new_frame_len
[max_val fundamental_location] = max(ft_mags);
fundamental_frequency = (fundamental_location-1)*fs/new_frame_len
%%
% This result is accurate to fs/new_frame_len Hz
fs/new_frame_len
%%
% If the frame was zero padded by a greater amount then the 
% frequency resolution would improve and therefore the accuracy of 
% the frequency estimate would improve.
 
%% What happens if the frame length is too short??
% We've seen in the examples so far that the separation between 
% fundamental and harmonics increases as the frequency resolution 
% increases. It follows that the separation between harmonics will
% decrease as the the frequency resolution decreases. If the 
% frequency resolution can be so low that the harmonics will not 
% be separated.
%
% Let's see what happens if we take frame length of 1500 samples
N = 1500;
frame = seg(1:N-1); % this is a frame associated with Note 1
ft_mags = abs(fft(frame));
num_bins_to_display = 100;
figure
plot([0:num_bins_to_display-1], ft_mags(1:num_bins_to_display))
 
xlabel('Frequency Bins')
ylabel('Magnitude')
title('Magnitude of First 100 DFT bins of Note 1')
%%
% Notice that only the first 50 bins are shown in this case 
% - this is to make it easier to see the harmonics.
%
% It can be seen that the harmonics are very close together 
% - in fact they are only separated by 1 bin!
%
% If a lower frequency resolution analysis is performed the 
% harmonics will not be separated at all.
%%
%
% Let's see what happens if we take frame length of 1200 samples
N = 1200;
frame = seg(1:N-1); % this is a frame associated with Note 1
ft_mags = abs(fft(frame));
num_bins_to_display = 100;
figure
plot([0:num_bins_to_display-1], ft_mags(1:num_bins_to_display))
 
xlabel('Frequency Bins')
ylabel('Magnitude')
title('Magnitude of First 100 DFT bins of Note 1')
%%
% At this stage there is now separation between the higher 
% harmonics
%
% Let's see what happens if we take frame length of 1000 samples
N = 1000;
frame = seg(1:N-1); % this is a frame associated with Note 1
ft_mags = abs(fft(frame));
num_bins_to_display = 100;
figure
plot([0:num_bins_to_display-1], ft_mags(1:num_bins_to_display))
 
xlabel('Frequency Bins')
ylabel('Magnitude')
title('Magnitude of First 100 DFT bins of Note 1')
%%
% There is no separation between fundamental or harmonics 
% - the frequency resolution is too low. Looking at this magnitude
% spectrum you would probably interpret it to mean that there was 
% one sinusoidal component present in the signal (or perhaps two 
% given the small peak at bin 10)
%%
% To the uninitiated the solution to this problem might be to zero
% pad the frame in order to improve the frequency resolution.
% However, this doesn't work. An indepth discussion as to reason 
% why it doesn't work is beyond the scope of this tutorial (as it
% requires a very good understanding of how the DFT works) but a 
% basic conceptual  understanding can be obtained by considering 
% an extreme case whereby you extracted a frame of which is just 
% of length 1 sample. If you only have only sample it would be 
% impossible to determine any frequency domain information since 
% frequency relates to the rate of change of samples. Even if you 
% had two samples you still have a very limited view of the 
% frequency of the signal and no amount of zero padding will help. 
% Hopefully you can appreciate that you need some number of 
% time-domain samples in order to extract out useful frequency 
% content. As a general rule you need at least one cycle of a 
% periodic signal to in order to be able to extract 'useful' 
% frequency content associated with the signal. It is only when 
% you have a sufficient amount of time-domain data that 
% zero-padding can be used to obtain more accurate frequency 
% estimates.
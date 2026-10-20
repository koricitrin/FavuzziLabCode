function CalculatePeaksFreqAmp(Paths)

sampleFreq = 30;

    for k = 1:size(Paths,1)
        cd(Paths(k,:))
        Sess = Paths(k,68:83)
        load([Sess '_dFFGF.mat'])
        TimeSec = (length(dFFGF)/sampleFreq);

        for neur = 1:size(dFFGF,1)

            % Compute baseline using mode
            baseline = mode(dFFGF(neur,:));

            % thresholdVal_1 = baseline + (1 * std(dFFGF(neur,:)));
            % thresholdVal_2 = baseline + (2 * std(dFFGF(neur,:)));
            thresholdVal = baseline + (1.5 * std(dFFGF(neur,:)));
         

            [pks, locs] = findpeaks(dFFGF(neur,:));
            numPeaks{neur} = sum(pks > thresholdVal);
            PeaksSigIndex = (pks > thresholdVal);
            SigPeakValue{neur} = pks(PeaksSigIndex);
            SigPeakTime{neur} = locs(PeaksSigIndex);
            MeanPeakValue{neur} =  mean(SigPeakValue{neur});
            StdPeakValue{neur} =  std(SigPeakValue{neur});
            PeakRate{neur}   =   numPeaks{neur}/TimeSec;
        
            % figure
            % hold on
            % plot(dFFGF(neur,:))
            % yline(thresholdVal, 'LineWidth', 2)
            % scatter(SigPeakTime{neur},SigPeakValue{neur})
            % xlim([0 length(dFFGF)]) 
            % T = ['neuron' num2str(neur) 'thres1p5'];
            % title(T)
            % savefig([T '.fig'])
            % print('-painters','-dpng',[T],'-r600');    
            % 

            'stop'
        end

        PeakInfo.numPeaks =  numPeaks;
        PeakInfo.PeakValue =  SigPeakValue;
        PeakInfo.PeakTime = SigPeakTime;
        PeakInfo.MeanPeakValue = MeanPeakValue;
        PeakInfo.StdPeakValue = StdPeakValue;
        PeakInfo.PeakRate = PeakRate;

  
       save('PeakInformation.mat', 'PeakInfo')
    end

end
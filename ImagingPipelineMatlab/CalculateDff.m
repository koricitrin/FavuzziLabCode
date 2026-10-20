function CalculateDff(FileNameBase, DataPath)
% calculate dF/F from the fluorescence data

      TwoPhotonPath = [DataPath 'suite2p\plane0\Fall.mat']
     data_2p = load(TwoPhotonPath);      

    % extract cluster information 
    ROIs = extractROIs(data_2p);
        save([FileNameBase '_ROIs.mat'], 'ROIs');

    DeconvolvedSpikes = data_2p.spks(ROIs.localROIs,:);
    save([FileNameBase '_DeconvolvedSpikes.mat'], 'DeconvolvedSpikes');

     % calculate corrected fluorescence
    Fcorrected = data_2p.F(ROIs.localROIs,:) - data_2p.ops.neucoeff*data_2p.Fneu(ROIs.localROIs,:); % corrected fluorescence
    Fbaseline = zeros(size(Fcorrected,1),size(Fcorrected,2));
    
    % generate gaussian filter to determine baseline
    sig_baseline = 10; % sec
    std = round(sig_baseline*data_2p.ops.fs);
    h = gaussFilter2P(6*std,std);
    lenGaussKernel = length(h);
    
    % calculate the baseline using minmax filter
    win = round(data_2p.ops.win_baseline*data_2p.ops.fs);
    for i = 1:length(ROIs.localROIs)
       
           baselineTmp = gauss_filter(Fcorrected(i,:),h,lenGaussKernel);
            baselineTmp = minimum_filter1d(baselineTmp,win);
            baselineTmp = maximum_filter1d(baselineTmp,win);
            Fbaseline(i,:) = baselineTmp;  % baseline fluorescence F0
            FminusBaseline(i,:) = Fcorrected(i,:) - baselineTmp; % F-F0 
         
    end
    
    % calculate dFF
    dFF = FminusBaseline./Fbaseline;  

    Fc = FminusBaseline;
    F0 = Fbaseline;

    save([FileNameBase '_dFF.mat'], 'F0', 'Fc', 'dFF');

    %% get gaussian filtered dFF
    stdsm = 25;
    h = gaussFilter2P(12*stdsm,stdsm); 
    lenGaussKernel = length(h);

  for i = 1:size(dFF,1)
         
       dFFGF(i,:) = gauss_filter(dFF(i,:),h,lenGaussKernel); % gaussian filtered non-thresholded dFF
  end
    save([FileNameBase '_dFFGF.mat'],'dFFGF', 'stdsm');
% figure
% subplot(3,1,1)
%  plot(DeconvolvedSpikes(1,1:10000))
%  title('spikes') 
%  subplot(3,1,2)
%  plot(dFF(1,1:10000))
%   title('dFF')
%   subplot(3,1,3)
%   plot(dFFGF(1,1:10000))
%   title('dFFGF-25')
%    T = ['compareSpikesDffgf25'];
%    savefig([T '.fig'])
%    print('-painters','-dpng',[T],'-r600');
end

function output = gauss_filter(input,h,lenh)
    % get a row vector
    if(size(input,1) ~= 1)
        input = input';
    end
    
    % reflect the input vector at the beginning and end
    halfWin = ceil(lenh/2);
    inReflectStart = input(halfWin:-1:1);
    inReflectEnd = input(end:-1:end-halfWin+1);
    inTmp = [inReflectStart input inReflectEnd];
    
    output = conv(inTmp,h);
    
    output = output(halfWin+floor(lenh/2)+1:end-halfWin-lenh+floor(lenh/2)+1); 
                    % cut the convolution result to be the same length as the original data
end

function output = minimum_filter1d(input,win)
    % get a row vector
    if(size(input,1) ~= 1)
        input = input';
    end
    
    % reflect the input vector at the beginning and end
    halfWin = ceil(win/2);
    inReflectStart = input(halfWin:-1:1);
    inReflectEnd = input(end:-1:end-halfWin+1);
    inTmp = [inReflectStart input inReflectEnd];
    
    outTmp = movmin(inTmp,win);
    output = outTmp(halfWin+1:end-halfWin);
end

function output = maximum_filter1d(input,win)
    % get a row vector
    if(size(input,1) ~= 1)
        input = input';
    end
    
    % reflect the input vector at the beginning and end
    halfWin = ceil(win/2);
    inReflectStart = input(halfWin:-1:1);
    inReflectEnd = input(end:-1:end-halfWin+1);
    inTmp = [inReflectStart input inReflectEnd];
    
    outTmp = movmax(inTmp,win);
    output = outTmp(halfWin+1:end-halfWin);
end

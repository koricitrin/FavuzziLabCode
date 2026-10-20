function ROIs = extractROIs(data_2p)
% extract the cells that are manually curated

    % indice of manually selected cells
    indSel = find(data_2p.iscell(:,1) == 1);
    
    % total number of cells
    totNoCells = size(data_2p.iscell,1);
    
    % label all the cells that are merged into one cell
    merged = zeros(1,totNoCells);
    for i = 1:length(indSel)
        if(isfield(data_2p.stat{indSel(i)},'imerge') && ~isempty(data_2p.stat{indSel(i)}.imerge))
            merged(data_2p.stat{indSel(i)}.imerge+1) = 1;
        end
    end
    indMerged = find(merged == 1);
    
    % final cell list
    indSel = setdiff(indSel, indMerged);
    totNoCells = length(indSel);
    
    % getting the statistics of the cells
    ROIs = struct(...
                'localROIs', zeros(1,totNoCells),...
                'ypix', {cell(1,totNoCells)},...
                'xpix', {cell(1,totNoCells)},...
                'lam', {cell(1,totNoCells)},...
                'med', zeros(2,totNoCells),...
                'footprint', zeros(1,totNoCells),...
                'mrs', zeros(1,totNoCells),...
                'compact', zeros(1,totNoCells),...
                'solidity', zeros(1,totNoCells),...
                'npix', zeros(1,totNoCells),...
                'radius', zeros(1,totNoCells),...
                'aspect_ratio', zeros(1,totNoCells),...
                'npix_norm', zeros(1,totNoCells),...
                'skew', zeros(1,totNoCells),...
                'std', zeros(1,totNoCells),...
                'chan2_prob', zeros(1,totNoCells));
            
    for i = 1:totNoCells
        ROIs.localROIs(i) = indSel(i);
        ROIs.ypix{i} = data_2p.stat{indSel(i)}.ypix;
        ROIs.xpix{i} = data_2p.stat{indSel(i)}.xpix;
        ROIs.lam{i} = data_2p.stat{indSel(i)}.lam;
        ROIs.med(:,i) = data_2p.stat{indSel(i)}.med';
        ROIs.footprint(i) = data_2p.stat{indSel(i)}.footprint;
        ROIs.mrs(i) = data_2p.stat{i}.mrs;
        ROIs.compact(i) = data_2p.stat{indSel(i)}.compact;
        ROIs.solidity(i) = data_2p.stat{indSel(i)}.solidity;
        ROIs.npix(i) = data_2p.stat{indSel(i)}.npix;
        ROIs.radius(i) = data_2p.stat{indSel(i)}.radius;
        ROIs.aspect_ratio(i) = data_2p.stat{indSel(i)}.aspect_ratio;
        ROIs.npix_norm(i) = data_2p.stat{indSel(i)}.npix_norm;
        ROIs.skew(i) = data_2p.stat{indSel(i)}.skew;
        ROIs.std(i) = data_2p.stat{indSel(i)}.std;
        ROIs.chan2_prob(i) = data_2p.stat{indSel(i)}.chan2_prob;
    end
    % save([savePath] 'Clu.mat'])
end


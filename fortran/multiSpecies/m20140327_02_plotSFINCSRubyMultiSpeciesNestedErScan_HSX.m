function m20140327_02_plotSFINCSRubyMultiSpeciesNestedErScan_HSX()

multiplyFluxesBy = -1;

multiplyErBy = -2.93;

% Name of .h5 HDF5 file from SFINCS:
h5filename='sfincsOutput.h5';

excludeRunsThatDidntConverge = true;
%excludeRunsThatDidntConverge = false;

figureOffset = 3;

colors = [1,0,0;
    0.8,0.6,0;
    0,0.7,0;
    0,0,1]

%{
colors = [1,0,0;
    1,0.5,0.5;
    1,0.9,0;
    0.8,0.6,0;
    0,0.7,0;
    0,1,0;
    0,0.8,0.9;
    0,0,1;
    1,0,1;
    0.8,0.8,0.8;
    0.5,0.5,0.5;
    0,0,0;
    1,0.5,0.5];
%}

linespecs = {'.','x','+'};

%linespecs = {'.-r','.-g','.-b','.-m','.-c','.-r','.-r','.-b','.-m'};

numRuns = 0;
RHSMode1s = 1;
RHSMode2s = 0;
dumpedFieldsYet = false;
%didItConverges = [];
Nthetas = [];
Nzetas = [];
Nxis = [];
NLs = [];
Nxs = [];
NxPotentialsPerVths = [];
xMaxs = [];
log10tols = [];
dPhiHatdpsiNs = [];
Nspecies = -1;
descriptions = {};
dPhiHatdpsiNs = {};
outputs = {};
runsThatSucceeded = {};
runsThatFailed = {};

NOuters = 0;
outerDirectories = dir();
for iOuter = 1:size(outerDirectories,1)
    if ~ outerDirectories(iOuter).isdir
        continue
    end

    % Skip the . and .. directories
    if strcmp(outerDirectories(iOuter).name,'.') | strcmp(outerDirectories(iOuter).name,'..')
        continue
    end

    % If we made it this far, then count this directory.

    NOuters = NOuters + 1;
    descriptions{NOuters} = outerDirectories(iOuter).name;
    NErsForThisOuter = 0;
    dPhiHatdpsiNsForThisOuter = [];
    outputsForThisOuter = [];
    runsThatSucceededForThisOuter = {};
    runsThatFailedForThisOuter = {};

    innerDirectories = dir(outerDirectories(iOuter).name);
    for iInner = 1:size(innerDirectories,1)

        if ~ innerDirectories(iInner).isdir
            continue
        end

        % Skip the . and .. directories
        if strcmp(innerDirectories(iInner).name,'.') | strcmp(innerDirectories(iInner).name,'..')
            continue
        end

        dirName = [outerDirectories(iOuter).name,'/',innerDirectories(iInner).name];
        %fprintf('Processing directory %s\n',dirName)
        
        % Try to open an HDF5 file
        filename = [dirName, '/', h5filename];
        try
            info = h5info(filename);
            fprintf('Successfully opened h5 file %s\n',filename)
        catch
            fprintf('Did not succeed in opening h5 file %s\n',filename)
            runsThatFailedForThisOuter{end+1} = innerDirectories(iInner).name;
            continue
        end
                
        if ~ dumpedFieldsYet
            fprintf('Fields saved in the HDF5 files:\n')
            for i=1:numel(info.Groups(1).Datasets)
                fprintf('  %s\n',info.Groups(1).Datasets(i).Name)
            end
            dumpedFieldsYet = true;
        end

        programMode = h5read(filename,'/programMode');
        if programMode ~= 1
            fprintf('Ignoring this run since programMode is not 1.\n')
            continue
        end
        
        location  = getLocationString(1);
        integerToRepresentTrue = h5read(filename,[location,'integerToRepresentTrue']);
        didItConverge = h5read(filename,[location,'didItConverge']);
        if excludeRunsThatDidntConverge && (didItConverge ~= integerToRepresentTrue)
            fprintf('Ignoring this run since it did not converge.\n')
            runsThatFailedForThisOuter{end+1} = innerDirectories(iInner).name;
            continue
        end
        
        
        % If we made it this far, then let's count the run.
        runsThatSucceededForThisOuter{end+1} = innerDirectories(iInner).name;
        NErsForThisOuter = NErsForThisOuter + 1;
        %didItConverges(numRuns) = (didItConverge == integerToRepresentTrue);
        if didItConverge ~= integerToRepresentTrue
            beep
            fprintf('Warning: the run with iOuter = %d and iInner = %d did not converge.\n',iOuter, iInner)
        end
        
        Nspecies_new = h5read(filename,[location,'Nspecies']);
        if Nspecies < 0
            Nspecies = Nspecies_new;
        else
            if Nspecies ~= Nspecies_new
                error('Number of species is not consistent among runs')
            end
        end
        
        dPhiHatdpsiNsForThisOuter(NErsForThisOuter) = h5read(filename,[location,'d(PhiHat)d(psi_N)']);
        
        outputsForThisOuter(NErsForThisOuter,((1:Nspecies)-1)*3+1) = h5read(filename,[location,'particleFlux']);
        outputsForThisOuter(NErsForThisOuter,((1:Nspecies)-1)*3+2) = h5read(filename,[location,'heatFlux']);
        outputsForThisOuter(NErsForThisOuter,((1:Nspecies)-1)*3+3) = h5read(filename,[location,'FSABFlow']);
        if Nspecies == 1
            outputsForThisOuter(NErsForThisOuter,4) = h5read(filename,[location,'didItConverge']);
            outputs(ForThisOuterNErsForThisOuter,5) = h5read(filename,[location,'elapsed time (s)']);
        end
        
    end % of iInner loop   
    
    dPhiHatdpsiNs{NOuters} = dPhiHatdpsiNsForThisOuter;
    outputs{NOuters} = outputsForThisOuter;
    runsThatSucceeded{NOuters} = runsThatSucceededForThisOuter;
    runsThatFailed{NOuters} = runsThatFailedForThisOuter;
    
end % of iOuter loop

fprintf('Summary of which runs succeeded:\n')
for iOuter = 1:NOuters
    fprintf('  %50s: ',descriptions{iOuter})
    for iInner = 1:numel(runsThatSucceeded{iOuter})
        fprintf('%s ',runsThatSucceeded{iOuter}{iInner})
    end
    fprintf('\n')
end
fprintf('Summary of which runs Failed:\n')
for iOuter = 1:NOuters
    fprintf('  %50s: ',descriptions{iOuter})
    for iInner = 1:numel(runsThatFailed{iOuter})
        fprintf('%s ',runsThatFailed{iOuter}{iInner})
    end
    fprintf('\n')
end

if Nspecies == 1
    yAxesLabels = {'Particle flux','q','<V|| B>','Did it converge','elapsed time'};
    numQuantities = numel(yAxesLabels);
    plotRows = 1:numQuantities;
    numRows=numQuantities;
else
    yAxesLabels=cell(0);
    for i=1:Nspecies
        if i==1
            speciesText = 'ions';
        else
            speciesText = 'electrons';
        end
        yAxesLabels{end+1} = ['Particle flux, ', speciesText];
        yAxesLabels{end+1} = ['Heat flux, ', speciesText];
        yAxesLabels{end+1} = ['<V|| B>, ', speciesText];
    end
    numQuantities = numel(yAxesLabels);
    plotRows = 1:numQuantities;
    numRows=numQuantities;
end


figure(1+figureOffset)
clf
set(gcf,'Color','w')

numRows = 2;
numCols = 3;

for iQuantity = 1:numQuantities
    subplot(numRows, numCols, iQuantity)
    for iOuter = 1:NOuters
        switch descriptions{iOuter}
          case 'FP_DKES'
            descriptions{iOuter} = 'Fokker-Planck collisions, DKES trajectories';
          case 'FP_full'
            descriptions{iOuter} = 'Fokker-Planck collisions, full trajectories';
          case 'PAS_DKES'
            descriptions{iOuter} = 'Pitch-angle scattering collisions, DKES trajectories';
          case 'PAS_full'
            descriptions{iOuter} = 'Pitch-angle scattering collisions, full trajectories';
        end
        %size(dPhiHatdpsiNs{iOuter})
        %size(outputs{iOuter}(:,iQuantity))
        %size(colors(iOuter,:))
        N = numel(dPhiHatdpsiNs{iOuter});
        %fprintf('about to plot\n')
        if N>0
            %size(outputs{iOuter})
            linespecIndex = 1 + mod(iOuter-1, numel(linespecs));
            colorIndex = 1 + mod(iOuter-1, size(colors,1));
            data_x_unsorted = dPhiHatdpsiNs{iOuter}' * multiplyErBy;
            data_y_unsorted = outputs{iOuter}(:,iQuantity);
            [~,permutation] = sort(data_x_unsorted);
            if iQuantity ~= 3 && iQuantity ~= 6
                data_y_unsorted = data_y_unsorted * multiplyFluxesBy;
            end
            plot(data_x_unsorted(permutation), data_y_unsorted(permutation), [linespecs{linespecIndex},'-'],'Color',colors(colorIndex,:),'DisplayName',descriptions{iOuter})
            %plot(dPhiHatdpsiNs{iOuter}', outputs{iOuter}(:,iQuantity), linespecs{linespecIndex},'Color',colors(colorIndex,:),'DisplayName',descriptions{iOuter})
        end
        hold on
    end
    %xlabel('dPhiHatdpsiN')
    xlabel('E_r (kV/m)')
    ylabel(yAxesLabels{iQuantity})
    if iQuantity == 1
        legend show
        legendHandle = legend();
        % To prevent underscores from causing subscripts:
        set(legendHandle,'Interpreter','none','Location','northwest')
    end
end

temp=dbstack;
nameOfThisProgram=sprintf('%s',temp(1).file);
stringForTop = ['E_r scan from fortran multi-species version of SFINCS, plotted using ',nameOfThisProgram];

annotation('textbox',[0 0.96 1 .04],'HorizontalAlignment','center',...
    'Interpreter','none','VerticalAlignment','bottom',...
    'FontSize',12,'LineStyle','none','String',stringForTop);

stringForBottom = ['Run in: ',pwd];

annotation('textbox',[0 0 1 .04],'HorizontalAlignment','center',...
           'Interpreter','none','VerticalAlignment','top',...
           'FontSize',12,'LineStyle','none','String', ...
           stringForBottom);


% *************************************************************
% Second figure
% *************************************************************

figure(5)
clf
set(gcf,'Color','w')
numRows = 2;
numCols = 2;

for iOuter = 1:4
    subplot(numRows,numCols,iOuter)
    for iQuantity = [1,4]
        if iQuantity==1
            speciesLinespec='-';
        else
            speciesLinespec=':';
        end
        linespecIndex = 1 + mod(iOuter-1, numel(linespecs));
        colorIndex = 1 + mod(iOuter-1, size(colors,1));
        data_x_unsorted = dPhiHatdpsiNs{iOuter}' * multiplyErBy;
        data_y_unsorted = outputs{iOuter}(:,iQuantity);
        [~,permutation] = sort(data_x_unsorted);
        data_y_unsorted = data_y_unsorted * multiplyFluxesBy;
        plot(data_x_unsorted(permutation), data_y_unsorted(permutation), [linespecs{linespecIndex},speciesLinespec],...
             'Color',colors(colorIndex,:))
        hold on
    end
    ylim([-8e-5,8e-5])
    legend('Ions','Electrons','Location','northwest')
    plot([min(data_x_unsorted), max(data_x_unsorted)], [0,0], ':k')
    xlabel('E_r (kV/m)')
    ylabel('Radial particle flux (code units)')
    title(descriptions{iOuter})
end

temp=dbstack;
nameOfThisProgram=sprintf('%s',temp(1).file);
stringForTop = ['E_r scan from fortran multi-species version of SFINCS, plotted using ',nameOfThisProgram];

annotation('textbox',[0 0.96 1 .04],'HorizontalAlignment','center',...
    'Interpreter','none','VerticalAlignment','bottom',...
    'FontSize',12,'LineStyle','none','String',stringForTop);

stringForBottom = ['Run in: ',pwd];

annotation('textbox',[0 0 1 .04],'HorizontalAlignment','center',...
           'Interpreter','none','VerticalAlignment','top',...
           'FontSize',12,'LineStyle','none','String', ...
           stringForBottom);

% --------------------------------------------------------

    function l = getLocationString(runNum)
        l = sprintf('/run%3d/',runNum);
    end

    addpath('~/MATLAB')
    %    export_fig('test.pdf')

end

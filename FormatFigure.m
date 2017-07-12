%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reformat the currently open figure for consistent display
% Modified May 19, 2016 by JWB to reduce font sizes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% target font sizes
labelSize = 11;
axisSize = 10;


% use fixed figure size
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [4.5 3.25]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0 0 4.5 3.25]);

% resize axis numbers
set(gca, 'FontSize', axisSize);

% resize axis labels 
axLabels = get(gca,{'XLabel', 'YLabel', 'ZLabel'});
set([axLabels{:}], 'FontSize', labelSize);

% resize legend text
legH = findobj(findobj(gcf), 'tag', 'legend');
set(legH, 'FontSize', labelSize);

% resize title text, if there is a title
titleH = get(gca, 'title');
if ~isempty(titleH)
    if iscell(titleH)
        for i = 1:length(titleH)
            set(titleH{i}, 'FontSize', labelSize);
        end
    else
        set(titleH, 'FontSize', labelSize);
    end
end




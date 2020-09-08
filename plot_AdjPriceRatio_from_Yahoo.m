function plot_AdjPriceRatio_from_Yahoo(ticker,startDate,endDate,f,stock)

%% Plot style
set(0,'DefaultTextInterpreter','tex')
axes_size = 20;
lw = 1;
N = length(stock); 
c = jet(N);
legendstrings = cell(1,N); 
j = 0;

if ismember(f,{'daily','day','d'})
    fstr = 'Daily';
elseif ismember(f,{'weekly','week','w','wk'})
    fstr = 'Weekly';
elseif ismember(f,{'monthly','month','mo','m'})
    fstr = 'Monthly';  
end

if ~ischar(startDate)
    startDate = datestr(floor(startDate));
end
if ~ischar(endDate)
    endDate = datestr(floor(endDate));
end

%% Plot
figure1 = figure('InvertHardcopy','off','Color',[1 1 1],'Units','normalized','Position',[0 0.28 1 0.58]);
axes1 = axes('Parent',figure1,'FontSize',axes_size,'FontName','times new roman','YScale','log');
for i=1:N
    hold(axes1,'on');
    val_ind = find(~isnan(stock(i).AdjClose),1,'first');
    if ~isempty(stock(i).AdjClose) 
        price0 = stock(i).AdjClose(val_ind); 
    end
    if ~isempty(stock(i).AdjClose) % Discard null data
        j = j+1;
        semilogy(stock(i).Date,stock(i).AdjClose/price0,'Color',c(i,:),'LineWidth',lw,'Parent',axes1);
        legendstrings{j} = sprintf(ticker{i}); 
    end
end
legend(legendstrings(1:j));
xlabel('','FontWeight','normal','FontSize',axes_size); 
ylabel('Price ratio','FontWeight','normal','FontSize',axes_size);
title([fstr, ' data from ', startDate, ' to ', endDate],'FontWeight','normal','FontSize',axes_size); 
set(legend,'Location','eastoutside','FontSize',axes_size*0.7,'Box','on');
grid on

end
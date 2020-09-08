clear legendstrings
j = 0; N = length(stock);
figure1 = figure('InvertHardcopy','off','Color',[1 1 1],'Units','normalized','Position',[0 0.28 1 0.58]);
axes1 = axes('Parent',figure1,'FontSize',20,'FontName','times new roman','YScale','log');
for i=1:N
    val_ind = find(~isnan(stock(i).AdjClose),1,'first');
    if ~isempty(stock(i).AdjClose) 
        price0 = stock(i).AdjClose(val_ind); 
    end
    [max_APR,ind_max] = max(stock(i).AdjClose/price0);
    if max_APR > 10 && ind_max < round(length(stock(i).AdjClose)/2)
        ind = tickerFinder(stock,stock(i).Ticker);
        stock(i).Ticker
        hold on
        semilogy(stock(i).Date,stock(i).AdjClose/price0,'Parent',axes1)
        j = j+1;
        legendstrings{j} = sprintf(stock(i).Ticker); 
    end
end
legend(legendstrings);
set(legend,'Location','eastoutside','FontSize',12,'Box','on');
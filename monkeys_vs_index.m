clc
clear 

%% Load stock data
main;

%% Inputs
monkeys = 1000; % How many monkeys will participate in the study
p = 40;         % How many stocks each monkey will buy and hold

%% Index data
index_ticker = {'^BVSP'};  
index = load_data_from_Yahoo(index_ticker,startDate,endDate,'m',downloads_folder);
index.Name = 'Ibovespa';

%% Clear stocks with no data and set NaN values to previous available
N = length(stock);
clear_inds = [];
for i=1:N
    if isempty(stock(i).AdjClose)  
        clear_inds = [clear_inds i];
    end
    if sum(isnan(stock(i).AdjClose))
        stock(i).AdjClose = fillmissing(stock(i).AdjClose, 'previous', 'EndValues', 'nearest');
    end
end
stock(clear_inds) = [];

%% Get monkeys' portfolios
N = length(stock);
good_monkeys = 0; 
portfolio(monkeys) = struct();
if p > N
    warning('foo:bar',['Selected number of stocks on monkey portfolio must\n'...
            ' be smaller or equal to total number of available stocks. \n'...
            'Setting p to maximum possible']);
    p = N;
end
for i=1:monkeys   
    AP_cell = {stock.AdjClose}';                  % Reshape adjusted close prices into cell array
    rand_stocks = randperm(N,p)';                 % Set randomly picked stocks to portfolio
    AP_cell = AP_cell(rand_stocks);               % Reduce to contain only randomly picked stocks
    [max_l,j] = max(cellfun(@length,AP_cell));    % Find which stock has the longest history and what is its length 
    APratio_cell = cellfun(@(x) ...
    [ones(max_l-length(x),1); x/x(1)], AP_cell,'UniformOutput',0);  % Sets trailing ones at the beginning of histories smaller than the longest
    APratio_mat = reshape(cell2mat(APratio_cell),[max_l, p]);       % Convert to matrix
    Dates_cell = {stock(rand_stocks).Date};                         % Cell array with the dates of portfolio's stocks
    % -- Set monkey random portfolio --
    portfolio(i).Ticker = {stock(rand_stocks).Ticker}';  % Set tickers 
    portfolio(i).Date = Dates_cell{j};                   % Set date vector 
    portfolio(i).Return = mean(APratio_mat,2);           % Set mean return (based on adjusted price) 
    % -- Check if monkey performed better than the index --
    if portfolio(i).Return(end) > index.AdjClose(end)/index.AdjClose(1)
        good_monkeys = good_monkeys+1;
    end
end
% -- Find 1% best portfolios
final_ret = cellfun(@(x) x(end), {portfolio.Return},'UniformOutput',1);
[val, ind] = sort(final_ret,'descend');
best_returns = val(1:ceil(monkeys/100));
best_ind = ind(1:ceil(monkeys/100));
best_tickers = reshape([portfolio(best_ind).Ticker],[p*length(best_ind),1]);

[best_tickers,~,ic] = unique(best_tickers);
a_counts = accumarray(ic,1);
[best_ticker_count, best_ticker_ind] = sort(a_counts,'descend');
for i=1:ceil(monkeys/100)
    stock_ind = tickerFinder(stock,best_tickers{best_ticker_ind(i)});
    disp([best_tickers{best_ticker_ind(i)} ' appeared in ' num2str(best_ticker_count(i)) ' out of the ' num2str(ceil(monkeys/100)) ' best portfolios (stock return was ' num2str(stock(stock_ind).AdjClose(end)/stock(stock_ind).AdjClose(find(~isnan(stock(stock_ind).AdjClose),1,'first')),'%.1f') 'x)'])
end

%% Plot monkeys vs index
set(0,'DefaultTextInterpreter','tex')
axes_size = 20;
lw = 1;
c = jet(monkeys);
figure1 = figure('InvertHardcopy','off','Color',[1 1 1],'Units','normalized','Position',[0 0.28 1 0.58]);
axes1 = axes('Parent',figure1,'FontSize',axes_size,'FontName','times new roman','YScale','log');
for i=1:monkeys
    hold(axes1,'on');
    semilogy(portfolio(i).Date,portfolio(i).Return,'Color',c(i,:),'LineWidth',lw,'Parent',axes1);
end
p1 = semilogy(index.Date,index.AdjClose/index.AdjClose(1),'k','LineWidth',2*lw,'Parent',axes1);
xlabel('','FontWeight','normal','FontSize',axes_size); 
ylabel('Return','FontWeight','normal','FontSize',axes_size);
title([num2str(100*good_monkeys/monkeys,'%.1f') '% (' num2str(good_monkeys) '/' num2str(monkeys) ') of monkeys beat the ' index.Name ' (each with ', num2str(p) ' random stocks)'],'FontWeight','bold','FontSize',axes_size);
lgd = legend(p1,index.Name);
set(lgd,'Location','northwest','FontSize',axes_size,'Box','on');
grid on

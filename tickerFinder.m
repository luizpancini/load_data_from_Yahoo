function ind = tickerFinder(stock,tickerName)

N = length(stock);
ind = find(arrayfun(@(x) strcmp(stock(x).Ticker, tickerName),1:N));

end
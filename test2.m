for i=1:N
    ratio = stock(i).AdjClose(2:end)./stock(i).AdjClose(1:end-1);
    stock(i).AdjClose(abs(ratio) > 10) = NaN;
    stock(i).AdjClose(abs(ratio) < 1/10) = NaN;
    stock(i).AdjClose(stock(i).AdjClose > 100*median(stock(i).AdjClose,'omitnan')) = NaN;
    stock(i).AdjClose(stock(i).AdjClose > 10^5) = NaN;
end

for i=1:N
    if sum(isnan(stock(i).AdjClose))
        stock(i).AdjClose = fillmissing(stock(i).AdjClose, 'previous', 'EndValues', 'nearest');
    end
end
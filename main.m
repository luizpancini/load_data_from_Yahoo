clc
clear 
close all

%% Inputs
% Folder for downloading the data (you may change this to be your browser's
% automatic download folder)
downloads_folder = ['C:\Users\', getenv('username'), '\Desktop'];
% Start and end dates
startDate = '01-Jan-2000';
endDate = now;
% Tickers list
ticker = {'AAPL','AMZN','MSFT','GOOGL','FB'};
ticker = unique(ticker); % Takes out repeated tickers and sets in alphabetical order            
% Sampling frequency: 'd' for dayly, 'w' for weekly, 'm' for monthly
f = 'w'; 

%% Get the data
stock = load_data_from_Yahoo(ticker,startDate,endDate,f,downloads_folder);

%% Plot adjusted price ratio
plot_AdjPriceRatio_from_Yahoo(ticker,startDate,endDate,f,stock)

%% Save the data
if ~ischar(startDate)
    startDateStr = datestr(floor(startDate));
else
    startDateStr = startDate;
end
if ~ischar(endDate)
    endDateStr = datestr(floor(endDate));
else
    endDateStr = endDate;
end
filename = ['stock_data_' startDateStr '_' endDateStr '_' f '.mat'];
save(filename,'stock','startDate','endDate','f');
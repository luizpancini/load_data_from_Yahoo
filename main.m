clc
clear 
close all

%% Inputs
% Folder for downloading the data (you may change this to be your browser's
% automatic download folder)
downloads_folder = ['C:\Users\', getenv('username'), '\Desktop'];
% Start and end dates
startDate = '01-Sep-2000';
endDate = now;
% BVSP (Brazil's stock exchange) tickers must be in the format 'ABCD1.SA'
ticker = {'AAPL','AMZN','FB','GOOGL','MSFT'};
% Sampling frequency: 'd' for dayly, 'w' for weekly, 'm' for monthly
f = 'm'; 

%% Get the data
stock = load_data_from_Yahoo(ticker,startDate,endDate,f,downloads_folder);

%% Plot adjusted price ratio
plot_AdjPriceRatio_from_Yahoo(ticker,startDate,endDate,f,stock)
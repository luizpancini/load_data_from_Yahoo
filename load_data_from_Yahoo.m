function stock = load_data_from_Yahoo(ticker,startDate,endDate,f,downloads_folder,t_limit)
% DESCRIPTION:
% 
% Gets stock's data from https://finance.yahoo.com/
% =========================================================================
% INPUTS:
% 
% ticker            --> Cell array of Yahoo stock tickers. 
% startDate         --> Starting date to retrieve the data. Accepts the 
%                       datetime format (dd-MM-yyyy).
% endDate           --> Ending date to retrieve the data. Accepts the 
%                       datetime format (dd-MM-yyyy) or "today".
% f                 --> Sampling frequency. Can be 
%                       dayly ('d','day','dayly') or
%                       weekly ('w','wk','week','weekly') or 
%                       monthly ('m', 'mo', 'month', 'montly').
% downloads_folder  --> (optional input) Folder to download the data. Set 
%                       it equal to your browser's automatic download 
%                       folder so that you don't have to manually accept 
%                       the downloads.
% t_limit           --> (optional input) Download time limit (in seconds)
%                       for a single ticker. You may need to set higher 
%                       values than the default for slow connections.
% =========================================================================
%  OUTPUTS:
% 
% stock             --> Structure with the stocks data.
% =========================================================================
% EXAMPLES: 
% 1. Get Apple's (AAPL) and Amazon's (AMZN) weekly stock data since January 
% 1st 2000:
% 
% stock = load_data_from_Yahoo({'AAPL','AMZN'},'01-Jan-2000',today,'w')
% 
% 2. Get Microsoft's (MSFT) dayly stock data in the last 15 days:
% 
% stock = load_data_from_Yahoo({'MSFT'},today-15,today,'d')
% =========================================================================
% Created by:
% Luiz G. P. dos Santos, September 2020.
% Based on:
% Josiah Renfree's hist_stock_data (https://www.mathworks.com/matlabcentral/fileexchange/18458-hist_stock_data-start_date-end_date-varargin)
% Captain Awesome's get_yahoo_stockdata6 (https://www.mathworks.com/matlabcentral/fileexchange/37502-historical-stock-data-download-alternate-method)

%% Recursion for multiple tickers
if length(ticker) > 1 
    stock = arrayfun(@(x) load_data_from_Yahoo(x,startDate,endDate,f),ticker,'uniformoutput',true);
    return
end

%% Handle inputs
if nargin < 6
    t_limit = 15; % Default
end
if nargin < 5
    downloads_folder = ['C:\Users\', getenv('username'), '\Desktop']; % Default 
end
if nargin < 4
    error('Not enough input arguments');
end
% Check dates
start_datenum = (floor(datenum(startDate)) - datenum('Jan-01-1970')) * 86400;
end_datenum = (floor(datenum(endDate)) - datenum('Jan-01-1970')) * 86400; 
if start_datenum > end_datenum
  error(['Bad date order: ', startDate, ' to ', endDate]);
end
% Check frequency
if ~ischar(f)
    error('f must be a string')
elseif ismember(f,{'daily','day','d'})
    f = 'd';
elseif ismember(f,{'weekly','week','w','wk'})
    f = 'wk';
elseif ismember(f,{'monthly','month','mo','m'})
    f = 'mo';  
else
    error(['Data frequency not available: ', f]);
end
% Check ticker
try
    char(ticker);
catch
    error('Bad ticker: not a string');
end

%% Get the data
download_link = ['https://query1.finance.yahoo.com/v7/finance/download/',char(ticker),...
                 '?period1=',num2str(start_datenum),'&period2=',num2str(end_datenum),...
                 '&interval=1',f,'&events=history'];            
fclose('all');       % close any opened files
filename = [downloads_folder,'\',char(ticker),'.csv'];
if isfile(filename)  % delete possible pre-existing csv file (avoid superposition)
    delete(filename) 
end
try 
    status = getResponseCode(openConnection(java.net.URL(download_link)));
    if status ~= 200 % If not OK 
        warning('foo:bar',['Stock data download failed, possibly bad ticker name: ', char(ticker), '\nHTTP response status code: ', num2str(status)]);
        stock.Date = []; stock.Open = []; stock.High = []; stock.Low = []; stock.Close = []; stock.AdjClose = []; stock.Volume  = []; stock.Ticker = char(ticker); 
        return
    end
catch
    try 
        warning('Java connection failed (try closing and opening Matlab again and check your Internet connection)');
        import matlab.net.*
        import matlab.net.http.*
        r = RequestMessage;
        uri = URI(download_link);
        resp = send(r,uri);
        status = resp.StatusCode;
        if status ~= 200 && status ~= 401 % If neither OK nor Unauthorized
            warning(['Stock data download failed, HTTP response status code: ', num2str(status)]);
            stock.Date = []; stock.Open = []; stock.High = []; stock.Low = []; stock.Close = []; stock.AdjClose = []; stock.Volume  = []; stock.Ticker = char(ticker);
            return
        end
    catch
        error('Could not get HTTP status - check your Internet connection')
    end
end
% Download
web(download_link,'-browser')

%% Read the data 
fileID = -1;
tic;
while fileID < 0 % wait for the file to be successfully downloaded 
    fileID = fopen(filename,'r');
    pause(1); t = toc;
    if t > t_limit
        warning(['Download is taking too long for ', char(ticker), ' - skipping']);
        stock.Date = []; stock.Open = []; stock.High = []; stock.Low = []; stock.Close = []; stock.AdjClose = []; stock.Volume  = []; stock.Ticker = char(ticker);
        return
    end
end
file = fileread(filename);
file = strrep(file, 'null', '');
dataArray = textscan(file,'%s%f%f%f%f%f%d%[^\n\r]','Delimiter',',',...
                     'EmptyValue',NaN,'HeaderLines',1,'ReturnOnError',false);
fclose(fileID);
delete([downloads_folder, '\*.csv']) % delete the files (avoid spamming)

%% Save the data
Date                = dataArray{:, 1};
stock.Date          = datetime(Date,'InputFormat','yyyy-MM-dd');
stock.Open          = dataArray{:, 2};
stock.High          = dataArray{:, 3};
stock.Low           = dataArray{:, 4};
stock.Close         = dataArray{:, 5};
stock.AdjClose      = dataArray{:, 6};
stock.Volume        = dataArray{:, 7}; 
stock.Ticker        = char(ticker);

% Discard Yahoo errors on adjusted close prices (variations greater than 
% 10 times in a single time unit or 1000 times higher than the median)
ratio = stock.AdjClose(2:end)./stock.AdjClose(1:end-1);
stock.AdjClose(abs(ratio) > 10) = NaN;
stock.AdjClose(abs(ratio) < 1/10) = NaN;
stock.AdjClose(stock.AdjClose > 1e3*median(stock.AdjClose,'omitnan')) = NaN;

%% Display progress
disp(['Got data from ', stock.Ticker]);

end
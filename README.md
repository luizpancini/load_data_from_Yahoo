# load_data_from_Yahoo
Contains Matlab function to gather stock's data from Yahoo Finance (load_data_from_Yahoo), along with a function to plot some results (plot_AdjPriceRatio_from_Yahoo), and a script to run these functions (main).

These files were created heavily based on the works of Josiah Renfree's hist_stock_data, and Captain Awesome's get_yahoo_stockdata6 functions.
The goal is to cover some failures of both of these, which may happen depending on the stock chosen. 
As such, load_data_from_Yahoo first tries to simply read the HTML data from the website. If that fails, it then downloads the data into a .csv file and reads it.

Josiah Renfree's hist_stock_data function is available at https://www.mathworks.com/matlabcentral/fileexchange/18458-hist_stock_data-start_date-end_date-varargin
and Captain Awesome's get_yahoo_stockdata6 function is available at https://www.mathworks.com/matlabcentral/fileexchange/37502-historical-stock-data-download-alternate-method

# TradeTool
A simple alternative to Metatrader's One Click Trading. Allows the trader to automatically place stops, and take-profits.

The goal of this project was to be able to provide a simple solution to placing stop-loss and take-profit levels for market 
orders. 

Metatrader 4's One Click Trading allows a drag and drop feature in order to place Stops and TPs. However, 
a key problem occurs when layering and placing multiple consecutive market orders, where it takes time to 
properly place stops.

UI Features: 
1. Textfields - for manually placing SL and TP points distance from current market price.
2. Toggles - enforces SL and TP levels
3. Adjustment Buttons - Allows adjustment without having the need to manually enter stop levels.
4. Market Buy and Market Sell Buttons - Allows immediate order execution and automatic placement of stops
   given that the features are enabled.


Key Priorties: 
1. Efficiency and execution speed

Limitations: 
1. Position Sizing is not calculated based on Risk/Trade
2. No interactive chart objects
3. Does not set limitations in the event that the trader decides to over-leverage on a trade.
   
![SS3](https://github.com/alfarasjb/MQL4-Projects/assets/72119101/1d024c18-5eef-4138-ab27-20d4bd0edcc7)


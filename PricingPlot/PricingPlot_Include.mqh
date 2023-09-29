
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property strict



#include <B63/CObjects.mqh>
#include <B63/Generic.mqh>


// INPUTS //
input ENUM_TIMEFRAMES         InpPeriods = PERIOD_D1; // Reference Period
input color                   InpLineCol = clrRed; // Line Color
input ENUM_LINE_STYLE         InpLineStyle = STYLE_SOLID; // Line Style
input color                   InpFontCol = clrWhite; // Font Color

// SCREEN ADJUSTMENTS - For scaling on different monitors // 
int screen_dpi = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
int scale_factor = (screen_dpi * 100) / 96;

// OBJECT CONSTANTS // 
const int defX                = (5);
const int defY                = (190);
const string font             = "Segoe UI Semibold";
const string fontBold         = "Segoe UI Bold";

// STRUCT //

// Storing Symbol Info - Called on init //
struct SInfo{
   string symbol;
   int digits;
   
   void initInfo(){
      symbol = Sym();
      digits = digits();
   }
   
   SInfo(){ initInfo(); }
};

// Storing Arrays and Data //
struct SData{
   double data[];
   double ohlc[4];
   double ratios [6];
   
   void fillArray(double &src[], double &dst[]){
      ArrayResize(dst, ArraySize(src));
      ArrayCopy(dst, src);
   }
   
   void initOHLC(){
      double open = iOpen(Sym(), InpPeriods, 1);
      double high = iHigh(Sym(), InpPeriods, 1);
      double low = iLow(Sym(), InpPeriods, 1);
      double close = iClose(Sym(), InpPeriods, 1);
      ohlc[0] = open;
      ohlc[1] = high;
      ohlc[2] = low;
      ohlc[3] = close;
   }
   
   SData(){
      double ratio []= {1, 0.618, 0.5, 0.382, 0.236, 0}; // Standard Fibonacci Retracement levels
      initOHLC();
      fillArray(ratio, ratios);
   }
};

// DECLARATION // 
SData sdata;
SInfo info;
CObjects obj(defX, defY, 10, scale_factor);


// Function Call on initializing EA //
int OnInit()
  {
  ObjectsDeleteAll(0, 0, -1);

   info.initInfo();
   initPrice();
   draw();

   return(INIT_SUCCEEDED);
  }
  
// Function Call on closing EA //
void OnDeinit(const int reason)
  {
  ObjectsDeleteAll(0, 0, -1);

  }
  
// Function call on every candle tick // 
void OnTick()
  {
  // Updates drawing on new candle
   if (IsNewCandle()) { draw(); } 
  }


// MAIN FUNCTIONS // 

void initPrice(){
   sdata.initOHLC();
   
   
   // assigning array contents to variables for readability
   double open = sdata.ohlc[0];
   double high = sdata.ohlc[1];
   double low = sdata.ohlc[2];
   double close = sdata.ohlc[3];
   
   // LONG: SWL - (diff * ratio)
   // SHORT: SWH - (diff * ratio)
   
   double bias = close > open ? 1 : -1;
   double referencePrice = close > open ? low : high;
   double data [] = {}; // array to send to struct variable 
   
   // Resizing main data array to fit ratios for scaling future features. 
   ArrayResize(data, ArraySize(sdata.ratios));
   
   
   // populating data array
   for(int i = 0; i < ArraySize(data); i++){
      double ratio = (high - low) * sdata.ratios[i];
      double level = referencePrice + (ratio * bias);
      data[i] = level;
   }
   sdata.fillArray(data, sdata.data); // sdata.data will be called later for drawing objects
}

void draw(){
   datetime t_start = startTime();
   datetime t_end = endTime();
   int fontSize = 8;
   
   // creating objects
   for (int i = 0; i < ArraySize(sdata.data) ; i++ ){
      // creates a pair: text and trendline for each price level
      // casting to avoid type warnings
      double ratio = NormalizeDouble((sdata.ratios[i] * 100), 2);
      double price = sdata.data[i];
      obj.CText(string(ratio)+"label", (string)ratio + " - " + normDouble(price), t_end, price, fontSize, InpFontCol);
      obj.CTrend(string(ratio) + "tline", price, t_start, t_end, InpLineStyle, InpLineCol);
   }
}


// WRAPPER FUNCTIONS //
int digits() { return (int)SymbolInfoInteger(Sym(), SYMBOL_DIGITS); }
string Sym(){  return Symbol(); }
datetime startTime(){ return iTime(info.symbol, InpPeriods, 0); }
datetime endTime() { return TimeCurrent(); }
string normDouble(double price){ return (string)NormalizeDouble(price, info.digits); }
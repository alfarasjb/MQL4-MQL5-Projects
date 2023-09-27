//+------------------------------------------------------------------+
//|                                          PricingPlot_Include.mqh |
//|                             Copyright 2023, Jay Benedict Alfaras |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property link      "https://www.mql5.com"
#property strict


#include <B63/CObjects.mqh>
#include <B63/Generic.mqh>

input ENUM_TIMEFRAMES         InpPeriods = PERIOD_D1; // Reference Period
input color                   InpLineCol = clrRed; // Line Color
input color                   InpFontCol = clrWhite; // Font Color
// SCREEN ADJUSTMENTS // 
int screen_dpi = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
int scale_factor = (screen_dpi * 100) / 96;

const int defX                = (5);
const int defY                = (190);
const string font             = "Segoe UI Semibold";
const string fontBold         = "Segoe UI Bold";

CObjects obj(defX, defY, 10, scale_factor);

struct SInfo{
   string symbol;
   int digits;
   
   SInfo(){
      symbol = Sym();
      digits = digits();
   }
};


struct SPricing{
   double premium;
   double discount;
   double equilibrium;
   
   void initPrice(double high, double low, double mid){
      premium = high;
      discount = low;
      equilibrium = mid;
   }
   
   SPricing(){
      initPrice(0, 0, 0);
   }
   
};

SPricing pricing;
SInfo info;

int OnInit()
  {
   initPrice();
   draw();

   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  ObjectsDeleteAll(0, 0, -1);

  }
void OnTick()
  {
   if (IsNewCandle()){ draw(); }
  }
//+------------------------------------------------------------------+


void initPrice(){
   double high = iHigh(Sym(), InpPeriods, 1);
   double low = iLow(Sym(), InpPeriods, 1);
   double mid = (high + low) / 2;
   pricing.initPrice(high, low, mid);
}


void draw(){
   datetime t_start = startTime();
   datetime t_end = endTime();
   string objects [] = {"HighLine", "LowLine", "MidLine","HighText", "LowText", "MidText"};
   int fontSize = 8;
   obj.CTrend(objects[0], pricing.premium, t_start, t_end, STYLE_DASH, InpLineCol);
   obj.CTrend(objects[1], pricing.discount, t_start, t_end, STYLE_DASH, InpLineCol);
   obj.CTrend(objects[2], pricing.equilibrium, t_start, t_end, STYLE_SOLID, InpLineCol);
   obj.CText(objects[3],"P - "+ normDouble(pricing.premium), t_end, pricing.premium, fontSize, InpFontCol);
   obj.CText(objects[4],"D - " + normDouble(pricing.discount), t_end, pricing.discount, fontSize, InpFontCol);
   obj.CText(objects[5],"N - " + normDouble(pricing.equilibrium), t_end, pricing.equilibrium, fontSize, InpFontCol);
   
}


int digits() { return (int)SymbolInfoInteger(Sym(), SYMBOL_DIGITS); }
string Sym(){  return Symbol(); }
datetime startTime(){ return iTime(info.symbol, InpPeriods, 0); }
datetime endTime() { return TimeCurrent(); }

string normDouble(double price){ return (string)NormalizeDouble(price, info.digits); }
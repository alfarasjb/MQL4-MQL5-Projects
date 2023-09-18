
#define app_copyright "Copyright 2023, block63"
#define app_version  "1.01"
#define app_description "A basic order management solution that allows Stop Loss and Take Profit levels to be automatically placed on market orders based on set POINTS distance."
#property strict

#include <B63/CObjects.mqh>
#include <B63/TradeOperations.mqh>
#include <B63/Generic.mqh>

// SCREEN ADJUSTMENTS // 
int screen_dpi = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
int scale_factor = (screen_dpi * 100) / 96;


// ENUM AND STRUCT //

enum EMode{
   Points = 1,
   Price = 2,
};

struct SBTName{
   string plus;
   string minus;
   string toggle;
   
   SBTName(){
      plus = "";
      minus = "";
      toggle = "";
   }
};

struct STrade{
   double entry;
   double stop;
   double target;
   float volume;
   bool slOn;
   bool tpOn;
   bool volOn;
   int stopPts;
   int tpPts;
   
   void update(double InpEntry, double InpStop, double InpTarget, float InpVolume, double InpSLOn, double InpTPOn, double InpVolOn, int InpSLPts, int InpTPPts){
      entry = InpEntry;
      stop = InpStop;
      target = InpTarget;
      volume = InpVolume == 0 ? (float)InpDefLots : (float)normLot(InpVolume);
      slOn = InpSLOn;
      tpOn = InpTPOn;
      volOn = InpVolOn;
      stopPts = InpSLPts;
      tpPts = InpTPPts;
      
   }
   
   void update(){
      update(0, 0, 0, volume, slOn, tpOn, volOn, stopPts, tpPts);
   }
   
   STrade(){
      update();
   }
   
   void reInit(double lot){
      entry = 0;
      stop = 0;
      target = 0;
      volume = (float)lot;
   }
};

struct SMarket{
   double minLot;
   double maxLot;
   double lotStep;
   int digits;
   
   SMarket(){
      minLot   = SymbolInfoDouble(Sym, SYMBOL_VOLUME_MIN);
      maxLot   = SymbolInfoDouble(Sym, SYMBOL_VOLUME_MAX);
      lotStep  = SymbolInfoDouble(Sym, SYMBOL_VOLUME_STEP);
      digits   = (int)SymbolInfoInteger(Sym, SYMBOL_DIGITS);
   }
   
   void reInit(){ 
      minLot   = SymbolInfoDouble(Sym, SYMBOL_VOLUME_MIN);
      maxLot   = SymbolInfoDouble(Sym, SYMBOL_VOLUME_MAX);
      lotStep  = SymbolInfoDouble(Sym, SYMBOL_VOLUME_STEP);
      digits   = (int)SymbolInfoInteger(Sym, SYMBOL_DIGITS);
   }
   
   
};

const int defX                = (5);
const int defY                = (190);
const string font             = "Segoe UI Semibold";
const string fontBold         = "Segoe UI Bold";


input int      InpMagic       = 232323; //Magic Number
EMode    InpMode        = Points; //Mode (Price/Points)
input double   InpDefLots     = 0.01; //Volume
input int      InpDefStop     = 200; //Default SL (Points)
input int      InpDefTP       = 200; //Default TP (Points)
input int      InpPointsStep  = 100; //Step (Points)

CObjects obj(defX, defY, 10, scale_factor);
CTradeOperations op();

STrade trade;
STrade errTrade;
SMarket market;

enum EMarketStatus{
   MarketIsOpen = 1,
   MarketIsClosed = 2,
   TradingDisabled = 3,
};

static double slInput = InpDefStop;
static double tpInput = InpDefTP;
static string Sym;
static bool   MarketOpen;
static bool   TradeDisabled;
static bool   TradingDay;
static bool   TradingSession;
EMarketStatus MarketStatus;





int OnInit() {
   initData();
   drawUI();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, 0, -1);
}

void OnTick() {
   updatePrice();
}

EMarketStatus status(){
   if (TradeDisabled) return TradingDisabled;
   if (TradingDay && TradingSession) return MarketIsOpen;
   return MarketIsClosed;
}
  
void initData(){
   Sym = Symbol();
   
   TradingDay = IsTradingDay(TimeCurrent());
   TradeDisabled= IsTradeDisabled(Sym);
   TradingSession = IsInSession(TimeCurrent());
   MarketStatus = status();
   
   market.reInit();
   //trade.reInit(market.minLot);
   trade.update();
   switch(InpMode){
      case 1:
         //slInput = InpDefPoints;
         //tpInput = InpDefPoints;
         break;
      case 2:
         slInput = bid();
         tpInput = bid();
         break;
      default:
         break;
   }
}

void OnChartEvent(const int id, const long &lparam, const double &daram, const string &sparam){
   if (CHARTEVENT_OBJECT_CLICK){  
      if (sparam == "BTBuy") {
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_BUY);
         if (ret < 0) error(ret);
      }
      if (sparam == "BTSell") {
         resetObject(sparam);
         int ret = sendOrd(ORDER_TYPE_SELL);
         if (ret < 0) error(ret);
      }
      if (sparam == "BTEDITSL+")        { slInput = adj(slInput, InpPointsStep, slRow, sparam); }
      if (sparam == "BTEDITSL-")        { slInput = adj(slInput, -InpPointsStep, minPoints(), slRow,  sparam); }
      
      if (sparam == "BTEDITTP+")        { tpInput = adj(tpInput, InpPointsStep, tpRow,sparam); }  
      if (sparam == "BTEDITTP-")        { tpInput = adj(tpInput, -InpPointsStep, minPoints(), tpRow, sparam); }
      
      if (sparam == "BTEDITVOL+" )      { trade.volume = (float)adj(normLot(trade.volume), market.lotStep, market.maxLot, volRow, sparam); }
      if (sparam == "BTEDITVOL-")       { trade.volume = (float)adj(normLot(trade.volume), -market.lotStep, market.minLot, volRow, sparam); }
      
      if (swButton(1, sparam))     { trade.slOn = toggle(trade.slOn, slRow); }
      if (swButton(2, sparam))     { trade.tpOn = toggle(trade.tpOn, tpRow); }
   }
   if (CHARTEVENT_OBJECT_ENDEDIT){
      if (sparam == "EDITSL"){
         double val = StringToDouble(getText(sparam));
         slInput = !minPoints(val) ? val : 0;
         slRow();
      }
      if (sparam == "EDITTP"){
         double val = StringToDouble(getText(sparam));
         tpInput = !minPoints(val) ? val : 0;
         tpRow();
      }
      if (sparam == "EDITVOL"){
         double val = StringToDouble(getText(sparam));
         trade.volume = !minLot(val) ? !maxLot(val) ? (float)val : (float)market.maxLot : (float)market.minLot;
         volRow();
      }
   }
   ChartRedraw();
}

bool swButton(int sw, string sparam){
   bool ret = False;
   switch(sw){
      case 1: 
         if (sparam == "BTSLBOOL" || sparam == "BTSLBOOLNOT") ret = true;
         break;
      case 2:
         if (sparam == "BTTPBOOL" || sparam == "BTTPBOOLNOT") ret = true;
         break;
      default:
         ret = False;
         break;
   }
   return ret;
}

const string buttons[]        = {"BTBuy", "BTSell", "BTSLBOOL", "BTTPBOOL", "BTVOLBOOL"};
const color colors[]          = {clrWhite, clrGray, clrDodgerBlue, clrCrimson, clrDimGray, clrDarkGray};
const color FontColor         = colors[0];
const int row1                = 150;
const int row2                = 120;
const int row3                = 90;


const int buyButtonOffset     = 120;
const int sellButtonOffset    = 10;

const int ordButtonDims[]     = {105, 50}; // width, height
const int editDims[]          = {80, 18};
const int bgDims[]            = {130, 25};

const int ordButtonSpace      = 10;



void drawUI(){
// DIMS
const int buttonWidth         = ordButtonDims[0];
const int buttonHeight        = ordButtonDims[1];
const int rectLabelWidth      = 225;

const int headerLineLen       = 205;
const int headerLineHeight    = 0;

// OFFSET
const int buttonYOffset       = buttonHeight + 10; // Distance from bottom
const int ordButtonYOff       = buttonYOffset - 13; 

const int headerY             = 175;
const int headerX             = 15;
const int headerFontSize      = 13;
// COLORS
const color buttonBordColor   = colors[1];
const color buyColor          = colors[2];
const color sellColor         = colors[3];

// FONTS
const int buttonFontSize      = 8;
const int ordFontSize         = 10;

// MISC 
const int zord                = 5;
const ENUM_LINE_STYLE style   = STYLE_SOLID;
const ENUM_BORDER_TYPE border = BORDER_FLAT;
const ENUM_BORDER_TYPE main   = BORDER_RAISED;
const int lineWidth           = 1;

const string headerString     = Sym + " | " + marketStatus();
   
   obj.CRectLabel("Buttons", defX, defY, rectLabelWidth, defY - 5, main, buttonBordColor, style, 2);  
   obj.CButton(buttons[0],buyButtonOffset,buttonYOffset, buttonWidth ,buttonHeight ,buttonFontSize,"", FontColor, buyColor, buttonBordColor, zord);
   obj.CButton(buttons[1],sellButtonOffset,buttonYOffset,buttonWidth ,buttonHeight,buttonFontSize,"", FontColor, sellColor, buttonBordColor, zord);   
   
   obj.CTextLabel("BuyLabel", buyButtonOffset + ordButtonSpace, ordButtonYOff, "BUY", font, ordFontSize, FontColor);
   obj.CTextLabel("SellLabel", sellButtonOffset + ordButtonSpace, ordButtonYOff, "SELL", font, ordFontSize, FontColor);
   obj.CTextLabel("Symbol", headerX, headerY, headerString, font, headerFontSize, FontColor);
   obj.CRectLabel("Header", headerX, headerY - 15, headerLineLen, headerLineHeight, border, FontColor, style, 1);
   textFields();
   updatePrice();
}

string marketStatus(){
   string val = "";
   switch(MarketStatus){
      case 1: 
         val = "Open";
         break;
      case 2:
         val = "Closed";
         break;
      case 3:
         val = "Disabled";
         break;
      default:
         val = "";
         break;
   }
   return val;
}

void updatePrice(){
   const int yOffset       = 25;
   const int fontSize      = 13;
   

   obj.CTextLabel("BuyPrice", buyButtonOffset + ordButtonSpace, yOffset, norm(ask()), fontBold, fontSize, FontColor);
   obj.CTextLabel("SellPrice", sellButtonOffset + ordButtonSpace , yOffset, norm(bid()), fontBold, fontSize, FontColor);

}

/*
 DRAFT
void updatePrice(){
   const int yOffset       = 25;
   const int fontSize      = 8;
   
   double buyP = ask();
   double sellP = bid();
   double pt = point();
   double buySL = trade.slOn ? buyP - (slPts() * pt) : 0;
   double buyTP = trade.tpOn ? buyP + (tpPts() * pt) : 0;
   double sellSL = trade.slOn ? sellP + (slPts() * pt) : 0;
   double sellTP = trade.tpOn ? sellP - (tpPts() * pt) : 0;
   //obj.CTextLabel("BuyPrice", buyButtonOffset + ordButtonSpace, yOffset, norm(ask()), fontBold, fontSize, FontColor);
   //obj.CTextLabel("SellPrice", sellButtonOffset + ordButtonSpace , yOffset, norm(bid()), fontBold, fontSize, FontColor);
   obj.CTextLabel("BuySL", buyButtonOffset + ordButtonSpace, yOffset, buySL, fontBold, fontSize, FontColor);
   obj.CTextLabel("BuyTP", buyButtonOffset + (4*ordButtonSpace), yOffset, buyTP, fontBold, fontSize, FontColor);
   obj.CTextLabel("SellSL", sellButtonOffset + ordButtonSpace, yOffset, sellSL, fontBold, fontSize, FontColor);
   obj.CTextLabel("SellTP", sellButtonOffset + (4*ordButtonSpace), yOffset, sellTP, fontBold, fontSize, FontColor);
}


 
*/

double slPts() { return getValues("EDITSL"); }
double tpPts() { return getValues("EDITTP"); }


void textFields(){

   const int xOffset      = 15;
   const int labelSize    = 10;
   
   obj.CTextLabel("TFSL", xOffset, row1 - 13, "SL", font, labelSize, FontColor);
   obj.CTextLabel("TFTP", xOffset, row2 - 12, "TP", font, labelSize, FontColor);
   obj.CTextLabel("TFVol", xOffset, row3 - 11, "VOL", font, labelSize, FontColor);
   obj.CTextLabel("TFVolLots", xOffset + 175, row3 - 11, "Lots", font, labelSize, FontColor);
   
   slRow();
   tpRow();
   volRow();

}

void slRow(double inp, bool state)  { createRow("EDITSL", buttons[2], buttons[2]+ "NOT", row1, (string)inp, state, true);}
void slRow(bool state)              { slRow(slInput, state); }
void slRow(double inp)              { slRow(inp, trade.slOn);}
void slRow()                        { slRow(slInput, trade.slOn); } // Default State

void tpRow(double inp, bool state)  { createRow("EDITTP",buttons[3], buttons[3] + "NOT", row2, (string)inp, state, true);}
void tpRow(bool state)              { tpRow(tpInput, state); }
void tpRow(double inp)              { tpRow(inp, trade.tpOn); }
void tpRow()                        { tpRow(tpInput, trade.tpOn); } 

void volRow(double inp)             { createRow("EDITVOL", buttons[4], buttons[4] + "NOT", row3, norm(inp, 2), trade.volOn, false);}
void volRow()                       { volRow(trade.volume); }

void createRow(string edit, string enabled, string disabled, int row, string editText, bool state, bool showSwitch){

// DIMS
const int editWidth     = editDims[0];
const int editHeight    = editDims[1];
const int bgWidth       = bgDims[0];
const int bgHeight      = bgDims[1];
const int btSize        = 18;

// OFFSET
const int space         = 3;

const int bgX           = 50;

const int btDisabled    = bgX + bgWidth + 5;
const int btEnabled     = btDisabled + btSize - 2;

// COLORS

const color btBGCol     = colors[4];
const color btBordCol   = colors[5];   

const color editCol     = colors[1];
const color togOnCol    = state ? colors[0] : colors[4];
const color togOffCol   = state ? colors[2] : colors[0];  

// FONTS
const int fontSize      = 10;
// MISC 
   obj.CAdjRow(edit, bgX, row, bgWidth, bgHeight, editWidth, editHeight, btSize, editText, fontSize, btBGCol, btBordCol, FontColor, editCol);
   if (showSwitch){
      // name1, name2, x, y, width, height, col1, col2, state
      obj.CSwitch(enabled, disabled, btDisabled, row - space, btSize, btSize, togOnCol, togOffCol, state);
   }
   
}

// ERROR HANDLING //

void error(int e){
#ifdef __MQL4__
const int ErrTradeDisabled    = 133;
const int ErrMarketClosed     = 132;
const int ErrBadVol           = 131;
const int ErrBadStops         = 130;
#endif


#ifdef __MQL5__
const int ErrTradeDisabled    = 10017;
const int ErrMarketClosed     = 10018;
const int ErrBadVol           = 10014;
const int ErrBadStops         = 10016;
#endif

const int errorCode = GetLastError();
   switch(e){
      case 0:
         if (errorCode == ErrTradeDisabled) Print("Order Send Failed. Trading is disabled for current symbol");
         if (errorCode == ErrMarketClosed) Print("Order Send Failed. Market is closed.");
         if (errorCode == ErrBadVol) Print("Order Send Error: Invalid Volume. Vol: ", errTrade.volume);
         if (errorCode == ErrBadStops) Print("Order Send Error: Invalid Stops. SL: ", errTrade.stop, " TP: ", errTrade.target);
         break;
      case -10:
         Print("Invalid Order Parameters for Market Buy. Price: ", ask() ," SL: ", errTrade.stop, " TP: ", errTrade.target);
         break;
      case -20:
         Print("Invalid Order Parameters for Market Sell. Price: ", bid() , " SL: ", errTrade.stop, " TP: ", errTrade.target);
         break;
      default:
         Print("Order Send Failed. Code: ", e);
         break;
   }
}


// ERROR HANDLING // 

// BUTTON FUNCTIONS //

// TYPEDEF (SEE DOCS)
// SYNTAX 
//  typedef type new_name;
// typedef function_result_type (*Function_name_type)(list_of_input_parameters_types);
typedef void (*Togg)(bool state);
typedef void (*Adj)(double inp);


bool toggle(bool toggle, Togg rowFunc){
   // SOLUTION: Created overload which accepts state bool 
   toggle =! toggle;
   rowFunc(toggle);
   return toggle;   
}

double adj(double inp, double step, Adj rowFunc, string sparam){
   return adj (inp, step, -1, rowFunc, sparam);
}

double adj(double inp, double step, double limit, Adj rowFunc, string sparam){
   double val = inp + step;
   resetObject(sparam);
   if (step < 0 && limit >= 0 && inp <= limit) return inp;
   if (step > 0 && limit >= 0 && inp >= limit) return inp;
   rowFunc(val);
   return val;
}

int sendOrd(ENUM_ORDER_TYPE ord){
   double val = StringToDouble(getText("EDITVOL"));
   tradeParams(ord);
   double sl = trade.stop;
   double tp = trade.target;
   int ticket = op.SendOrder(ord, val, trade.entry, sl, tp, InpMagic);
   
   if (ticket < 0) {
      errTrade.stop = sl;
      errTrade.target = tp;
      errTrade.volume = trade.volume;
      if (ord == 0 && (sl > 0 && tp > 0)  && (sl > tp || sl > ask() || ask() > tp)) return -10;
      if (ord == 1 && (sl > 0 && tp > 0) && (tp > sl || tp > bid() || bid() > sl)) return -20;
      error(0);
   }
   
   return ticket;
}

// BUTTON FUNCTIONS //

// MISC FUNCTIONS //
string norm(double val)             { return DoubleToString(val, market.digits); }

string norm(double val, int digits) { return DoubleToString(val, digits); }

double minPoints(){ return 0; }

bool minPoints(double points){
   if (points > 0) return false;
   return true;
}

bool minLot(double lot){
   if (lot > market.minLot) return false;
   return true;
}

bool maxLot(double lot){
   if (lot < market.maxLot) return false;
   return true;
}

void tradeParams(ENUM_ORDER_TYPE ord){
   double sl = getValues("EDITSL");
   double tp = getValues("EDITTP");
   double vol = getValues("EDITVOL");
   if (InpMode == Points){
      if (ord == 0) {
         double stop = trade.slOn ? sl != 0 ? ask() - sl * point() : 0 : 0;
         double target = trade.tpOn ? tp != 0 ? ask() + tp * point() : 0 : 0;
         trade.update(ask(), stop, target, (float)vol, trade.slOn, trade.tpOn, true,(int)sl, (int)tp);
      }
      if (ord == 1) {
         double stop = trade.slOn ? sl!= 0 ? bid() + sl * point() : 0 : 0;
         double target = trade.tpOn ? tp!= 0 ? bid() - tp * point() : 0 : 0;
         trade.update(bid(), stop, target, (float)vol, trade.slOn, trade.tpOn, true, (int)sl, (int)tp);
      }
   }
   if (InpMode == Price){
      trade.stop = sl;
      trade.target = tp;
   } 
}


// WRAPPER //
string getText(string sparam)       { return ObjectGetString(0, sparam, OBJPROP_TEXT); }
double getValues(string sparam)     { return StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT)); }
bool getBool(string sparam)         { return (bool)ObjectGetInteger(0, sparam, OBJPROP_STATE); }
double point()                      { return SymbolInfoDouble(Sym, SYMBOL_POINT); }
double normLot(double lot)          { return NormalizeDouble(lot, 2); }

#ifdef __MQL4__
double ask()   { return SymbolInfoDouble(Sym, SYMBOL_ASK); }
double bid()   { return SymbolInfoDouble(Sym, SYMBOL_BID); }

#endif

#ifdef __MQL5__
double ask()   { return SymbolInfoDouble(Sym, SYMBOL_ASK); }
double bid()   { return SymbolInfoDouble(Sym, SYMBOL_BID); }

#endif




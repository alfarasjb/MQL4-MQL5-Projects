#property strict

#include <B63/Generic.mqh>



struct SIndi{
   double currMA; 
   double prevMA; 
   double wkPivot; 
   double wkOpen; 
   double wkClose;
   double currOpen;
   double thisWkPivot;
   
   int dir;
   int maDir;
   int open_dir;
   int pivot_dir;
   int ma_delta_dir;
   int open_piv_dir;
   
   int signal; 

   int initData(){

      currMA = MA(0); // 0
      prevMA = MA(1); // 1
      wkPivot = wkPivot(1); // wk pivot calculated from prev wk 
      thisWkPivot = wkPivot(0);
      wkOpen = Open_W(1);
      wkClose = Close_W(1);
      currOpen = Open_W(0);
      
      dir = wkClose > wkOpen ? 1 : - 1;
      maDir = wkClose > currMA ? 1 : - 1;
      open_dir = wkOpen >currMA ? 1 : -1;
      pivot_dir = wkOpen > wkPivot ? 1 : -1;
      ma_delta_dir = currMA > prevMA ? 1 : -1; 
      open_piv_dir = currOpen > thisWkPivot ? 1 : -1;
      

      int signals [6];
      signals [0] = dir;
      signals [1] = maDir;
      signals [2] = open_dir;
      signals [3] = pivot_dir;
      signals [4] = ma_delta_dir;
      signals [5] = open_piv_dir;
      signal = checkElements(signals) ? dir : 0;
      return signal;      
   }
   
   SIndi(){
      initData();
   }
};

struct STrade{
   double entry;
   double stop;
   double target;
   float volume;
   
   void update(double InpEntry, double InpStop, double InpTarget, float InpVolume){
      entry = InpEntry;
      stop = InpStop;
      target = InpTarget;
      volume = InpVolume;
   }
   
   void update(){ update(0, 0, 0, 1); }
   
   STrade(){ update(); }
   
   void reInit(double lot){
      entry = 0;
      stop = 0;
      target = 0;
      volume = (float)lot;
   }
};


static string Sym;
input int InpMaLength            = 10;
input ENUM_MA_METHOD InpMAMethod   = MODE_SMA;
input ENUM_TIMEFRAMES InpTimeFrame = PERIOD_W1;
input int InpHoldTime              = 10;
input bool InpUseStops             = False;
input bool InpStacking             = True;
SIndi IndData;
STrade trade;

MqlDateTime today;

int OnInit() {

   Sym = Symbol();
   func();

   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {

  }
void OnTick() { 
   func(); 
}




bool func(){
   // Main Function
   TimeToStruct(TimeCurrent(), today);
   int sig = IndData.initData();
   if (!IsNewCandle()) return false;
   if (today.day_of_week != 1) return false;
   if (!sig) return false;
   if (!orders(sig)) Print("Order Operation Failed.", GetLastError());    
   return true;
}


bool orders(int sig){
   int ord = sig == 1 ? ORDER_TYPE_BUY : sig == - 1? ORDER_TYPE_SELL : -1; 
   if (!checkOrd(ord)) return false;
   if(InpUseStops) tradeParams(ord);
   
   if (!orderSend(ord)) PrintFormat("Order Send Error: %i", GetLastError());
   return true;
}


bool checkElements(int &items[]){
   // need to check all elements if the same for valid forecast
   for (int i = 0; i < ArraySize(items) - 1 ; i++ ){
      if (items[i] != items[i + 1]) return false;
   }
   return true;
}

void tradeParams(int ord){
   if (ord == ORDER_TYPE_BUY)       { trade.stop = prevLow(PERIOD_MN1); }
   else if (ord == ORDER_TYPE_SELL) { trade.stop = prevHigh(PERIOD_MN1); }
}


bool checkOrd(int ord){
   if (!OrdersTotal()) return true; // check for open orders. if no open orders, return 
   int tick = selectByPos(0);
   if (!InpStacking) return false; 
   if (OrderType() != ord || expired() || limit()){
      // Close all on opposite signal
      int ords = PosTotal();
      for (int i = 0; i < ords; i++){
         selectByPos(i);
         closeOrder();
      }
   }
   return true;
   // close
   
}


double wkPivot(int shift){
   double wkH = iHigh(Sym, InpTimeFrame, shift + 1);
   double wkL = iLow(Sym, InpTimeFrame, shift + 1);
   double wkC = iClose(Sym, InpTimeFrame, shift + 1);
   double piv = (wkH + wkL + wkC) / 3;
   return piv;
}


// -- WRAPPERS -- //

int orderSend(int ord){ 
   // check if current open order matches signal
   int ticket = OrderSend(Sym, ord, trade.volume, Ask, 3, trade.stop, trade.target, NULL, 232323, 0, clrNONE);
   if (ticket < 0) return 0;
   return ticket;
}

int PosTotal()             { return OrdersTotal(); }
bool closeOrder()          { return OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE); }
int selectByPos(int idx)  { return OrderSelect(idx, SELECT_BY_POS, MODE_TRADES); }

double bal()   { return AccountInfoDouble(ACCOUNT_BALANCE); }
double pl()    { return OrderProfit(); }

double prevHigh(ENUM_TIMEFRAMES prd)   { return iHigh(Sym, prd, 1); }
double prevLow(ENUM_TIMEFRAMES prd)    { return iLow(Sym, prd, 1); }

double minLot() { return SymbolInfoDouble(Sym, SYMBOL_VOLUME_MIN); }
datetime Wk_Start(int shift) { return iTime(Sym, InpTimeFrame, shift); }
double Open_W(int shift) { return iOpen(Sym, InpTimeFrame, shift); }
double Close_W(int shift) { return iClose(Sym, InpTimeFrame, shift) ; }
double MA(int shift) { return iMA(Sym, InpTimeFrame, InpMaLength, 0, InpMAMethod, PRICE_CLOSE, shift); }

bool limit(){
   if (pl() < bal() * 0.01) return true;
   return false;
}

bool expired(){
   int shift = iBarShift(Sym, PERIOD_W1, OrderOpenTime());
   if (shift >= InpHoldTime) return true;
   return false;
}
double norm (double price){
   return NormalizeDouble(price, 5);
}

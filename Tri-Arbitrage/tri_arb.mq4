#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property version   "1.00"
#property strict

#include <B63/Generic.mqh>

const string quote_curr = "GBPUSD";
const string base_curr = "EURUSD";

// fmt: BASE/QUOTE | CROSS 
string sets[2][3] = {"EURUSD", "GBPUSD", "EURGBP",    "AUDUSD", "NZDUSD", "AUDNZD"};

string crosses[] = {"EURGBP", "AUDNZD"};

input int            InpMagic       = 232323;
input int            InpMinDelta    = 100;
input int            InpMinLoss     = 1;
input double         InpSize        = 0.01;
input double         InpRRR         = 2;

struct SSymbolData{
   int set;
   int vect;
   
   SSymbolData(){
      set = -1;
      
      int dims = ArrayDimension(sets);
      int size = ArraySize(sets);
      vect = size / dims;
   }
};

struct SPriceData{
   double prices[];
   int order_list[];
   double true_price;
   double implied_price;
   
   void reset_order_list(){
      ArrayFree(order_list);
   }
   void update_price(double t, double imp){
      true_price = t;
      implied_price = imp;
   }
   SPriceData(){
      true_price = 0;
      implied_price = 0;
   }
};

struct STradeData{
   int cross_order;
   
   void reset(){
      cross_order = -1;
   }
   
   STradeData(){
      reset();
   }
   
};

struct SAcctInfo{
   double bal;
   
   SAcctInfo(){
      bal = AccountInfoDouble(ACCOUNT_BALANCE);
   }
};

int OnInit()
  {
//---
initialize();

//---
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
//---
   
  }
void OnTick()
  {
//---
   // specify trading range? 
      show_data();
   
   
  }

SPriceData s_price_data;
SAcctInfo s_acct_info;
SSymbolData s_symbol_data;
STradeData s_trade_data;

void initialize(){   
   for (int i = 0; i < ArraySize(crosses); i++){
      if (Symbol() == crosses[i]) {
         s_symbol_data.set = i;
         break;
      }
   }
}

bool show_data(){
   int set = s_symbol_data.set;
   
   if (Symbol() != sets[set][2]) return false;
   // future optimization: input parameter: matrix dimension(set)
   double price_array [3];

   for (int i = 0; i < s_symbol_data.vect ; i ++) {
      double bid = SymbolInfoDouble(sets[set][i], SYMBOL_BID);
      long spread = SymbolInfoInteger(sets[set][i], SYMBOL_SPREAD);
      double point = SymbolInfoDouble(sets[set][i], SYMBOL_POINT);
      price_array[i] = bid - (spread * point);
   }
   ArrayCopy(s_price_data.prices, price_array);
   double implied_price = NormalizeDouble((s_price_data.prices[0] / s_price_data.prices[1]), (int)SymbolInfoInteger(sets[set][2], SYMBOL_DIGITS));
   double true_price = s_price_data.prices[2];
   s_price_data.update_price(true_price, implied_price);
   
   int delta =(int)((true_price - implied_price) / SymbolInfoDouble(Symbol(), SYMBOL_POINT)); // POINTS FORMAT
   Comment(sets[set][0], " ", sets[set][1], " ", sets[set][2], "\nTrue: ", true_price, "\nImplied: ", implied_price, "\nDelta: ", delta, "\nMagic: ", InpMagic);

   // CLOSE BY PROFIT
   if (AccountEquity() > s_acct_info.bal && 
   (AccountProfit() >= (InpMinLoss * InpRRR))) close_orders("profit"); 
   
   // CLOSE BY LOSS
   else if (AccountEquity() < s_acct_info.bal &&
   (AccountProfit() <= -InpMinLoss)) close_orders("loss"); 
   
   // CLOSE ON NEUTRAL
   else if (AccountProfit() > 0 && MathAbs(delta) == 0) close_orders("neutral");
   
   else if (true_price > implied_price && MathAbs(delta) >= InpMinDelta && s_trade_data.cross_order != 1){
      // SHORT CROSS 
      // LONG SYNTHETIC
      Print("Short Cross");
      
      // CLOSE BY SIGNAL
      if (open_positions() && s_trade_data.cross_order == 0) close_orders("signal");
      
      int orders [3] = {0, 1, 1};
      ArrayCopy(s_price_data.order_list, orders);
      if (!send_orders(orders) && !open_positions()) Print("Something Went Wrong.");
   }
   else if (true_price < implied_price && MathAbs(delta) >= InpMinDelta && s_trade_data.cross_order != 0){
      // LONG CROSS
      // SHORT SYNTHETIC
      Print("Long Cross");
      
      // CLOSE BY SIGNAL
      if(open_positions() && s_trade_data.cross_order == 1) close_orders("signal");
      int orders [3] = {1, 0, 0};
      ArrayCopy(s_price_data.order_list, orders);
      if (!send_orders(orders) && !open_positions()) Print("Something Went Wrong.");
   }
   return true;
}

bool close_orders(string source){
   //if (OrdersTotal() != ArraySize(s_order_data.order_list)) return false;
   Print("Close By ", source);
   if (!open_positions()) return false;
   int orders = OrdersTotal();
   Print("Orders: ", orders);
   for (int i = 0; i < orders; i++){ // batch close
      // CLOSE BY TICKET
      /*
      int selected = OrderSelect(s_order_data.order_list[i], SELECT_BY_TICKET, MODE_TRADES);
      if (OrderMagicNumber() != InpMagic) return false;
      int closed = OrderClose(s_order_data.order_list[i], OrderLots(), Bid, 3, clrNONE);
   */
      // CLOSE BY POSITION
      int selected = OrderSelect(0, SELECT_BY_POS, MODE_TRADES); // SELECT INDEX 0: First trade in the order pool (don't use i)
      Print("Index: ", i, " Close: ", OrderTicket(), " Selected: ", selected);
      if (OrderMagicNumber() != InpMagic) return false;
      int closed = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE);
   }
   s_trade_data.reset();
   return true;
}

struct SOrderData{
   int order_list[];
   
   void update_order_list(int &tickets[]){
      ArrayResize(order_list, ArraySize(tickets));
      ArrayCopy(order_list, tickets);
   }
};

SOrderData s_order_data;

bool send_orders(int &orders[]){
   int tickets [3];
   // lazy checking 
   double cross_open = iOpen(sets[s_symbol_data.set][2], PERIOD_D1, 0);
   if ((orders[2] == 1 && Bid < cross_open) || (orders[2] == 0 && Bid > cross_open)) {
      Print("Open Ref");
      return false;
      
   }
   if (s_price_data.order_list[0] != orders[0]) {
      s_price_data.reset_order_list();
      return false;   
   }
   if (open_positions()) return false; // proceed to order send only if there are no open positions. (prevent overlap with batch close)
   
   Print("True: ", s_price_data.true_price, " Implied: ", s_price_data.implied_price);
   
   int size = ArraySize(s_price_data.order_list);
   //int size = 2;
   
   for (int i = 0; i < size; i ++){
   // buy at asking price, sell at bid price
      double order_price = s_price_data.order_list[i] == 0 ? Ask : s_price_data.order_list[i] == 1 ? Bid : Bid;
      int ticket = OrderSend(sets[s_symbol_data.set][i], orders[i], InpSize, order_price, 3, 0, 0, NULL, InpMagic, 0, clrNONE);
      if (ticket < 0) {
         Print("Order Send Error for ", sets[s_symbol_data.set][i], "ERROR: ", GetLastError());
         s_price_data.reset_order_list(); // flush order data
         return false;
      }
      tickets[i] = ticket;
   }
   s_trade_data.cross_order = s_price_data.order_list[2];
   s_order_data.update_order_list(tickets);
   s_price_data.reset_order_list(); // flush order data
   return true;
}


bool open_positions() { return OrdersTotal() > 0;}

#property copyright "Jay Benedict Alfaras"
#property strict


// GENERIC FUNCTIONS

bool IsNewCandle()
  {
   static datetime saved_candle_time;
   #ifdef __MQL4__
   datetime currtime = Time[0];
   #endif 
   #ifdef __MQL5__  
   datetime currtime = iTime(Symbol(), PERIOD_CURRENT, 0);
   #endif 
   if(currtime==saved_candle_time)
     {
      return(false);
     }
   else
     {
      saved_candle_time=currtime;
      return(true);
     }
  }
  
bool IsTradingDay(datetime time){
   //receiving datetime and returning trading day start time and end time 
   MqlDateTime mtime;
   TimeToStruct(time,mtime);
   datetime fromTime;
   datetime toTime;
   return SymbolInfoSessionTrade(Symbol(),(ENUM_DAY_OF_WEEK)mtime.day_of_week,0,fromTime,toTime);
}

bool IsInSession(datetime time){
   MqlDateTime mtime;
   MqlDateTime fTimeStruct;
   MqlDateTime tTimeStruct;
   TimeToStruct(time, mtime);
   datetime fromTime;
   datetime toTime;
   SymbolInfoSessionTrade(Symbol(),(ENUM_DAY_OF_WEEK)mtime.day_of_week,0,fromTime,toTime);
   fromTime = compare(time, fromTime);
   toTime = compare(time, toTime);
   TimeToStruct(fromTime, fTimeStruct);
   TimeToStruct(toTime, tTimeStruct);

   if (time >= fromTime && time < toTime) return true;
   return false;
}

datetime compare(datetime ref, datetime overlap){
   MqlDateTime overlapStruct;
   MqlDateTime refStruct;
   TimeToStruct(ref, refStruct);
   TimeToStruct(overlap, overlapStruct);
   
   
   overlapStruct.day = refStruct.day;
   overlapStruct.mon = refStruct.mon;
   overlapStruct.year = refStruct.year;
   
   datetime val = StructToTime(overlapStruct);
   if ((overlapStruct.hour == 24 || overlapStruct.hour == 0)&& overlapStruct.min == 0) val = val + 86400 - 1;
   return val;
}


bool IsMarketOpen(string symbol){
   ENUM_SYMBOL_TRADE_MODE marketStatus = (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE);
   if (marketStatus != SYMBOL_TRADE_MODE_FULL) return false;
   return true;
}

bool IsTradeDisabled(string symbol){
   ENUM_SYMBOL_TRADE_MODE marketStatus = (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE);
   if (marketStatus == SYMBOL_TRADE_MODE_FULL) return false;
   return true;
}

MqlDateTime mqlTime(){
   MqlDateTime timenow;
   TimeToStruct(TimeCurrent(), timenow);
   return timenow;
}

MqlDateTime mqlTime(datetime time){
   MqlDateTime timeStruct;
   TimeToStruct(time, timeStruct);
   return timeStruct;
}


int setFactor(){
   int digits = (int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   if (digits == 5) return (10000);
   if (digits == 3) return (100);
   if (digits == 2) return (10);
   else return(0);
}


void resetObject(string sparam){
   Sleep(100);
   ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
}

void updateObject(string sparam){
   ObjectDelete(0, sparam);
   
}

bool openPositions(){
   if (!PositionsTotal()) return false;
   return true;
}


// TRADE OPERATIONS //

#ifdef __MQL4__
string PositionSymbol() {return OrderSymbol();}
int PositionsTotal() {return OrdersTotal();}
double PositionPriceOpen() {return OrderOpenPrice();}
double PositionStopLoss() {return OrderStopLoss();}
double PositionTakeProfit() {return OrderTakeProfit();}
long PositionTicket() {return OrderTicket();}
double PositionVolume() {return OrderLots();}
double PositionProfit() { return OrderProfit(); }
datetime PositionOpenTime() { return OrderOpenTime(); }
int PositionMagicNumber() { return OrderMagicNumber(); }
datetime PositionExpiration () { return OrderExpiration(); }
ENUM_ORDER_TYPE PositionOrderType() {return (ENUM_ORDER_TYPE)OrderType();}

bool PositionClose() { return OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE);}
bool PositionDelete() {return OrderDelete(OrderTicket(), clrNONE); }
bool PositionSelectByIndex(int idx){ 
   bool select = OrderSelect(idx, SELECT_BY_POS, MODE_TRADES);
   if (PositionTicket() <= 0) return false;
   return true;
}

int PositionSelectByTicket(int ticket){
   return OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
}



#endif

#ifdef __MQL5__
double PositionPriceOpen(){return PositionGetDouble(POSITION_PRICE_OPEN);}
double PositionStopLoss() {return PositionGetDouble(POSITION_SL);}
double PositionTakeProfit(){return PositionGetDouble(POSITION_TP);}
long PositionTicket() {return PositionGetInteger(POSITION_TICKET);}
long PositionMagic() {return PositionGetInteger(POSITION_MAGIC);}
string PositionSymbol() {return PositionGetString(POSITION_SYMBOL);}
datetime PositionTimeOpen() {return (datetime)PositionGetInteger(POSITION_TIME);}



#endif 


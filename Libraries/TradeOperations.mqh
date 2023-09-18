
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property strict

#ifdef __MQL5__
#include <Trade/Trade.mqh>
CTrade Trade();
#endif



#include <B63/Generic.mqh>

//HEADER - NAMING CONVENTION 
//S - STRUCT
//E - ENUM
//F - FUNCTION
//C - CLASS


struct STradeParams{
   ENUM_ORDER_TYPE ord;
   double entry;
   double tp;
   double sl;
   double volume;
   long magic;
   datetime expiry;
   
   STradeParams(){
      ord = -1;
      entry = 0;
      tp = 0;
      sl = 0;
      volume = 0;
      magic = 0;
      expiry = 0;
   }
   
};


struct SVol{
   double volume;
   double gainAmt;
   double gainPct;
   double expAmt;
   double expPct;
   
   SVol(){
      volume = 0;
      gainAmt = 0;
      gainPct = 0;
      expAmt = 0;
      expPct = 0;
   }
};


enum ERisk{
   FixedLot = 1,
   PercentBalance = 2,
   FixedAmount = 3,
};

class CTradeOperations{

protected:
   ERisk RiskType;
   double RiskAmt;
   double RiskPct;
   double RiskLot;
   SVol vol;

private:
   
   void FRisk(ERisk inpRiskType){ RiskType = inpRiskType; }
   void FRiskAmt (double inpRiskAmt) { RiskAmt = inpRiskAmt; }
   void FRiskPct (double inpRiskPct) { RiskPct = inpRiskPct; }
   void FRiskLot (double inpRiskLot) { RiskLot = inpRiskLot; }
   
   ERisk FRisk(){ return RiskType; }
   double FRiskAmt() { return RiskAmt; }
   double FRiskPct() { return RiskPct; }
   double FRiskLot() { return RiskLot; }
   
   double SVolExpPct() { return vol.expPct; }
   double SVolExpAmt() { return vol.expAmt; }
   
public: 
   CTradeOperations(void);
   CTradeOperations(ERisk inpRiskType, double inpRiskAmt, double inpRiskPct, double inpRiskLot);
   double volume(double stopPts);
   double volume(double entry, double stop);
   
#ifdef __MQL4__
   int      PosTotal()         { return OrdersTotal(); }
   double   PosPriceOpen()     { return OrderOpenPrice(); }
   double   PosStopLoss()      { return OrderStopLoss(); }
   double   PosTakeProfit()    { return OrderTakeProfit(); }
   long     PosTicket()        { return OrderTicket(); }
   double   PosVolume()        { return OrderLots(); }
   ENUM_ORDER_TYPE      PosOrderType()     { return (ENUM_ORDER_TYPE)OrderType(); }
   
   int SendOrder(ENUM_ORDER_TYPE order, double volume, double entry, double stop, double target, int magic){
      return SendOrder(Symbol(), order,volume, entry, stop, target, magic, 0);
   }
   
   int SendOrder(string symbol, ENUM_ORDER_TYPE order, double volume, double entry, double stop, double target, int magic, datetime expiry){
      return OrderSend(symbol, order, volume, entry, 3, stop, target, NULL, magic, expiry, clrNONE);
   }
   
   bool DeleteOrder(int tick) { return OrderDelete(tick); }
#endif

#ifdef __MQL5__

   int SendOrder(ENUM_ORDER_TYPE order, double volume, double entry, double stop, double target, int magic){
      return SendOrder(Symbol(), order, volume, entry, stop, target, magic , 0);
   }

   int SendOrder(string symbol, ENUM_ORDER_TYPE order, double volume, double entry, double stop, double target, int magic, datetime expiry){
      Trade.SetExpertMagicNumber(magic);
      return Trade.PositionOpen(symbol, order, volume, entry, stop, target, NULL);
   }

#endif
   

};

CTradeOperations::CTradeOperations(void){
   RiskType = FixedLot;
   RiskAmt = 1;
   RiskPct = 1;
   RiskLot = 0.01;
}

CTradeOperations::CTradeOperations(ERisk inpRiskType,double inpRiskAmt,double inpRiskPct,double inpRiskLot){
   FRisk(inpRiskType);
   FRiskAmt(inpRiskAmt);
   FRiskPct(inpRiskPct);
   FRiskLot(inpRiskLot);
}


double CTradeOperations::volume(double stopPts){
   
   static double retLot;
   static double riskAmt;
   static double riskPct;
   
   //double retLot     = 0;
   //double riskAmt    = 0;
   //double riskPct    = 0;
   double minLot     = 0.01;
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   riskAmt = FRisk() == PercentBalance ? balance * (FRiskPct() / 100) : FRisk() == FixedAmount ? FRiskAmt() : (FRiskLot() * stopPts);
   riskPct = (riskAmt / balance) * 100;
   retLot = FRisk() == FixedLot ? FRiskLot() : riskAmt / stopPts;
   
   vol.volume = retLot;
   vol.expAmt = FRisk() == FixedAmount ? FRiskAmt() : riskAmt;
   vol.expPct = FRisk() == PercentBalance ? FRiskPct() : riskPct;
   
   /*
   trade.gainAmt = inpTargetType == RRR ? riskAmt * inpTargRRR : inpTargPips * 10 * retLot;
   trade.gainPct = (trade.gainAmt / balance) * 100;
   trade.exposureAmt = inpRiskType == FixedAmount ? inpRiskAmt : riskAmt;
   trade.exposurePct = inpRiskType == PercentBalance ? inpRiskPct : riskPct;
   */
   
   if (retLot < minLot) return (NormalizeDouble(minLot, 2));
   
   return NormalizeDouble(retLot, 2); 
}

double CTradeOperations::volume(double entry, double stop){
   double stopPts    = MathAbs(entry - stop) * setFactor() * 10;
   
   return volume(stopPts);
   
}




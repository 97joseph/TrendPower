//+------------------------------------------------------------------+
//|                                                 TrailingStop.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <..\Experts\TrendPower\V4.4\Inputs.mqh>
class TrailingStop
  {
private:
   string            SYMBOL;
   ENUM_TIMEFRAMES   TIMEFRAME;
   double            point;
   int               digits;
   

public:
                     TrailingStop(string symbol,ENUM_TIMEFRAMES timeframe);
   void              SetStopLoss(int pos, double SL);
                    ~TrailingStop();
   void              Execute(double ATR);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TrailingStop::TrailingStop(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   SYMBOL=symbol;
   TIMEFRAME=timeframe;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TrailingStop::~TrailingStop()
  {
  }
//+------------------------------------------------------------------+
void TrailingStop::Execute(double ATR)
  {
   double            atr = ATR;
   int t=PositionsTotal();
   for(int i=t-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      double profit = PositionGetDouble(POSITION_PROFIT);
      double TP = PositionGetDouble(POSITION_TP);
      string sym = PositionGetString(POSITION_SYMBOL);
      if (sym != SYMBOL) continue;
      if (TP >0) continue;
      double SL = PositionGetDouble(POSITION_SL);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
      double curPrice =0;
      double gap=0;
      point = SymbolInfoDouble(SYMBOL, SYMBOL_POINT);
      digits = (int)SymbolInfoInteger(SYMBOL,SYMBOL_DIGITS);
      if(type == POSITION_TYPE_BUY)
        {
         curPrice = SymbolInfoDouble(SYMBOL, SYMBOL_ASK);
         
         gap = (curPrice - SL)/point/10;
         if(gap > atr/point/10)
           {
            //Adjust Stop Loss
            double new_SL = NormalizeDouble(curPrice-atr*ATR_TRAIL_STOP_MULTIPLIER,digits);
            if((new_SL-SL)/point/10 >1)
               SetStopLoss(i,new_SL);

           }
        }
      if(type == POSITION_TYPE_SELL)
        {
         curPrice = SymbolInfoDouble(SYMBOL,SYMBOL_BID);
         gap = (SL - curPrice)/point/10;
         if(gap > atr/point/10)
           {

            //Adjust Stop Loss
            double new_SL = NormalizeDouble(curPrice+atr*ATR_TRAIL_STOP_MULTIPLIER,digits);
            if((SL-new_SL)/point/10 >1)
               SetStopLoss(i,new_SL);

           }
        }




     }

  }
//+------------------------------------------------------------------+
void TrailingStop::SetStopLoss(int pos, double SL)
  {

   MqlTradeRequest   request;
   MqlTradeResult    result;
   

   ZeroMemory(request);
   ZeroMemory(result);
   
   ulong ticket = PositionGetTicket(pos);

   request.action  =TRADE_ACTION_SLTP; // type of trade operation
   request.position=ticket;   // ticket of the position
   request.symbol=SYMBOL;     // symbol
   request.sl      =SL;                // Stop Loss of the position
   request.tp =0;
   
   if(!OrderSend(request,result))
     {
      PrintFormat("OrderSend error %d",GetLastError());// if unable to send the request, output the error code

     }
   else
     {
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);//--- information about the operation

     }

  }
//+------------------------------------------------------------------+

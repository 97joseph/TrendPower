//+------------------------------------------------------------------+
//|                                           GlobalPositiveTake.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <..\Experts\TrendPower\V4.4\TradingFunctions\Trade.mqh>
class GlobalPositiveTake
  {
private:
   string            SYMBOL;
   double            point;
   int               digits;
Trade             *trade;
public:
                     GlobalPositiveTake(string SYMBOL);
                    ~GlobalPositiveTake();
                    void ClosePositive(double positiveProfit);
                    
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GlobalPositiveTake::GlobalPositiveTake(string symbol)
  {
   SYMBOL=symbol;
   
   point=SymbolInfoDouble(SYMBOL,SYMBOL_POINT);
   digits=(int)SymbolInfoInteger(SYMBOL,SYMBOL_DIGITS);
   trade = new Trade(SYMBOL); 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GlobalPositiveTake::~GlobalPositiveTake()
  {
  }
//+------------------------------------------------------------------+
void GlobalPositiveTake::ClosePositive(double positiveProfit)
{
   int t=PositionsTotal();
   for(int i=t-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      double profit = PositionGetDouble(POSITION_PROFIT);
      if(profit > positiveProfit)
      {
         trade.exitSinglePosition(i,"Global POSITIVE Profit");
      }
      

     }
   
}
//+------------------------------------------------------------------+
//|                                            InterTradePipsGap.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <..\Experts\TrendPower\V4.4\Inputs.mqh>
class InterTradePipsGap
  {
private:
   string            SYMBOL;
   double            point;
   int               digits;
public:
   LastTrade         last;
                     InterTradePipsGap(string symbol);
                    ~InterTradePipsGap();
   bool              Check();
   void              SetLastTrade(ulong orderType);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
InterTradePipsGap::InterTradePipsGap(string symbol)
  {
   SYMBOL=symbol;

   point=SymbolInfoDouble(SYMBOL,SYMBOL_POINT);
   digits=(int)SymbolInfoInteger(SYMBOL,SYMBOL_DIGITS);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
InterTradePipsGap::~InterTradePipsGap()
  {
  }
//+------------------------------------------------------------------+
bool InterTradePipsGap::Check()
  {
   double bid = SymbolInfoDouble(SYMBOL,SYMBOL_BID);
   double ask = SymbolInfoDouble(SYMBOL,SYMBOL_ASK);
   double price=0;
   if(last.type ==POSITION_TYPE_BUY) price = last.lastBuyPrice;
   if(last.type ==POSITION_TYPE_SELL) price = last.lastSellPrice;
   double        gap = MathAbs(price- ask)/point/10;  
   
   double target = INTER_TRADE_PIPS;
   
   
   if(ENABLE_INCLUDE_SPREAD_IN_PIPS) target = target + SymbolInfoInteger(SYMBOL,SYMBOL_SPREAD);
   
   if(gap > target) 
   {
      return true;
   }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InterTradePipsGap::SetLastTrade(ulong order)
  {
   PositionSelectByTicket(order);

   double volume=PositionGetDouble(POSITION_VOLUME);
   string sym=PositionGetString(POSITION_SYMBOL);
   ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // type of the position
   double price = PositionGetDouble(POSITION_PRICE_OPEN);
   if(type==POSITION_TYPE_BUY)
     {
      last.buyTrades++;
      last.lastBuyPrice = price;
      last.type = POSITION_TYPE_BUY;

     }
   if(type==POSITION_TYPE_SELL)
     {
      last.sellTrades++;
      last.lastSellPrice = price;
      last.type = POSITION_TYPE_SELL;
     }

  }
//+------------------------------------------------------------------+

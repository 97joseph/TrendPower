//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include<Trade\Trade.mqh>
class Trade
  {
private:
string            SYMBOL;
   ENUM_TIMEFRAMES   TIMEFRAME;
   double            point;
   int               digits;
   CTrade            ct;


public:
                     Trade(string symbol,ENUM_TIMEFRAMES timeframe=PERIOD_D1);
                    ~Trade();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trade::Trade(string symbol,ENUM_TIMEFRAMES timeframe=PERIOD_D1)
  {
     SYMBOL=symbol;
      TIMEFRAME=timeframe;
      point=SymbolInfoDouble(SYMBOL,SYMBOL_POINT);
      digits=(int)SymbolInfoInteger(SYMBOL,SYMBOL_DIGITS);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trade::~Trade()
  {
  }
//+------------------------------------------------------------------+
void Trade::tradeBuy(double SL=0,int magic,double TP=0,double LOTSIZE=0.01,double atr=NULL)
  {

   MqlTradeRequest request;
   MqlTradeResult  result;

//--- zeroing the request and result values
   ZeroMemory(request);
   ZeroMemory(result);

//double price;                                                       // order triggering price

   digits=(int)SymbolInfoInteger(SYMBOL,SYMBOL_DIGITS);                // number of decimal places (precision)

//--- parameters to place a pending order
   request.action=TRADE_ACTION_DEAL;                             // type of trade operation
   request.symbol=SYMBOL;                                         // symbol
   request.volume=LOTSIZE;                                              // volume of 0.1 lot
   request.deviation=2;
   request.magic=magic;
   request.type=ORDER_TYPE_BUY;                                // order type
   request.comment = "A:" +DoubleToString(NormalizeDouble(atr,5));  //Original Trade Entry ATR
   double price=SymbolInfoDouble(SYMBOL,SYMBOL_ASK); // price for opening
//request.comment = NormalizeDouble(price,digits);                      // normalized opening price
   request.price=NormalizeDouble(price,digits);                      // normalized opening price
   request.sl=SL; //Stop Loss
   if(TP>0)
      request.tp=TP; //Take Profit
//double slPrice = NormalizeDouble(price - ATR_VAL*1.5,digits);
//request.sl = slPrice;

//double tpPrice = NormalizeDouble(price + ATR_VAL*0.8*RISK_REWARD,digits);
//request.tp = tpPrice;

//--- send the request
   if(!OrderSend(request,result))
     {
      PrintFormat("OrderSend error %d",GetLastError());                 // if unable to send the request, output the error code
     }
   else
     {
      //--- information about the operation
      double a=atr;
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
      lastTicket=result.order;
     }
//log

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade::tradeSell(double SL,int magic,double TP,double LOTSIZE,double atr=NULL)
  {

   MqlTradeRequest request;
   MqlTradeResult  result;

//--- zeroing the request and result values
   ZeroMemory(request);
   ZeroMemory(result);

//double price;                                                       // order triggering price

   digits=(int)SymbolInfoInteger(SYMBOL,SYMBOL_DIGITS);                // number of decimal places (precision)

//--- parameters to place a pending order
   request.action=TRADE_ACTION_DEAL;                             // type of trade operation
   request.symbol=SYMBOL;                                         // symbol
   request.volume=LOTSIZE;                                              // volume of 0.1 lot
   request.deviation=2;
   request.magic=magic;
   request.type=ORDER_TYPE_SELL;                                // order type
   request.comment = "A:"+DoubleToString(NormalizeDouble(atr,5));  //Original Trade Entry ATR
   double price=SymbolInfoDouble(SYMBOL,SYMBOL_BID); // price for opening
//request.comment =   NormalizeDouble(price,digits);                      // normalized opening price
   request.price=NormalizeDouble(price,digits);                      // normalized opening price
   request.sl=SL; //Stop Loss
   if(TP>0)
      request.tp=TP;
//double slPrice = NormalizeDouble(price - ATR_VAL*1.5,digits);
//request.sl = slPrice;

//double tpPrice = NormalizeDouble(price + ATR_VAL*0.8*RISK_REWARD,digits);
//request.tp = tpPrice;

//--- send the request
   if(!OrderSend(request,result))
     {
      PrintFormat("OrderSend error %d",GetLastError());                 // if unable to send the request, output the error code
     }
   else
     {
      //--- information about the operation
      double a=atr;
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
      lastTicket=result.order;
     }
//Log

  }

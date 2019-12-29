//+------------------------------------------------------------------+
//|                                                     TradeBuy.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include<Trade\Trade.mqh>
class TradeBuy
  {
private:
   string            SYMBOL;
   double            point;
   int               digits;
   CTrade            ct;
public:
                     TradeBuy();
                    ~TradeBuy();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeBuy::TradeBuy()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeBuy::~TradeBuy()
  {
  }
//+------------------------------------------------------------------+
TradeBuy::Market(double SL,int magic=0,double TP,double LOTSIZE,double atr=NULL, double comment ="")
  {
   MqlTradeRequest request;
   MqlTradeResult  result;

//--- zeroing the request and result values
   ZeroMemory(request);
   ZeroMemory(result);

   digits=(int)SymbolInfoInteger(SYMBOL,SYMBOL_DIGITS);                // number of decimal places (precision)

//--- parameters to place a pending order
   request.action=TRADE_ACTION_DEAL;                             // type of trade operation
   request.symbol=SYMBOL;                                         // symbol
   request.volume=LOTSIZE;                                              // volume of 0.1 lot
   request.deviation=2;
   request.magic=magic;
   request.type=ORDER_TYPE_BUY;                                // order type
   request.comment = comment; //Trade comment
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

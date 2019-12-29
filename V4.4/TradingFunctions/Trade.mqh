//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include<Trade\Trade.mqh>
#define BUY 1
#define SELL 2
#include <..\Experts\TrendPower\V4.4\Inputs.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Trade
  {
private:
   string            SYMBOL;
   double            point;
   int               digits;
   CTrade            ct;
   //Trade Parametsr
   ENUM_TRADE_REQUEST_ACTIONS requestAction;
   MqlTradeRequest   request;
   MqlTradeResult    result;
   ENUM_ORDER_TYPE   orderType;

   MqlTradeResult              Market(double SL =0, double TP=0,double LOTSIZE=0.01,string comments="");
   MqlTradeResult              Execute();

public:
                     Trade(string symbol);
                    ~Trade();

   MqlTradeResult              BuyMarket(double SL =0, double TP=0,double LOTSIZE=0.01,string comments="");
   MqlTradeResult              SellMarket(double SL =0, double TP=0,double LOTSIZE=0.01,string comments="");
   SLTP              setSLTP(int direction,double atr);
   void              exitSinglePosition(int pos,string reason,ulong ticket=NULL);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trade::Trade(string symbol)
  {

   SYMBOL=symbol;

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
MqlTradeResult Trade::Execute()
  {


   if(!OrderSend(request,result))
     {
      PrintFormat("OrderSend error %d",GetLastError());// if unable to send the request, output the error code
      
     }
   else
     {
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);//--- information about the operation
      
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MqlTradeResult Trade::Market(double SL =0, double TP=0,double LOTSIZE=0.01,string comments="")
  {

   request.symbol       = SYMBOL;
   request.deviation    = 2;
   request.action=TRADE_ACTION_DEAL;
   request.comment      = comments;
   request.sl           = SL;
   request.tp           = TP;
   request.volume       = LOTSIZE;
   return Execute();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MqlTradeResult Trade::BuyMarket(double SL =0, double TP=0,double LOTSIZE=0.01,string comments="")
  {

   ZeroMemory(request);
   ZeroMemory(result);

   double price= NormalizeDouble(SymbolInfoDouble(SYMBOL,SYMBOL_ASK),digits);

   request.type         = ORDER_TYPE_BUY;
   request.price         = price;

   return Market(SL,TP,LOTSIZE,comments);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MqlTradeResult Trade::SellMarket(double SL =0, double TP=0,double LOTSIZE=0.01,string comments="")
  {

   ZeroMemory(request);
   ZeroMemory(result);

   double price= NormalizeDouble(SymbolInfoDouble(SYMBOL,SYMBOL_BID),digits);

   request.type         = ORDER_TYPE_SELL;
   request.price         = price;

   return Market(SL,TP,LOTSIZE,comments);

  }
//+------------------------------------------------------------------+
SLTP Trade::setSLTP(int direction,double atr)
  {

   SLTP data;
   data.SL=0;
   data.TP=0;


   double stop_loss_pips=0;

   if(ENABLE_STOP_ON_ATR)
     {
      stop_loss_pips = atr * ATR_STOP_MULTIPLIER/point/10;
     }
   else
     {
      stop_loss_pips = STOP_LOSS_PIPS;
     }

   if(direction==UP)
     {
      double ask =SymbolInfoDouble(SYMBOL, SYMBOL_ASK);
      data.ask =ask;
      data.SL = ask - stop_loss_pips*point*10;
      data.TP = ask + TAKE_PROFIT_PIPS*point*10;
     }

   if(direction==DOWN)
     {
      double bid = SymbolInfoDouble(SYMBOL, SYMBOL_BID);
      data.bid = bid;
      data.SL = bid + stop_loss_pips*point*10;
      data.TP = bid - TAKE_PROFIT_PIPS*point*10;

     }
   return data;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade::exitSinglePosition(int pos,string reason,ulong ticket=NULL)
  {


//--- zeroing the request and result values
   ZeroMemory(request);
   ZeroMemory(result);
   
   ulong  position_ticket=0;
   if(ticket==0)
     {
      position_ticket=PositionGetTicket(pos);
     }
   else
     {
      position_ticket=ticket;
      PositionSelectByTicket(ticket);

     }

   double volume=PositionGetDouble(POSITION_VOLUME);
   string sym=PositionGetString(POSITION_SYMBOL);
   ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // type of the position

   if(type==POSITION_TYPE_BUY)
     {
      request.price = SymbolInfoDouble(sym,SYMBOL_BID);
      request.type=ORDER_TYPE_SELL;
     }
   else
     {
      request.price = SymbolInfoDouble(sym,SYMBOL_ASK);
      request.type=ORDER_TYPE_BUY;
     }




   request.position =position_ticket;
   request.symbol       = sym;
   request.deviation    = 5;
   request.action=TRADE_ACTION_DEAL;
   request.volume       = volume;
   request.comment  = (string) reason;
   Execute();

  }
//+------------------------------------------------------------------+

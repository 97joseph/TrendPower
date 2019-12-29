//+------------------------------------------------------------------+
//|                                                          TVP.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#undef UP
#undef DOWN
#undef FLAT

#define UP 1
#define DOWN 2
#define FLAT 3

#include <..\Experts\TrendPower\V4.4\BaseLine.mqh>
#include <..\Experts\TrendPower\V4.4\Exit.mqh>
#include <..\Experts\TrendPower\V4.4\Confirmation.mqh>
#include <..\Experts\TrendPower\V4.4\LastTradeDetails.mqh>
#include <..\Experts\TrendPower\V4.4\ATR.mqh>
#include <..\Experts\TrendPower\V4.4\TradingFunctions\Trade.mqh>
#include <..\Experts\TrendPower\V4.4\TradingFunctions\GlobalPositiveTake.mqh>
#include <..\Experts\TrendPower\V4.4\TradingFunctions\InterTradePipsGap.mqh>
#include <..\Experts\TrendPower\V4.4\TradingFunctions\TrailingStop.mqh>

//Proposed Improvements.
//1. Trailing profit when trades are winning
//2. Stop loss based on ATR, or factors of ATR
//3. Add Global Stops & Equity Take



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MAIN
  {
private:
   BaseLine          *baseline;
   Confirmation      *confirmation;
   Exit              *exit;
   LastTradeDetails  *lastDetails;
   TradingFunctions  *TF;
   ATR               *atr;
   Trade             *trade;
   GlobalPositiveTake   *GPosTake;
   InterTradePipsGap *interTradePips;
   TrailingStop       *trailStop;
public:
   string            SYMBOL;
   double            ATR_CURRENT;
                     MAIN(string symbol);
                    ~MAIN();
   void              Execute();

   void              Update_LastTradeTime();

   void              logdata(ulong ticket,double openPrice,ENUM_POSITION_TYPE posType,double lot,double atr,double baseline,double primary,double confirmation,double confirmation2,double exit,double sl,double tp);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MAIN::MAIN(string symbol)
  {
   SYMBOL=symbol;

   lastDetails=new LastTradeDetails(SYMBOL);
   baseline=new BaseLine(SYMBOL,TRADING_PERIOD);
   confirmation=new Confirmation(SYMBOL);
   exit=new Exit(SYMBOL,TRADING_PERIOD);
   atr = new ATR(SYMBOL,TRADING_PERIOD,14);


   double point = SymbolInfoDouble(SYMBOL, SYMBOL_POINT);
   TF=new TradingFunctions(SYMBOL,TRADING_PERIOD);
   trade = new Trade(SYMBOL);
   GPosTake = new GlobalPositiveTake(SYMBOL);
   interTradePips = new InterTradePipsGap(SYMBOL);
   trailStop = new TrailingStop(SYMBOL,PERIOD_D1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MAIN::~MAIN()
  {

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MAIN::Execute()
  {



//---DEBUGGING STOP-----
   datetime tStop=TimeCurrent();
   if(tStop>StringToTime("2019.12.13"))
     {
      tStop=tStop;
     }

   double profit = AccountInfoDouble(ACCOUNT_PROFIT);
   int spread = (int)SymbolInfoInteger(SYMBOL,SYMBOL_SPREAD);
   if(profit >=GLOBAL_TAKE_PROFIT)
     {
      //Close ALL
      TF.GlobalCloseAllPositionsNew("Global Take Profit Met");
     }

   if(profit <= GLOBAL_STOP_LOSS)
     {
      //Close ALL
      TF.GlobalCloseAllPositionsNew("Global Stop Loss Hit");
     }

   if(ENABLE_GLOBAL_POSITIVE_TAKE)
     {
      GPosTake.ClosePositive(POSITIVE_TAKE);
     }
   
   atr.getATR();
   trailStop.Execute(atr.aTR);
   
   lastDetails.Fetch();
   int baseline_direction = baseline.Execute();

   double target_pips = INTER_TRADE_PIPS;
   if(ENABLE_INCLUDE_SPREAD_IN_PIPS)
     {
      target_pips =target_pips + spread;
     }
   int confirmation_direction = confirmation.Confirmation_no_direction(target_pips,lastDetails.last,baseline_direction,baseline.last_ma_price);
   double atrValue  = atr.getATR();
   if(baseline_direction == UP)
     {
      if(confirmation_direction==UP)
        {
         if(lastDetails.last.PositionsOpen<MAX_TRADES)
           {
            if(lastDetails.last.buyTrades<MAX_BUY_TRADES)
              {
               int timeDiff=(int)(TimeCurrent()-lastDetails.last.openTime);
               if(timeDiff>INTER_TRADE_WAIT_SECONDS) // Inter-Trade Wait
                 {
                  if(interTradePips.Check())
                    {
                     //Trade Buy
                     SLTP data;
                     double SL = trade.setSLTP(UP,atrValue).SL;
                     double TP = trade.setSLTP(UP,atrValue).TP;
                     double ask = trade.setSLTP(UP,atrValue).ask;
                     double bid = trade.setSLTP(UP,atrValue).bid;
                     
                     trade.BuyMarket(SL,0,LOT);
                     MqlTradeResult result = trade.BuyMarket(SL,TP,LOT);
                     
                     interTradePips.SetLastTrade(result.order);
                     if(result.order == 34)
                       {
                        string gichini = "Mark";
                       }
                     //TF.tradeBuy(SL,0,TP,LOT);
                    }
                 }
              }
           }
        }
     }
   if(baseline_direction == DOWN)
     {
      if(confirmation_direction==DOWN)
        {
         if(lastDetails.last.PositionsOpen<MAX_TRADES)
           {
            if(lastDetails.last.buyTrades<MAX_SELL_TRADES)
              {
               int timeDiff=(int)(TimeCurrent()-lastDetails.last.openTime);
               if(timeDiff>INTER_TRADE_WAIT_SECONDS) // Inter-Trade Wait
                 {
                  if(interTradePips.Check())
                    {
                     //Trade Sell
                     SLTP data;

                     double SL = trade.setSLTP(DOWN,atrValue).SL;
                     double TP = trade.setSLTP(DOWN,atrValue).TP;
                     double ask = trade.setSLTP(DOWN,atrValue).ask;
                     double bid = trade.setSLTP(DOWN,atrValue).bid;
                     
                     trade.SellMarket(SL,0,LOT);
                     MqlTradeResult result = trade.SellMarket(SL,TP,LOT);
                     
                     interTradePips.SetLastTrade(result.order);
                     //TF.tradeSell(SL,0,TP,LOT);
                     if(result.order == 34)
                       {
                        string gichini = "Mark";
                       }
                    }
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+

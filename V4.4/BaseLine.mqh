//+------------------------------------------------------------------+
//|                                                   Predictive.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <..\Experts\TrendPower\V4.4\TradingFunctions.mqh>
class BaseLine
  {
private:
   string            SYMBOL;
   ENUM_TIMEFRAMES   TIMEFRAME;
   TradingFunctions  *TF;
   double            point;
   int               digits;
   int               HandleBaseline;
   int               HandleHeiken;
   int               HandleKelter;
public:
   double            last_ma_price;

                     BaseLine(string symbol,ENUM_TIMEFRAMES timeframe);
                    ~BaseLine();
   int               Execute();
   int               TrendPower();
   int               HeikenAshi();
   int               Keltner();
  };
//+----------------------------------------------------}--------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLine::BaseLine(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   SYMBOL=symbol;
   TIMEFRAME=timeframe;
   TF=new TradingFunctions(SYMBOL,TIMEFRAME);
   point=SymbolInfoDouble(SYMBOL,SYMBOL_POINT);
   digits=(int)SymbolInfoInteger(SYMBOL,SYMBOL_DIGITS);
   HandleBaseline=iCustom(SYMBOL,TIMEFRAME,"trendpower",TREND_POWER_PERIOD_STEP,TREND_POWER_SMOOTHING_METHOD,TREND_POWER_PRICE_TYPE,TREND_POWER_HORIZONTAL_SHIFT);
   HandleHeiken=iCustom(SYMBOL,TIMEFRAME,"heiken_ashi");
   HandleKelter=iCustom(SYMBOL,TIMEFRAME,"keltner_channel",5,MODE_LWMA,0.5,PRICE_CLOSE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseLine::~BaseLine()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BaseLine::Execute()
  {
   int tp = TrendPower();
   int hk = HeikenAshi();
   int kt = Keltner();
   
   if(kt==UP)
     {
      if(tp==UP && hk == UP)
         return UP;
      if(tp==DOWN && hk == DOWN)
         return DOWN;
      return FLAT;
     }
   return FLAT;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BaseLine::HeikenAshi()
  {
   double Heiken[];
   ArraySetAsSeries(Heiken,true);
   CopyBuffer(HandleHeiken,4,0,4,Heiken);

   if(Heiken[1]==0 && Heiken[0]==0)
     {

      return UP;
     }
   if((int)Heiken[1]==1 && Heiken[0]==1)
     {

      return DOWN;
     }
   return FLAT;


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BaseLine::Keltner()
  {
   double KeltnerUpper[];
   double KeltnerLower[];

   ArraySetAsSeries(KeltnerUpper,true);
   ArraySetAsSeries(KeltnerLower,true);

   CopyBuffer(HandleKelter,0,0,4,KeltnerUpper);
   CopyBuffer(HandleKelter,2,0,4,KeltnerLower);

   
   double RatesHigh[];
   double RatesLow[];
   
   CopyHigh(SYMBOL,PERIOD_M1,0,3,RatesHigh);
   CopyLow(SYMBOL,PERIOD_M1,0,3,RatesLow);
   
   double price = SymbolInfoDouble(SYMBOL,SYMBOL_ASK);
   
   
   if(price > KeltnerUpper[0])
      return FLAT;
   if(price < KeltnerLower[0])
      return FLAT;
   return UP;


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BaseLine::TrendPower()
  {
   double Base[];

   ArraySetAsSeries(Base,true);
   CopyBuffer(HandleBaseline,0,0,3,Base);

   double Rates[];
   CopyClose(SYMBOL,PERIOD_M1,0,4,Rates);
   
   if(ArraySize(Rates)==0)
      return FLAT;
   double pipGap = MathAbs(Rates[1] - Base[1])/point/10;

   last_ma_price = Base[0];

   if(Rates[0] > Base[0] && pipGap >=TREND_POWER_REQUIRE_PIP_GAP)
      return  UP;
   if(Rates[0] < Base[0] && pipGap >=TREND_POWER_REQUIRE_PIP_GAP)
      return  DOWN;
   if(pipGap <TREND_POWER_REQUIRE_PIP_GAP)
      return  FLAT;

   return  FLAT;

  }

//+------------------------------------------------------------------+

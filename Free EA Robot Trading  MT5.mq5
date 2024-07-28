//Bollinger & RSI & Martingale

#include <Trade\Trade.mqh>

CTrade trade;

// Parameters
input int BollingerPeriod = 20;
input double BollingerDeviation = 2.0;
input int RSIPeriod = 14;
input double LotSize = 0.1;
input double StopLoss = 50; // in points
input double TakeProfit = 100; // in points
input double MartingaleMultiplier = 2.0; // Martingale multiplier

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double BollingerUpper, BollingerLower;
   double RSIValue;
   
   // Calculate indicators
   CalculateBollingerBands(BollingerUpper, BollingerLower);
   RSIValue = iRSI(Symbol(), PERIOD_CURRENT, RSIPeriod, PRICE_CLOSE, 0);

   // Generate trading signals
   if (ShouldBuy(BollingerLower, RSIValue))
      OpenBuyOrder();

   if (ShouldSell(BollingerUpper, RSIValue))
      OpenSellOrder();

   // Check existing positions and apply Martingale strategy if necessary
   ManageOpenPositions();
  }
//+------------------------------------------------------------------+
//| Function to calculate Bollinger Bands                            |
//+------------------------------------------------------------------+
void CalculateBollingerBands(double &upper, double &lower)
  {
   upper = iBands(Symbol(), PERIOD_CURRENT, BollingerPeriod, 0, BollingerDeviation, PRICE_CLOSE, MODE_UPPER, 0);
   lower = iBands(Symbol(), PERIOD_CURRENT, BollingerPeriod, 0, BollingerDeviation, PRICE_CLOSE, MODE_LOWER, 0);
  }
//+------------------------------------------------------------------+
//| Function to check if should buy                                  |
//+------------------------------------------------------------------+
bool ShouldBuy(double lowerBand, double RSIValue)
  {
   double price = Close[0];
   if(price < lowerBand && RSIValue < 30)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//| Function to check if should sell                                 |
//+------------------------------------------------------------------+
bool ShouldSell(double upperBand, double RSIValue)
  {
   double price = Close[0];
   if(price > upperBand && RSIValue > 70)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//| Function to open a buy order                                     |
//+------------------------------------------------------------------+
void OpenBuyOrder()
  {
   double lotSize = LotSize;

   // Check if there are existing buy positions
   if(PositionSelect(Symbol()))
     {
      for(int i = 0; i < PositionsTotal(); i++)
        {
         if(PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            lotSize = PositionGetDouble(POSITION_VOLUME) * MartingaleMultiplier;
            break;
           }
        }
     }
   
   trade.SetExpertMagicNumber(0); // Set a unique magic number if needed
   double price = Ask;
   double sl = price - StopLoss * _Point;
   double tp = price + TakeProfit * _Point;
   trade.Buy(lotSize, NULL, price, sl, tp, "Buy Order");
  }
//+------------------------------------------------------------------+
//| Function to open a sell order                                    |
//+------------------------------------------------------------------+
void OpenSellOrder()
  {
   double lotSize = LotSize;

   // Check if there are existing sell positions
   if(PositionSelect(Symbol()))
     {
      for(int i = 0; i < PositionsTotal(); i++)
        {
         if(PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            lotSize = PositionGetDouble(POSITION_VOLUME) * MartingaleMultiplier;
            break;
           }
        }
     }
   
   trade.SetExpertMagicNumber(0); // Set a unique magic number if needed
   double price = Bid;
   double sl = price + StopLoss * _Point;
   double tp = price - TakeProfit * _Point;
   trade.Sell(lotSize, NULL, price, sl, tp, "Sell Order");
  }
//+------------------------------------------------------------------+
//| Function to manage open positions                                |
//+------------------------------------------------------------------+
void ManageOpenPositions()
  {
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetSymbol(i) == Symbol())
        {
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? Bid : Ask;
         double lotSize = PositionGetDouble(POSITION_VOLUME);

         // Apply Martingale strategy if price has moved against the position
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && currentPrice < openPrice - StopLoss * _Point)
           {
            double sl = currentPrice - StopLoss * _Point;
            double tp = currentPrice + TakeProfit * _Point;
            trade.Buy(lotSize * MartingaleMultiplier, NULL, currentPrice, sl, tp, "Martingale Buy Order");
           }
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && currentPrice > openPrice + StopLoss * _Point)
           {
            double sl = currentPrice + StopLoss * _Point;
            double tp = currentPrice - TakeProfit * _Point;
            trade.Sell(lotSize * MartingaleMultiplier, NULL, currentPrice, sl, tp, "Martingale Sell Order");
           }
        }
     }
  }
//+------------------------------------------------------------------+

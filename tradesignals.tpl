//@version=4
study(title="Potato Signal", overlay=true)//, commission_type=strategy.commission.percent, commission_value=0.025, default_qty_type=strategy.cash, default_qty_value=10000, initial_capital=10000, slippage=0)

// === INPUT BACKTEST RANGE ===
// useDate = input(true, title='---------------- Use Date ----------------', type=input.bool)
// FromMonth = input(defval=7, title="From Month", minval=1, maxval=12)
// FromDay = input(defval=25, title="From Day", minval=1, maxval=31)
// FromYear = input(defval=2019, title="From Year", minval=2017)
// ToMonth = input(defval=1, title="To Month", minval=1, maxval=12)
// ToDay = input(defval=1, title="To Day", minval=1, maxval=31)
// ToYear = input(defval=9999, title="To Year", minval=2017)
// start = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
// finish = timestamp(ToYear, ToMonth, ToDay, 23, 59)  // backtest finish window
// window() =>  // create function "within window of time"
//     time >= start and time <= finish ? true : false
// === INPUT BACKTEST RANGE ===


sources = input(defval=close, title="Source")
isHA = input(false, "Use HA Candles", input.bool)
heikenashi_1 = heikinashi(syminfo.tickerid)
security_1 = security(heikenashi_1, timeframe.period, sources)
src = isHA ? security_1 : sources
// Sampling Period
// Settings for 5min chart, BTCUSDC. For Other coin, change the paremeters

per = input(defval=27, minval=1, title="Sampling Period")

// Range Multiplier

mult = input(defval=1.0, minval=0.1, title="Range Multiplier")

// Smooth Average Range

smoothrng(x, t, m) =>
    wper = t * 2 - 1
    avrng = ema(abs(x - x[1]), t)
    smoothrng = ema(avrng, wper) * m
    smoothrng
smrng = smoothrng(src, per, mult)

// Range Filter

rngfilt(x, r) =>
    rngfilt = x
    rngfilt := x > nz(rngfilt[1]) ? x - r < nz(rngfilt[1]) ? nz(rngfilt[1]) : x - r : 
       x + r > nz(rngfilt[1]) ? nz(rngfilt[1]) : x + r
    rngfilt
filt = rngfilt(src, smrng)

// Filter Direction

upward = 0.0
upward := filt > filt[1] ? nz(upward[1]) + 1 : filt < filt[1] ? 0 : nz(upward[1])
downward = 0.0
downward := filt < filt[1] ? nz(downward[1]) + 1 : filt > filt[1] ? 0 : nz(downward[1])

// Target Bands

hband = filt + smrng
lband = filt - smrng

// Colors

filtcolor = upward > 0 ? color.lime : downward > 0 ? color.red : color.orange
barcolor = src > filt and src > src[1] and upward > 0 ? color.lime : 
   src > filt and src < src[1] and upward > 0 ? color.green : 
   src < filt and src < src[1] and downward > 0 ? color.red : 
   src < filt and src > src[1] and downward > 0 ? color.maroon : color.orange

//filtplot = plot(filt, color=filtcolor, linewidth=3, title="Range Filter")

// Target

hbandplot = plot(hband, color=color.aqua, transp=100, title="High Target")
lbandplot = plot(lband, color=color.fuchsia, transp=100, title="Low Target")

// Fills

//fill(hbandplot, filtplot, color=color.aqua, title="High Target Range")
//fill(lbandplot, filtplot, color=color.fuchsia, title="Low Target Range")

// Bar Color

//barcolor(barcolor)

// Break Outs 

longCond = bool(na)
shortCond = bool(na)
longCond := src > filt and src > src[1] and upward > 0 or 
   src > filt and src < src[1] and upward > 0
shortCond := src < filt and src < src[1] and downward > 0 or 
   src < filt and src > src[1] and downward > 0

CondIni = 0
CondIni := longCond ? 1 : shortCond ? -1 : CondIni[1]
longCondition = longCond and CondIni[1] == -1
shortCondition = shortCond and CondIni[1] == 1

//Alerts

plotshape(longCondition, title="Buy Signal", text="buy🚀", textcolor=color.white, style=shape.labelup, size=size.small, location=location.belowbar, color=color.green, transp=0)
plotshape(shortCondition, title="Sell Signal", text="sell⚠️️", textcolor=color.white, style=shape.labeldown, size=size.small, location=location.abovebar, color=color.red, transp=0)

alertcondition(longCondition, title="Alert: Buy", message="Buy Signal")
alertcondition(shortCondition, title="Alert: Sell", message="Sell Signal")

//strategy.entry("Long", strategy.long, stop = hband, when = window() , comment="Long")
//strategy.entry("Short", strategy.short, stop = lband, when = window() , comment="Short")

// strategy.entry("Long", strategy.long, when=longCondition and window(), comment="Long")
// strategy.entry("Short", strategy.short, when=shortCondition and window(), comment="Short")



// // === Stop LOSS ===
// useStopLoss = input(false, title='----- Use Stop Loss / Take profit -----', type=input.bool)
// sl_inp = input(100, title='Stop Loss %', type=input.float, step=0.25) / 100
// tp_inp = input(1.5, title='Take Profit %', type=input.float, step=0.25) / 100
// stop_level = strategy.position_avg_price * (1 - sl_inp)
// take_level = strategy.position_avg_price * (1 + tp_inp)
// stop_level_short = strategy.position_avg_price * (1 + sl_inp)
// take_level_short = strategy.position_avg_price * (1 - tp_inp)
// // === Stop LOSS ===

// if useStopLoss
//     strategy.exit("Stop Loss/Profit Long", "Long", stop=stop_level, limit=take_level)
//     strategy.exit("Stop Loss/Profit Short", "Short", stop=stop_level_short, limit=take_level_short)

//@version=3
study(shorttitle="MA_X", title="Moving Average Color Direction Detection ", overlay=true)

// === INPUTS

ma_type   = input(defval="EMA", title="MA Type: ", options=["SMA", "EMA", "WMA", "VWMA", "SMMA", "DEMA", "TEMA", "HullMA", "ZEMA", "TMA", "SSMA"])
ma_len    = input(defval=21, title="MA Lenght", minval=1)
ma_src    = input(close, title="MA Source")
reaction  = input(defval=3, title="MA Reaction", minval=1)

// SuperSmoother filter
// © 2013  John F. Ehlers
variant_supersmoother(src,len) =>
    a1 = exp(-1.414*3.14159 / len)
    b1 = 2*a1*cos(1.414*3.14159 / len)
    c2 = b1
    c3 = (-a1)*a1
    c1 = 1 - c2 - c3
    v9 = 0.0
    v9 := c1*(src + nz(src[1])) / 2 + c2*nz(v9[1]) + c3*nz(v9[2])
    v9
    
variant_smoothed(src,len) =>
    v5 = 0.0
    v5 := na(v5[1]) ? sma(src, len) : (v5[1] * (len - 1) + src) / len
    v5

variant_zerolagema(src,len) =>
    ema1 = ema(src, len)
    ema2 = ema(ema1, len)
    v10 = ema1+(ema1-ema2)
    v10
    
variant_doubleema(src,len) =>
    v2 = ema(src, len)
    v6 = 2 * v2 - ema(v2, len)
    v6

variant_tripleema(src,len) =>
    v2 = ema(src, len)
    v7 = 3 * (v2 - ema(v2, len)) + ema(ema(v2, len), len)              
    v7
    
variant(type, src, len) =>
    type=="EMA"     ? ema(src,len) : 
      type=="WMA"   ? wma(src,len): 
      type=="VWMA"  ? vwma(src,len) : 
      type=="SMMA"  ? variant_smoothed(src,len) : 
      type=="DEMA"  ? variant_doubleema(src,len): 
      type=="TEMA"  ? variant_tripleema(src,len): 
      type=="HullMA"? wma(2 * wma(src, len / 2) - wma(src, len), round(sqrt(len))) :
      type=="SSMA"  ? variant_supersmoother(src,len) : 
      type=="ZEMA"  ? variant_zerolagema(src,len) : 
      type=="TMA"   ? sma(sma(src,len),len) : sma(src,len)


// === Moving Average
ma_series = variant(ma_type,ma_src,ma_len)

direction = 0
direction := rising(ma_series,reaction) ? 1 : falling(ma_series,reaction) ? -1 : nz(direction[1])
change_direction= change(direction,1)

pcol = direction>0 ? lime : direction<0 ? red : na
plot(ma_series, color=pcol,style=line,join=true,linewidth=3,transp=10,title="MA PLOT")

/////// Alerts ///////

alertcondition(change_direction,title="Change Direction MA",message="Change Direction MA")


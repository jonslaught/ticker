# General info about stocks

@Stocks = new Meteor.Collection('stocks',
  transform: (doc) ->
    s = new Stock(doc)
    return s
)

if Meteor.isServer
  Stocks._ensureIndex({symbol: 1})
  
class @Stock
  constructor: (doc) ->
     _.extend(@,doc)

  @lookup: (symbol) -> Stocks.findOne({symbol: symbol})

  @lastTradingDay: (time = do defaultTime) ->

    if time.isWeekday()
      return @tradingDay(time)
    else
      return @lastTradingDay daysBefore(time,1)

  # Todo: timezones. guh.
  @tradingDay: (time = do defaultTime) ->
    trading_day = Date.create(time)
    trading_day.setHours(0,0,0,0)
    return trading_day

  @tradingOpen: (time = do defaultTime) ->
    trading_open = Date.create(@tradingDay(time))
    trading_open.setHours(9-3,30,0,0)
    return trading_open

  @tradingClose: (time = do defaultTime) ->
    trading_close = Date.create(@tradingDay(time))
    trading_close.setHours(12+4-3,0,0,0)  
    return trading_close

  @tradingActive: (time = do defaultTime) ->
    time.isBetween(@tradingOpen(time),@tradingClose(time)) and time.isWeekday()

  @tradingDays: (start, end) ->

    days = []
    t = start
    while t < end
      open = @tradingOpen t
      close = @tradingClose t
      days.push([open,close])
      t = daysAfter(t,1)

    return days
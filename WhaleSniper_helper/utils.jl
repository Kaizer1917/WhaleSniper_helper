using Binance

const MOONY = "moony"
const REKT = "rekt"
const NEUT = "neut"
const TREND = "trend"
const OLD_UNIX = "OldUnix"
const NEW_UNIX = "NewUnix"
const VOLUME = "Amount"
const MAIN_MARKET = "MainMarket"
const COIN_NAME = "CoinName"
const NEW_VOL = "NewVol"
const VOL_DIFF = "VolDiff"
const MARKET_NAME = "MarketName"
const ID = "id"

function get_binance_price(symbol)
    client = Binance.Client()
    return parse(Float64, Binance.get_symbol_ticker(client, symbol)["price"])
end


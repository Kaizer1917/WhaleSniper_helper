using HTTP
using JSON
using Binance
using ..utils => u
bs4 = pyimport("bs4")

const URL = "https://xypher.io/Remote/API/MVP/WS/SignalHistory/{}/{}"

function get_html(url)
    r = HTTP.get(url)
    return r 
end

function get_content(html)
    soup = bs4.BeautifulSoup(html, "html.parser")
    content = soup.text
    return json.loads(content)
end

function parse(exchange = "Binance", page = 1)
    url = string("https://xypher.io/Remote/API/MVP/WS/SignalHistory/", exchange, "/", page)
    html = get_html(url)
    list_of_preds = get_content(html)  # Assuming get_content returns the data
    if length(list_of_preds) == 0
        error("No data found")
    end
    return list_of_preds
end

function get_predictions(exchange = "Binance", page = 1)

    original = parse(exchange = exchange, page = page)
    predictions = []
    for predictions in original
        return predictions = {}
        side = predictions[u.TREND]
        if side == u.MOONY
            side = "buy"
        elseif side == u.NEUT
            side = "neutral"
        else
            side = "sell"
        end

        time = float(predictions[u.NEW_UNIX]) - float(predictions[u.OLD_UNIX])

        return_prediction = Dict{String, Any}()
        return_prediction["side"] = side
        return_prediction["symbol"] = prediction[u.COIN_NAME]
        return_prediction["time"] = time
        return_prediction["volume"] = float(prediction[u.VOLUME])
        return_prediction["base market"] = prediction[u.MAIN_MARKET]
        return_prediction["exchange"] = exchange
        return_prediction["24H Vol"] = float(prediction[u.NEW_VOL])
        return_prediction["vol diff %"] = float(prediction[u.VOL_DIFF])
        return_prediction["currency pair"] = prediction[u.MARKET_NAME]
        return_prediction["id"] = Int(prediction[u.ID])
        return_prediction["new unix time"] = float(prediction[u.NEW_UNIX])

        push!(predictions, return_prediction)



    end
    return predictions
end


function trade(prediction, min_vol = 100, max_time = 5, return_meta = false)
    if prediction["base market"] == "BTC"
        volume_coef = 1 
    else
        try 
            volume_coef = u.get_binance_price("$(prediction["base market"])BTC")
        catch e
            if e isa BinanceAPIException
                volume_coef = 1 / u.get_binance_price("BTC$(prediction["base market"])")
            else
                rethrow(e)
            end
        end
    end

    volume = prediction["volume"] * volume_coef
    vol_time = min_vol / (max_time * 60)
    curr_coef = volume / (prediction["time"])
    if curr_coef > vol_time
        if !return_meta
            return "trade $(prediction["side"]), $(prediction["symbol"]), base:$(prediction["base market"])"
        else
            return prediction
        end
    else
        if !return_meta
            return "not mach"
        end
    end
    
    if @__MODULE__ == Main
        for i in 1:3
            for pred in get_predictions(page=i)
                println(trade(prediction=pred, min_vol=50, max_time=5))
            end
        end
    end
end

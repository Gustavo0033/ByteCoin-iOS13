//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate{
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

//MARK: - apiKey and url from the coinAPI
struct CoinManager {
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "E4414CA8-B8F4-4138-94F4-E7F7E1E6F3FA"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    

    //MARK: - Creating the url from the currency choosed
    
    func getCoinPrice(for currency: String){
        
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let bitcoinPrice = self.parseJSON(safeData){
                        
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    
                    }
                }
            }
            task.resume()
        }
    }
    
    
    //MARK: - get the currency price as lastPrice
    func parseJSON(_ data: Data) -> Double? {
        let decode = JSONDecoder()
        do{
            let decodedDate = try decode.decode(CoinData.self, from: data)
            let lastPrice = decodedDate.rate
            print(lastPrice)
            return lastPrice
            
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}


//
//  Network.swift
//  translate
//
//  Created by Pavel Driver on 09.09.2018.
//  Copyright © 2018 Pavel Driver. All rights reserved.
//

import Foundation

func sendResponseGET(_ url: String, server: String, parameters: [String: String], completion: @escaping ([String: Any]?, Error?) -> Void){
    var components = URLComponents(string: server)!
    components.queryItems = parameters.map { (key, value) in
        URLQueryItem(name: key, value: value)
    }
    components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    let request = URLRequest(url: components.url!)
    
    let session = URLSession.shared
    session.dataTask(with: request){(data, response, error) in
        
        guard let data = data,
            let response = response as? HTTPURLResponse,
            (200 ..< 300) ~= response.statusCode,
            error == nil else {
                completion(nil, error)
                return
        }
        
        let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        completion(responseObject, nil)
        }.resume()
}

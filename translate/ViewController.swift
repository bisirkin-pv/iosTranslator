//
//  ViewController.swift
//  translate
//
//  Created by Pavel Driver on 08.09.2018.
//  Copyright © 2018 Pavel Driver. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let translateServer = "https://prog-tools.ru:8445/translator/rest/translate/v1"
    
    struct responseJson: Codable {
        var info : String
        var text : String
    }
    
    @IBOutlet weak var inputWord: UITextField!
    @IBOutlet weak var outputWords: UITextView!
    
    @IBAction func sendTranslateENG(_ sender: Any) {
        if inputWord!.text! == ""{
            return
        }
        let parameters = ["engine": "yandex", "lang": "ru-en", "text": inputWord!.text!]
        
        sendResponseGET(translateServer, parameters: parameters) { responseObject, error in
            guard let responseObject = responseObject, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            
            if let text = responseObject["text"] as? String {
                DispatchQueue.main.async {
                    self.outputWords!.text = self.outputWords!.text + "\n(RU)  \(self.inputWord!.text!) -> (ENG) \(text)"
                    self.inputWord!.text?.removeAll()
                }
            }
        }
    }
    
    @IBAction func sendTranslateRU(_ sender: Any) {
        if inputWord!.text! == ""{
            return
        }
        let parameters = ["engine": "yandex", "lang": "en-ru", "text": inputWord!.text!]
        sendResponseGET(translateServer, parameters: parameters) { responseObject, error in
            guard let responseObject = responseObject, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            
            if let text = responseObject["text"] as? String {
                DispatchQueue.main.async {
                    self.outputWords!.text = self.outputWords!.text + "\n(ENG) \(self.inputWord!.text!) -> (RU) \(text)"
                    self.inputWord!.text?.removeAll()
                }
            }
        }
    }
    
    func sendResponseGET(_ url: String, parameters: [String: String], completion: @escaping ([String: Any]?, Error?) -> Void){
        var components = URLComponents(string: translateServer)!
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
    
}


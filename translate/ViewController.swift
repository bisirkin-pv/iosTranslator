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
    
    @IBOutlet weak var inputWord: UITextField!
    @IBOutlet weak var outputWords: UITextView!
    @IBAction func send(_ sender: UIButton) {
        print("yes")
        if inputWord!.text! == ""{
            return
        }
        // проверяем на наличие английских букв
        let hashtags = inputWord!.text!.checkLang(pattern: "[a-zA-Z]+")
        let lang = hashtags.count > 0 ? "en-ru" : "ru-en"
        let parameters = ["engine": "yandex", "lang": lang, "text": inputWord!.text!]
        sendResponseGET(translateServer, server: translateServer, parameters: parameters) { responseObject, error in
            guard let responseObject = responseObject, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            
            if let text = responseObject["text"] as? String {
                DispatchQueue.main.async {
                    let strFrom = lang == "en-ru" ? "(ENG) " : "(RU) "
                    let strTo = lang == "en-ru" ? "(RU)  " : "(ENG) "
                    let outText = strFrom + "\(self.inputWord!.text!) -> " + strTo + " \(text)"
                    self.outputWords!.text = self.outputWords!.text + "\n" + outText
                    self.inputWord!.text?.removeAll()
                }
            }
        }
    }
}


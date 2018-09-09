//
//  ViewController.swift
//  translate
//
//  Created by Pavel Driver on 08.09.2018.
//  Copyright © 2018 Pavel Driver. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let translateServer = "https://prog-tools.ru:8445/translator/rest/translate/v1"
    
    struct Translate: Codable {
        var from: String
        var to: String
        var was: String
        var has: String
    }
    var arrayWords: [Translate] = []
    
    @IBOutlet weak var tbTableList: UITableView!
    @IBOutlet weak var inputWord: UITextField!
    
    override func viewDidLoad() {
        tbTableList.dataSource = self
        tbTableList.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrayWords.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "listWord")
        let wordLine = cell?.contentView.viewWithTag(101) as! UILabel
        let translate = arrayWords[indexPath.row]
        let outText = "\(translate.from)\(translate.was) -> \(translate.to) \(translate.has)"
        wordLine.text = outText
        return cell!
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
    //@IBOutlet weak var outputWords: UITextView!
    @IBAction func send(_ sender: UIButton) {
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
                    let strFrom = lang == "en-ru" ? "🇺🇸 " : "🇷🇺"
                    let strTo = lang == "en-ru" ? "🇷🇺" : "🇺🇸"
                    let translate = Translate(from: strFrom, to: strTo, was: self.inputWord!.text!, has: text)
                    self.arrayWords.append(translate)
                    self.inputWord!.text?.removeAll()
                    self.tbTableList.reloadData()
                }
            }
        }
    }
}


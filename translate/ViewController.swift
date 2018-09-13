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
        let wordWas = cell?.contentView.viewWithTag(101) as! UILabel
        let wordHas = cell?.contentView.viewWithTag(102) as! UILabel
        let translate = arrayWords[indexPath.row]
        wordHas.text = "\(translate.to): \(translate.has)"
        wordWas.text = "\(translate.from): \(translate.was)"
        return cell!
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.arrayWords.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
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
                    let strFrom = lang == "en-ru" ? "ENG" : "RU"
                    let strTo = lang == "en-ru" ? "RU" : "ENG"
                    let translate = Translate(from: strFrom, to: strTo, was: self.inputWord!.text!, has: text)
                    self.arrayWords.append(translate)
                    self.inputWord!.text?.removeAll()
                    self.tbTableList.reloadData()
                }
            }
        }
    }
}


//
//  ViewController.swift
//  translate
//
//  Created by Pavel Driver on 08.09.2018.
//  Copyright © 2018 Pavel Driver. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let translateServer = "https://prog-tools.ru:8445/translator/rest/translate/v1"
    
    struct Translate: Codable {
        var from: String    //с какого языка переводим
        var to: String      //на какой язык переводим
        var was: String     //исходное слово
        var has: String     //перевод
    }
    var arrayWords: [Translate] = []
    
    @IBOutlet weak var tbTableList: UITableView!
    @IBOutlet weak var inputWord: UITextField!
    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        tbTableList.dataSource = self
        tbTableList.delegate = self
        inputWord.delegate = self
        mainView.addTapGestureToHideKeyboard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrayWords.count
    }
    
    //Отображение ячейки
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
    
    //Удаляем запись в таблице по свайпу
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.arrayWords.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //скрываем клавиатуру по нажатию  Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendResponse()
        return true
    }
    
    //Кнопка "Перевести"
    @IBAction func send(_ sender: Any) {
        sendResponse()
    }
    
    //Функция получения перевода
    func sendResponse(){
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

extension UIView {
    
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tapGesture)
    }
    
    var topSuperview: UIView? {
        var view = superview
        while view?.superview != nil {
            view = view!.superview
        }
        return view
    }
    
    @objc func dismissKeyboard() {
        topSuperview?.endEditing(true)
    }
}


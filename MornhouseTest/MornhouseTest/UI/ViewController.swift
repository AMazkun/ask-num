//
//  ViewController.swift
//  MornhouseTest
//
//  Created by admin on 25.10.2022.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    let realm = try! Realm()
    lazy var responses: Results<Response> = { self.realm.objects(Response.self) }()
    var selectedResponse: Response? = nil

    @IBOutlet weak var responseTable: UITableView!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var numInput: UITextField!
    @IBOutlet weak var askBtn: UIButton!
    @IBOutlet weak var randonBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        responseTable.delegate = self
        responseTable.dataSource = self
        responseTable.rowHeight = UITableView.automaticDimension

        responses = realm.objects(Response.self)
        responseTable.reloadData()
        self.navigationItem.rightBarButtonItem = editButtonItem
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the button's title.
        super.setEditing(editing, animated: true)

        // Toggle table view editing.
        responseTable.setEditing(editing, animated: true)
        askBtn.isEnabled = !editing
        randonBtn.isEnabled = !editing
    }

    func getResponse (_ url : URL) {
        msgLabel.text = ""
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                interfaceUpdate(action: {self.msgLabel.text = (error ?? URLError(.badServerResponse)).localizedDescription })
                return
            }
            interfaceUpdate(action: {
                self.storeRespones(String(data: data, encoding: .utf8)!)
            })
        }
        task.resume()
    }
    
    func storeRespones(_ msg: String) {
        let splitedAnswer = msg.split(separator: " ", maxSplits: 1)
        if splitedAnswer.count > 1 {
            let num = splitedAnswer[0].trimmingCharacters(in: [" ", "\t"])
            let answer = splitedAnswer[1].trimmingCharacters(in: [" ", "\t"])
            try! realm.write {
                let newResponse = Response()
                newResponse.num = num
                newResponse.answer = answer
                realm.add(newResponse)
            }
            responseTable.reloadData()
            let newIndexPath = IndexPath(row: responses.count - 1, section: 0)
            responseTable.selectRow(at: newIndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.bottom)
        }
    }
    
    @IBAction func GetNumResponse(_ sender: Any) {
        guard let s = numInput.text,
              let num = Int(s.trimmingCharacters(in: [" ", "\t"])) else {
            msgLabel.text = "Shirt entered"
            return
        }
        let url = URL(string: "http://numbersapi.com/\(num)")!
        getResponse(url)
    }
    
    @IBAction func GetRandomResponese(_ sender: Any) {
        let url = URL(string: "http://numbersapi.com/random/math")!
        getResponse(url)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail", let detailView = segue.destination as? DetailView {
            detailView.selectedResponse = responses[responseTable.indexPathForSelectedRow!.row]
            return
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogCell
    
        let responses = responses[indexPath.row]
        cell.numLabel?.text = responses.num
        cell.answerLabel?.text = responses.answer

        return cell
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responses.count
    }
  
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
         {
            try! realm.write {
                realm.delete(responses[indexPath.row])
            }
            tableView.reloadData()
         }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        //selectedResponse = responses[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: tableView)
    }
}

func interfaceUpdate(action: @escaping () -> Void) {
        DispatchQueue.main.async {
            // Run UI Updates
            action()
        }
}

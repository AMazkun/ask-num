//
//  DetailView.swift
//  MornhouseTest
//
//  Created by admin on 26.10.2022.
//

import UIKit

class DetailView: UIViewController {
    var selectedResponse : Response? = nil

    @IBOutlet weak var answerText: UITextView!
    @IBOutlet weak var numLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedResponse != nil {
            numLbl.text = selectedResponse!.num
            answerText.text = selectedResponse!.answer
        }

    }
    }

//
//  ViewController.swift
//  CustomInputView
//
//  Created by iOS on 2018/5/24.
//  Copyright © 2018年 weiman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var inputButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        inputButton.layer.borderColor = UIColor.hex("eeeeee", alpha: 1.0).cgColor
        inputButton.layer.borderWidth = 1
        inputButton.layer.cornerRadius = 20
        inputButton.layer.masksToBounds = true
    }

    @IBAction func inputButtonAction(_ sender: UIButton) {
        
        let view = CustomInputView.instance(superView: self.view)
        view?.delegate = self
        
    }
    
}

extension ViewController: CustomInputViewDelegate {
    
    func send(text: String) {
        print("-----待发送的文字-------- ")
        print(" \(text)")
    }
}




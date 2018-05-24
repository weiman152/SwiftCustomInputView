# SwiftCustomInputView
swift4.0，弹出键盘，输入文字，评论功能的封装

使用方法：

@IBAction func inputButtonAction(_ sender: UIButton) {
        
        let view = CustomInputView.instance(superView: self.view)
        view?.delegate = self
        
    }
    
    

//
//  CustomInputView.swift
//  CustomInputView
//
//  Created by iOS on 2018/5/24.
//  Copyright © 2018年 weiman. All rights reserved.
//

import UIKit

protocol CustomInputViewDelegate: NSObjectProtocol {
    /// 发送
    func send(text: String)
}

class CustomInputView: UIView {
    
    weak var delegate: CustomInputViewDelegate?
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    
    /// 最大限制字数，默认是100
    private var maxWords: Int = 300
    /// 在textview不滚动的情况下，允许输入的最大行数，超过这个行数，就进行滚动
    private var maxRows: Int = 6
    private var oneLineHeight: CGFloat = 0
    private var origialHeight: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        setupLayout()
        setupNotification()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupLayout()
        setupNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        backgroundColor = UIColor(white: 0.5, alpha: 0.3)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.hex("eeeeee").cgColor
        textView.layer.cornerRadius = 20
        textView.layer.masksToBounds = true
        
        textView.delegate = self
        textView.becomeFirstResponder()
        // 这句话让光标不会因为圆角而被遮挡一块
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
        
        origialHeight = bottomViewHeight.constant
    }
    
    private func setupLayout() {
        
    }
    
    /// 通知
    private func setupNotification() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange),
            name: .UIKeyboardWillChangeFrame,
            object: nil
        )
    }
    
}

/// 公有方法
extension CustomInputView {
    
    /// 初始化
    class func instance(superView: UIView) -> CustomInputView? {
        let view = Bundle.main.loadNibNamed("CustomInputView", owner: nil, options: nil)?.last
        guard let customView = view as? CustomInputView else {
            return nil
        }
        superView.addSubview(customView)
        customView.frame = superView.bounds
        return customView
    }
    
    /// 消失
    func dismiss() {
       removeFromSuperview()
    }
    
    /// 设置背景颜色和透明度
    func set(backgroundColor: String, alpha: CGFloat = 1.0) {
        self.backgroundColor = .hex(backgroundColor, alpha: alpha)
    }
    
    /// 最大字数限制
    func set(max: Int) {
       self.maxWords = max
    }
    
    /// 在textview不滚动的情况下，允许输入的最大行数，超过这个行数，就进行滚动
    /// 注意，不是最多输入的行数
    func set(maxRows: Int) {
        self.maxRows = maxRows
    }
    
}

/// 私有方法
extension CustomInputView {
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        delegate?.send(text: textView.text)
    }
    
    @objc private func keyboardWillChange(_ notify: Notification) {
        guard let userInfo = notify.userInfo else {
            return
        }
        guard
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as?TimeInterval,
            let curveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int,
            let curve = UIViewAnimationCurve(rawValue: curveRaw),
            let endRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }
        
        handleKeyBoardFrame(duration: duration, curve: curve, endRect: endRect)
    }
    
    private func handleKeyBoardFrame(duration: TimeInterval,
                                     curve: UIViewAnimationCurve,
                                     endRect: CGRect) {
        // 注意：endRect在第三方键盘上获取的时候会先后出现两个高度，所以设置高度的时候，不要把下面这句话放在动画里面执行，不然的话，第三方键盘会抖一下
        self.bottomViewBottom.constant = endRect.height
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { (_) in
            
        }
    }
    
    private func handleBottomHeight(currentHeight: CGFloat, maxHeight: CGFloat) {
        // 一行的高度
        if oneLineHeight == 0 {
            oneLineHeight = currentHeight
        }
        if currentHeight <= oneLineHeight {
            bottomViewHeight.constant = origialHeight
        } else {
            if CGFloat(currentHeight) < maxHeight {
                bottomViewHeight.constant = CGFloat(currentHeight)
            } else {
                bottomViewHeight.constant = maxHeight
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    private func handleTextHeight(textView: UITextView) {
        // 一行的高度（居然还有这种方法，涨知识）
        guard let lineHeight = textView.font?.lineHeight else {
            return
        }
        
        // ceilf:向上取整
        let textMaxHeight = ceilf(Float(lineHeight) * Float(maxRows))
        // 最大高度,别忘了上下间距
        let maxHeight: CGFloat = CGFloat(textMaxHeight) + extraSize().paddingTop + extraSize().paddingBottom + extraSize().marginTop + extraSize().marginBottom
        let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat(MAXFLOAT)))
        let currentHeight = CGFloat(ceilf(Float(size.height))) + extraSize().paddingTop + extraSize().paddingBottom + extraSize().marginTop + extraSize().marginBottom
        
        handleBottomHeight(currentHeight: currentHeight, maxHeight: maxHeight)
        
    }
    
    private func extraSize() -> (paddingTop: CGFloat, paddingBottom: CGFloat, marginTop: CGFloat, marginBottom: CGFloat) {
        let textTop: CGFloat = textView.textContainerInset.top
        let textBottom: CGFloat = textView.textContainerInset.bottom
        let textViewTop: CGFloat = 10
        let textViewBottom: CGFloat = 10
        
        return (textTop,textBottom,textViewTop,textViewBottom)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss()
    }
}

/// 代理方法
extension CustomInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // 判断输入是否超出规定长度
        if let text = textView.text, text.count >= maxWords {
            let result = text.prefix(maxWords)
            textView.text = String(result)
            return
        }
        
        if textView.text.count > 0 {
            sendButton.isSelected = true
        } else {
            sendButton.isSelected = false
        }
        
        // 计算当前textview内容的高度，动态改变textview以及父view的高度
        handleTextHeight(textView: textView)
    }
}

/// UIColor的扩展
extension UIColor {
    
    static func hex(_ string: String, alpha: CGFloat = 1.0) -> UIColor {
        let scanner = Scanner(string: string)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0x00ff00) >> 8
        let b = (rgbValue & 0x0000ff)
        if #available(iOS 10.0, *) {
            return UIColor(
                displayP3Red: CGFloat(r) / 0xff,
                green: CGFloat(g) / 0xff,
                blue: CGFloat(b) / 0xff,
                alpha: alpha
            )
        } else {
            return UIColor(
                red: CGFloat(r) / 0xff,
                green: CGFloat(g) / 0xff,
                blue: CGFloat(b) / 0xff,
                alpha: alpha
            )
        }
    }
}






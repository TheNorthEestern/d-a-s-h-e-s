//
//  CLTypingLabel.swift
//  CLTypingLabel
//  The MIT License (MIT)
//  Copyright © 2016 Chenglin 2/21/16.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files
//  (the “Software”), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

/*
 Set text at runtime to trigger type animation;
 
 Set charInterval property for interval time between each character, default is 0.1;
 
 Call pauseTyping() to pause animation;
 
 Call conitinueTyping() to continue paused animation;
 */

enum CLTypingLabelKind {
    case text
    case attributedText
}

@IBDesignable open class CLTypingLabel: UILabel {
    /*
     Set interval time between each characters
     */
    @IBInspectable open var charInterval: Double = 0.1
    
    /*
     SizeToFit label after each character
     */
    @IBInspectable open var centerText: Bool = true
    
    fileprivate var currentTypingID: Int = 0
    fileprivate var kind: CLTypingLabelKind = .text
    fileprivate var typingStopped: Bool = false
    fileprivate var typingOver: Bool = true
    fileprivate var stoppedSubstring: String = ""
    fileprivate var attributes: [NSAttributedStringKey: Any]?
    
    override open var text: String! {
        get {
            return super.text
        }
        
        set {
            if charInterval < 0 {
                charInterval = -charInterval
            }
            
            currentTypingID += 1
            typingStopped = false
            typingOver = false
            stoppedSubstring = ""
            
            let val = newValue ?? ""
            setTextWithTypingAnimation(val, charInterval, true, {
                (stoppedSubString) -> String in
                return StringManipulator.dashify(stoppedSubString)
            })
            
            kind = .text
        }
    }
    
    override open var attributedText: NSAttributedString! {
        get {
            return super.attributedText
        }
        
        set {
            if charInterval < 0 {
                charInterval = -charInterval
            }
            
            currentTypingID += 1
            typingStopped = false
            typingOver = false
            stoppedSubstring = ""
            
            let val = newValue ?? NSAttributedString()
            attributes = newValue.attributes(at: 0, effectiveRange: nil)
            setAttributedTextWithTypingAnimation(val, charInterval, true, attributes!)
            
            kind = .attributedText
        }
    }
    
    open func performCompletionAction() {
        super.text = StringManipulator.dashify(self.text)
    }
    
    // MARK: -
    // MARK: Stop Typing Animation
    
    open func pauseTyping() {
        typingStopped = true
    }
    
    // MARK: -
    // MARK: Continue Typing Animation
    
    open func continueTyping() {
        guard typingOver == false else {
            print("CLTypingLabel: Animation is already over")
            return
        }
        
        guard typingStopped == true else {
            print("CLTypingLabel: Animation is not stopped")
            return
        }
        
        typingStopped = false
        
        switch kind {
        case .text:
            setTextWithTypingAnimation(stoppedSubstring, charInterval, false, {
                (stoppedSubString) -> String in
                return StringManipulator.dashify(stoppedSubString)
            })
        case .attributedText:
            let stoppedAttributedText = NSAttributedString(string: self.stoppedSubstring, attributes: self.attributes)
            setAttributedTextWithTypingAnimation(stoppedAttributedText, charInterval, false, attributes!)
        }
    }
    
    // MARK: -
    // MARK: Set Text & Attributed Text
    
    fileprivate func setAttributedTextWithTypingAnimation(_ typedAttributedText: NSAttributedString, _ charInterval: TimeInterval, _ initial: Bool, _ attributes: Dictionary<NSAttributedStringKey, Any>) {
        if initial == true {
            super.attributedText = NSAttributedString()
        }
        
        let dispatchedTypingID = currentTypingID
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            for (index, char) in typedAttributedText.string.enumerated() {
                guard self.currentTypingID == dispatchedTypingID else {
                    return
                }
                
                guard self.typingStopped == false else {
                    let position = typedAttributedText.string.index(typedAttributedText.string.startIndex, offsetBy: index)
                  self.stoppedSubstring = String(typedAttributedText.string[position...])
                    return
                }
                
                DispatchQueue.main.async {
                    super.attributedText = NSAttributedString(string: super.attributedText!.string + String(char), attributes: attributes)
                    
                    if self.centerText == true {
                        self.sizeToFit()
                    }
                }
                
                Thread.sleep(forTimeInterval: charInterval)
            }
            
            self.typingOver = true
            self.typingStopped = false
        }
    }
    
    fileprivate func setTextWithTypingAnimation(_ typedText: String, _ charInterval: TimeInterval, _ initial: Bool, _ completion: @escaping (_ myText: String) -> String) {
        if initial == true {
            super.text = ""
        }
        
        let dispatchedTypingID = currentTypingID
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            for (index, char) in typedText.enumerated() {
                guard self.currentTypingID == dispatchedTypingID else {
                    return
                }
                
                guard self.typingStopped == false else {
                    let position = typedText.index(typedText.startIndex, offsetBy: index)
                    self.stoppedSubstring = String(typedText[position...])
                    return
                }
                
                DispatchQueue.main.async {
                    super.text = super.text! + String(char)
                    
                    if self.centerText == true {
                        self.sizeToFit()
                    }
                    
                    if index == typedText.count - 1 {
                        super.text = self.text
                        Thread.sleep(forTimeInterval: charInterval * 2)
                        super.text = completion(self.text.replacingOccurrences(of: " ", with: "")) + "!"
                    }
                }
                
                Thread.sleep(forTimeInterval: charInterval)
            }
            
            self.typingOver = true
            self.typingStopped = false
        }
    }
}

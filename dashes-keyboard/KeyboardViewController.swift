//
//  KeyboardViewController.swift
//  dashes-keyboard
//
//  Created by Kacy James on 1/22/17.
//  Copyright © 2017 Student Driver. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    let alphanumerics: CharacterSet = CharacterSet.alphanumerics
    var customInterface : UIView!
    var originalWord: String!
    var deleteButtonTimer: Timer?
    var previousTouchXPos: CGFloat = 0.0
    
    @IBOutlet weak var forceCursorView: UIStackView!
    @IBOutlet weak var mainKeyGroup: UIStackView!
    @IBOutlet weak var undoButton: CircularButton!
    @IBOutlet weak var deleteButton: CircularButton!
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet weak var dashifyButton: CircularButton!
    
    var t: String? {
        if let documentContext = textDocumentProxy.documentContextBeforeInput as String? {
            let length = documentContext.characters.count
            var components = [String]()
            if length > 0 {
                if (documentContext.containsAlphabets) {
                    components = documentContext.components(separatedBy: alphanumerics.union(CharacterSet.punctuationCharacters).inverted)
                }
                return (components.count > 0) ? components[components.endIndex - 1] : nil
            }
        }
        return nil
    }
    
    var lastWordTyped: String? {
        if let leftwardContext = textDocumentProxy.documentContextBeforeInput, let rightwardContext = textDocumentProxy.documentContextAfterInput {
            
            let leftwardLength = leftwardContext.characters.count
            let rightwardLength = rightwardContext.characters.count
            var leftwardComponents = [String]()
            var rightwardComponents = [String]()
            rightwardComponents = rightwardContext.components(separatedBy: alphanumerics.inverted)
            leftwardComponents = leftwardContext.components(separatedBy: alphanumerics.inverted)
            
//            if leftwardLength >= 0 && rightwardLength >= 0 {
//                if (leftwardContext.containsAlphabets && rightwardContext.containsAlphabets) {
//                    leftwardComponents = leftwardContext.components(separatedBy: alphanumerics.inverted)
//                    rightwardComponents = rightwardContext.components(separatedBy: alphanumerics.inverted)
//                    print ("elward", leftwardComponents, leftwardComponents[leftwardComponents.endIndex - 1])
//                    print ("arward", rightwardComponents, rightwardComponents[rightwardComponents.endIndex - 1])
//                    return leftwardComponents[leftwardComponents.endIndex - 1] + rightwardComponents[rightwardComponents.endIndex - 1]
//                }
//            }
            
            if rightwardLength >= 0 && !rightwardComponents[rightwardComponents.startIndex].isEmpty {
                if rightwardContext.containsAlphabets {
                    print (leftwardComponents, rightwardComponents, rightwardComponents[rightwardComponents.startIndex])
                    return rightwardComponents[rightwardComponents.startIndex]
                }
            } else {
                if leftwardContext.containsAlphabets {
                    print ("LEFT", rightwardComponents.count, leftwardComponents, rightwardComponents, leftwardComponents[leftwardComponents.startIndex])
                    return leftwardComponents[leftwardComponents.endIndex - 1]
                }
            }
            
            /* if leftwardLength >= 0 {
                if (leftwardContext.containsAlphabets || rightwardContext.containsAlphabets) {
                    
                    
                }
            } */
            
            
        }
        return nil
    }
    
    @IBAction func sendText(_ sender: Any) {
        let tdp = (textDocumentProxy as UIKeyInput)
        if let originalWord = lastWordTyped {
            self.originalWord = lastWordTyped
            for _ in (lastWordTyped?.characters.indices)! {
                tdp.deleteBackward()
            }
            tdp.insertText("\(StringManipulator.dashify(originalWord)) ")
            undoButton.layer.opacity = 1.0
            undoButton.isEnabled = true
        }
    }
    
    @IBAction func undoDashify(_ sender: Any) {
        for _ in 0..<((originalWord?.characters.count)! * 2) {
            textDocumentProxy.deleteBackward()
        }
        (textDocumentProxy as UIKeyInput).insertText("\(originalWord!)")
        undoButton.layer.opacity = 0.5
        undoButton.isEnabled = false
    }
    
    @IBAction func deleteText(timer: Timer) {
        if let word = originalWord {
            if (userHasBegunDeleting(the: word)) {
                configureUndoButton()
            }
        }
        textDocumentProxy.deleteBackward()
        updatePreview()
    }
}

extension KeyboardViewController {
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("called view did appear")
        updatePreview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("called view did load")
        let nib = UINib(nibName: "IdealKeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        
        view = objects[0] as? UIView
        
        configureDashifyButton()
        configureUndoButton()
        configureDeleteButton()
      
        
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
        updatePreview()
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        updatePreview()
        nextKeyboardButton.setTitleColor(UIColor.black, for: [])
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let t = touch.location(in: self.view)
            
            if #available(iOS 9.0, *) {
                if traitCollection.forceTouchCapability == .available {
                    // let force = touch.force / touch.maximumPossibleForce
                    if touch.force >= (touch.maximumPossibleForce / 2) {
                        mainKeyGroup.isHidden = true
                        forceCursorView.isHidden = false
                        let increase = t.x - previousTouchXPos
                        let percentIncrease = increase / (previousTouchXPos * 100)
                        print(percentIncrease)
                        if let lwt = lastWordTyped {
                            print(lwt)
                        }
                        if percentIncrease < -0.0002 {
                            previousTouchXPos = t.x
                            Thread.sleep(forTimeInterval: 0.065)
                            print ("num chars \(lastWordTyped?.characters.count)")
                            textDocumentProxy.adjustTextPosition(byCharacterOffset: -1)
                        }
                        if percentIncrease > 0.0002 {
                            previousTouchXPos = t.x
                            Thread.sleep(forTimeInterval: 0.065)
                            print ("num chars \(lastWordTyped?.characters.count)")
                            textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
                        }
                    } else {
                        mainKeyGroup.isHidden = false
                        forceCursorView.isHidden = true
                    }
                }
            }
        }
    }
    
    func userHasBegunDeleting(the modifiedWord: String) -> Bool {
        return StringManipulator.dashify(modifiedWord) == lastWordTyped!
    }
    
    func configureDeleteButton() {
        let deleteButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(KeyboardViewController.deleteText))
        deleteButtonLongPressGestureRecognizer.minimumPressDuration = 0.5
        deleteButtonLongPressGestureRecognizer.numberOfTouchesRequired = 1
        deleteButtonLongPressGestureRecognizer.allowableMovement = 75
        deleteButton.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
    }
    
    func configureUndoButton() {
        undoButton.isEnabled = false
        undoButton.layer.opacity = 0.5
    }
    
    func configureDashifyButton() {
        dashifyButton.titleLabel?.numberOfLines = 1
        dashifyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dashifyButton.titleLabel?.lineBreakMode = .byClipping
    }
    
    func updatePreview() {
        if let word = lastWordTyped, !(word.containsPunctuation) {
                dashifyButton.isEnabled = true
                dashifyButton.setTitle("☞ \(StringManipulator.dashify(word))", for: .normal)
        } else {
            dashifyButton.setTitle("⬆︎ select a word ⬆︎", for: .normal)
            dashifyButton.isEnabled = false
            // dashifyButton.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
}

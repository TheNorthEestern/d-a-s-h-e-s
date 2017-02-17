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
    var deleteButtonTimer: Timer?
    var previousTouchXPos: CGFloat = 0.0
    // The distance the cursor must travel before it can successfully dashify a word.
    var jumpDistance: Int!
    
    
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
            
            let leftwardComponents = leftwardContext.components(separatedBy: alphanumerics.inverted)
            let rightwardComponents = rightwardContext.components(separatedBy: alphanumerics.inverted)
            let fore = leftwardComponents[leftwardComponents.endIndex - 1]
            let aft = rightwardComponents[rightwardComponents.startIndex]
            
            // If space after cursor isn't empty and space before it is -> <cursor>dashes
            if !aft.isEmpty && fore.isEmpty {
                if rightwardContext.containsAlphabets {
                    jumpDistance = aft.characters.count
                    return rightwardComponents[rightwardComponents.startIndex]
                }
            }
            // If space before cursor isn't empty and space after it is -> dashes<cursor>
            if !fore.isEmpty && aft.isEmpty {
                if leftwardContext.containsAlphabets {
                    jumpDistance = 0
                    return leftwardComponents[leftwardComponents.endIndex - 1]
                }
            }
            // If space before the cursor isn't empty and space after the cursor isn't empty -> da<cursor>shes
            if !fore.isEmpty && !aft.isEmpty {
                jumpDistance = aft.characters.count
                return leftwardComponents[leftwardComponents.endIndex - 1] + rightwardComponents[rightwardComponents.startIndex]
            }
            // If space before the cursor is empty and space after the cursor is empty -> unlimited <cursor> power
            if fore.isEmpty && aft.isEmpty {
                return nil
            }
        }
        // If cursor is at the beginning of the input field. -> <field><cursor>dashes</field>
        else if let leftwardContext = textDocumentProxy.documentContextBeforeInput {
            let leftwardComponents = leftwardContext.components(separatedBy: alphanumerics.inverted)
            jumpDistance = 0
            return leftwardComponents[leftwardComponents.endIndex - 1]
            
        }
        // If cursor is at the end of the input field. -> <field>dashes<cursor></field>
        else if let rightwardContext = textDocumentProxy.documentContextAfterInput {
            let rightwardComponents = rightwardContext.components(separatedBy: alphanumerics.inverted)
            jumpDistance = rightwardComponents[rightwardComponents.startIndex].characters.count
            return rightwardComponents[rightwardComponents.startIndex]
        }
        return nil
    }
    
    @IBAction func sendText(_ sender: UIButton) {
        let tdp = (textDocumentProxy as UIKeyInput)
        if let originalWord = lastWordTyped, originalWord.characters.count > 1 {
            if jumpDistance > 0 {
                textDocumentProxy.adjustTextPosition(byCharacterOffset: jumpDistance)
            }
            
            for _ in (lastWordTyped?.characters.indices)! {
                tdp.deleteBackward()
            }
            
            tdp.insertText("\(StringManipulator.dashify(originalWord))")
        } else {
            sender.shake()
        }
        updatePreview()
    }
    
    @IBAction func undoDashify(_ sender: Any) {
        textDocumentProxy.insertText(" ")
        updatePreview()
    }
    
    @IBAction func deleteText(timer: Timer) {
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
                    if touch.force >= (touch.maximumPossibleForce / 2) {
                        mainKeyGroup.isHidden = true
                        forceCursorView.isHidden = false
                        let increase = t.x - previousTouchXPos
                        let percentIncrease = increase / (previousTouchXPos * 100)
                    
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
    
    func configureDeleteButton() {
        let deleteButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(KeyboardViewController.deleteText))
        deleteButtonLongPressGestureRecognizer.minimumPressDuration = 0.5
        deleteButtonLongPressGestureRecognizer.numberOfTouchesRequired = 1
        deleteButtonLongPressGestureRecognizer.allowableMovement = 75
        deleteButton.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
    }
    
    func configureDashifyButton() {
        dashifyButton.titleLabel?.numberOfLines = 1
        dashifyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dashifyButton.titleLabel?.lineBreakMode = .byClipping
    }
    
    func updatePreview() {
        if let word = lastWordTyped, word.characters.count > 1 && !(word.containsPunctuation) {
                dashifyButton.isEnabled = true
                dashifyButton.setTitle("☞ \(StringManipulator.dashify(word))", for: .normal)
        } else {
            dashifyButton.setTitle("⬆︎ select a word ⬆︎", for: .normal)
            // dashifyButton.isEnabled = false
            // dashifyButton.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
}

//
//  stickerView.swift
//  stickerTextView
//
//  Created by 刘业臻 on 16/4/20.
//  Copyright © 2016年 luiyezheng. All rights reserved.
//

import UIKit

public protocol JLStickerImageViewDelegate: class {
    func labelViewDidSelected(_ label: JLStickerLabelView)
    func labelViewDidHideEditingHandles()
    func labelViewDidClose()
}

public class JLStickerImageView: UIImageView, UIGestureRecognizerDelegate {
    public var currentlyEditingLabel: JLStickerLabelView?
    public weak var delegate: JLStickerImageViewDelegate?
    
    fileprivate var labels: [JLStickerLabelView]!
    
    fileprivate lazy var tapOutsideGestureRecognizer: UITapGestureRecognizer! = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(JLStickerImageView.tapOutside))
        tapGesture.delegate = self
        return tapGesture
        
    }()
    
    //MARK: -
    //MARK: init
    
    init() {
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = true
        labels = []
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        labels = []
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
        labels = []
    }
    
}

//MARK: -
//MARK: Functions
extension JLStickerImageView {
    
    public func addLabel(withText text: String) {
        if let label: JLStickerLabelView = currentlyEditingLabel {
            label.hideEditingHandlers()
        }
        
        let labelView = JLStickerLabelView(frame: self.frame)
        labelView.setupTextLabel()
        labelView.delegate = self
        labelView.showsContentShadow = false
        labelView.hideEditingHandlers()
        labelView.borderColor = UIColor.clear
        labelView.labelTextView?.isEditable = false
        labelView.labelTextView?.text = text
        self.addSubview(labelView)
        currentlyEditingLabel = labelView
        adjustsWidthToFillItsContens(currentlyEditingLabel!)
        labels.append(labelView)
    }
    
    public func addLabel() {
        if let label: JLStickerLabelView = currentlyEditingLabel {
            label.hideEditingHandlers()
        }
        
        let labelFrame = CGRect(x: self.bounds.midX - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                y: self.bounds.midY - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                width: 60, height: 50)
        let labelView = JLStickerLabelView(frame: labelFrame)
        labelView.setupTextLabel()
        labelView.delegate = self
        labelView.showsContentShadow = false
        labelView.borderColor = UIColor.white
        //        labelView.labelTextView?.fontName = "Roboto-Medium"
        self.addSubview(labelView)
        currentlyEditingLabel = labelView
        adjustsWidthToFillItsContens(currentlyEditingLabel!)
        labels.append(labelView)
        
        self.addGestureRecognizer(tapOutsideGestureRecognizer)
    }
    
    public func removeAllLabel() {
        labels.forEach {
            $0.removeFromSuperview()
        }
        
        labels = []
    }
    
    public func addImage() {
        if let label: JLStickerLabelView = currentlyEditingLabel {
            label.hideEditingHandlers()
        }
        
        let labelFrame = CGRect(x: self.bounds.midX - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                y: self.bounds.midY - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                width: 60, height: 50)
        let labelView = JLStickerLabelView(frame: labelFrame)
        labelView.setupImageLabel()
        labelView.showsContentShadow = false
        labelView.delegate = self
        labelView.borderColor = UIColor.white
        self.addSubview(labelView)
        currentlyEditingLabel = labelView
        adjustsWidthToFillItsContens(currentlyEditingLabel!)
        labels.append(labelView)
        
        self.addGestureRecognizer(tapOutsideGestureRecognizer)
    }
    
    public func renderContentOnView() -> UIImage? {
        
        self.cleanup()
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        UIColor.clear.set()
        context.fill(self.bounds)
        self.isOpaque = false
        self.layer.isOpaque = false
        self.backgroundColor = UIColor.clear
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        self.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return img
    }
    
    public func limitImageViewToSuperView() {
        if self.superview == nil {
            return
        }
        guard let imageSize = self.image?.size else {
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = true
        let aspectRatio = imageSize.width / imageSize.height
        
        if imageSize.width > imageSize.height {
            self.bounds.size.width = self.superview!.bounds.size.width
            self.bounds.size.height = self.superview!.bounds.size.width / aspectRatio
        }else {
            self.bounds.size.height = self.superview!.bounds.size.height
            self.bounds.size.width = self.superview!.bounds.size.height * aspectRatio
        }
    }
    
    public func adjust(toBounds bounds:CGRect, _ view: JLStickerLabelView) {
        guard let labelTextView = view.labelTextView else {
            return
        }
        
        let textFrame = CGRect(x: 0, y: 0, width: bounds.width*0.90, height: bounds.height*0.50)
        adjustFontSizeToFillRect(textFrame, view: view)
        labelTextView.isUserInteractionEnabled = false
        labelTextView.alignment = .center
        labelTextView.setNeedsDisplay()
        view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    }
    
    // MARK: -
    
    func cleanup() {
        for label in labels {
            if let isEmpty = label.labelTextView?.text.isEmpty, isEmpty {
                label.closeTap(nil)
            } else {
                label.hideEditingHandlers()
            }
        }
    }
}

//MARK-
//MARK: Gesture
extension JLStickerImageView {
    @objc func tapOutside() {
        if let _: JLStickerLabelView = currentlyEditingLabel {
            currentlyEditingLabel!.hideEditingHandlers()
        }
        
    }
}

//MARK-
//MARK: stickerViewDelegate
extension JLStickerImageView: JLStickerLabelViewDelegate {
    public func labelViewDidBeginEditing(_ label: JLStickerLabelView) {
        //labels.removeObject(label)
        
    }
    
    public func labelViewDidClose(_ label: JLStickerLabelView) {
        delegate?.labelViewDidClose()
    }
    
    public func labelViewDidShowEditingHandles(_ label: JLStickerLabelView) {
        currentlyEditingLabel = label
        
    }
    
    public func labelViewDidHideEditingHandles(_ label: JLStickerLabelView) {
        delegate?.labelViewDidHideEditingHandles()
//        currentlyEditingLabel = nil
    }
    
    public func labelViewDidStartEditing(_ label: JLStickerLabelView) {
        currentlyEditingLabel = label
    }
    
    public func labelViewDidChangeEditing(_ label: JLStickerLabelView) {
        
    }
    
    public func labelViewDidEndEditing(_ label: JLStickerLabelView) {
        
        
    }
    
    public func labelViewDidSelected(_ label: JLStickerLabelView) {
        delegate?.labelViewDidSelected(label)
    }
    
}

//MARK: -
//MARK: Set propeties

extension JLStickerImageView: adjustFontSizeToFillRectProtocol {
    
    public enum textShadowPropterties {
        case offSet(CGSize)
        case color(UIColor)
        case blurRadius(CGFloat)
    }
    
    public var fontName: String! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel!.labelTextView?.fontName = newValue
                adjustsWidthToFillItsContens(currentlyEditingLabel!)
            }
        }
        get {
            return self.currentlyEditingLabel?.labelTextView?.fontName
        }
    }
    
    public var textColor: UIColor! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel!.labelTextView?.foregroundColor = newValue
            }
        }
        get {
            return self.currentlyEditingLabel?.labelTextView?.foregroundColor
        }
    }
    
    public var textAlpha: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel!.labelTextView?.textAlpha = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel?.labelTextView?.textAlpha
        }
    }
    
    //MARK: -
    //MARK: text Format
    
    public var textAlignment: NSTextAlignment! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel!.labelTextView?.alignment = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel?.labelTextView?.alignment
        }
    }
    
    public var lineSpacing: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel!.labelTextView?.lineSpacing = newValue
                adjustsWidthToFillItsContens(currentlyEditingLabel!)
            }
            
        }
        get {
            return self.currentlyEditingLabel?.labelTextView?.lineSpacing
            
        }
    }
    
    //MARK: -
    //MARK: text Background
    
    public var textBackgroundColor: UIColor! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel!.labelTextView?.textBackgroundColor = newValue
            }
            
        }
        
        get {
            return self.currentlyEditingLabel?.labelTextView?.textBackgroundColor
        }
    }
    
    public var textBackgroundAlpha: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel!.labelTextView?.textBackgroundAlpha = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel?.labelTextView?.textBackgroundAlpha
            
        }
    }
    
    //MARK: -
    //MARK: text shadow
    
    public var textShadowOffset: CGSize! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel!.labelTextView?.textShadowOffset = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel?.labelTextView?.shadow?.shadowOffset
        }
    }
    
    public var textShadowColor: UIColor! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel!.labelTextView?.textShadowColor = newValue
            }
            
        }
        get {
            return (self.currentlyEditingLabel?.labelTextView?.shadow?.shadowColor) as? UIColor
        }
    }
    
    public var textShadowBlur: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel!.labelTextView?.textShadowBlur = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel?.labelTextView?.shadow?.shadowBlurRadius
        }
    }
}

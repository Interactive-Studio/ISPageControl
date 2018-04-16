//
//  ISPageControl.swift
//  ISPageControl
//
//  Created by gwangbeom on 2017. 11. 26..
//  Copyright © 2017년 gwangbeom. All rights reserved.
//

import UIKit

open class ISPageControl: UIControl {
    
    open var fadeScale: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var fadeOpacity: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate let limit = 5
    fileprivate var fullScaleIndex = [0, 1, 2]
    fileprivate var dotLayers: [CALayer] = []
    fileprivate var centerIndex: Int { return fullScaleIndex[1] }
    
    open var currentPage = 0 {
        didSet {
            guard numberOfPages > currentPage else {
                return
            }
            update()
        }
    }
    
    @IBInspectable open var inactiveTintColor: UIColor = UIColor.lightGray {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var currentPageTintColor: UIColor = #colorLiteral(red: 0, green: 0.6276981994, blue: 1, alpha: 1) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var dotRadius: CGFloat = 5 {
        didSet {
            if dotHeight < 2 * dotRadius {
                dotHeight = 2 * dotRadius
            }
            if dotWidth < 2 * dotRadius {
                dotWidth = 2 * dotRadius
            }
            updateDotLayersLayout()
        }
    }
    
    @IBInspectable open var dotWidth: CGFloat = 10 {
        didSet {
            if dotRadius > dotWidth / 2 {
                dotRadius = dotWidth / 2
            }
            updateDotLayersLayout()
        }
    }
    
    @IBInspectable open var dotHeight: CGFloat = 10 {
        didSet {
            if dotRadius > dotHeight / 2  {
                dotRadius = dotHeight / 2
            }
            updateDotLayersLayout()
        }
    }
    
    @IBInspectable open var padding: CGFloat = 8 {
        didSet {
            updateDotLayersLayout()
        }
    }
    
    @IBInspectable open var minScaleValue: CGFloat = 0.4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var middleScaleValue: CGFloat = 0.7 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var minOpacityValue: CGFloat = 0.4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var middleOpacityValue: CGFloat = 0.7 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var numberOfPages: Int = 0 {
        didSet {
            setupDotLayers()
            isHidden = hideForSinglePage && numberOfPages <= 1
        }
    }
    
    @IBInspectable open var hideForSinglePage: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var inactiveTransparency: CGFloat = 0.4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var borderColor: UIColor = UIColor.clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required public init(frame: CGRect, numberOfPages: Int) {
        super.init(frame: frame)
        self.numberOfPages = numberOfPages
        setupDotLayers()
    }
    
    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let minValue = min(7, numberOfPages)
        return CGSize(width: CGFloat(minValue) * dotWidth + CGFloat(minValue - 1) * padding, height: dotHeight)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        dotLayers.forEach {
            if borderWidth > 0 {
                $0.borderWidth = borderWidth
                $0.borderColor = borderColor.cgColor
            }
        }
        
        update()
    }
}

private extension ISPageControl {
    
    func setupDotLayers() {
        dotLayers.forEach{ $0.removeFromSuperlayer() }
        dotLayers.removeAll()

        (0..<numberOfPages).forEach { _ in
            let dotLayer = CALayer()
            layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
        }
        
        updateDotLayersLayout() // 이부분은 변경이 필요할듯
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    func updateDotLayersLayout() {
        let floatCount = CGFloat(numberOfPages)
        let x = (bounds.size.width - dotWidth * floatCount - padding * (floatCount - 1)) * 0.5
        let y = (bounds.size.height - dotHeight) * 0.5
        var frame = CGRect(x: x, y: y, width: dotWidth, height: dotHeight)
        
        dotLayers.forEach {
            $0.cornerRadius = dotRadius
            $0.frame = frame
            frame.origin.x += dotWidth + padding
        }
    }
    
    func setupDotLayersPosition() {
        let centerLayer = dotLayers[centerIndex]
        centerLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        
        dotLayers.enumerated().filter{ $0.offset != centerIndex }.forEach {
            let index = abs($0.offset - centerIndex)
            let interval = $0.offset > centerIndex ? dotWidth + padding : -(dotWidth + padding)
            $0.element.position = CGPoint(x: centerLayer.position.x + interval * CGFloat(index), y: $0.element.position.y)
        }
    }
    
    func setupDotLayersScale() {
        dotLayers.enumerated().forEach {
            guard let first = fullScaleIndex.first, let last = fullScaleIndex.last else {
                return
            }
            
            if fadeScale {
                
                var transform = CGAffineTransform.identity
                if !fullScaleIndex.contains($0.offset) {
                    var scaleValue: CGFloat = 0
                    if abs($0.offset - first) == 1 || abs($0.offset - last) == 1 {
                        scaleValue = min(middleScaleValue, 1)
                    } else if abs($0.offset - first) == 2 || abs($0.offset - last) == 2 {
                        scaleValue = min(minScaleValue, 1)
                    } else {
                        scaleValue = 0
                    }
                    transform = transform.scaledBy(x: scaleValue, y: scaleValue)
                }
                
                $0.element.setAffineTransform(transform)
            }
                
            if fadeOpacity {
                
                var opacity: CGFloat = 1
                if !fullScaleIndex.contains($0.offset) {
                    var scaleValue: CGFloat = 0
                    if abs($0.offset - first) == 1 || abs($0.offset - last) == 1 {
                        scaleValue = min(middleOpacityValue, 1)
                    } else if abs($0.offset - first) == 2 || abs($0.offset - last) == 2 {
                        scaleValue = min(minOpacityValue, 1)
                    } else {
                        scaleValue = 0
                    }
                    opacity = scaleValue
                }
                
                $0.element.opacity = Float(opacity)
                
            }
            
            
        }
    }
    
    func update() {
        dotLayers.enumerated().forEach() {
            $0.element.backgroundColor = $0.offset == currentPage ? currentPageTintColor.cgColor : inactiveTintColor.withAlphaComponent(inactiveTransparency).cgColor
        }
        
        guard numberOfPages > limit else {
            return
        }
        
        changeFullScaleIndexsIfNeeded()
        setupDotLayersPosition()
        setupDotLayersScale()
    }
    
    func changeFullScaleIndexsIfNeeded() {
        guard !fullScaleIndex.contains(currentPage) else {
            return
        }
        
        // TODO: Refactoring
        let moreThanBefore = (fullScaleIndex.last ?? 0) < currentPage
        if moreThanBefore {
            fullScaleIndex[0] = currentPage - 2
            fullScaleIndex[1] = currentPage - 1
            fullScaleIndex[2] = currentPage
        } else {
            fullScaleIndex[0] = currentPage
            fullScaleIndex[1] = currentPage + 1
            fullScaleIndex[2] = currentPage + 2
        }
    }
}

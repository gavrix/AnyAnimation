//
//  Created by Sergey Gavrilyuk on 2017-08-15.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

public class LayerAnimator: Animator {
    
    public static let sharedInstance = LayerAnimator()
    private let window = UIWindow()
    
    private var runningAnimationsLayers = [CALayer]()
    
    public func run(animation: Animation) {
        let layer = AnimatingLayer (timeFunc: { interval in
            animation.tick(at: RelativeTimeInterval(interval: interval, maxInterval: 1))
        })
        layer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        layer.backgroundColor = UIColor.green.cgColor
        window.layer.addSublayer(layer)
        
        
        let layerAnimation = CABasicAnimation(keyPath: "time")
        layerAnimation.fromValue = 0.0
        layerAnimation.toValue = 1.0
        layerAnimation.duration = animation.duration
        
        layer.add(layerAnimation, forKey: nil)
        layer.time = 1.0
        self.runningAnimationsLayers.append(layer)
        
    }
}


fileprivate class AnimatingLayer: CALayer {
    
    var timeFunc: ((TimeInterval) -> Void)?
    init(timeFunc: @escaping (TimeInterval) -> Void) {
        self.timeFunc = timeFunc
        self.time = 0
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    dynamic var time: TimeInterval
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "time" { return true }
        return super.needsDisplay(forKey: key)
    }
    
    override init(layer: Any) {
        let anotherLayer = layer as! AnimatingLayer
        self.time = anotherLayer.time
        super.init(layer: layer)
    }
    
    override func presentation() -> AnimatingLayer? {
        return super.presentation() as? AnimatingLayer
    }
    
    override func display() {
        guard let presentationLayer = presentation() else { return }
        
        timeFunc?(presentationLayer.time)
    }
}




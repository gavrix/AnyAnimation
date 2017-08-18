//
//  SpriteKitAnimator.swift
//  Killme
//
//  Created by Sergey Gavrilyuk on 2017-08-17.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import Foundation
import SpriteKit


public class SKAnimator: Animator {
    
    public static let sharedInstance = SKAnimator()
    
    private var scene = SKScene()
    private var sceneView = SKView()
    
    private init() {
        sceneView.presentScene(scene)
    }
    
    public func run(animation: Animation) {
        let duration = animation.duration
        scene.run(SKAction.customAction(withDuration: duration) {_, elapsed in
            let relativeTime = RelativeTimeInterval(interval: TimeInterval(elapsed), maxInterval: duration)
            animation.tick(at: relativeTime)
        })
    }
}

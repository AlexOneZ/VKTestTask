//
//  FPSCounter.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 04.12.2024.
//

import Foundation

import UIKit

class FPSCounter: UILabel {
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    private var frameCount: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
        start()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
        start()
    }

    private func setupLabel() {
        self.textAlignment = .center
        self.textColor = .white
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.text = "FPS: --"
    }
    
    private func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFPS))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateFPS(_ link: CADisplayLink) {
        if lastUpdateTime == 0 {
            lastUpdateTime = link.timestamp
            return
        }
        
        frameCount += 1
        let delta = link.timestamp - lastUpdateTime
        if delta >= 1 {
            let fps = Double(frameCount) / delta
            self.text = String(format: "FPS: %.0f", fps)
            frameCount = 0
            lastUpdateTime = link.timestamp
        }
    }
    
    deinit {
        stop()
    }
}

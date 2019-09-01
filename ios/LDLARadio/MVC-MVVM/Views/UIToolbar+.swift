//
//  UIToolbar+.swift
//  LDLARadio
//
//  Created by fox on 31/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit

extension UIToolbar {
    
    func reloadToolbar() {
        
        let stream = StreamPlaybackManager.instance
        
        if stream.isReadyToPlay() == false {
            return
        }
        
        var all = [UIBarButtonItem]()
        
        let image = stream.image()
        if let image = image {
            let size = CGSize(width: 40, height: 40)
            let imageView = UIImageView.init(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(origin: .zero, size: image.size)
            imageView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            
            all.append(UIBarButtonItem(customView: imageView))
        }
        
        if stream.hasDuration() {
            all.append(contentsOf: [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(UIToolbar.handleRewind(_:)))
                ])
        }
        all.append(contentsOf: [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: stream.isPlaying() ? .pause : .play, target: self, action: #selector(UIToolbar.handlePlay(_:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            ])
        
        if stream.hasDuration() {
            all.append(
                UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(UIToolbar.handleFastForward(_:)))
                )
        }
        
        if image != nil {
            let info = UIBarButtonItem(title: "\(Commons.symbols.showAwesome(icon: .info_circle))", style: .done, target: self, action: #selector(UIToolbar.info(_:)))
            guard let font = UIFont(name: Commons.font.awesome, size: Commons.font.size.XXL) else {
                fatalError()
            }
            info.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            all.append(contentsOf: [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                info,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                ])
        }
        items = all
        
        
    }

    @objc private func handleRewind(_ button: UIBarButtonItem) {
        StreamPlaybackManager.instance.backward()
//        reloadData()
    }
    
    @objc private func handleFastForward(_ button: UIBarButtonItem) {
        StreamPlaybackManager.instance.forward()
//        reloadData()
    }
    
    @objc private func handlePlay(_ button: UIBarButtonItem) {
        let stream = StreamPlaybackManager.instance
        let isPlaying = stream.isPlaying()
        if isPlaying {
            stream.pause()
        } else {
            stream.playCurrentPosition()
        }
//        reloadData()
    }
    
    @objc private func info(_ sender: Any?) {
        let audioPlayInfo = StreamPlaybackManager.instance.info()
        AppDelegate.instance.window?.rootViewController?.showAlert(title: audioPlayInfo?.0, message: audioPlayInfo?.1, error: nil)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 64
        return sizeThatFits
    }
}

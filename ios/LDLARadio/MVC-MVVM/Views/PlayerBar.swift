//
//  PlayerBar.swift
//  LDLARadio
//
//  Created by fox on 31/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit

class PlayerBar : UIToolbar {
    
    var isFullScreen: Bool = false
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        reloadToolbar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func reloadToolbar() {
        
        let stream = StreamPlaybackManager.instance
        
        if stream.isReadyToPlay() == false || isFullScreen {
            navigationController?.setToolbarHidden(true, animated: false)
            navigationController?.toolbar.isHidden = true
            return
        }
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.toolbar.isHidden = false
        
        var items = [UIBarButtonItem]()
        
        let image = stream.image()
        if let image = image {
            let size = CGSize(width: 40, height: 40)
            let imageView = UIImageView.init(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(origin: .zero, size: image.size)
            imageView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            
            items.append(contentsOf: [
                UIBarButtonItem(customView: imageView)
                ])
        }
        
        if stream.hasDuration() {
            items.append(contentsOf: [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(AudioViewController.handleRewind(_:)))
                ])
        }
        items.append(contentsOf: [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: stream.isPlaying() ? .pause : .play, target: self, action: #selector(AudioViewController.handlePlay(_:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            ])
        
        if stream.hasDuration() {
            items.append(contentsOf: [
                UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(AudioViewController.handleFastForward(_:)))
                ])
        }
        
        if image != nil {
            let info = UIBarButtonItem(title: "\(Commons.symbols.showAwesome(icon: .info_circle))", style: .done, target: self, action: #selector(AudioViewController.info(_:)))
            guard let font = UIFont(name: Commons.font.awesome, size: Commons.font.size.XXL) else {
                fatalError()
            }
            let attribute = [NSAttributedString.Key.font: font]
            for state in [.normal, .selected] as [UIControl.State] {
                info.setTitleTextAttributes(attribute, for: state)
            }
            info.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .selected)
            items.append(contentsOf: [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                info,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                ])
        }
        toolbar.items = items
        
        
    }

}

extension UIToolbar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 300
        return sizeThatFits
    }
}

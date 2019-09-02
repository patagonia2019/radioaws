//
//  UIToolbar+.swift
//  LDLARadio
//
//  Created by fox on 31/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore

extension UIToolbar {
    
    private func timeStringFor(seconds: Float) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad

        guard let output = formatter.string(from: TimeInterval(seconds)) else {
            return nil
        }
        if seconds < 3600 {
            guard let rng = output.range(of: ":") else { return nil }
            return String(output[rng.upperBound...])
        }
        return output
    }

    func reloadToolbar() {
        
        let stream = StreamPlaybackManager.instance
        
        if stream.isReadyToPlay() == false {
            return
        }
        
        var all = [UIBarButtonItem]()
        
        let image = stream.image()
        if let image = image {
            let size = CGSize(width: 56, height: 56)
            let imageView = UIImageView.init(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(origin: .zero, size: image.size)
            imageView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            
            all.append(UIBarButtonItem(customView: imageView))
        }
        
        if stream.hasDuration() {
            let slider = UISlider(frame: CGRect(origin: .zero, size: CGSize(width: frame.size.width/4, height: frame.size.height)))
            slider.minimumTrackTintColor = .lavender
            slider.maximumTrackTintColor = .blueberry
            let currentStreamTime = stream.getCurrentTime()
            let totalStreamTime = stream.getTotalTime()
            slider.value = Float(currentStreamTime)
            slider.maximumValue = Float(totalStreamTime)
            slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
            let currentTimeLabel = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: frame.size.height)))
            currentTimeLabel.text = timeStringFor(seconds: Float(currentStreamTime))

            let totalTimeLabel = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: frame.size.height)))
            totalTimeLabel.text = timeStringFor(seconds: Float(totalStreamTime))
            
            all.append(contentsOf: [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(customView: currentTimeLabel),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(customView: slider),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(customView: totalTimeLabel),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                ])
        }
        all.append(contentsOf: [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: stream.isPlaying() ? .pause : .play, target: self, action: #selector(UIToolbar.handlePlay(_:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            ])
        
        if image != nil {
            let audioPlayInfo = StreamPlaybackManager.instance.info()
            var isError = false
            if let error = audioPlayInfo?.2, error.count > 0 {
                isError = true
            }
            let info = UIBarButtonItem(title: "\(Commons.symbols.showAwesome(icon: isError ? .bug : .info_circle))", style: .done, target: self, action: #selector(UIToolbar.info(_:)))
            guard let font = UIFont(name: Commons.font.awesome, size: Commons.font.size.XXL) else {
                fatalError()
            }
            if isError {
                info.setTitleTextAttributes([NSAttributedString.Key.font: font,
                                             NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
            }
            else {
                info.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            }
            info.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .highlighted)
            info.customView?.heightAnchor.constraint(equalToConstant: 56).isActive = true
            info.customView?.widthAnchor.constraint(equalToConstant: 56).isActive = true

            let bookImage = UIImage(named: stream.isBookmark() ? "f5d1-apple-alt-solid" : "apple-alt-line")
            let bookmark = UIBarButtonItem(image: bookImage, style: .done, target: self, action: #selector(UIToolbar.changeBookmark(_:)))
            
            all.append(contentsOf: [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                info,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                bookmark,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                ])
            
            
        }
        items = all
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider?) {
        let value = sender?.value ?? 0
        StreamPlaybackManager.instance.playPosition(position: Double(value))
    }
    
    @objc private func handlePlay(_ button: UIBarButtonItem) {
        let stream = StreamPlaybackManager.instance
        let isPlaying = stream.isPlaying()
        if isPlaying {
            stream.pause()
        } else {
            stream.playCurrentPosition()
        }
    }
    
    @objc private func changeBookmark(_ sender: Any?) {
        StreamPlaybackManager.instance.changeAudioBookmark()
        reloadToolbar()
    }
    
    @objc private func info(_ sender: Any?) {
        let audioPlayInfo = StreamPlaybackManager.instance.info()
        var error: JFError?
        if let errorMessage = audioPlayInfo?.2 {
            error = JFError(code: 0, desc: errorMessage, reason: audioPlayInfo?.2, suggestion: "", path: "", line: "", url: "", underError: nil)
            AppDelegate.instance.window?.rootViewController?.showAlert(title: error?.title(), message: error?.message(), error: nil)
        }
        else {
            AppDelegate.instance.window?.rootViewController?.showAlert(title: audioPlayInfo?.0, message: audioPlayInfo?.1, error: error)
        }
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 56
        return sizeThatFits
    }
}

//
//  UIToolbar+.swift
//  LDLARadio
//
//  Created by fox on 31/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore
import AVKit

extension UIToolbar {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if UIApplication.shared.applicationState != .active {
            return
        }
        DispatchQueue.main.async {
            self.reloadToolbar()
        }
    }
        
    func reloadToolbar(_ sliderNewValue: Float? = nil) {
        
        var all = [UIBarButtonItem]()
        
        all.append(contentsOf: reloadSpinner())
        all.append(contentsOf: reloadImage())
        all.append(contentsOf: reloadDurationStack(rect: frame))
        all.append(contentsOf: reloadPlayPause())
        all.append(contentsOf: reloadInfo())
        all.append(contentsOf: reloadBookmark())
        
        if all.count > 0 && items?.count ?? 0 < all.count {
            items = all
        }
    }
    
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
    
    private func reloadSpinner() -> [UIBarButtonItem] {
        var all = [UIBarButtonItem]()
        
        var spinnerView : UIActivityIndicatorView? = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.spinner.rawValue
        })?.customView as? UIActivityIndicatorView
        
        if spinnerView == nil {
            let size = Commons.size.toolbarSpinnerSize
            spinnerView = UIActivityIndicatorView.init(frame: CGRect(origin: .zero, size: size))
            spinnerView?.style = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? .whiteLarge : .white
            spinnerView?.contentMode = .scaleAspectFit
            spinnerView?.color = .midnight
            spinnerView?.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            spinnerView?.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            if let spinnerView = spinnerView {
                let button = UIBarButtonItem(customView: spinnerView)
                button.tag = Commons.toolBar.spinner.rawValue
                all.append(button)
            }
        }
        
        let stream = StreamPlaybackManager.instance
        if stream.isPaused() || stream.isPlaying() {
            spinnerView?.stopAnimating()
        }
        else {
            spinnerView?.startAnimating()
        }
        return all
    }
    
    private func reloadImage() -> [UIBarButtonItem] {
        var all = [UIBarButtonItem]()

        let stream = StreamPlaybackManager.instance
        
        let image = stream.image()
        var imageView : UIImageView? = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.image.rawValue
        })?.customView as? UIImageView
        
        if imageView == nil {
            imageView = UIImageView.init(image: image)
            imageView?.contentMode = .scaleAspectFit
            let size = Commons.size.toolbarImageSize
            imageView?.frame = CGRect(origin: .zero, size: size)
            imageView?.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            imageView?.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            if let imageView = imageView {
                let button = UIBarButtonItem(customView: imageView)
                button.tag = Commons.toolBar.image.rawValue
                all.append(button)
            }
        }
        else {
            imageView?.image = image
        }
        return all
    }
    
    private func reloadPlayPause() -> [UIBarButtonItem] {
        
        var all = [UIBarButtonItem]()

        var playPause : UIButton? = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.playPause.rawValue
        })?.customView as? UIButton
        if playPause == nil {
            playPause = UIButton(type: .custom)
            guard let font = UIFont(name: Commons.font.awesome, size: Commons.size.toolbarButtonFontSize) else {
                fatalError()
            }
            playPause?.setTitleColor(.midnight, for: .normal)
            playPause?.setTitleColor(.steel, for: .highlighted)
            playPause?.titleLabel?.font = font
            playPause?.addTarget(self, action: #selector(UIToolbar.handlePlay(_:)), for: .touchUpInside)
            
            if let playPause = playPause {
                let button = UIBarButtonItem(customView: playPause)
                button.tag = Commons.toolBar.playPause.rawValue
                all.append(contentsOf: [
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    button,
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    ])
            }
        }
        
        let stream = StreamPlaybackManager.instance
        
        if stream.isReadyToPlay() {
            playPause?.isHidden = false
        }
        else {
            playPause?.isHidden = true
        }
        
        playPause?.setTitle("\(Commons.symbols.showAwesome(icon: stream.isPlaying() ? .pause_circle : .play_circle))", for: .normal)
        playPause?.setTitle("\(Commons.symbols.showAwesome(icon: stream.isPlaying() ? .play_circle : .pause_circle))", for: .highlighted)
        
        return all
    }
    
    private func reloadInfo() -> [UIBarButtonItem] {
        
        var all = [UIBarButtonItem]()
        
        var infoButton : UIButton? = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.info.rawValue
        })?.customView as? UIButton
        if infoButton == nil {
            infoButton = UIButton(type: .custom)
            guard let font = UIFont(name: Commons.font.awesome, size: Commons.size.toolbarButtonFontSize) else {
                fatalError()
            }
            infoButton?.setTitleColor(.midnight, for: .normal)
            infoButton?.setTitleColor(.steel, for: .highlighted)
            infoButton?.titleLabel?.font = font
            infoButton?.addTarget(self, action: #selector(UIToolbar.handleInfo(_:)), for: .touchUpInside)
            
            if let infoButton = infoButton {
                let button = UIBarButtonItem(customView: infoButton)
                button.tag = Commons.toolBar.info.rawValue
                all.append(contentsOf: [
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    button,
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    ])
            }
        }
        let stream = StreamPlaybackManager.instance
        let audioPlayInfo = stream.info()
        var isError = false
        if let error = audioPlayInfo?.2, error.count > 0 {
            isError = true
        }
        
        if isError == false {
            if stream.isReadyToPlay() {
                infoButton?.isHidden = false
            }
            else {
                infoButton?.isHidden = true
            }
        }
        infoButton?.setTitle("\(Commons.symbols.showAwesome(icon: isError ? .bug : .info_circle))", for: .normal)

        return all
    }
    
    
    private func reloadBookmark() -> [UIBarButtonItem] {

        var all = [UIBarButtonItem]()
        
        var bookmarkButton : UIButton? = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.bookmark.rawValue
        })?.customView as? UIButton
        if bookmarkButton == nil {
            bookmarkButton = UIButton(type: .custom)
            bookmarkButton?.addTarget(self, action: #selector(UIToolbar.handleBookmark(_:)), for: .touchUpInside)
            
            if let bookmarkButton = bookmarkButton {
                let button = UIBarButtonItem(customView: bookmarkButton)
                button.tag = Commons.toolBar.bookmark.rawValue

                all.append(contentsOf: [
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    button,
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    ])
            }
        }
        let stream = StreamPlaybackManager.instance
        if stream.isReadyToPlay() {
            bookmarkButton?.isHidden = false
        }
        else {
            bookmarkButton?.isHidden = true
        }
        let image = UIImage(named: stream.isBookmark() ? "f5d1-apple-alt-solid" : "apple-alt-line")
        bookmarkButton?.setImage(image, for: .normal)
        
        return all
    }
    
    private func reloadDurationStack(rect: CGRect) -> [UIBarButtonItem] {
        
        var all = [UIBarButtonItem]()
        
        let stream = StreamPlaybackManager.instance
        
        var slider : UISlider? = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.slider.rawValue
        })?.customView as? UISlider
        var currentTimeLabel : UILabel? = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.currentTime.rawValue
        })?.customView as? UILabel
        var totalTimeLabel : UILabel? = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.totalTime.rawValue
        })?.customView as? UILabel
        

        var firstTime = false
        if slider == nil {
            firstTime = true
            slider = UISlider(frame: CGRect(origin: .zero, size: CGSize(width: rect.size.width/4, height: rect.size.height)))
            slider?.minimumTrackTintColor = .lavender
            slider?.maximumTrackTintColor = .blueberry
            slider?.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
            slider?.addTarget(self, action: #selector(sliderEnd(_:)), for: .touchUpInside)
            slider?.addTarget(self, action: #selector(sliderStart(_:)), for: .touchDown)
            slider?.widthAnchor.constraint(equalToConstant: rect.size.width/4).isActive = true
            slider?.tag = Commons.toolBar.slider.rawValue
        }
        let currentStreamTime = Float(stream.getCurrentTime())
        print("JF.slider.reload: \(currentStreamTime)")
        let totalStreamTime = Float(stream.getTotalTime())
        if !stream.isPaused() && stream.isPlaying() {
            slider?.value = currentStreamTime
            slider?.maximumValue = totalStreamTime
        }
        
        guard let font = UIFont(name: Commons.font.name, size: UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? Commons.font.size.S : Commons.font.size.XS) else {
            fatalError()
        }
        
        if currentTimeLabel == nil {
            currentTimeLabel = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: Commons.size.toolbarLabelWidth, height: rect.size.height)))
            currentTimeLabel?.textAlignment = .right
            currentTimeLabel?.font = font
            currentTimeLabel?.widthAnchor.constraint(equalToConstant: Commons.size.toolbarLabelWidth).isActive = true
            currentTimeLabel?.tag = Commons.toolBar.currentTime.rawValue
        }
        if !stream.isPaused() && stream.isPlaying() {
            currentTimeLabel?.text = timeStringFor(seconds: currentStreamTime)
        }
        
        if totalTimeLabel == nil {
            totalTimeLabel = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: Commons.size.toolbarLabelWidth, height: rect.size.height)))
            totalTimeLabel?.textAlignment = .left
            totalTimeLabel?.font = font
            totalTimeLabel?.widthAnchor.constraint(equalToConstant: Commons.size.toolbarLabelWidth).isActive = true
            totalTimeLabel?.tag = Commons.toolBar.totalTime.rawValue
        }
        if !stream.isPaused() && stream.isPlaying() {
            totalTimeLabel?.text = timeStringFor(seconds: totalStreamTime)
        }
        
        if firstTime {
            for item in [currentTimeLabel, slider, totalTimeLabel] {
                if let item = item {
                    let button = UIBarButtonItem(customView: item)
                    button.tag = item.tag
                    all.append(contentsOf: [
                        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                        button
                        ])
                }
            }
            all.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }

        if stream.hasDuration() && totalStreamTime > 0 {
            currentTimeLabel?.isHidden = false
            slider?.isHidden = false
            totalTimeLabel?.isHidden = false
        }
        else {
            currentTimeLabel?.isHidden = true
            slider?.isHidden = true
            totalTimeLabel?.isHidden = true
        }
        return all
    }
    
    private func reloadCurrentTimeLabel(_ sliderNewValue: Float? = nil) {
        guard let sliderNewValue = sliderNewValue else {
            return
        }
        guard let currentTimeLabel : UILabel = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.currentTime.rawValue
        })?.customView as? UILabel else {
            return
        }
        currentTimeLabel.text = timeStringFor(seconds: sliderNewValue)
    }

    @objc private func sliderValueChanged(_ sender: UISlider?) {
        let value = sender?.value ?? 0
        print("JF.slider.sliderValueChanged: \(value)")
        DispatchQueue.main.async {
            self.reloadCurrentTimeLabel(value)
        }
    }

    @objc private func sliderStart(_ sender: UISlider?) {
        let value = sender?.value ?? 0
        print("JF.slider.sliderStart: \(value)")
        DispatchQueue.main.async {
            self.reloadCurrentTimeLabel(value)
        }
        StreamPlaybackManager.instance.pause()
    }

    @objc private func sliderEnd(_ sender: UISlider?) {
        let value = sender?.value ?? 0
        print("JF.slider.sliderEnd: \(value)")
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
        _ = reloadPlayPause()
    }
    
    @objc private func handleBookmark(_ sender: Any?) {
        StreamPlaybackManager.instance.changeAudioBookmark()
        _ = reloadBookmark()
    }
    
    @objc private func handleInfo(_ sender: Any?) {
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
        sizeThatFits.height = Commons.size.toolbarHeight
        return sizeThatFits
    }
}

/**
 Extend `UIToolbar` to conform to the `AssetPlaybackDelegate` protocol.
 */
extension UIToolbar: AssetPlaybackDelegate {
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerError error: JFError) {
        Analytics.logError(error: error)
        
        AppDelegate.instance.window?.rootViewController?.showAlert(error: error)
        setNeedsLayout()
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer, isPlaying: Bool) {
        if isPlaying {
            setNeedsLayout()
            print("JF FINALLY PLAYING")
        } else {
            print("JF PAUSE")
        }
    }
    
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer) {
        print("JF CHANGE")
        setNeedsLayout()
    }
 
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidDetectDuration player: AVPlayer, duration: TimeInterval) {
        if !streamPlaybackManager.isPaused() {
            setNeedsLayout()
        }
    }
}

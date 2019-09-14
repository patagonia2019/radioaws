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
        
        all.append(contentsOf: reloadImage())
        all.append(contentsOf: reloadSpinner())
        all.append(contentsOf: reloadDurationStack(rect: frame))
        all.append(contentsOf: reloadPlayPause())
        all.append(contentsOf: reloadInfo())
        all.append(contentsOf: reloadBookmark())
        
        clipsToBounds = false
        
        if all.count > 0 && items?.count ?? 0 < all.count {
            items = all
        }
    }
    
    private func awesomeFont() -> UIFont? {
        return UIFont(name: Commons.font.awesome, size: Commons.size.toolbarButtonFontSize)
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
            spinnerView?.style = .whiteLarge
            spinnerView?.color = .maraschino
            spinnerView?.contentMode = .scaleAspectFit
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
            playPause?.titleLabel?.font = awesomeFont()!
            playPause?.addTarget(self, action: #selector(UIToolbar.handlePlay(_:)), for: .touchUpInside)
            playPause?.heightAnchor.constraint(equalToConstant: Commons.size.toolbarButtonFontSize).isActive = true
            playPause?.widthAnchor.constraint(equalToConstant: Commons.size.toolbarButtonFontSize).isActive = true
            playPause?.frame.size = CGSize(width: Commons.size.toolbarButtonFontSize, height: Commons.size.toolbarButtonFontSize)

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
        
        playPause?.setTitleColor(stream.isPlaying() ? .salmon : .strawberry, for: .normal)
        playPause?.setTitleColor(stream.isPlaying() ? .strawberry : .salmon, for: .highlighted)

        return all
    }
    
    private func reloadInfo() -> [UIBarButtonItem] {
        
        var all = [UIBarButtonItem]()
        
        var infoButton : UIButton? = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.info.rawValue
        })?.customView as? UIButton
        if infoButton == nil {
            infoButton = UIButton(type: .custom)
            infoButton?.setTitleColor(.cerulean, for: .normal)
            infoButton?.setTitleColor(.nobel, for: .highlighted)
            infoButton?.titleLabel?.font = awesomeFont()!
            infoButton?.addTarget(self, action: #selector(UIToolbar.handleInfo(_:)), for: .touchUpInside)
            infoButton?.heightAnchor.constraint(equalToConstant: Commons.size.toolbarButtonFontSize).isActive = true
            infoButton?.widthAnchor.constraint(equalToConstant: Commons.size.toolbarButtonFontSize).isActive = true
            infoButton?.frame.size = CGSize(width: Commons.size.toolbarButtonFontSize, height: Commons.size.toolbarButtonFontSize)

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
        if isError {
            infoButton?.setTitle("\(Commons.symbols.showAwesome(icon: .bug))", for: .normal)
            infoButton?.setTitleColor(.strawberry, for: .normal)
        }
        else {
            infoButton?.setTitle("\(Commons.symbols.showAwesome(icon: .info_circle))", for: .normal)
            infoButton?.setTitleColor(.cerulean, for: .normal)

        }

        return all
    }
    
    
    private func reloadBookmark() -> [UIBarButtonItem] {

        var all = [UIBarButtonItem]()
        
        var bookmarkButton : UIButton? = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.bookmark.rawValue
        })?.customView as? UIButton
        if bookmarkButton == nil {
            bookmarkButton = UIButton(type: .custom)
            bookmarkButton?.titleLabel?.font = awesomeFont()!
            bookmarkButton?.setTitle("\(Commons.symbols.showAwesome(icon: .heart))", for: .normal)
            bookmarkButton?.addTarget(self, action: #selector(UIToolbar.handleBookmark(_:)), for: .touchUpInside)
            bookmarkButton?.heightAnchor.constraint(equalToConstant: Commons.size.toolbarButtonFontSize).isActive = true
            bookmarkButton?.widthAnchor.constraint(equalToConstant: Commons.size.toolbarButtonFontSize).isActive = true
            bookmarkButton?.frame.size = CGSize(width: Commons.size.toolbarButtonFontSize, height: Commons.size.toolbarButtonFontSize)

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
        bookmarkButton?.setTitleColor(stream.isBookmark() ? .bublegum : .silver, for: .normal)
        bookmarkButton?.setTitleColor(stream.isBookmark() ? .silver : .bublegum, for: .highlighted)

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
            slider?.minimumTrackTintColor = .lemon
            slider?.maximumTrackTintColor = .lime
            slider?.tintColor = .aqua
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
        
        guard let font = UIFont(name: Commons.font.regular, size: UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? Commons.font.size.S : Commons.font.size.XS) else {
            fatalError()
        }
        
        if currentTimeLabel == nil {
            currentTimeLabel = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: Commons.size.toolbarLabelWidth, height: rect.size.height)))
            currentTimeLabel?.font = font
            currentTimeLabel?.textAlignment = .right
            currentTimeLabel?.textColor = .clover
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
            totalTimeLabel?.textColor = .clover
            totalTimeLabel?.widthAnchor.constraint(equalToConstant: Commons.size.toolbarLabelWidth).isActive = true
            totalTimeLabel?.tag = Commons.toolBar.totalTime.rawValue
        }
        if !stream.isPaused() && stream.isPlaying() {
            totalTimeLabel?.font = font
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
        
        let mainView = AppDelegate.instance.window
        
        var bigCurrentTimeLabel : UILabel? = mainView?.subviews.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.bigCurrentTime.rawValue
        }) as? UILabel
        
        if bigCurrentTimeLabel == nil {
            guard let font = UIFont(name: Commons.font.bold, size: Commons.font.size.XXXXL) else {
                fatalError()
            }
            
            let length = UIScreen.main.bounds.size.width / 2
            bigCurrentTimeLabel = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: length, height: length)))
            bigCurrentTimeLabel?.textAlignment = .center
            bigCurrentTimeLabel?.layer.cornerRadius = length / 2
            bigCurrentTimeLabel?.layer.borderColor = UIColor.nobel.cgColor
            bigCurrentTimeLabel?.layer.borderWidth = 1
            bigCurrentTimeLabel?.layer.backgroundColor = UIColor.cantaloupe.cgColor
            bigCurrentTimeLabel?.textColor = .clover
            bigCurrentTimeLabel?.shadowColor = .magnesium
            bigCurrentTimeLabel?.font = font
            bigCurrentTimeLabel?.alpha = 0.8
            bigCurrentTimeLabel?.isHidden = true
            bigCurrentTimeLabel?.tag = Commons.toolBar.bigCurrentTime.rawValue
            if let bigCurrentTimeLabel = bigCurrentTimeLabel {
                mainView?.addSubview(bigCurrentTimeLabel)
            }
            bigCurrentTimeLabel?.center = mainView?.center ?? CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        }

        if let bigCurrentTimeLabel = bigCurrentTimeLabel, bigCurrentTimeLabel.isHidden == false && stream.isPlaying() {
            bigCurrentTimeLabel.isHidden = true
        }
        
        
        var messageLabel : UILabel? = mainView?.subviews.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.message.rawValue
        }) as? UILabel
        
        if messageLabel == nil {
            guard let font = UIFont(name: Commons.font.bold, size: Commons.font.size.XXXL) else {
                fatalError()
            }
            
            let length = UIScreen.main.bounds.size.width / 2
            messageLabel = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: length, height: length)))
            messageLabel?.textAlignment = .center
            messageLabel?.layer.cornerRadius = length / 2
            messageLabel?.layer.borderColor = UIColor.nobel.cgColor
            messageLabel?.layer.borderWidth = 1
            messageLabel?.layer.backgroundColor = UIColor.eggplant.cgColor
            messageLabel?.textColor = .clover
            messageLabel?.shadowColor = .magnesium
            messageLabel?.font = font
            messageLabel?.alpha = 0
            messageLabel?.tag = Commons.toolBar.message.rawValue
            if let messageLabel = messageLabel {
                mainView?.addSubview(messageLabel)
            }
            messageLabel?.center = mainView?.center ?? CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)

        }
        
        return all
    }
    
    private func reloadCurrentTimeLabel(_ sliderNewValue: Float? = nil) {
        guard let sliderNewValue = sliderNewValue else {
            return
        }
        
        let mainView = AppDelegate.instance.window

        let bigCurrentTimeLabel : UILabel? = mainView?.subviews.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.bigCurrentTime.rawValue
        }) as? UILabel

        guard let currentTimeLabel : UILabel = items?.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.currentTime.rawValue
        })?.customView as? UILabel else {
            return
        }
        currentTimeLabel.text = timeStringFor(seconds: sliderNewValue)
        bigCurrentTimeLabel?.text = currentTimeLabel.text
        if let bigCurrentTimeLabel = bigCurrentTimeLabel, bigCurrentTimeLabel.isHidden == true {
            bigCurrentTimeLabel.isHidden = false
        }

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
        StreamPlaybackManager.instance.pause()
        DispatchQueue.main.async {
            self.reloadCurrentTimeLabel(value)
        }
    }

    @objc private func sliderEnd(_ sender: UISlider?) {
        let value = sender?.value ?? 0
        print("JF.slider.sliderEnd: \(value)")
        StreamPlaybackManager.instance.playPosition(position: Double(value))
    }
    
    @objc private func handlePlay(_ button: UIBarButtonItem) {
        let stream = StreamPlaybackManager.instance
        let isPlaying = stream.isPlaying()
        
        let mainView = AppDelegate.instance.window
        let messageLabel : UILabel? = mainView?.subviews.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.message.rawValue
        }) as? UILabel

        if isPlaying {
            stream.pause()
            messageLabel?.layer.backgroundColor = UIColor.strawberry.cgColor
        } else {
            stream.playCurrentPosition()
            messageLabel?.layer.backgroundColor = UIColor.salmon.cgColor
        }
        _ = self.reloadPlayPause()

        if isPlaying {
            messageLabel?.text = "Paused"
        } else {
            messageLabel?.text = "Playing"
        }
        messageLabel?.alpha = 1
        UIView.animate(withDuration: 3.0, animations: {
            messageLabel?.alpha = 0
        })
    }
    
    @objc private func handleBookmark(_ sender: Any?) {
        let stream = StreamPlaybackManager.instance
        let mainView = AppDelegate.instance.window
        let messageLabel : UILabel? = mainView?.subviews.first(where: { (item) -> Bool in
            return item.tag == Commons.toolBar.message.rawValue
        }) as? UILabel

        if stream.isBookmark() {
            messageLabel?.layer.backgroundColor = UIColor.silver.cgColor
            messageLabel?.text = "removed"
        } else {
            messageLabel?.layer.backgroundColor = UIColor.bublegum.cgColor
            messageLabel?.text = "added"
        }
        StreamPlaybackManager.instance.changeAudioBookmark { _ in
            _ = self.reloadBookmark()
        }

        messageLabel?.alpha = 1
        UIView.animate(withDuration: 3.0, animations: {
            messageLabel?.alpha = 0
        })
    }
    
    @objc private func handleInfo(_ sender: Any?) {
        let audioPlayInfo = StreamPlaybackManager.instance.info()
        var error: JFError?
        if audioPlayInfo?.2 != nil {
            error = JFError(code: 0, desc: audioPlayInfo?.2, reason: audioPlayInfo?.3, suggestion: "", path: "", line: "", url: "", underError: nil)
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

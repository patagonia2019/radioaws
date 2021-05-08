//
//  Toolbar.swift
//  LDLARadio
//
//  Created by fox on 31/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit
import AVKit

class Toolbar: UIToolbar {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        items = [imageBar, fexibleSpace(), spinnerBar, fexibleSpace(), playBar, fexibleSpace()]
//        items = [imageBar, fexibleSpace(), spinnerBar, fexibleSpace(), sliderButton, fexibleSpace(), playBar]
    }
    
    func fexibleSpace() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if UIApplication.shared.applicationState != .active {
            return
        }
        reloadToolbar()
    }
    
    func reloadToolbar(_ sliderNewValue: Float? = nil) {
        
        let stream = StreamPlaybackManager.instance
        imageButton.setImage(stream.image(), for: .normal)
        
        if stream.isLoading() {
            spinnerView.startAnimating()
        } else {
            spinnerView.stopAnimating()
        }
        
        let totalTime = Float(stream.getTotalTime())
        if stream.isPlaying() {
            sliderButton.customView = sliderGroup
            slider.value = Float(stream.getCurrentTime())
            slider.maximumValue = totalTime
        } else {
            sliderButton.customView = nil
        }
        slider.isHidden = stream.hasDuration() && totalTime > 0 ? false : true
        
        if stream.isReadyToPlay() {
            playPauseButton.isHidden = false
        } else {
            playPauseButton.isHidden = true
        }
        
        playPauseButton.setTitle("\(Commons.Symbol.showAwesome(icon: stream.isPlaying() ? .pause_circle : .play_circle))", for: .normal)
        playPauseButton.setTitle("\(Commons.Symbol.showAwesome(icon: stream.isPlaying() ? .play_circle : .pause_circle))", for: .highlighted)
        
        playPauseButton.setTitleColor(stream.isPlaying() ? .salmon : .strawberry, for: .normal)
        playPauseButton.setTitleColor(stream.isPlaying() ? .strawberry : .salmon, for: .highlighted)        
    }

    lazy var imageBar = {
        return UIBarButtonItem.init(customView: imageButton)
    }()
    
    lazy var imageButton: UIButton = {
        let stream = StreamPlaybackManager.instance
        let image = stream.image()

        let imageButton = UIButton(type: .custom)
        imageButton.setImage(image, for: .normal)
        imageButton.imageView?.contentMode = .scaleAspectFit
        imageButton.addTarget(self, action: #selector(Toolbar.showImage(_:)), for: .touchUpInside)
        let size = Commons.Size.toolbarImageSize
        imageButton.frame = CGRect(origin: .zero, size: size)
        imageButton.layer.cornerRadius = size.width / 2
        imageButton.layer.masksToBounds = true
        imageButton.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        imageButton.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        return imageButton
    }()
    
    lazy var spinnerView: UIActivityIndicatorView = {
        let size = Commons.Size.toolbarSpinnerSize
        let spinnerView = UIActivityIndicatorView.init(frame: CGRect(origin: .zero, size: size))
        spinnerView.style = .whiteLarge
        spinnerView.color = .maraschino
        spinnerView.contentMode = .scaleAspectFit
        spinnerView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        return spinnerView
    }()
    
    lazy var spinnerBar = {
        return UIBarButtonItem.init(customView: spinnerView)
    }()

    lazy var sliderButton = {
        return UIBarButtonItem.init(customView: sliderGroup)
    }()
    
    lazy var playPauseButton: UIButton = {
        let playPause = UIButton(type: .custom)
        playPause.titleLabel?.font = awesomeFont()
        playPause.addTarget(self, action: #selector(Toolbar.handlePlay(_:)), for: .touchUpInside)
        let size = Commons.Size.toolbarButtonFontSize
        playPause.heightAnchor.constraint(equalToConstant: size).isActive = true
        playPause.widthAnchor.constraint(equalToConstant: size).isActive = true
        playPause.frame.size = CGSize(width: size, height: size)
        return playPause
    }()

    lazy var playBar = {
        return UIBarButtonItem.init(customView: playPauseButton)
    }()

    lazy var bigImageButton: UIButton = {
        let rect = UIScreen.main.bounds
        let bigImageButton = UIButton(type: .custom)
        bigImageButton.imageView?.contentMode = .scaleAspectFill
        bigImageButton.addTarget(self, action: #selector(Toolbar.showImage(_:)), for: .touchUpInside)
        let length = CGFloat.minimum(rect.size.width, rect.size.height) * 0.8
        let size = CGSize(width: length, height: length)
        bigImageButton.frame = CGRect(origin: .zero, size: size)
        bigImageButton.layer.cornerRadius = 8
        bigImageButton.layer.masksToBounds = true
        bigImageButton.layer.borderColor = UIColor.nobel.cgColor
        bigImageButton.layer.borderWidth = 1
        bigImageButton.alpha = 0
        bigImageButton.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        bigImageButton.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        bigImageButton.tag = Commons.Toolbar.bigImage.rawValue
        let window = AppDelegate.instance.window
        window?.addSubview(bigImageButton)
        bigImageButton.center = window?.center ?? CGPoint(x: rect.midX, y: rect.midY)
        return bigImageButton
    }()
    
    @IBAction func showImage(_ sender: Any) {
        bigImageButton.setBackgroundImage(StreamPlaybackManager.instance.image(), for: .normal)
        UIView.animate(withDuration: 1.0, animations: {
            self.bigImageButton.alpha = (self.bigImageButton.alpha == 0) ? 1 : 0
        })
    }
  
    
    private func awesomeFont() -> UIFont? {
        return UIFont(name: Commons.Font.awesome, size: Commons.Size.toolbarButtonFontSize)
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
    
    private func reloadSpinner() {
        let stream = StreamPlaybackManager.instance
        if stream.isLoading() {
            spinnerView.startAnimating()
        } else {
            spinnerView.stopAnimating()
        }
    }
    
    var currentTimeLabel: UILabel? {
        return createToolbarLabel(rect: UIScreen.main.bounds, textAlignment: .right)
    }

    var totalTimeLabel: UILabel? {
        return createToolbarLabel(rect: UIScreen.main.bounds, textAlignment: .left)
    }
    
    var messageLabel: UILabel? {
        return createRoundLabel(rect: UIScreen.main.bounds)
    }

    private func reloadDurationStack() {

        let stream = StreamPlaybackManager.instance

        if let currentTimeLabel = currentTimeLabel, currentTimeLabel.alpha == 1 && stream.isPlaying() {
            UIView.animate(withDuration: 3.0, animations: {
                currentTimeLabel.alpha = 0
            })

        }
    }
    
    var sliderGroup: UIView {
        let width = frame.size.width / (Commons.isPad() ? 2 : 4)
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        view.heightAnchor.constraint(equalToConstant: frame.size.height).isActive = true
        view.addSubview(slider)
        if let currentTimeLabel = currentTimeLabel {
            view.addSubview(currentTimeLabel)
        }
        if let totalTimeLabel = totalTimeLabel {
            view.addSubview(totalTimeLabel)
        }
        return view
    }

    var slider: UISlider {
        let slider = UISlider(frame: .zero)
        slider.minimumTrackTintColor = .lemon
        slider.maximumTrackTintColor = .lime
        slider.tintColor = .aqua
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderEnd(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderStart(_:)), for: .touchDown)
        return slider
    }
    
    private func createToolbarLabel(rect: CGRect, textAlignment: NSTextAlignment) -> UILabel? {
        let label = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: Commons.Size.toolbarLabelWidth, height: rect.size.height)))
        guard let font = UIFont(name: Commons.Font.regular, size: Commons.isPad() ? Commons.Font.Size.S : Commons.Font.Size.XS) else { fatalError() }
        label.font = font
        label.textAlignment = textAlignment
        label.textColor = .clover
        label.widthAnchor.constraint(equalToConstant: Commons.Size.toolbarLabelWidth).isActive = true
//        let stream = StreamPlaybackManager.instance
        //
        //        if stream.isPlaying() {
        //            label?.text = timeStringFor(seconds: Float(streamTime))
        //        }
        
//        label?.isHidden = stream.hasDuration() && streamTime > 0 ? false : true
        return label
    }

    private func createRoundLabel(rect: CGRect) -> UILabel? {
        let mainView = AppDelegate.instance.window

        guard let font = UIFont(name: Commons.Font.bold, size: Commons.Font.Size.XXXXL) else {
            fatalError()
        }
        let length = min(rect.size.width, rect.size.height) / (Commons.isPad() ? 4 : 2)
        let label = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: length, height: length)))
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.layer.cornerRadius = length / 2
        label.layer.borderColor = UIColor.nobel.cgColor
        label.layer.borderWidth = 1
        label.layer.backgroundColor = UIColor.cantaloupe.cgColor
        label.textColor = .clover
        label.shadowColor = .magnesium
        label.font = font
        label.alpha = 0.0
        mainView?.addSubview(label)

        return label
    }

    private func reloadCurrentTimeLabel(_ sliderNewValue: Float? = nil) {
        guard let sliderNewValue = sliderNewValue else {
            return
        }
        spinnerView.startAnimating()
        let text = timeStringFor(seconds: sliderNewValue)
        currentTimeLabel?.text = text
//        messageLabel?.text = text
//        if let messageLabel = messageLabel, messageLabel.alpha == 0 {
//            messageLabel.alpha = 1
//        }

    }

    @objc private func sliderValueChanged(_ sender: UISlider?) {
        let value = sender?.value ?? 0
        Log.debug("JF.slider.sliderValueChanged: %ld", value)
        DispatchQueue.main.async {
            self.reloadCurrentTimeLabel(value)
        }
    }

    @objc private func sliderStart(_ sender: UISlider?) {
        let value = sender?.value ?? 0
        Log.debug("JF.slider.sliderStart: %ld", value)
        StreamPlaybackManager.instance.pause()

        DispatchQueue.main.async {

            self.reloadCurrentTimeLabel(value)
        }
    }

    @objc private func sliderEnd(_ sender: UISlider?) {
        let value = sender?.value ?? 0
        Log.debug("JF.slider.sliderEnd: %ld", value)
        StreamPlaybackManager.instance.playPosition(position: Double(value))
    }

    private func hideMessages() {
        
        UIView.animate(withDuration: 3.0, animations: {
//            self.messageLabel?.alpha = 0
            self.imageButton.alpha = 0
        })

    }

    @objc private func handleImage(_ sender: Any?) {
        let mainView = AppDelegate.instance.window

        let stream = StreamPlaybackManager.instance
        let image = stream.image()

        var imageButton: UIButton? = mainView?.subviews.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.bigImage.rawValue
        }) as? UIButton

        let rect = UIScreen.main.bounds

        if imageButton == nil {
            imageButton = UIButton(type: .custom)
            imageButton?.imageView?.contentMode = .scaleAspectFill
            imageButton?.addTarget(self, action: #selector(Toolbar.handleImage(_:)), for: .touchUpInside)
            let length = CGFloat.minimum(rect.size.width, rect.size.height) * 0.8
            let size = CGSize(width: length, height: length)
            imageButton?.frame = CGRect(origin: .zero, size: size)
            imageButton?.layer.cornerRadius = 8
            imageButton?.layer.masksToBounds = true
            imageButton?.layer.borderColor = UIColor.nobel.cgColor
            imageButton?.layer.borderWidth = 1
            imageButton?.alpha = 0
            imageButton?.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            imageButton?.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            imageButton?.tag = Commons.Toolbar.bigImage.rawValue
            if let imageButton = imageButton {
                mainView?.addSubview(imageButton)
            }
        }
        imageButton?.setBackgroundImage(image, for: .normal)
        imageButton?.center = mainView?.center ?? CGPoint(x: rect.midX, y: rect.midY)

        UIView.animate(withDuration: 1.0, animations: {
            imageButton?.alpha = (imageButton?.alpha ?? 0 == 0) ? 1 : 0
        })
    }

    @objc private func handlePlay(_ button: UIBarButtonItem) {

        showMessage { () -> (UIColor, String) in
            let stream = StreamPlaybackManager.instance
            let isPlaying = stream.isPlaying()

            var color: UIColor = .black
            var text: String = ""

            if isPlaying {
                stream.pause()
                color = UIColor.strawberry
            } else {
                spinnerView.startAnimating()

                stream.playCurrentPosition()
                color = UIColor.salmon
            }
//            _ = self.reloadPlayPause()

            if isPlaying {
                text = "pause"
            } else {
                text = "play"
            }
            return (color, text)
        }
    }

    private func showMessage(action: (() -> (UIColor, String))) {
        return
        hideMessages()

        let (color, message) = action()
        messageLabel?.layer.backgroundColor = color.cgColor
        messageLabel?.text = message
        messageLabel?.alpha = 0
        UIView.animate(withDuration: 3.0, animations: {
            self.messageLabel?.alpha = 1
        })
    }

    @objc private func handleInfo(_ sender: Any?) {
        hideMessages()

        let audioPlayInfo = StreamPlaybackManager.instance.info()
        var error: NSError?
        if audioPlayInfo?.2 != nil {
            error = NSError(code: 0, desc: audioPlayInfo?.2, reason: audioPlayInfo?.3, suggestion: "", path: "", line: "", url: "", underError: nil)
            AppDelegate.instance.window?.rootViewController?.showAlert(title: error?.title(), message: error?.message(), error: nil)
        } else {
            AppDelegate.instance.window?.rootViewController?.showAlert(title: audioPlayInfo?.0, message: audioPlayInfo?.1, error: error)
        }

    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = Commons.Size.toolbarHeight
        return sizeThatFits
    }
}

/**
 Extend `Toolbar` to conform to the `AssetPlaybackDelegate` protocol.
 */
extension Toolbar: AssetPlaybackDelegate {
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerError error: NSError, audio: Audio?) {
        Analytics.logError(error: error)

        AppDelegate.instance.window?.rootViewController?.showAlert(error: error)
        setNeedsLayout()
    }

    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer, isPlaying: Bool) {
        setNeedsLayout()

        if isPlaying {
            spinnerView.stopAnimating()
            Log.debug("JF FINALLY PLAYING")
        } else {
            spinnerView.stopAnimating()
            Log.debug("JF PAUSE")
        }
    }

    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidChange player: AVPlayer) {
        Log.debug("JF CHANGE")
        setNeedsLayout()
    }

    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerCurrentItemDidDetectDuration player: AVPlayer, duration: TimeInterval) {
        setNeedsLayout()
    }
}

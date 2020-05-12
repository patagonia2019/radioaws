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
        
        if !all.isEmpty && !(items?.isEmpty ?? false) && (items?.count ?? 0) < all.count {
            items = all
        }
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

    private func reloadSpinner() -> [UIBarButtonItem] {
        var all = [UIBarButtonItem]()

        var spinnerView: UIActivityIndicatorView? = items?.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.spinner.rawValue
        })?.customView as? UIActivityIndicatorView

        if spinnerView == nil {
            let size = Commons.Size.toolbarSpinnerSize
            spinnerView = UIActivityIndicatorView.init(frame: CGRect(origin: .zero, size: size))
            spinnerView?.style = .whiteLarge
            spinnerView?.color = .maraschino
            spinnerView?.contentMode = .scaleAspectFit
            spinnerView?.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            spinnerView?.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            if let spinnerView = spinnerView {
                let button = UIBarButtonItem(customView: spinnerView)
                button.tag = Commons.Toolbar.spinner.rawValue
                all.append(button)
            }
        }

        let stream = StreamPlaybackManager.instance
        if stream.isLoading() {
            spinnerView?.startAnimating()
        } else {
            spinnerView?.stopAnimating()
        }

        return all
    }

    private func reloadImage() -> [UIBarButtonItem] {
        var all = [UIBarButtonItem]()

        let stream = StreamPlaybackManager.instance

        let image = stream.image()
        var imageButton: UIButton? = items?.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.image.rawValue
        })?.customView as? UIButton

        if imageButton == nil {
            imageButton = UIButton(type: .custom)
            imageButton?.setImage(image, for: .normal)
            imageButton?.imageView?.contentMode = .scaleAspectFit
            imageButton?.addTarget(self, action: #selector(UIToolbar.handleImage(_:)), for: .touchUpInside)
            let size = Commons.Size.toolbarImageSize
            imageButton?.frame = CGRect(origin: .zero, size: size)
            imageButton?.layer.cornerRadius = size.width / 2
            imageButton?.layer.masksToBounds = true
            imageButton?.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            imageButton?.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            if let imageButton = imageButton {
                let button = UIBarButtonItem(customView: imageButton)
                button.tag = Commons.Toolbar.image.rawValue
                all.append(button)
            }
        } else {
            imageButton?.setImage(image, for: .normal)
        }
        return all
    }

    private func reloadPlayPause() -> [UIBarButtonItem] {

        var all = [UIBarButtonItem]()

        var playPause: UIButton? = items?.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.playPause.rawValue
        })?.customView as? UIButton
        if playPause == nil {
            playPause = UIButton(type: .custom)
            playPause?.titleLabel?.font = awesomeFont()
            playPause?.addTarget(self, action: #selector(UIToolbar.handlePlay(_:)), for: .touchUpInside)
            playPause?.heightAnchor.constraint(equalToConstant: Commons.Size.toolbarButtonFontSize).isActive = true
            playPause?.widthAnchor.constraint(equalToConstant: Commons.Size.toolbarButtonFontSize).isActive = true
            playPause?.frame.size = CGSize(width: Commons.Size.toolbarButtonFontSize, height: Commons.Size.toolbarButtonFontSize)

            if let playPause = playPause {
                let button = UIBarButtonItem(customView: playPause)
                button.tag = Commons.Toolbar.playPause.rawValue
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
        } else {
            playPause?.isHidden = true
        }

        playPause?.setTitle("\(Commons.Symbol.showAwesome(icon: stream.isPlaying() ? .pause_circle : .play_circle))", for: .normal)
        playPause?.setTitle("\(Commons.Symbol.showAwesome(icon: stream.isPlaying() ? .play_circle : .pause_circle))", for: .highlighted)

        playPause?.setTitleColor(stream.isPlaying() ? .salmon : .strawberry, for: .normal)
        playPause?.setTitleColor(stream.isPlaying() ? .strawberry : .salmon, for: .highlighted)

        return all
    }

    private func reloadInfo() -> [UIBarButtonItem] {

        var all = [UIBarButtonItem]()

        var infoButton: UIButton? = items?.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.info.rawValue
        })?.customView as? UIButton
        if infoButton == nil {
            infoButton = UIButton(type: .custom)
            infoButton?.setTitleColor(.cerulean, for: .normal)
            infoButton?.setTitleColor(.nobel, for: .highlighted)
            infoButton?.titleLabel?.font = awesomeFont()
            infoButton?.addTarget(self, action: #selector(UIToolbar.handleInfo(_:)), for: .touchUpInside)
            infoButton?.heightAnchor.constraint(equalToConstant: Commons.Size.toolbarButtonFontSize).isActive = true
            infoButton?.widthAnchor.constraint(equalToConstant: Commons.Size.toolbarButtonFontSize).isActive = true
            infoButton?.frame.size = CGSize(width: Commons.Size.toolbarButtonFontSize, height: Commons.Size.toolbarButtonFontSize)

            if let infoButton = infoButton {
                let button = UIBarButtonItem(customView: infoButton)
                button.tag = Commons.Toolbar.info.rawValue
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
        if let error = audioPlayInfo?.2, !error.isEmpty {
            isError = true
        }

        if isError == false {
            if stream.isReadyToPlay() {
                infoButton?.isHidden = false
            } else {
                infoButton?.isHidden = true
            }
        }
        if isError {
            infoButton?.setTitle("\(Commons.Symbol.showAwesome(icon: .bug))", for: .normal)
            infoButton?.setTitleColor(.strawberry, for: .normal)
        } else {
            infoButton?.setTitle("\(Commons.Symbol.showAwesome(icon: .info_circle))", for: .normal)
            infoButton?.setTitleColor(.cerulean, for: .normal)

        }

        return all
    }

    private func reloadBookmark() -> [UIBarButtonItem] {

        var all = [UIBarButtonItem]()

        var bookmarkButton: UIButton? = items?.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.bookmark.rawValue
        })?.customView as? UIButton
        if bookmarkButton == nil {
            bookmarkButton = UIButton(type: .custom)
            bookmarkButton?.titleLabel?.font = awesomeFont()
            bookmarkButton?.setTitle("\(Commons.Symbol.showAwesome(icon: .heart))", for: .normal)
            bookmarkButton?.addTarget(self, action: #selector(UIToolbar.handleBookmark(_:)), for: .touchUpInside)
            bookmarkButton?.heightAnchor.constraint(equalToConstant: Commons.Size.toolbarButtonFontSize).isActive = true
            bookmarkButton?.widthAnchor.constraint(equalToConstant: Commons.Size.toolbarButtonFontSize).isActive = true
            bookmarkButton?.frame.size = CGSize(width: Commons.Size.toolbarButtonFontSize, height: Commons.Size.toolbarButtonFontSize)

            if let bookmarkButton = bookmarkButton {
                let button = UIBarButtonItem(customView: bookmarkButton)
                button.tag = Commons.Toolbar.bookmark.rawValue

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
        } else {
            bookmarkButton?.isHidden = true
        }
        bookmarkButton?.setTitleColor(stream.isBookmark() ? .bublegum : .silver, for: .normal)
        bookmarkButton?.setTitleColor(stream.isBookmark() ? .silver : .bublegum, for: .highlighted)

        return all
    }

    private func reloadDurationStack(rect: CGRect) -> [UIBarButtonItem] {

        var all = [UIBarButtonItem]()

        let stream = StreamPlaybackManager.instance

        let currentStreamTime = Float(stream.getCurrentTime())
        let totalStreamTime = Float(stream.getTotalTime())

        let (firstTime, slider) = createSlider(rect: rect, currentTime: currentStreamTime, totalTime: totalStreamTime)

        guard let font = UIFont(name: Commons.Font.regular, size: Commons.isPad() ? Commons.Font.Size.S : Commons.Font.Size.XS) else {
            fatalError()
        }

        let currentTimeLabel = createToolbarLabel(rect: rect, streamTime: currentStreamTime, font: font, tag: .currentTime, textAlignment: .right)
        let totalTimeLabel = createToolbarLabel(rect: rect, streamTime: totalStreamTime, font: font, tag: .totalTime, textAlignment: .left)

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
        let mainRect = UIScreen.main.bounds
        if let currentTimeLabel = createRoundLabel(tag: .bigCurrentTime, rect: mainRect), currentTimeLabel.alpha == 1 && stream.isPlaying() {
            UIView.animate(withDuration: 3.0, animations: {
                currentTimeLabel.alpha = 0
            })

        }
        _ = createRoundLabel(tag: .message, rect: mainRect)

        return all
    }

    private func createSlider(rect: CGRect, currentTime: Float, totalTime: Float) -> (Bool, UISlider?) {
        let stream = StreamPlaybackManager.instance

        let tag = Commons.Toolbar.slider.rawValue
        var slider: UISlider? = items?.first(where: { (item) -> Bool in
            item.tag == tag
        })?.customView as? UISlider

        var firstTime = false
        if slider == nil {
            firstTime = true
            let width = rect.size.width / (Commons.isPad() ? 2 : 4)
            slider = UISlider(frame: .zero)
            slider?.minimumTrackTintColor = .lemon
            slider?.maximumTrackTintColor = .lime
            slider?.tintColor = .aqua
            slider?.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
            slider?.addTarget(self, action: #selector(sliderEnd(_:)), for: .touchUpInside)
            slider?.addTarget(self, action: #selector(sliderStart(_:)), for: .touchDown)
            slider?.widthAnchor.constraint(equalToConstant: width).isActive = true
            slider?.heightAnchor.constraint(equalToConstant: rect.size.height).isActive = true
            slider?.tag = tag
        }
        if stream.isPlaying() {
            slider?.value = currentTime
            slider?.maximumValue = totalTime
        }

        slider?.isHidden = stream.hasDuration() && totalTime > 0 ? false : true

        return (firstTime, slider)
    }

    private func createToolbarLabel(rect: CGRect, streamTime: Float, font: UIFont?, tag: Commons.Toolbar, textAlignment: NSTextAlignment) -> UILabel? {
        var label: UILabel? = items?.first(where: { (item) -> Bool in
            item.tag == tag.rawValue
        })?.customView as? UILabel

        if label == nil {
            label = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: Commons.Size.toolbarLabelWidth, height: rect.size.height)))
            label?.font = font
            label?.textAlignment = textAlignment
            label?.textColor = .clover
            label?.widthAnchor.constraint(equalToConstant: Commons.Size.toolbarLabelWidth).isActive = true
            label?.tag = tag.rawValue
        }
        let stream = StreamPlaybackManager.instance

        if stream.isPlaying() {
            label?.text = timeStringFor(seconds: Float(streamTime))
        }

        label?.isHidden = stream.hasDuration() && streamTime > 0 ? false : true

        return label
    }

    private func createRoundLabel(tag: Commons.Toolbar, rect: CGRect) -> UILabel? {
        let mainView = AppDelegate.instance.window

        var label: UILabel? = mainView?.subviews.first(where: { (item) -> Bool in
            item.tag == tag.rawValue
        }) as? UILabel

        if label == nil {
            guard let font = UIFont(name: Commons.Font.bold, size: Commons.Font.Size.XXXXL) else {
                fatalError()
            }
            let length = min(rect.size.width, rect.size.height) / (Commons.isPad() ? 4 : 2)
            label = UILabel.init(frame: CGRect(origin: .zero, size: CGSize(width: length, height: length)))
            label?.textAlignment = .center
            label?.adjustsFontSizeToFitWidth = true
            label?.layer.cornerRadius = length / 2
            label?.layer.borderColor = UIColor.nobel.cgColor
            label?.layer.borderWidth = 1
            label?.layer.backgroundColor = UIColor.cantaloupe.cgColor
            label?.textColor = .clover
            label?.shadowColor = .magnesium
            label?.font = font
            label?.alpha = 0.0
            label?.tag = tag.rawValue
            if let label = label {
                mainView?.addSubview(label)
            }
        }
        label?.center = mainView?.center ?? CGPoint(x: rect.midX, y: rect.midY)

        return label
    }

    private func reloadCurrentTimeLabel(_ sliderNewValue: Float? = nil) {
        guard let sliderNewValue = sliderNewValue else {
            return
        }

        let mainView = AppDelegate.instance.window

        let bigCurrentTimeLabel: UILabel? = mainView?.subviews.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.bigCurrentTime.rawValue
        }) as? UILabel

        guard let currentTimeLabel: UILabel = items?.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.currentTime.rawValue
        })?.customView as? UILabel else {
            return
        }

        let spinnerView: UIActivityIndicatorView? = items?.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.spinner.rawValue
        })?.customView as? UIActivityIndicatorView
        spinnerView?.startAnimating()

        currentTimeLabel.text = timeStringFor(seconds: sliderNewValue)
        bigCurrentTimeLabel?.text = currentTimeLabel.text
        if let bigCurrentTimeLabel = bigCurrentTimeLabel, bigCurrentTimeLabel.alpha == 0 {
            bigCurrentTimeLabel.alpha = 1
        }

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
        let mainView = AppDelegate.instance.window
        let bigCurrentTimeLabel: UILabel? = mainView?.subviews.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.bigCurrentTime.rawValue
        }) as? UILabel
        let imageButton: UIButton? = mainView?.subviews.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.bigImage.rawValue
        }) as? UIButton

        UIView.animate(withDuration: 1.0, animations: {
            if bigCurrentTimeLabel?.alpha == 1 {
                bigCurrentTimeLabel?.alpha = 0
            }
            if imageButton?.alpha == 1 {
                imageButton?.alpha = 0
            }
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
            imageButton?.addTarget(self, action: #selector(UIToolbar.handleImage(_:)), for: .touchUpInside)
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
                let spinnerView: UIActivityIndicatorView? = items?.first(where: { (item) -> Bool in
                    item.tag == Commons.Toolbar.spinner.rawValue
                })?.customView as? UIActivityIndicatorView
                spinnerView?.startAnimating()

                stream.playCurrentPosition()
                color = UIColor.salmon
            }
            _ = self.reloadPlayPause()

            if isPlaying {
                text = "pause"
            } else {
                text = "play"
            }
            return (color, text)
        }
    }

    private func showMessage(action: (() -> (UIColor, String))) {
        hideMessages()

        let mainView = AppDelegate.instance.window
        let messageLabel: UILabel? = mainView?.subviews.first(where: { (item) -> Bool in
            item.tag == Commons.Toolbar.message.rawValue
        }) as? UILabel

        let (color, message) = action()
        messageLabel?.layer.backgroundColor = color.cgColor
        messageLabel?.text = message
        messageLabel?.alpha = 1
        UIView.animate(withDuration: 3.0, animations: {
            messageLabel?.alpha = 0
        })

    }

    @objc private func handleBookmark(_ sender: Any?) {
        showMessage { () -> (UIColor, String) in
            let stream = StreamPlaybackManager.instance
            let isBookmark = stream.isBookmark()

            var color: UIColor = .black
            var text: String = ""

            if isBookmark {
                color = UIColor.silver
                text = "remove"
            } else {
                color = UIColor.bublegum
                text = "add"
            }
            StreamPlaybackManager.instance.changeAudioBookmark { _ in
                _ = self.reloadBookmark()
            }

            return (color, text)
        }

    }

    @objc private func handleInfo(_ sender: Any?) {
        hideMessages()

        let audioPlayInfo = StreamPlaybackManager.instance.info()
        var error: JFError?
        if audioPlayInfo?.2 != nil {
            error = JFError(code: 0, desc: audioPlayInfo?.2, reason: audioPlayInfo?.3, suggestion: "", path: "", line: "", url: "", underError: nil)
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
 Extend `UIToolbar` to conform to the `AssetPlaybackDelegate` protocol.
 */
extension UIToolbar: AssetPlaybackDelegate {
    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerError error: JFError, audio: Audio?) {
        Analytics.logError(error: error)

        AppDelegate.instance.window?.rootViewController?.showAlert(error: error)
        setNeedsLayout()
    }

    func streamPlaybackManager(_ streamPlaybackManager: StreamPlaybackManager, playerReadyToPlay player: AVPlayer, isPlaying: Bool) {
        setNeedsLayout()

        if isPlaying {

            let spinnerView: UIActivityIndicatorView? = items?.first(where: { (item) -> Bool in
                item.tag == Commons.Toolbar.spinner.rawValue
            })?.customView as? UIActivityIndicatorView
            spinnerView?.stopAnimating()

            Log.debug("JF FINALLY PLAYING")
        } else {
            let spinnerView: UIActivityIndicatorView? = items?.first(where: { (item) -> Bool in
                item.tag == Commons.Toolbar.spinner.rawValue
            })?.customView as? UIActivityIndicatorView
            spinnerView?.stopAnimating()

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

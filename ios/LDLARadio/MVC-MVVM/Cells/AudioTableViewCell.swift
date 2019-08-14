//
//  AudioTableViewCell.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import AlamofireImage
import JFCore

class AudioTableViewCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier: String = "AudioTableViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var downloadStateLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var bookmarkButton: UIButton!
    weak var delegate: AudioTableViewCellDelegate?
    fileprivate let formatter = DateComponentsFormatter()

    // Player buttons
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var startOfStreamButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var endOfStreamButton: UIButton!
    @IBOutlet weak var resizeButton: UIButton!
    @IBOutlet weak var targetSoundButton: UIButton!

    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet weak var playerStack: UIStackView!
    @IBOutlet weak var progressStack: UIStackView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var bugButton: UIButton!
    @IBOutlet weak var sliderStack: UIStackView!
    
    fileprivate var timerPlayed: Timer?

    var model : AudioViewModel? = nil {
        didSet {
            let labels = [downloadStateLabel, subtitleLabel, titleLabel]
            let texts = [model?.detail, model?.subTitle, model?.title]
            for i in 0..<3 {
                if let text = texts[i]?.text, text.count > 0 {
                    labels[i]?.isHidden = false
                    labels[i]?.text = text
                    labels[i]?.textColor = texts[i]?.color
                    labels[i]?.font = texts[i]?.font
                }
                else {
                    labels[i]?.isHidden = true
                    if i == 0 {
                        titleLabel.numberOfLines = 3
                    }
                    else if i == 1 {
                        titleLabel.numberOfLines += 2
                    }
                }
            }
            
            logoView.image = model?.placeholderImage
            thumbnailView.image = logoView.image
            if let thumbnailUrl = model?.thumbnailUrl {
                logoView.af_setImage(withURL: thumbnailUrl, placeholderImage: model?.placeholderImage) { (response) in
                    self.thumbnailView.image = self.logoView.image
                    self.model?.image = self.logoView.image
                }
            }
            bookmarkButton.isHighlighted = model?.isBookmarked ?? false
            bugButton.alpha = 0
            targetSoundButton.alpha = 0
            graphButton.alpha = 0
            
            if model?.isPlaying ?? false {
                playButton.isHighlighted = true
                selectionStyle = model?.selectionStyle ?? .none
                // show big logo, and hide thumbnail
                logoView.isHidden = false
                thumbnailView.isHidden = true
                playerStack.isHidden = false
                progressStack.isHidden = false
                if let timerPlayed = timerPlayed {
                    timerPlayed.invalidate()
                }
//                updateTimePlayed()
                timerPlayed = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimePlayed), userInfo: nil, repeats: true)
                resizeButton.isHighlighted = model?.isFullScreen ?? false
                
                sliderStack.alpha = 1
                currentTimeLabel.alpha = 1
                totalTimeLabel.alpha = 1
                backwardButton.isHidden = false
                forwardButton.isHidden = false
                startOfStreamButton.isHidden = false
                endOfStreamButton.isHidden = false

            }
            else {
                playButton.isHighlighted = false
                selectionStyle = .none
                // show thumbnail, and hide logo
                logoView.isHidden = true
                thumbnailView.isHidden = false
                playerStack.isHidden = true
                progressStack.isHidden = true
                if let timerPlayed = timerPlayed {
                    timerPlayed.invalidate()
                }
                resizeButton.isHighlighted = false
                
                sliderStack.alpha = 0
                currentTimeLabel.alpha = 0
                totalTimeLabel.alpha = 0
                backwardButton.isHidden = true
                forwardButton.isHidden = true
                startOfStreamButton.isHidden = true
                endOfStreamButton.isHidden = true

            }

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        for label in [ downloadStateLabel, subtitleLabel, titleLabel] {
            label?.text = ""
            label?.isHidden = false
            label?.numberOfLines = 1
        }
        
        logoView.image = nil
        downloadProgressView.isHidden = true
        bookmarkButton.isHighlighted = false

    }
    
    @IBAction func bookmarkAction(_ sender: UIButton?) {
        bookmarkButton.isHighlighted = !bookmarkButton.isHighlighted
        delegate?.audioTableViewCell(self, bookmarkDidChange: bookmarkButton.isHighlighted)
    }
    
    @IBAction func playAction(_ sender: UIButton?) {
        playButton.isHighlighted = !playButton.isHighlighted

        if let timerPlayed = timerPlayed {
            timerPlayed.invalidate()
        }

        if model?.isPlaying ?? false {
            model?.isPlaying = false
            StreamPlaybackManager.sharedManager.pause(propagate: false)
        }
        else {
            delegate?.audioTableViewCell(self, didPlay: playButton.isHighlighted)
        }
    }
    
    @IBAction func startOfStreamAction(_ sender: UIButton?) {
        delegate?.audioTableViewCell(self, didChangePosition: 0)
    }
    
    @IBAction func endOfStreamAction(_ sender: UIButton?) {
        delegate?.audioTableViewCell(self, didChangeToEnd: true)
    }

    @IBAction func backwardAction(_ sender: UIButton?) {
        delegate?.audioTableViewCell(self, didChangeOffset: true)
    }
    
    @IBAction func forwardAction(_ sender: UIButton?) {
        delegate?.audioTableViewCell(self, didChangeOffset: false)
    }
    
    @IBAction func graphAction(_ sender: UIButton?) {
        graphButton.isHighlighted = !graphButton.isHighlighted
        delegate?.audioTableViewCell(self, didShowGraph: graphButton.isHighlighted)
    }
    
    @IBAction func infoAction(_ sender: UIButton?) {
        delegate?.audioTableViewCell(self, didShowInfo: infoButton.isHighlighted)
    }
    
    @IBAction func bugAction(_ sender: UIButton?) {
        delegate?.audioTableViewCell(self, didShowBug: true)
    }
    
    @IBAction func resizeAction(_ sender: UIButton?) {
        let isFullScreen = !(model?.isFullScreen ?? false)
        model?.isFullScreen = isFullScreen
        delegate?.audioTableViewCell(self, didResize: isFullScreen)
    }
    
    @IBAction func targetSoundAction(_ sender: UIButton?) {
        targetSoundButton.isHighlighted = !targetSoundButton.isHighlighted
        delegate?.audioTableViewCell(self, didChangeTargetSound: targetSoundButton.isHighlighted)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider?) {
        let value = sender?.value ?? 0
        delegate?.audioTableViewCell(self, didChangePosition: value)
        updateTimeLabel(with: value)
    }

    @objc fileprivate func updateTimePlayed() {
        let currentStreamTime = StreamPlaybackManager.sharedManager.getCurrentTime()
        let totalStreamTime = StreamPlaybackManager.sharedManager.getTotalTime()
        sliderView.value = Float(currentStreamTime)
        sliderView.maximumValue = Float(totalStreamTime)
        currentTimeLabel.text = timeStringFor(seconds: Float(currentStreamTime))
        totalTimeLabel.text = timeStringFor(seconds: Float(totalStreamTime))
        if model?.isPlaying ?? false,
            StreamPlaybackManager.sharedManager.canGoToEnd() {
            if sliderView.value >= sliderView.maximumValue {
                if let timerPlayed = timerPlayed {
                    timerPlayed.invalidate()
                }
                playButton.isHighlighted = false
                StreamPlaybackManager.sharedManager.pause(propagate: false)
            }
        }
        else {
            if let timerPlayed = timerPlayed {
                timerPlayed.invalidate()
            }
            sliderStack.alpha = 0
            currentTimeLabel.alpha = 0
            totalTimeLabel.alpha = 0
            backwardButton.isHidden = true
            forwardButton.isHidden = true
            startOfStreamButton.isHidden = true
            endOfStreamButton.isHidden = true
        }
    }
    
    fileprivate func updateTimeLabel(with updatedTime: Float) {
        currentTimeLabel.text = timeStringFor(seconds: updatedTime)
    }
    
    func timeStringFor(seconds : Float) -> String
    {
        let output = formatter.string(from: TimeInterval(seconds))!
        return seconds < 3600 ? output.substring(from: output.range(of: ":")!.upperBound) : output
    }

    
}

protocol AudioTableViewCellDelegate: class {
    
    func audioTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState)
    func audioTableViewCell(_ cell: AudioTableViewCell, bookmarkDidChange newState: Bool)
    func audioTableViewCell(_ cell: AudioTableViewCell, didPlay newState: Bool)
    func audioTableViewCell(_ cell: AudioTableViewCell, didChangeOffset isBackward: Bool)
    func audioTableViewCell(_ cell: AudioTableViewCell, didChangeToEnd toEnd: Bool)
    func audioTableViewCell(_ cell: AudioTableViewCell, didChangePosition newState: Float)
    func audioTableViewCell(_ cell: AudioTableViewCell, didResize newState: Bool)
    func audioTableViewCell(_ cell: AudioTableViewCell, didChangeTargetSound newState: Bool)
    func audioTableViewCell(_ cell: AudioTableViewCell, didShowGraph newValue: Bool)
    func audioTableViewCell(_ cell: AudioTableViewCell, didShowInfo newValue: Bool)
    func audioTableViewCell(_ cell: AudioTableViewCell, didShowBug newValue: Bool)
}

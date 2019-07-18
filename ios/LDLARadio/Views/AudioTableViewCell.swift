//
//  AudioTableViewCell.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import AlamofireImage

class AudioTableViewCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = "AudioTableViewCellIdentifier"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var downloadStateLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    weak var delegate: AssetListTableViewCellDelegate?
    
    var model : AudioViewModel? = nil {
        didSet {
            downloadStateLabel.text = model?.detail
            downloadStateLabel.textColor = model?.detailColor
            downloadStateLabel.font = model?.detailFont
            subtitleLabel.text = model?.subTitle
            subtitleLabel.textColor = model?.subTitleColor
            subtitleLabel.font = model?.subTitleFont
            titleLabel.text = model?.title
            titleLabel.textColor = model?.titleColor
            titleLabel.font = model?.titleFont
            if let thumbnailUrl = model?.thumbnailUrl {
                logoView.af_setImage(withURL: thumbnailUrl)
            }
        }
    }

    var stream: Stream? {
        didSet {
            if let stream = stream {
                let downloadState = StreamPersistenceManager.sharedManager.downloadState(for: stream)
                
                switch downloadState {
                case .downloaded:
                    downloadProgressView.isHidden = true
                    downloadStateLabel.text = downloadState.rawValue
                    break
                case .downloading:
                    downloadProgressView.isHidden = false
                    downloadStateLabel.text = downloadState.rawValue
                    break
                case .notDownloaded:
                    break
                }
                
                logoView.image = nil
                if let imageUrl = stream.station?.imageUrl,
                    let url = URL(string: imageUrl) {
                    logoView.af_setImage(withURL: url)
                }
                var aux = [String]()
                if let cityName = stream.station?.city?.name {
                    aux.append(cityName)
                }
                if let tuningDial = stream.station?.tuningDial {
                    aux.append(tuningDial)
                }
                subtitleLabel.text = aux.joined(separator: " - ")
                titleLabel.text = stream.station?.name
                
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector: #selector(handleStreamDownloadStateChangedNotification(_:)), name: StreamDownloadStateChangedNotification, object: nil)
                notificationCenter.addObserver(self, selector: #selector(handleAssetDownloadProgressNotification(_:)), name: StreamDownloadProgressNotification, object: nil)
            }
            else {
                downloadProgressView.isHidden = false
                titleLabel.text = ""
                subtitleLabel.text = ""
                downloadStateLabel.text = ""
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        subtitleLabel.text = ""
        titleLabel.text = ""
        logoView.image = nil
        downloadStateLabel.text = ""
        downloadProgressView.isHidden = true
    }
    
    // MARK: Notification handling
    
    @objc func handleStreamDownloadStateChangedNotification(_ notification: Notification) {
        guard let assetStreamName = notification.userInfo![Stream.Keys.name] as? String,
            let downloadStateRawValue = notification.userInfo![Stream.Keys.downloadState] as? String,
            let downloadState = Stream.DownloadState(rawValue: downloadStateRawValue),
            let asset = stream, asset.name == assetStreamName else { return }
        
        DispatchQueue.main.async {
            switch downloadState {
            case .downloading:
                self.downloadProgressView.isHidden = false
                
                if let downloadSelection = notification.userInfo?[Stream.Keys.downloadSelectionDisplayName] as? String {
                    self.downloadStateLabel.text = "\(downloadState): \(downloadSelection)"
                    return
                }
                
            case .downloaded, .notDownloaded:
                self.downloadProgressView.isHidden = true
            }
            
            self.delegate?.assetListTableViewCell(self, downloadStateDidChange: downloadState)
        }
    }
    
    @objc func handleAssetDownloadProgressNotification(_ notification: NSNotification) {
        guard let assetStreamName = notification.userInfo![Stream.Keys.name] as? String, let asset = stream , asset.name == assetStreamName else { return }
        guard let progress = notification.userInfo![Stream.Keys.percentDownloaded] as? Double else { return }
        
        self.downloadProgressView.setProgress(Float(progress), animated: true)
    }
}

protocol AssetListTableViewCellDelegate: class {
    
    func assetListTableViewCell(_ cell: AudioTableViewCell, downloadStateDidChange newState: Stream.DownloadState)
}

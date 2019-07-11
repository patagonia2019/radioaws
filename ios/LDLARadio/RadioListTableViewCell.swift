//
//  RadioListTableViewCell.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import AlamofireImage

class RadioListTableViewCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = "RadioListTableViewCellIdentifier"
    
    @IBOutlet weak var assetNameLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var assetImageView: UIImageView!
    
    @IBOutlet weak var downloadStateLabel: UILabel!
    
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    weak var delegate: AssetListTableViewCellDelegate?
        
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
                
                assetImageView.image = nil
                if let imageUrl = stream.station?.imageUrl,
                    let url = URL(string: imageUrl) {
                    assetImageView.af_setImage(withURL: url)
                }
                cityLabel.text = stream.station?.city?.name
                assetNameLabel.text = stream.station?.name
                
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector: #selector(handleStreamDownloadStateChangedNotification(_:)), name: StreamDownloadStateChangedNotification, object: nil)
                notificationCenter.addObserver(self, selector: #selector(handleAssetDownloadProgressNotification(_:)), name: StreamDownloadProgressNotification, object: nil)
            }
            else {
                downloadProgressView.isHidden = false
                assetNameLabel.text = ""
                downloadStateLabel.text = ""
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        assetNameLabel.text = ""
        cityLabel.text = ""
        assetImageView.image = nil
        downloadStateLabel.text = ""
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
    
    func assetListTableViewCell(_ cell: RadioListTableViewCell, downloadStateDidChange newState: Stream.DownloadState)
}

//
//  UIViewController+.swift
//  LDLARadio
//
//  Created by fox on 05/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFCore

extension UIViewController {
    func share(indexPath: IndexPath?, controller: BaseController? = nil, tableView: UITableView? = nil) {
        var text = [String]()

        var shareUrl: URL?
        var image: UIImage?
        text.append("Hey!")
        if  let tableView = tableView,
            let indexPath = indexPath,
            let controller = controller,
            let object = controller.model(forSection: indexPath.section, row: indexPath.row) {
            if let audio = object as? AudioViewModel {
                text.append("Play \"\(audio.title.text)\" Enjoy! ;)")
                let cell = tableView.cellForRow(at: indexPath) as? AudioTableViewCell
                image = cell?.thumbnailView.image ?? audio.placeholderImage
                shareUrl = audio.urlAsset()?.url
            } else if let section = object as? CatalogViewModel {
                text.append("Play \"\(section.title.text)\" Enjoy! ;)")
                shareUrl = section.url
            }
            text.append("\n")
        }
        else {
            let stream = StreamPlaybackManager.instance
            image = stream.image()
            // title, subTitle, section, detail
            if let info = stream.info() {
                let title = info.0
                text.append("Play \"\(title)\" Enjoy! ;)")
                if let urlString = stream.urlString() {
                    shareUrl = URL(string: urlString)
                }
            }
        }

        text.append("Hurry up! Download \"Los Locos de la Azotea\" from https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1")
        guard let url = shareUrl ?? URL(string: "https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1"),
            let img = image ?? UIImage.init(named: "bg") else {
                return
        }
        let items: [Any] = [img, text.joined(separator: " "), url]

        Analytics.logFunction(function: "share",
                              parameters: ["text": text as AnyObject,
                                           "url": url.absoluteString as AnyObject])

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view

        UIPasteboard.general.string = url.absoluteString

        activityViewController.completionWithItemsHandler = { _, _, _, _ in
        }
        present(activityViewController, animated: true)
    }

}

extension UIViewController: UIActivityItemSource {
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "Download Los Locos de la Azotea from https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1"
    }

    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return "Download Los Locos de la Azotea from https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1"
    }

    public func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Download Los Locos de la Azotea from https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1"
    }

}

//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        view.addSubview(label)
        view.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = attributedQuote
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        self.view = view
    }
    
    var attributedQuoteNormal: NSAttributedString {
        let quote = "Los Locos de la Azotea"
        let font = UIFont.systemFont(ofSize: 72)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.red,
        ]
        let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
        return attributedQuote
    }

    // Shadow
    var attributedQuoteShadow: NSAttributedString {
        let quote = "Los Locos de la Azotea"
        let font = UIFont.systemFont(ofSize: 72)
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.red
        shadow.shadowBlurRadius = 5

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .shadow: shadow
        ]
        let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
        return attributedQuote
    }

    // paragraph
    var attributedQuoteParagraph: NSAttributedString {
        let quote = "Los Locos de la Azotea"
        let font = UIFont.systemFont(ofSize: 72)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.firstLineHeadIndent = 5.0

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.blue,
            .paragraphStyle: paragraphStyle
        ]

        return NSAttributedString(string: quote, attributes: attributes)
    }
    
    var attributedQuote: NSAttributedString {
        let quote = "Los Locos de la Azotea"
        let attributedQuote = NSMutableAttributedString(string: quote)
        attributedQuote.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 7, length: 5))
        
        let attributes: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor.green, NSAttributedString.Key.kern: 10]
        attributedQuote.addAttributes(attributes, range: NSRange(location: 0, length: 6))
        
        return attributedQuote
    }
    
    
    var attributedQuoteAppend: NSAttributedString {

        let firstAttributes: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor.green, NSAttributedString.Key.kern: 10]
        let secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]

        let firstString = NSMutableAttributedString(string: "Los ", attributes: firstAttributes)
        let secondString = NSAttributedString(string: "Locos ", attributes: secondAttributes)
        let thirdString = NSAttributedString(string: "de la Azotea")

        firstString.append(secondString)
        firstString.append(thirdString)
        return firstString
    }
    
    var attributedQuote2: NSAttributedString {
        let firstAttributes: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor.green, NSAttributedString.Key.kern: 10]
        let secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]

        let string = "Want to listen good music? You should download"
        let secondString = NSAttributedString(string: "Los Locos de la Azotea Radio", attributes: secondAttributes)

        let attributedString = NSMutableAttributedString(string: string, attributes: firstAttributes)
        attributedString.append(secondString)
        
        return attributedString
    }

    var attributedQuoteLink: NSAttributedString {
        let string = "Want to listen good music? You should download Los Locos de la Azotea Radio App!"
        let substring = "Los Locos de la Azotea Radio"
        let range = (string as NSString).range(of: substring)
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.link, value: "https://apps.apple.com/do/app/los-locos-de-la-azotea/id1474338334", range: range)
        
        return attributedString
    }
    
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

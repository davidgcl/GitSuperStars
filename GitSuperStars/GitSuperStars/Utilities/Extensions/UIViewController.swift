import UIKit

extension UIViewController {
    
    func extShowAlert(title: String, message: String, completion: ((_ success:Bool)->(Void))? ) {
        
        let alert:UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "", style: .default) { (action) in
            if let completion = completion {
                completion(true)
            }
        }
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
        // customize container
        let containerView = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 10.0
        
        // container shadow
        containerView.layer.shadowColor = Color.colorBlack.withAlpha(0.2).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        containerView.layer.shadowRadius = 10.0
        containerView.layer.shadowOpacity = 0.2
        
        // customize ok action
        let okLocalizedAttributtedText = NSMutableAttributedString(string: LocalizedString.ok.value.uppercased())
        let okRange = NSRange(location: 0, length: okLocalizedAttributtedText.length)
        okLocalizedAttributtedText.addAttribute(NSAttributedString.Key.kern, value: 0.2, range: okRange)
        okLocalizedAttributtedText.addAttribute(NSAttributedString.Key.font, value: Font.roboto_medium.value(size: Size.font_subtitle.value), range: okRange)
        alert.view.tintColor = Color.colorPrimaryDark.value
        if let okLabel = (okAction.value(forKey: "__representer")as? NSObject)?.value(forKey: "label") as? UILabel {
            okLabel.attributedText = okLocalizedAttributtedText
        }
        
        // title
        let attributedTitleText = NSMutableAttributedString(string: title)
        let titleRange = NSRange(location: 0, length: attributedTitleText.length)
        attributedTitleText.addAttribute(NSAttributedString.Key.kern, value: 0.2, range: titleRange)
        attributedTitleText.addAttribute(NSAttributedString.Key.font, value: Font.roboto_medium.value(size: Size.font_subtitle.value), range: titleRange)
        attributedTitleText.addAttribute(NSAttributedString.Key.foregroundColor, value: Color.colorAccentDarker.value, range: titleRange)
        alert.setValue(attributedTitleText, forKey: "attributedTitle")
        
        // message
        let attributedMessageText = NSMutableAttributedString(string: message)
        let messageRange = NSRange(location: 0, length: attributedMessageText.length)
        attributedMessageText.addAttribute(NSAttributedString.Key.font, value: Font.roboto_regular.value(size: Size.font_body.value), range: messageRange)
        attributedMessageText.addAttribute(NSAttributedString.Key.foregroundColor, value: Color.colorGreyDarker.value, range: messageRange)
        alert.setValue(attributedMessageText, forKey: "attributedMessage")
        
    }
}

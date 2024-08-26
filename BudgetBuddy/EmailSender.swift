import Foundation
import MessageUI

final class EmailSender: NSObject, MFMailComposeViewControllerDelegate {
    
    static let shared = EmailSender()
    
    private override init() {
        super.init()
    }
    
    ///   - recipient: The email address of the recipient.
    ///   - subject: The subject of the email.
    ///   - body: The body content of the email.
    ///   - viewController: The view controller from which the email composer is presented.
    func sendEmail(recipient: String, subject: String, body: String, from viewController: UIViewController) {
        guard MFMailComposeViewController.canSendMail() else {
            print("Cannot send mail")
            return
        }
        
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients([recipient])
        mailComposeViewController.setSubject(subject)
        mailComposeViewController.setMessageBody(body, isHTML: false)
        
        viewController.present(mailComposeViewController, animated: true, completion: nil)
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        if let error = error {
            print("Mail sent failed with error: \(error.localizedDescription)")
        } else {
            print("Mail sent successfully with result: \(result)")
        }
    }
}

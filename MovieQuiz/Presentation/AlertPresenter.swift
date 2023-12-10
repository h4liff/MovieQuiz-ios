import UIKit
import Foundation

final class AlertPresenter {
    weak var viewController: UIViewController?
    
    func show(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        
        alert.view.accessibilityIdentifier = "Alert"
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
    func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        viewController?.present(alert, animated: true, completion: nil)
    }
}


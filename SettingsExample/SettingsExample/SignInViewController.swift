//
//  SignInViewController.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2017-04-08.
//  Copyright © 2017 Reid van Melle. All rights reserved.
//

import Foundation
import QuickSettings

extension UIViewController {

    // MARK: - Alert and Dialog

    func simpleAlert(_ title: String?, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: completion)
    }

    func embedFillingChildVC(_ childVC: UIViewController) {
        guard let containerView = self.view else { return }

        self.addChild(childVC)
        containerView.addSubview(childVC.view)

        //childVC.view.translatesAutoresizingMaskIntoConstraints = false
        //containerView.pinItemFillHorizontally(childVC.view)
        //containerView.pinItemFillVertically(childVC.view)
        childVC.didMove(toParent: self)
        containerView.layoutIfNeeded()
    }
}

class SignInViewController: UIViewController {

    fileprivate var email = UserDefaults.standard.string(forKey: Constant.emailKey)
    fileprivate var password: String?

    fileprivate enum Constant {
        static let emailKey = "signIn.email"
        static let passwordKey = "signIn.password"
    }

    fileprivate func updateView() {
        navigationItem.rightBarButtonItem?.isEnabled = email != nil && password != nil
    }

    lazy var settingsVC: QSSettingsViewController = {
        let vc = QSSettingsViewController(root:self.currentSettings, delegate:self, dataStore:self)
        self.embedFillingChildVC(vc)
        return vc
    }()

    @objc func loginAction() {
        view.endEditing(true)
        guard let email = email, let _ = password else {
            simpleAlert("Invalid Input", message: "You must provide both an email and a password to continue.")
            return
        }
        simpleAlert("Login", message: "Logged in with email=\(email) password=******")
    }

    private var currentSettings: QSGroup {
        let account = [
            QSGroup(title: nil, footer: nil) {
                return [
                    QSText(label: "Email/Username", key: Constant.emailKey, defaultValue: email,
                           placeholder: "work email address", type: .email),
                    QSText(label: "Password", key: Constant.passwordKey, placeholder: "password",
                           type: .password)
                ]
            }
        ]
        let accountSettings = QSGroup(title: "Account", children: account, footer:nil)
        return accountSettings
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsVC.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign In", style: .plain, target: self, action: #selector(loginAction))
        updateView()
    }

}

extension SignInViewController: QSSettingsDataSource {
    func hasValue(forKey key: String) -> Bool {
        return false
    }

    func value<T>(forKey key: String, type: T.Type) -> T? {
        switch type {
        case is String.Type:
            if key == Constant.emailKey {
                return UserDefaults.standard.string(forKey: key) as? T
            } else {
                return nil
            }
        default:
            fatalError()
        }
    }

    func set<T>(_ value: T, forKey key: String) {
        guard let value = value as? String else { fatalError() }
        switch key {
        case Constant.emailKey:
            email = value
            UserDefaults.standard.set(value, forKey: Constant.emailKey)
        case Constant.passwordKey:
            password = value
        default:
            fatalError()
        }
        updateView()
    }
}

extension SignInViewController: QSSettingsViewControllerDelegate {
    func settingsViewController(settingsVc: QSSettingsViewController, didUpdateSetting settingId: String) {
        
    }
}

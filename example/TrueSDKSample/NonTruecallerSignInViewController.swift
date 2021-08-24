//
//  NonTruecallerSignInViewController.swift
//  TrueSDKSample
//
//  Created by Sreedeepkesav M S on 17/11/20.
//  Copyright © 2020 Aleksandar Mihailovski. All rights reserved.
//

import UIKit
import TrueSDK

protocol NonTrueCallerDelegate {
    func didReceiveNonTC(profileResponse : TCTrueProfile)
}

class NonTruecallerSignInViewController: UIViewController, TCTrueSDKDelegate, TCTrueSDKViewDelegate {

    @IBOutlet weak var errorToast: ErrorToast!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var otpView: UIView!
    
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var otpField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    //Default india since the market now is only india
    let defaultCountryCode = "in"
    var delegate: NonTrueCallerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close",
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(donePressed(_:)))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(donePressed(_:)))
        }
        
        TCTrueSDK.sharedManager().delegate = self
        TCTrueSDK.sharedManager().viewDelegate = self
        
        otpView.isHidden = true
        phoneNumberView.isHidden = false
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc func donePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUp() {
        view.endEditing(true)
        TCTrueSDK.sharedManager().requestVerification(forPhone: phoneNumberField.text ?? "",
                                                      countryCode: defaultCountryCode)
    }

    @IBAction func continueWithOTP() {
        view.endEditing(true)
        TCTrueSDK.sharedManager().verifySecurityCode(otpField.text ?? "",
                                                     andUpdateFirstname: firstNameField.text ?? "",
                                                     lastName: lastNameField.text ?? "")
    }
    
    private func verifyFields() -> Bool {
        guard otpField.text?.isEmpty == true,
              firstNameField.text?.isEmpty == true else {
            showAlert(with: "Error", message: "Please check the input", actionHandler: nil)
            return false
        }
        
        return true
    }
    
    private func showAlert(with title: String, message: String, actionHandler: (() -> Void)?) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alertAction in
            actionHandler?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TCTrueSDKDelegate -
    
    func didReceive(_ profile: TCTrueProfile) {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(with: "Profile verified",
                            message: "Profile verified with name: \(profile.firstName ?? "") lastName: \(profile.lastName ?? "") phone: \(profile.phoneNumber ?? "")",
                            actionHandler: {
                                self?.delegate?.didReceiveNonTC(profileResponse: profile)
                                self?.dismiss(animated: true, completion: nil)
                            })
        }
    }
    
    func didFailToReceiveTrueProfileWithError(_ error: TCError) {
        errorToast.error = error
    }
    
    func verificationStatusChanged(to verificationState: TCVerificationState) {
        DispatchQueue.main.async {
            self.handle(verificationState: verificationState)
        }
    }
    
    private func handle(verificationState: TCVerificationState) {
        switch verificationState {
        case .otpInitiated:
            self.otpView.isHidden = false
            self.phoneNumberView.isHidden = true
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(with: "OTP initiated", message: "OTP valid for \(String(describing: (TCTrueSDK.sharedManager().tokenTtl() ?? 0))) seconds from now", actionHandler: nil)
            }
        case .verificationComplete:
            break;
        case .otpReceived, .verifiedBefore:
            break;
        @unknown default:
            break;
        }
    }
}

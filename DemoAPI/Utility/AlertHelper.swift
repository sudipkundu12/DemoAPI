//
//  AlertHelper.swift
//  XOOWEE
//
//  Created by Pace Wisdom on 16/09/18.
//  Copyright © 2018 Xoowee. All rights reserved.
//
import Foundation
import UIKit

class AlertHelper: NSObject {
    
    //Alert with title and dismiss button only
    static func showAlertWithTitle(_ conroller: UIViewController, title: String, message: String = "" ,dismissButtonTitle: String, dismissAction:@escaping ()->Void) {
        
        let validationLinkAlert = UIAlertController(title:title, message:message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: dismissButtonTitle, style: .default) { (action) -> Void in
            dismissAction()
        }
        
        validationLinkAlert.addAction(dismissAction)
        conroller.present(validationLinkAlert, animated: true, completion: nil)
    }
    
    //Alert with title with message
    static func showALertWithTitleAndMessage(_ controller: UIViewController, title: String, message: String, dismissButtonTitle: String, okButtonTitle: String, dismissAction:@escaping ()-> Void, okAction:@escaping ()-> Void) {
        
        let validationLinkAlert = UIAlertController(title:title, message:message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: dismissButtonTitle, style: UIAlertAction.Style.cancel) { (action) in
            dismissAction()
        }
        
        let okAction = UIAlertAction(title: okButtonTitle, style: UIAlertAction.Style.destructive) { (action) in
            okAction()
        }
        
        validationLinkAlert.addAction(dismissAction)
        validationLinkAlert.addAction(okAction)
        
        controller.present(validationLinkAlert, animated: true, completion: nil)
        
    }
    static func openShareDialogOnViewController(_ controller:UIViewController, textToShare:String, webUrl:String) {
        
        if let myWebsite = NSURL(string: webUrl) {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //            activityVC.popoverPresentationController?.sourceView = sender as? UIView
            controller.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
}

//
//  ViewController.swift
//  DemoAPI
//
//  Created by sudip kundu on 10/04/19.
//  Copyright © 2019 sudip kundu. All rights reserved.
//

import UIKit
import ObjectMapper
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NetworkManager.requestWithoutToken(target: .userLogin(email:"kundu.sudip@gmail.com", password:"rets" , grant_type: ""), success: { (response) in
            print(response)
            // Convert JSON String to Model
            let responseModel =  Mapper<Json4Swift_Base>().map(JSONString: response.rawString()!)
            // Create JSON String from Model
           // let JSONString = Mapper().toJSONString(responseModel, prettyPrint: true)
            print(responseModel?.error_description)
            if response["error_description"].string != nil {
                AlertHelper.showAlertWithTitle(self, title: (response["error_description"].string)!, dismissButtonTitle: "OK", dismissAction: {
                    return
                })
            }
            if response["access_token"].string != nil {
                UserDefaults.standard.setValue(response["access_token"].string, forKey: "user_access_token")
                self.performSegue(withIdentifier: Segue_Identifier.login_segue, sender: nil)
            }
        })
    }


}


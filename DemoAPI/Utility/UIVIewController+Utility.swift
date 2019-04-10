//
//  UIVIewController+Utility.swift
//  XOOWEE
//
//  Created by Pace Wisdom on 16/09/18.
//  Copyright © 2018 Xoowee. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class func controllerFromMainStoryBoard() -> UIViewController? {
        return self.controllerWithStoryBoardName("Main")
    }
    class func controllerWithStoryBoardName(_ name:String!)-> UIViewController? {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: self.nameOfClass)
        return controller
    }
}

public extension NSObject{
    public class var nameOfClass: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public var nameOfClass: String{
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}

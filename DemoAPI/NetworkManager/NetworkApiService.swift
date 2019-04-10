//
//  NetworkApiService.swift
//  XOOWEE
//
//  Created by Pace Wisdom on 25/09/18.
//  Copyright © 2018 Xoowee. All rights reserved.
//

import UIKit

import Foundation
import Moya

enum NetworkApiService {
    
    // MARK: - create User

    case userLogin(email:String,password:String,grant_type:String)
    case forgetPassword(email:String)
    case changePassword(newPassword:String,oldPassword:String,confromPassword:String)
    case userProfile(userId:String)
    case userEvents(userId:String,pageNumber:String,pageSize:String,eventName:String,sortColumn:String)
    case userEventsattendace(eventid:String,attendeeName:String)
    case addNewUser(eventid:String,firstName:String,lastName:String,email:String,Designation:String,PhoneNumber:String,Company:String)
    case attendeeCheckIN(AttendeeId:String,Action:String)
    case questionList(eventID:String)
    case questionListAnswerSubmit(answerDict:[String:Any])
    case qrCodePostApi(AttendeeId:String,QRCode:String)
    case getTicket(attendeeId:String)
///event/Answer/Submit /event/Attendee/Ticket?attendeeId=121
    // /Attendee/QrCode
//    AttendeeId:1
//    Action:Add/Update
//http://ec2-54-163-0-98.compute-1.amazonaws.com/Api.Xoowee/api/event/attendee?eventid=2
}
// MARK: - TargetType Protocol Implementation
extension NetworkApiService: TargetType {
    
    var baseURL: URL{
        switch self {
            //--
        case .userProfile(let userId):
            return URL(string: NetworkManager.sharedInstance.baseAPIUrl + "/user/Profile?userid=\(userId)")!
            //--
        case .userEvents(let userId, let pageNumber, let pageSize,let eventName, let sortColumn):
            return URL(string: NetworkManager.sharedInstance.baseAPIUrl + "/user/events?pageNumber=\(pageNumber)&pageSize=\(pageSize)&eventName=\(eventName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)&userid=&\(userId)sortColumn=\(sortColumn)")!
         //--
        case .userEventsattendace(let eventid, let attendeeName):
            return URL(string: NetworkManager.sharedInstance.baseAPIUrl + "/event/attendees?eventid=\(eventid)&attendeeName=\(String(describing: attendeeName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!))")!
        case .questionList(let eventID):
            return URL(string: NetworkManager.sharedInstance.baseAPIUrl + "/Event/Questionaire?eventid=\(eventID)")!
        case .getTicket(let attendeeId):
            return URL(string: NetworkManager.sharedInstance.baseAPIUrl + "/event/Attendee/Ticket?attendeeId=\(attendeeId)")!

        default:
            return URL(string: NetworkManager.sharedInstance.baseAPIUrl)!
        }
    }


    var path: String {
        switch self {
            
        case .userLogin:
            return "/token"
        case .forgetPassword:
            return "/user/ForgotPassword"
        case .changePassword:
            return "/user/changepassword"
        case .userProfile( _):
            return ""
        case .userEvents(_,_,_, _,_):
            return ""
        case .userEventsattendace(_,_):
            return ""
        case .addNewUser:
            return "/event/attendee"
        case .attendeeCheckIN:
            return "/event/Attendee/CheckIn"
        case .questionList:
            return ""
        case .questionListAnswerSubmit:
            return "/event/Answer/Submit"
        case .qrCodePostApi:
            return "/event/Attendee/QrCode";
        case .getTicket( _):
            return ""

        }
    }
    var method: Moya.Method {
        switch self {
        case .userLogin:
            return .post
        case .forgetPassword:
            return .post
        case .changePassword:
            return .post
        case .addNewUser:
            return .post
        case .attendeeCheckIN:
            return .post
        case .questionListAnswerSubmit:
            return .post
        case .qrCodePostApi:
            return .post
        default:
            return .get
        }
    }
    
    /// Responsible for calling the services.
    var task: Task {
        
        switch self {
        case .userLogin(let email, let password, _):
            return .requestParameters(parameters: ["username":email,"password":password,"grant_type":"password"], encoding: URLEncoding.default)
        case .forgetPassword(let email):
            return .requestParameters(parameters: ["Email" : email], encoding: URLEncoding.default)
        case .changePassword(let newPassword, let oldPassword, _):
                return .requestParameters(parameters: ["OldPassword":oldPassword,"NewPassword":newPassword], encoding: URLEncoding.default)
        case .addNewUser(let eventid, let firstName, let lastName,let email, let Designation, let PhoneNumber,let Company):
            return .requestParameters(parameters: ["eventid":eventid,"firstName":firstName,"lastName":lastName,"email":email], encoding: URLEncoding.default)
        case .attendeeCheckIN(let AttendeeId, let Action):
            return .requestParameters(parameters: ["AttendeeId":AttendeeId,"Action":Action], encoding: URLEncoding.default)
        case .questionListAnswerSubmit(let answerDict):
            return .requestParameters(parameters: answerDict, encoding: URLEncoding.default)

        case .qrCodePostApi(let AttendeeId, let QRCode):
       return .requestParameters(parameters: ["AttendeeId":AttendeeId,"QRCode":QRCode], encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    var parameters: [String:Any]? {
        switch self {
        case .questionListAnswerSubmit(let answerDict):
            return answerDict
        default:
            return nil
        }
    }
    
    /// Stub/Sample date
    var sampleData: Data {
        switch self {
        default :
            return "".utf8Encoded
        }
        
    }
    var headers: [String: String]? {
        return ["Content-type": "application/x-www-form-urlencoded"]
    }
}
// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}



//
//  File.swift
//  RGNetwork
//
//  Created by ReevesGoo on 2017/6/16.
//  Copyright © 2017年 ReevesGoo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreTelephony

class TMNetwork: SessionManager {
    
    static let shared :TMNetwork = {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let tools = TMNetwork(configuration: configuration)
        return tools
    }()
    
    //设置请求头 给服务器发送相关信息 比如AppKey用于服务端验证
    fileprivate lazy var initHeader:HTTPHeaders = {
        
        var dict = [String:String]()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        dict["RG_VERSION"] = version
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        let rate:CGFloat = UIScreen.main.scale
        let uuidStr = UIDevice.current.identifierForVendor?.uuidString
        let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName
        let deviceInfo:String = String(format: "OSVersion=%@&UDID=%@&Width=%f&Height=%f&VersionName=%@&VersionCode=%@&Carrier=%@&Brand=APPLE", UIDevice.current.systemVersion,uuidStr!,kScreenW*rate,kScreenH*rate,version,build,carrier!)
        dict["RG_DEVICE-INFO"] = deviceInfo
        //        print(deviceInfo)
        dict["RG_KEY"] = kAppKey
        dict["RG_CLIENTTYPE"] = "iOS"
        
        return dict
        
    }()
    
    //附加请求头信息
    fileprivate func setHttpHeader(url:String) -> HTTPHeaders {
        let timestamp = "1430000000"  //示例
        //        let token = NSString(format: "/api%@%@%@", url,timestamp,kAppToken)
        //        initHeader["X-CTAA-TOKEN"] = token.md5() as String
        initHeader["RG_TIMESTAMP"] = NSString(format: "%@", timestamp) as String
        
        //添加cookie，用于服务端验证身份
        if let cookie = userDefault.object(forKey: kHttpCookie) {
            initHeader["Cookie"] = cookie as? String
        }
        
        return initHeader
    }
    
}

extension TMNetwork {
    
    //网络请求封装
    
    func dataRequest(urlString: String, isGet:Bool, params : [String : Any]?, callback:
        @escaping (_ response: AnyObject?, _ error: String?)->()) {
        
        let finalUrl = portString(lastPath: urlString)
        let header = setHttpHeader(url: urlString)
        request(finalUrl, method:isGet ? .get : .post, parameters: params,headers:header).responseString{ (responseStr) in
            
            switch responseStr.result{
            case .success(let value):
                
                let result = JSON.init(parseJSON: value)
                //打印解析后的数据
                DLogMore(message: result)
                guard let code = result["status"].int else{
                    callback(nil, value)
                    return
                }
                switch code{
                    
                case 10000:
                    //请求数据成功
                    callback(result["result"].object as AnyObject, nil)
                case 10003:
                    //Cookie失效,重新登录
                    callback(nil, "登录信息已过期，请重新登录！")
                    //删除本地保存的用户和cookie信息
                    userDefault.removeObject(forKey: kHttpCookie)
                    userDefault.removeObject(forKey: kUserInfo)
                    userDefault.removeObject(forKey: kUserType)
                    //                    notice.post(name: NSNotification.Name.init(KLoginCookiesInvalidNoti), object: false)
                    
                case 10011,10012:
                    //做对应 处理
                    callback(nil, result["message"].string)
                default:
                    callback(nil, result["message"].string)
                }
                
            case .failure(let error):
                callback(nil, error.localizedDescription)
            }
            
        }
    }
    
    //上传图片网络请求
    func postImageRequest(urlString:String,params:[String:String]?,progress:(_ uploadProgress:Progress)->(),img:UIImage,callback:
        @escaping (_ response: AnyObject?, _ error: String?)->()) -> () {
        
        let finalUrl = portString(lastPath: urlString)
        let header = setHttpHeader(url: urlString)
        upload(multipartFormData: { (multiFormData) in
            
            let imageData = UIImageJPEGRepresentation(img, 1.0)
            //            let imageName = String(describing: Date()) + ".jpg"
            multiFormData.append(imageData!, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
            //参数拼接
            if params != nil {
                for (key,value) in params!{
                    multiFormData.append(value.data(using: .utf8)!, withName: key)
                }
            }
            
        }, to: finalUrl,headers:header) { (encodingResult) in
            switch encodingResult {
            case .success(let uploadRequest, _, _):
                
                uploadRequest.responseString(completionHandler: { (responseStr) in
                    
                    switch responseStr.result{
                    case .success(let value):
                        
                        let result = JSON.init(parseJSON: value)
                        guard let code = result["status"].int else{
                            callback(nil, "数据错误")
                            return
                        }
                        
                        switch code{
                        case 10000:
                            callback(result["result"].object as AnyObject, nil)
                        default:
                            callback(nil, result["message"].string)
                        }
                        
                    case .failure(let error):
                        print("error:\(error)")
                        callback(nil, "上传失败")
                    }
                    
                })
            case .failure(let error):
                print(error)
                callback(nil, "上传失败")
            }
        }
    }
    
    //get测试
    func getRequet(urlString: String,callback:
        @escaping (_ response: AnyObject?, _ error: String?) -> ()) {
        
        let finalUrl = portString(lastPath: urlString)
        //        let header = setHttpHeader(url: urlString)
        request(finalUrl).responseString { (responseStr) in
            
            switch responseStr.result{
            case .success(let value):
                
                let result = JSON.init(parseJSON: value)
                
                print("result:\(result)")
                
                guard let code = result["code"].int else{
                    callback(nil, "数据错误")
                    return
                    
                }
                switch code{
                    
                case 10000:
                    //                    let tempData = try! JSONSerialization.data(withJSONObject: result["result"].object, options:.prettyPrinted)
                    //                    callback(tempData as AnyObject, nil)
                    
                    callback(result["result"].object as AnyObject, nil)
                default:
                    callback(nil, result["msg"].string)
                }
            case .failure(let error):
                DLogMore(message: error.localizedDescription)
                callback(nil, error.localizedDescription)
            }
        }
        
    }
    
    //长连接 post请求（暂未用）
    func postNewOrderRequest(urlString: String, params : [String : Any], callback:
        @escaping (_ response: String?, _ error: String?)->()) {
        
        let finalUrl = portString(lastPath: urlString)
        let header = setHttpHeader(url: urlString)
        var dict :[String:Any] = params
        if dict["uid"] != nil {
            //            let infoDict = Utility.defaults(forKey: kUserInfo) as! [String:String]
            //            dict["uid"] = infoDict["uid"]
            //            dict["user_token"] = infoDict["user_token"]
        }
        
        request(finalUrl, method: .post, parameters: dict,headers:header).responseString{ (responseStr) in
            
            switch responseStr.result{
            case .success(let value):
                
                //                let result = JSON.init(data: value.data(using: .utf8, allowLossyConversion: false)!)
                //
                //                print("result:\(result)")
                
                callback(value, nil)
                
            case .failure(let error):
                print("error:\(error)")
                callback(nil, error.localizedDescription)
            }
            
        }
    }
    
    
    
    //解密后string进行Json反序列化处理
    func dictionaryWithJsonString(jsonStr:String) -> [String:AnyObject]? {
        
        let jsonData = jsonStr.data(using: .utf8)
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
        
        return dict as? [String : AnyObject]
    }
    
    //备注 SwiftyJSON用法备注
    //    let jsonObject = json.object as AnyObject
    //
    //    let jsonObject = json.rawValue  as AnyObject
    //
    //    //JSON转化为Data
    //    let data = json.rawData()
    //
    //    //JSON转化为String字符串
    //    if let string = json.rawString() {
    //        //Do something you want
    //    }
    //
    //    //JSON转化为Dictionary字典（[String: AnyObject]?）
    //    if let dic = json.dictionaryObject {
    //        //Do something you want
    //    }
    //
    //    //JSON转化为Array数组（[AnyObject]?）
    //    if let arr = json.arrayObject {
    //        //Do something you want
    //    }
    
}


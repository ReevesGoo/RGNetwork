//
//  ViewController.swift
//  RGNetwork
//
//  Created by ReevesGoo on 2017/6/16.
//  Copyright © 2017年 ReevesGoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginRequest()
        
        
    }

    //exampl: 登录请求实例
    private func loginRequest(){
        
        let param = ["username":"John Wick","password":"88888888"] as [String : Any]
        
        TMNetwork.shared.dataRequest(urlString: kUserLogin, isGet: false, params: param){ (response : AnyObject?, error:String?) in
            
            if error != nil {
                return
            }
            guard let userInfo = response as? [String:Any] else{
                return
            }
            //本地保存用户信息
            let userData = NSKeyedArchiver.archivedData(withRootObject: userInfo)
            userDefault.set(userData, forKey: kUserInfo)
            userDefault.synchronize()
            
            //本地保存cookie
            if let cookies = HTTPCookieStorage.shared.cookies(for: URL.init(string: baseDomain)!){
                let request = HTTPCookie.requestHeaderFields(with: cookies)
                if let requestCookie = request["Cookie"] {
                    print(cookies)
                    print(requestCookie)
                    userDefault.set(requestCookie, forKey: kHttpCookie)
                    userDefault.synchronize()
                }
            }
        }
        
    }


}


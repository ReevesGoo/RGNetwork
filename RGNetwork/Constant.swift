//
//  Constant.swift
//  SDY-daoyouduan
//
//  Created by ReevesGoo on 2017/6/16.
//  Copyright © 2017年 ReevesGoo. All rights reserved.
//

import Foundation
import UIKit

let kAppKey = ""
let kAppToken = ""

let baseDomain = "http://192.168.11.184:8002/api"
let imageDomainUrl = ""
let imageGainUrl = ""

let kUserInfo = "userInfo"
let kUserType = "userType"
let kHttpCookie = "HttpCookie"


func imageDomainString(lastPath:String) -> String{
    return imageDomainUrl +  (lastPath)
}

func portString(lastPath:String) -> String {
    return baseDomain + (lastPath)
}


let kUserLogin = "/user/login"


func DLog<T>(message:T){
    #if DEBUG
    print(message)
    #endif
}

func DLogMore<T>(message:T,filename:String = #file,methodName:String = #function,lineNum:Int = #line){
    #if DEBUG
    let now = Date()
    print("文件:\(filename)\n方法:\(methodName)\n行数:\(lineNum)\n打印时间:\(now)\n打印信息\(message)")
    #endif
}

//判断用户是否登录
func userIsLogin() -> Bool{
    if let _ = userDefault.object(forKey: kHttpCookie) , let _ = userDefault.object(forKey: kUserInfo) {
        return true
    }else{
        return false
    }
    
}

func convertArrayToString(arr:[[String:Any]]) -> String {
    var result:String = ""
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: arr, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
            result = JSONString
        }
    } catch {
        result = ""
    }
    return result
}

func convertDictionaryToString(dict:[String:Any]) -> String {
    var result:String = ""
    do {
        //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
            result = JSONString
        }
    } catch {
        result = ""
    }
    return result
}

func SF(form:String,argu:String) -> String{
    return String(format: form, argu)
}

///  快速创建一个颜色

func RGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red / 255, green: green / 255 , blue: blue / 255, alpha: 1)
}
///  随机颜色
func RandomColor() -> UIColor {
    return RGB(red: CGFloat(arc4random() % 256), green: CGFloat(arc4random() % 256), blue: CGFloat(arc4random() % 256))
}


//屏幕尺寸
let kScreenFrame = UIScreen.main.bounds
let kScreenSize = UIScreen.main.bounds.size

//屏幕高度
let kScreenH = UIScreen.main.bounds.size.height;

//屏幕宽度
let kScreenW = UIScreen.main.bounds.size.width;


// NSUserDefault
let userDefault = UserDefaults.standard
// 通知中心
let notice = NotificationCenter.default

//判断iPhone4
let IPHONE4_DEV:Bool! = (UIScreen.main.bounds.size.height == 480) ? true : false

//判断iPhone5/5c/5s
let IPHONE5_DEV:Bool! = (UIScreen.main.bounds.size.height == 568) ? true : false

//判断iPhone6/6s
let IPHONE6s_DEV:Bool! = (UIScreen.main.bounds.size.height == 667) ? true : false

//判断iPhone6p
let IPHONE6p_DEV:Bool! = (UIScreen.main.bounds.size.height == 736) ? true : false

//其它屏幕尺寸相对iphone6的宽度
func kWithRelIPhone6(width: CGFloat) -> CGFloat {
    return width * kScreenW / 750.0;
}

//其它屏幕尺寸相对iphone6的高度
func kHeightRelIPhone6(width: CGFloat) -> CGFloat {
    return width * kScreenH / 1334.0;
}


//RGB 16进制转换
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

//通过颜色获取图片
func imageWithColor(color:UIColor, size:CGSize) -> UIImage {
    
    let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height);
    UIGraphicsBeginImageContext(rect.size);
    let context = UIGraphicsGetCurrentContext();
    context?.setFillColor(color.cgColor);
    context?.addRect(rect);
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext();
    return img!;
}






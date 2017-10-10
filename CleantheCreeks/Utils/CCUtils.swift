//
//  CCUtils.swift
//  Clean the Creek
//
//  Created by a on 2/22/16.
//  Copyright © 2016 RedCherry. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreGraphics

extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        tintColor.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

class CCUtils {
    
    /******* Just Get Color ********/
    static func getGMAquaColor() -> UIColor {
        return UIColor (red: 16/256.0, green: 185/256.0, blue: 215/256.0, alpha: 1)
    }
    
    /******* Just Get Fonts *******/
    static func getAppFont(fontsize: CGFloat) -> UIFont! {
        return UIFont(name: "ProximaNovaSoft-Regular", size: fontsize);
    }
    
    static func getAppMediumFont(fontsize: CGFloat) -> UIFont! {
        return UIFont(name: "ProximaNovaSoft-Medium", size: fontsize);
    }
    
    static func getAppBoldFont(fontsize: CGFloat) -> UIFont! {
        return UIFont(name: "ProximaNovaSoft-Bold", size: fontsize);
    }
    
    static func getAppSemiBoldFont(fontsize: CGFloat) -> UIFont! {
        return UIFont(name: "ProximaNovaSoft-SemiBold", size: fontsize);
    }
    /*
    Define UIColor from hex value
    
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    static func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    static func parseDateTime(dateStr: String!, format:String="yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ") -> NSDate! {
        if(dateStr == nil || dateStr.isEmpty) {
            return nil;
        }
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.dateFromString(dateStr)!
    }
    
    static func printDateTime(date: NSDate!,format:String="yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ") -> String! {
        if(date == nil) {
            return "";
        }
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.stringFromDate(date);
    }
    
    static func distanceFromCoordinate(fromLat: Double, fromLon: Double, toLat: Double, toLon: Double) -> Double {
        let locA = CLLocation(latitude: fromLat, longitude: fromLon);
        let locB = CLLocation(latitude: toLat, longitude: toLon);
        
        return locA.distanceFromLocation(locB);
    }
    
    static func setTextAccessoryView(text: UIView, target: AnyObject?, selector: Selector?) {
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: text, action: #selector(UIResponder.resignFirstResponder))
        barButton.tintColor = UIColor.blackColor()
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        toolbar.barTintColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue:241.0/255.0, alpha:1.0)
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: text, action: #selector(UIResponder.resignFirstResponder))
        
        toolbar.items = [flexible, flexible, barButton]
        
        if let ctrl = text as? UITextView {
            ctrl.inputAccessoryView = toolbar
        }
        else if let ctrl = text as? UITextField {
            ctrl.inputAccessoryView = toolbar
        }
        
    }
    
    static func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
        let ms = Int((interval % 1) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }
    
    /*
    1 : Attribute Name
    2 : StartIndex
    3 : Length
    4 : Value
    */
    
    static func insertStyle2Label(label : UILabel , params : [(String, Int, Int, AnyObject)]){
        let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: label.text!)
        
        for (attributeName, startIndex, length, value) : (String, Int, Int, AnyObject) in params {
            if attributeName == "font"{
                attributedString.addAttribute(NSFontAttributeName, value: value, range: NSMakeRange(startIndex, length))
            }else if attributeName == "color" {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: value, range: NSMakeRange(startIndex, length))
            }
        }
        
        label.attributedText = attributedString
    }
    
    static func widthOfScreen() -> CGFloat{
        let screenRect = UIScreen.mainScreen().bounds
        return screenRect.size.width
    }
    
    static func heightOfScreen() -> CGFloat {
        let screenRect = UIScreen.mainScreen().bounds
        return screenRect.size.height
    }
    
    static func heightOfNonSearchBarHeader() -> CGFloat {
        return heightOfScreen()
    }
    
    static func heightOfHeader() -> CGFloat {
        return heightOfScreen() * 0.16042
    }
    
}

extension NSDate {
    static func date2String(date : NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.stringFromDate(date)
        return strDate
    }
    
    static func string2Date(strDate : String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.dateFromString(strDate)
        return date!
    }
    
    static func intervalString2Date(strIntervalDate : String) -> NSDate {
        
        let timeinterval : NSTimeInterval = (strIntervalDate as NSString).doubleValue
        let date = NSDate(timeIntervalSince1970:timeinterval)
        return date
    }
    
    static func strDate2stringHumanReadableDate(strDate : String, datePattern : String = "EEEE MMM dd") -> String{
        let date = NSDate.string2Date(strDate)
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = datePattern
        
        let dateString = dayTimePeriodFormatter.stringFromDate(date)
        return dateString
    }
    
    static func date2StringHumanReadableDate(date : NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM. dd yyyy"
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
}

extension NSRange {
    func toRange(string: String) -> Range<String.Index> {
        let startIndex = string.startIndex.advancedBy(location)
        let endIndex = startIndex.advancedBy(length)
        return startIndex..<endIndex
    }
}

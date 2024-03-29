//
//  CommonClass.swift
//
//
//  Created by Maheshwari on 17/05/16.
//  Copyright © 2016 Maheshwari. All rights reserved.
//

import UIKit
import SystemConfiguration
import Foundation


protocol PostCodeVerification {
    func success(addressArray:Array<String>)
    func error(error:String)
}

class API: UIView {
    let session = NSURLSession.sharedSession()
    var delegate: PostCodeVerification?
    
    //Checking Reachability function
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func verifyPostCode(postcode:String){
        
        //Check if network is present
        if(self.isConnectedToNetwork())
        {
            
            let urlString = String(format:"https://api.getaddress.io/v2/uk/%@?api-key=McuJM5nIIEqqGRVCRUBztQ4159",postcode)
            
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL: url!)
            
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let data = data
                {
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                    if let dict = json as? NSDictionary
                    {
                        if let addressArray = dict["Addresses"] as? Array<String>
                        {
                            self.delegate?.success(addressArray)
                        }
                        else{
                            self.delegate?.error("The postcode doesn't look right")
                        }
                        
                    }
                }
                
            }
            dataTask.resume()
        }
        else{
            delegate?.error("No network found")
        }
    }
    
    func registerTheUserWithTitle(title:String,first_name:String,second_name:String,date_of_birth:String,email:String,phone_number:String,address_1:String,address_2:String,address_3:String,town:String,country:String,post_code:String,house_number:String)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://54.191.188.214:8080/SavioAPI/V1/Customers/Register")!)
        request.HTTPMethod = "POST"
        
        let params = ["title":title,"first_name":first_name,"second_name":second_name,"date_of_birth":date_of_birth,"email":email,"phone_number":phone_number,"address_1":address_1,"address_2":address_2,"address_3":address_3,"town":town,"country":country,"post_code":post_code,"house_number":house_number] as Dictionary<String, String>

        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    print(jsonResult)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        })
        
        
    }
    
    
    //KeychainItemWrapper methods
    func storeValueInKeychain(pin:String){
        //Save the value of password into keychain
        KeychainItemWrapper.save("myPassword", data: pin)
    }

    func getValueFromKeychain()-> String{
        //get the value of password from keychain
        return KeychainItemWrapper.load("myPassword") as! String
        
    }
    
}

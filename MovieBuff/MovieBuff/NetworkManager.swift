//
//  NetworkManager.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 16/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import Foundation

public enum Method: String {
    case GET = "GET"
    case POST = "POST"
}

typealias NetworkRequestCompletionHandler = (response : AnyObject?, error : NSError?) -> Void

class NetworkManager: NSObject {
    
    var queueOpened: Bool?
    var requestQueue: NSOperationQueue?
    
    class var sharedInstance : NetworkManager {
        struct Static {
            static var instance: NetworkManager?
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = NetworkManager()
        }
        return Static.instance!
    }
    
    
    override init() {
        self.requestQueue = NSOperationQueue()
        self.requestQueue?.name = "AwesomeNetworkQueue"
        self.queueOpened = true
    }
    
    func requestForData(method: Method, url: String, param: NSDictionary, completionBlock:NetworkRequestCompletionHandler) {
        if self.queueOpened == true {
            
            var requestOperation = NetworkRequest(method: method, address: url, param: param, completion: completionBlock)
            self.requestQueue?.addOperation(requestOperation)
        }
    }
    
    func cancelAllRequest() {
        self.requestQueue?.cancelAllOperations()
    }
}

extension NSString {
    var escapeStr: NSString {
        return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,self,"[].",":/?&=;+!@#$()',*",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
    }
}

class NetworkRequest : NSOperation {
    
    var address: String?
    var method: Method?
    var operationParameters: NSDictionary?
    var operationCompletionBlock: NetworkRequestCompletionHandler?
    
    var operationTask: NSURLSessionTask?
    var operationResponse: NSHTTPURLResponse?
    
    init(method: Method, address: String, param: NSDictionary, completion: NetworkRequestCompletionHandler) {
        
        self.method = method
        self.address = address
        self.operationParameters = param
        self.operationCompletionBlock = completion
    }
    
    func finish() {
        if (self.operationTask != nil) {
            self.operationTask?.cancel()
            self.operationTask = nil
        }
    }
    
    override var asynchronous: Bool {
        return true
    }
    
    override func cancel() {
        if self.executing == true {
            self.finish()
        }
        super.cancel()
    }
    
    override func start() {
        if self.cancelled {
            self.finish()
            return
        }
        
        if self.method == .GET {
            self.GET()
        }
        else {
            self.POST()
        }
    }
    
    
    func parameterString() -> String {
        let params = self.operationParameters!
        var stringParameters = NSMutableArray(capacity: params.count)
        params.enumerateKeysAndObjectsUsingBlock { (key, object, stop) -> Void in
            if object.isKindOfClass(NSString) {
                let val = object as! NSString
                stringParameters.addObject("\(key)=\(val.escapeStr)")
            }
            else if object.isKindOfClass(NSNumber) {
                stringParameters.addObject("\(key)=\(object)")
            }
            else {
                NSException(name:NSInvalidArgumentException, reason:"\(self.method?.rawValue) requests only accept NSString and NSNumber parameters.", userInfo:nil).raise()
            }
        }
        return stringParameters.componentsJoinedByString("&")
    }
    
    
    func GET() {
    
        let strURL = self.address! + "&" + self.parameterString()
        println("URL: \(strURL)")
        let url = NSURL(string: strURL)
        
        let session = NSURLSession.sharedSession()
        self.operationTask = session.dataTaskWithURL(url!, completionHandler: { data, response, error -> Void in
            
            self.parseResponse(response, data: data, error: error)
        })
        
        self.operationTask!.resume()
        
    }
    
    
    func POST() {
    
        let url = NSURL(string: self.address!)
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = Method.POST.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(self.operationParameters!, options: nil, error: &err)

        let session = NSURLSession.sharedSession()
        self.operationTask = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in

            self.parseResponse(response, data: data, error: error)
        })
        
        self.operationTask!.resume()
    }
    
    
    func parseResponse(response: NSURLResponse!, data: NSData?, error: NSError?) {
    
        self.operationResponse = (response as! NSHTTPURLResponse)
//        println("[Status Code]: \(self.operationResponse?.statusCode)");
//        println("Response: \(response)")
        
//        var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
//        println("Body: \(strData)")

        var err: NSError?
        var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments, error: &err)  //as? NSDictionary
        
        // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
        if(err != nil) {
            println(err!.localizedDescription)
            let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
            println("Error could not parse JSON: '\(jsonStr)'")
            
            self.callCompletionBlock(json, error: err)
        }
        else {
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON: AnyObject = json {
                
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
//                var success = parseJSON["success"] as? Int
//                println("Succes: \(success)")

                self.callCompletionBlock(parseJSON, error: err)
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: \(jsonStr)")
                
                self.callCompletionBlock(data, error: error)

            }
        }
    }
    
    func callCompletionBlock(response: AnyObject?, error: NSError?) {
    
        dispatch_async(dispatch_get_main_queue()) {
            var newErr: NSError?
            if response == nil && error != nil { //check this as well self.operationURLResponse.statusCode == 500
                let dicInfo = [NSLocalizedDescriptionKey: "Bad Server Response."]
                newErr = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: dicInfo)
            }
            
            if self.operationCompletionBlock != nil && self.cancelled == false {
                self.operationCompletionBlock!(response: response, error: newErr)
            }
            
            self.finish()
        }
        
    }
    
}



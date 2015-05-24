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
        dispatch_once(&Static.onceToken, { () -> Void in
            Static.instance = NetworkManager()
        })
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
    func escapeStr() -> (NSString) {
        var escapeStr: NSString {
            
            return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,self,"[].",":/?&=;+!@#$()',*",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
        }
        return escapeStr
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
                stringParameters.addObject("\(key)=\(val.escapeStr())")
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
        let url = NSURL(string: strURL)
        
        let session = NSURLSession.sharedSession()
        self.operationTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, urlResponse: NSURLResponse!, error: NSError!) -> Void in
            
            self.operationResponse = (urlResponse as! NSHTTPURLResponse)
            println("[Status Code]: \(self.operationResponse?.statusCode)");
            
            self.callCompletionBlock(data, error: error)
        })
        
        self.operationTask!.resume()
        
    }
    
    func POST() {
    
        let session = NSURLSession.sharedSession()
        let strBasePath = "http://www.myapifilms.com/imdb?token=3962c3d1-e56d-40fd-b392-3b03bc621454"
        let strURL = strBasePath + self.address!
        let url = NSURL(string: strURL)
        var mutableURLRequest = NSMutableURLRequest(URL: url!)
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        //            println(se)
        //        mutableURLRequest.HTTPMethod = method.rawValue

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











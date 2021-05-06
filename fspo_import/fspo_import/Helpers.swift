//
//  Helpers.swift
//  fspo_import
//
//  Created by Кирилл on 29.04.2021.
//

import Foundation


public typealias JSON = [String: AnyObject]
public func asJSON(_ anyObject: AnyObject) -> JSON? { anyObject as? JSON }
public func asArray(_ anyObject: AnyObject) -> [JSON]? { anyObject as? [JSON] }
public func asInt(_ anyObject: AnyObject) -> Int? { anyObject as? Int }
public func asString(_ anyObject: AnyObject) -> String? { anyObject as? String }

extension URLSession {
   public func syncTask(with: URL) -> (Data?, Error?) {
       var retData: Data?
       var retError: Error?
       
       let semaphore = DispatchSemaphore(value: 0);
       dataTask(with: with) { (data, _, error) in
           retData = data
           retError = error
           semaphore.signal()
           print(with)
       }.resume()
       _ = semaphore.wait(timeout: .distantFuture)
       
       return (retData, retError)
   }
   
   public func jsonTask(with: URL) throws -> JSON?  {
       let result = syncTask(with: with)
       if let data = result.0 {
           return try JSONSerialization.jsonObject(with: data, options: []) as? JSON
       }
       if let error = result.1 { throw error }
       return nil
   }
}

import CryptoKit
public func MD5(_ string: String) -> String {
   let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())

   return digest.map {
       String(format: "%02hhx", $0)
   }.joined()
}


protocol KeepAlive {
    func keepAlive()
}
extension KeepAlive {
    func keepAlive() { Thread.sleep(forTimeInterval: .infinity) }
}

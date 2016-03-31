//
//  Installer.swift
//  Alcatraz
//
//  Created by Wojciech Czekalski on 16.09.2015.
//  Copyright © 2015 supermar.in. All rights reserved.
//

import Foundation

func installPackage(package: ATZPackage) -> ResultType { // this is quick and dirty
    
    var result = ResultType.Error(description: "undefined")
    
    let semaphore = dispatch_semaphore_create(0)
    
    let queue = NSOperationQueue()
    
    queue.addOperationWithBlock { () -> Void in
        
        package.installer().installPackage(package, progress: {(_,_) -> Void in }, completion: { (error: NSError!) -> Void in
            if let error = error {
                result = .Error(description: error.localizedDescription)
            } else {
                result = .Finish(description: nil)
            }
            dispatch_semaphore_signal(semaphore)
        })
    }
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    
    return result
}
//
//  main.swift
//  AlcatrazCLI
//
//  Created by Wojciech Czekalski on 09.09.2015.
//  Copyright © 2015 supermar.in. All rights reserved.
//

import Foundation

enum ResultType {
    case Continue(f:() -> ResultType)
    case Error(description: String)
    case Finish(description: String?)
    
    func resolve() -> String? {
        switch self {
        case .Error(let description):
            return description
        case .Continue(let f):
            return f().resolve()
        case .Finish(let d):
            return d
        }
    }
}

enum Command: String {
    case help, update, install, remove
    
    func parse(args:[String]) -> ResultType {
        switch self {
        case .help:
            guard args.count == 0 else {
                return .Error(description: errorString(args))
            }
            return .Continue(f: helpString)
        case .update:
            return .Finish(description: nil)
        case .install:
            return validateInstall(args)
        case .remove:
            return .Finish(description: nil)
        }
    }
    
    var description: String {
        get {
            switch self {
            case .update:
                return "updates Alcatraz and Alcatraz CLI"
            case .remove:
                return ""
            case .help:
                return ""
            case .install:
                return "installs a package. Usage: 'alcatraz install [package-name]'"
            }
        }
    }
    
    static let commands: [Command] = [.update, .install, .remove]
}

func validateInstall(args: [String]) -> ResultType {
    guard args.count == 1 else {
        return ResultType.Error(description: errorString(args))
    }
    return .Continue(f: install(args.first!))
}

func install(packageName: String) -> () -> ResultType {
    return {
        if let package = packageForName(packageName) {
            return installPackage(package)
        } else {
            return .Error(description: "Could not fetch \(packageName)")
        }
    }
}

func packageForName(name: String) -> ATZPackage? {
    
    let URL = NSURL(string: ATZDownloader.packageRepoPath())

    if let URL = URL, data = NSData(contentsOfURL: URL) {
        
        do {
            let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary as Dictionary
            
            let packages = ATZPackageFactory.createPackagesFromDicts(dict["packages"]! as! [NSObject : AnyObject]) as! Array<ATZPackage>
            return packages.filter({ (package: ATZPackage) -> Bool in
                    return package.name.isEqual(name)
                }).first
            
        } catch {
            
        }
    }
    return nil
}

func helpString() -> ResultType {
    
    let introText = "\nAlcatraz is an amazing Xcode package manager\n\n"
    let commandsCaption = "   The available commands are:\n"
   
    let formatCommand = { (command: Command) -> String in
        return "      " + "\(command.rawValue) - \(command.description)" + "\n"
    }
    
    let helpText = introText + commandsCaption + Command.commands.map(formatCommand).joinWithSeparator("");
    
    return .Finish(description: helpText)
}

func errorString(args: [String]) -> String {
    let argsString = args.joinWithSeparator(" ")
    let fullCommandString = "alcatraz \(argsString)".stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    
    return "\"\(fullCommandString)\" is not a valid command. See 'alcatraz help' for more info"
}

func run(var args: [String]) {
    
    args.removeFirst() // Removes executable path from arguments
    
    guard let command = Command(rawValue: args.first!) else {
        print(errorString(args))
        return
    }
    
    args.removeFirst()
    
    if let retString = command.parse(args).resolve() {
        print(retString)
    }
}

run(Process.arguments)

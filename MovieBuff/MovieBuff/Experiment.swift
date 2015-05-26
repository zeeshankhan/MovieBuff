//
//  Experiment.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 26/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

    import Foundation

    @objc protocol FooDelegate {
        optional func makeSomething()
    }

    class Foo {
        weak var myDelegate: FooDelegate?
        init(delegate: FooDelegate) {
            self.myDelegate = delegate
        }
        
        func doSomething() {
            println("Foo is doing something...")
            self.myDelegate?.makeSomething!()
        }
    }

    class Boo : Foo, FooDelegate {
        
        class var sharedInstance: Boo {
            struct Static {
                static var instance: Boo?
                static var onceToken: dispatch_once_t = 0
            }
            dispatch_once(&Static.onceToken) {
                Static.instance = Boo(delegate: self)
            }
            return Static.instance!
        }
        
        func makeSomething() {
            println("Boo, make something...")
        }
        
        // Cannot invoke 'dispatch_once' with an argument list of type '(inout dispatch_once_t, () -> _)'
    }


//
//  RegisterVC.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 16/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import UIKit

/*
You think that in the real world, doing this works? Because people like diplomatic answers, you know.
I think the world is changing. I am the same person in my organization also. I always give true feedback. Harsh. And sometimes people don’t like it. They feel crushed when you give true feedback on, let’s say, their design. So I am in a position to fix and not misguide them. If something is bad, I actually say that it is very, very bad. Others might say okay, work harder. I don’t like to do that. And it is not like I don’t have good things to say. I do. It is rare because the bar is very high, but I do whenever something crosses that. I believe it is very important to convey the right message.

// http://www.livemint.com/Leisure/RHydHC9UCUEClrokP5v7NM/Why-you-shouldnt-quit-in-a-hurry.html#nav=also_read

Optional
http://stackoverflow.com/questions/24003642/what-is-an-optional-value-in-swift

Implicit Optional
http://stackoverflow.com/questions/24006975/why-create-implicitly-unwrapped-optionals



*/

class RegisterVC: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    // MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK:- IBAction
    @IBAction func registerAction() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "login")
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

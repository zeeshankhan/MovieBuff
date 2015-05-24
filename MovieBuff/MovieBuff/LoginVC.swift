//
//  LoginVC.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 16/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    // MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    @IBAction func loginAction() {
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

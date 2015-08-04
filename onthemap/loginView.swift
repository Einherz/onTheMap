//
//  ViewController.swift
//  onthemap
//
//  Created by Amorn Apichattanakul on 7/20/15.
//  Copyright (c) 2015 amorn. All rights reserved.
//

import UIKit

class loginView: UIViewController, FBSDKLoginButtonDelegate,loginDelegate,UIGestureRecognizerDelegate {

    
    @IBOutlet weak var loginBtn: FBSDKLoginButton!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var avatarMeme: UIImageView!
    @IBOutlet weak var bubbleTxt: UIImageView!
    @IBOutlet weak var tryTxt: UILabel!
    
    let login:udacityAPI = udacityAPI()
    var delegate:loginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.layer.cornerRadius = 5;
        bgView.layer.masksToBounds = true;
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture);
        
        self.login.delegate = self
        self.loginBtn.delegate = self;
        self.loginBtn.readPermissions = ["public_profile", "email", "user_friends"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(sender: UIButton) {
        if(!emailTxt.text.isEmpty && !passwordTxt.text.isEmpty)
        {
            self.login.loginUdacity(emailTxt.text, passwordField: passwordTxt.text, facebook: "0")
        } else {
            let alert = UIAlertView()
            alert.title = "Please fill all information"
            alert.message = "Email and Password could not be empty"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
//Mark keyboard hiding
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        // force keyboard to hide
        self.view.endEditing(true)
        return false
    }
    
    func hideKeyBoard()
    {
        // force keyboard to hide
        self.view.endEditing(true);
    }
//Mark LoginDelegate
    func didFinishedLogin(jsonData: NSDictionary) {
        println("data inc \(jsonData)");
        if let errorStatus = jsonData.valueForKey("error") as? String{
            println("alert error");
            var serialImg: [UIImage] = [
                UIImage(named: "crymeme1.png")!,
                UIImage(named: "crymeme2.png")!,
                UIImage(named: "crymeme3.png")!,
                UIImage(named: "crymeme4.png")!
            ]
            
            self.avatarMeme.animationImages = serialImg
            self.avatarMeme.animationDuration = 1.75;
            self.avatarMeme.animationRepeatCount = 0;
            self.avatarMeme.startAnimating()
            
            UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.Repeat | UIViewAnimationOptions.Autoreverse, animations: { () -> Void in
                self.bubbleTxt.alpha = 1
                self.tryTxt.alpha = 1
            }, completion: nil)

            let title = jsonData.valueForKey("status") as! Int
            let alert = UIAlertView()
           alert.title = "Error status \(title)"
           alert.message = "\(errorStatus)"
           alert.addButtonWithTitle("OK")
           alert.show()
        } else {
            println("login succeed");
            self.avatarMeme.image = UIImage(named: "me.png")
            
            let udaKey = jsonData.valueForKey("account")?.valueForKey("key") as! NSString
            let registerID = jsonData.valueForKey("account")?.valueForKey("registered") as! Int
            let expire = jsonData.valueForKey("session")?.valueForKey("expiration") as! NSString
            let userID = jsonData.valueForKey("session")?.valueForKey("id") as! NSString
            let loginData:loginInfo = loginInfo(udaKey: udaKey, register: registerID, expiration: expire, userID: userID)
            
            let chkLogin:sharePreference = sharePreference()
           // println("\(udaKey)"
            chkLogin.saveLogin(udaKey, register: registerID, expire: expire, userID: userID)
            
            self.performSegueWithIdentifier("toMain", sender: self)
        }
    }
    
//Mark FacebookLoginViewDelegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("Log in")
        if(error != nil)
        {
            
        } else if result.isCancelled {
             println("User's not accept")
        } else {
            if result.grantedPermissions.contains("email")
            {
                //login completed
                println("User's accepted")
                self.getFBData();
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("Log out");
    }
    
    func getFBData()
    {
        let requestData:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        requestData.startWithCompletionHandler({(connection,result,error) -> Void in
            if(error != nil){
               println("Error : \(error)")
            } else {
               println("get user Data")
                let userName:NSString = result.valueForKey("name") as! NSString
                 println("User Name is: \(userName)")
                var userEmail:NSString? = result.valueForKey("email") as? NSString
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                println("token is: \(token)")
                
                // in case somebody use very old Facebook and not register email yet // this is from my experience with couple of Apps with Facebook
                if userEmail == nil{
                    userEmail = userName.stringByReplacingOccurrencesOfString(" ", withString: "")
                    userEmail = "\(userEmail)@facebook.com" // use for tracking if somebody has no email
                    println("User Email is: \(userEmail)")
                }
                
                self.login.loginUdacity(self.emailTxt.text, passwordField: self.passwordTxt.text, facebook: token)
                
            }
        })
    }
}


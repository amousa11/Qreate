//
//  CodeScannerViewController.swift
//  iOSDecalCustomApp
//
//  Created by Joshua Zeitsoff on 4/5/17.
//  Copyright © 2017 Cathy Pham Le. All rights reserved.
//

import UIKit
import Firebase
import MTBBarcodeScanner

class CodeScannervarwController: UIViewController {
    
    @IBOutlet var previewView: UIView!
    var scanner: MTBBarcodeScanner?
    var usersNamesOfPeopleThatAreHere : [String]?
    var eid: String?
    
    //@IBOutlet weak var label: UILabel!
    @IBAction func backButton(_ sender: UIButton) {
        //updateInvites()
        //self.performSegue(withIdentifier: "backToEvent", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanner = MTBBarcodeScanner(previewView: self.previewView)
        self.usersNamesOfPeopleThatAreHere = [""]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            try self.scanner?.startScanning(resultBlock: { codes in
                if let codes = codes {
                    for code in codes {
                        
                        let stringValue = code.stringValue!
                        let eventIndex = stringValue.index(stringValue.startIndex, offsetBy: 6)
                        let userIndex = stringValue.index(stringValue.startIndex, offsetBy: 7)
                        self.eid = stringValue.substring(to: eventIndex)
                        let username = stringValue.substring(from: userIndex)
                        
                        for inv in invites {
                            if (inv.eventId == self.eid && inv.username == username && inv.present == "false") {
                                
                                let alertController = UIAlertController(title: "Success!", message: "\(inv.username) has checked in.", preferredStyle: .alert)
                                
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                alertController.addAction(defaultAction)
                                
                                self.present(alertController, animated: true, completion: nil)
                                
                                //self.label.text = "Status: Success! " + inv.username
                                self.usersNamesOfPeopleThatAreHere?.append(inv.username)
                                inv.present = "true"
                                //tell database scanned
                            }
                            else if (inv.eventId == self.eid && inv.username == username && inv.present == "true") {
                                let alertController = UIAlertController(title: "Oops!", message: "\(inv.username) has already checked in.", preferredStyle: .alert)
                            
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                alertController.addAction(defaultAction)
                            
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            })
        } catch {
            NSLog("Unable to start scanning")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "unwindToMyEvent" {
                if let dest = segue.destination as? MyEventViewController {
                    if dest.scanned != nil {
                        if eid != nil {
                            if dest.scanned.keys.contains(eid!) {
                                dest.scanned[eid!]! += self.usersNamesOfPeopleThatAreHere!
                            } else {
                                dest.scanned[eid!] = self.usersNamesOfPeopleThatAreHere
                            }
                        }
                    }
                    
                    //dest.whoHasCheckedIn = self.usersNamesOfPeopleThatAreHere
                }
            }
        }
    }
}

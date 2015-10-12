//
//  StatsViewController.swift
//  ToDo
//
//  Created by Daniel Golden on 10/12/15.
//  Copyright © 2015 iOS Decal. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
  @IBOutlet weak var tasksLabel: UILabel!
  
  override func viewDidLoad() {
    //Update the label with the tasks completed
    tasksLabel.text = tasksCompleted.description
    super.viewDidLoad()
  }

}

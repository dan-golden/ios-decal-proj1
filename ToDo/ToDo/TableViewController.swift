//
//  TableViewController.swift
//  ToDo
//
//  Created by Daniel Golden on 10/11/15.
//  Copyright © 2015 iOS Decal. All rights reserved.
//

import UIKit

var tableData:Array<String> = Array<String>()
var timers = Array<NSTimer?>()

class TableViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func unwindToToDo(segue:UIStoryboardSegue) {
    
  }
  
  @IBAction func unwindSaveToToDo(sender:UIStoryboardSegue) {
    if let sourceViewController = sender.sourceViewController as? AddItemViewController, enteredText = sourceViewController.toDoText.text {
      //Append the new task and insert it into the table
      let newIndexPath = NSIndexPath(forRow: tableData.count, inSection: 0)
      tableData.append(enteredText)
      timers.append(nil)
      tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //Get a cell prototype, set it's label to be the correct task, and make sure it's not marked as completed
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    cell.accessoryType = .None
    cell.textLabel?.text = tableData[indexPath.row]
    return cell
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableData.count
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func deleteCell(timer:NSTimer) {
    //Remove the cell and decrement the number of tasks completed
    let indexPath = timer.userInfo as! NSIndexPath
    tableView.beginUpdates()
    tableData.removeAtIndex(indexPath.row)
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    tableView.endUpdates()
    tasksCompleted--
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    //Mark task as completed and display checkmark
    cell?.accessoryType = .Checkmark
    tasksCompleted++
    //Deselect the row so that it doesn't stay highlighted
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    //Start a 24-hour timer to delete the cell and add it to the timers array at the index corresponding to the cell row
    timers[indexPath.row] = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "deleteCell:", userInfo: indexPath, repeats: false)
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func decrementCompletedTasks(timer:NSTimer) {
    tasksCompleted--;
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      let cell = tableView.cellForRowAtIndexPath(indexPath)
      //If the cell is a completed task, invalidate its old timer and create a new one
      if cell?.accessoryType == .Checkmark {
        let oldTimer = timers[indexPath.row]!
        //Schedule a new timer to decrement the tasks, but don't remove the nonexistent cell from the table
        NSTimer.scheduledTimerWithTimeInterval(oldTimer.fireDate.timeIntervalSinceNow, target: self, selector: "decrementCompletedTasks:", userInfo: nil, repeats: false)
        oldTimer.invalidate()
      }
      //Remove the entry in the timer array corresponding to the cell
      timers.removeAtIndex(indexPath.row)
      //Update timers for cells below removed cell so that they remove the correct cell
      for(var i = indexPath.row; i<timers.count; i++) {
        if let oldTimer = timers[i] {
          //Create a new timer with the same time remaining as before, and a new NSIndexPath corresponding to the cell's new row in the userInfo
          let timer = NSTimer.scheduledTimerWithTimeInterval(oldTimer.fireDate.timeIntervalSinceNow, target: self, selector: "deleteCell:", userInfo: NSIndexPath(forRow:i, inSection:indexPath.section), repeats: false)
          //Invalidate the old timer and store the new timer in the array
          oldTimer.invalidate()
          timers[i] = timer
        }
      }
      //Remove the cell from the table
      tableView.beginUpdates()
      tableData.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      tableView.endUpdates()
    }
  }
  
}

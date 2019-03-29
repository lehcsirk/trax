//
//  ViewController.swift
//  justFasting
//
//  Created by Cameron Krischel on 2/8/19.
//  Copyright © 2019 Cameron Krischel. All rights reserved.
//

import UIKit
import QuartzCore

let defaults = UserDefaults.standard

class ViewController: UIViewController
{
    // Gradient shapelayer for popup menus when editing/cancelling/deleting
    let menuLayer = CAGradientLayer()
    
    var dur1 = UILabel()
    var dur2 = UILabel()
    var dur3 = UILabel()
    var dur4 = UILabel()
    var dur5 = UILabel()
    var dur6 = UILabel()
    var dur7 = UILabel()
    
    
    var fastTextSize = CGFloat(100)
    var layerArray = [CALayer]()
    var pageNumber = 0
    var fastNumber = 0
    var fastNum = 0
    var currentMode = 0
    var editOld = UILabel()
    var buttonsArray = [UIButton]()
    var saveStartArray = [UIButton]()
    var saveStopArray = [UIButton]()
    // Screen size so we can get width and height
    let screenSize: CGRect = UIScreen.main.bounds
    // Sets width of bars on graph
    lazy var barWidth = Int(screenSize.width*0.108695652)
    // Lets us make calaculations for date/time
    let timestamp = NSDate().timeIntervalSince1970
    // Simple variable for incrementing
    var time = [0]
    // Timer for time calculations
    var timer = Timer()
    var timer2 = Timer()
    // Hr, min, sec for display
    var hours = 0
    var minutes = 0
    var seconds = 0
    //=====================================Stores data=====================================//
    var fastLog         = ["","","","","","","","","","","","","",""]
    var rawFastLog      = ["","","","","","","","","","","","","",""]
    var fastGraph       = [-1,-1,-1,-1,-1,-1,-1]
    var currentlyFasting = ["0"]
    var currentDate = NSDate()
    var saveDate = [0]
    var trueGoal = [82800]
    var myGoal = 2
    // Sets top and bottom heights of the graph
    lazy var bottomHeight = Int(screenSize.height*0.747282609)
    lazy var topHeight = Int(screenSize.height*0.366847826) // just a placeholder, will be changed
    // Saves our important data between sessions
    let copyFastGraph = defaults.array(forKey: "savedGraph")  as? [Int] ?? [Int]()
    let copyFastLog = defaults.stringArray(forKey: "savedLog") ?? [String]()
    let copyRawFastLog = defaults.stringArray(forKey: "savedRawLog") ?? [String]()
    let copyCurrentlyFasting = defaults.stringArray(forKey: "savedBool") ?? [String]()
    let copySaveDate = defaults.array(forKey: "savedDate")  as? [Int] ?? [Int]()
    let copyTrueGoal = defaults.array(forKey: "savedGoal")  as? [Int] ?? [Int]()
    let copyTime = defaults.array(forKey: "savedTime")  as? [Int] ?? [Int]()
    //=====================================Colors=====================================//
    let lightRed = UIColor(red: 255/255.0, green: 104/255.0, blue: 104/255.0, alpha: 1)
    let lightBlue = UIColor(red: 113/255.0, green: 175/255.0, blue: 255/255.0, alpha: 1)
    let darkRed = UIColor(red: 196/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
    let darkBlue = UIColor(red: 0/255.0, green: 74/255.0, blue: 255/255.0, alpha: 1)
    let topColor = UIColor(red: 214/255.0, green: 103/255.0, blue: 118/255.0, alpha: 1)
    let bottomColor = UIColor(red: 254/255.0, green: 111/255.0, blue: 74/255.0, alpha: 1)
    let beige = UIColor(red: 231/255.0, green: 228/255.0, blue: 156/255.0, alpha: 1)
    let topRec = UIColor(red: 142/255.0, green: 203/255.0, blue: 209/255.0, alpha: 1)
    let lowRec = UIColor(red: 229/255.0, green: 227/255.0, blue: 156/255.0, alpha: 1)
    let topLine = UIColor(red: 213/255.0, green: 213/255.0, blue: 213/255.0, alpha: 1)
    let lowLine = UIColor(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1)
    
    let topMenu = UIColor(red: 142/255.0, green: 203/255.0, blue: 209/255.0, alpha: 1)
    let bottomMenu = UIColor(red: 229/255.0, green: 227/255.0, blue: 156/255.0, alpha: 1)
    
    //=====================================outlets and actions=====================================//
    @IBOutlet weak var csvLabel: UIButton!
    
    @IBAction func exportCSV(_ sender: Any)
    {
        let fileName = "myFasts.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Time Started,Fast Duration\n"
        if(rawFastLog.count > 0)
        {
            for i in 0...(rawFastLog.count-1)
            {
                csvText.append(contentsOf: rawFastLog[i] + "\n")
                print("CSV: " + String(i))
            }
            do
            {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                if let popOver = vc.popoverPresentationController
                {
                    popOver.sourceView = self.view
                    popOver.sourceRect = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height/8)
                    //popOver.barButtonItem
                }
                vc.excludedActivityTypes = [
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.postToTwitter,
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.openInIBooks
                ]
                present(vc, animated: true, completion: nil)
                print("Created CSV")
            } catch
            {
                print("Failed to create file")
                print("\(error)")
            }
        }
        else
        {
            print("No Data to Export")
        }
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var editStartPickerLabel: UIDatePicker!
    
    @IBOutlet weak var cancelStartLabel: UIButton!
    @IBAction func cancelNewStart(_ sender: Any)
    {
        pickDateLabel.sendActions(for: .touchUpInside)
    }
    @IBOutlet weak var saveNewStartLabel: UIButton!
    @IBAction func saveNewStart(_ sender: Any)
    {
        if(Int(datePicker.date.timeIntervalSince1970) <= Int(NSDate().timeIntervalSince1970))
        {
            // If current time is selected, it shifts to nearest second
            saveDate[0] = Int(datePicker.date.timeIntervalSince1970)
    
            defaults.set(saveDate,          forKey: "savedDate")
            datePicker.isHidden = true
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = true
            }
            datePicker.date = NSDate() as Date
            saveNewStartLabel.isHidden = true
            cancelStartLabel.isHidden = true
            editOld.isHidden = true
            menuLayer.isHidden = true
            //resetLabel.isHidden = false
            displayGoal()
        }
    }
    
    @IBOutlet weak var pickDateLabel: UIButton!
    @IBAction func pickDate(_ sender: Any)
    {
        if(datePicker.isHidden == true)
        {
            datePicker.date = NSDate(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(time[0])) as Date
            datePicker.isHidden = false
            editOld.isHidden = false
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            menuLayer.isHidden = false
            CATransaction.commit()
            
            editOld.text = "Edit Current Fast Start Time"
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = false
            }
            saveNewStartLabel.isHidden = false
            cancelStartLabel.isHidden = false
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = false
            }
        }
        else if(datePicker.isHidden == false)
        {
            datePicker.isHidden = true
            editOld.isHidden = true
            menuLayer.isHidden = true
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = true
            }
            
            saveNewStartLabel.isHidden = true
            cancelStartLabel.isHidden = true
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = true
            }
        }
    }
    
    @IBOutlet weak var cancelDelete: UIButton!
    @IBOutlet weak var confirmDelete: UIButton!
    @IBAction func cancelDeleteAction(_ sender: Any)
    {
        print("Fast Number: " + String(fastNumber + 7*pageNumber))
        cancelDelete.isHidden = true
        confirmDelete.isHidden = true
        editOld.isHidden = true
        menuLayer.isHidden = true
        menuLayer.frame = CGRect(x: 0, y: Int(screenSize.height*0.5), width: Int(screenSize.width), height: Int(screenSize.height*0.5))
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
        
    }
    @IBAction func confirmDeleteAction(_ sender: Any)
    {
        print("Fast Number: " + String(fastNumber + 7*pageNumber))
        if(fastLog[fastNumber + 7*pageNumber] == "")
        {
            print("empty fast")
        }
        else
        {
            fastGraph.remove(at: fastNumber + 7*pageNumber)
            fastLog.remove(at: fastNumber + 7*pageNumber)
            rawFastLog.remove(at: fastNumber + 7*pageNumber)
            fastLog.append("")
            rawFastLog.append("")
            fastGraph.append(-1)
            defaults.set(fastGraph,         forKey: "savedGraph")
            defaults.set(fastLog,           forKey: "savedLog")
            defaults.set(rawFastLog,        forKey: "savedRawLog")
            displayLog()
            displayGraph()
        }
        cancelDelete.isHidden = true
        confirmDelete.isHidden = true
        editOld.isHidden = true
        menuLayer.isHidden = true
        menuLayer.frame = CGRect(x: 0, y: Int(screenSize.height*0.5), width: Int(screenSize.width), height: Int(screenSize.height*0.5))
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    
    @IBOutlet weak var confirmLabel: UIButton!
    @IBOutlet weak var cancelLabel: UIButton!
    @IBAction func confirmEnd(_ sender: Any)
    {
        myButton.isUserInteractionEnabled = true
        myButton.sendActions(for: .touchUpInside)
        menuLayer.isHidden = true
        confirmLabel.isHidden = true
        cancelLabel.isHidden = true
    }
    @IBAction func cancelEnd(_ sender: Any)
    {
        myButton.isUserInteractionEnabled = true
        currentMode = 0
        myButton.setTitle("Stop Fast", for: [])
        menuLayer.isHidden = true
        confirmLabel.isHidden = true
        cancelLabel.isHidden = true
    }
    
    @IBOutlet weak var fast1: UILabel!
    @IBOutlet weak var fast2: UILabel!
    @IBOutlet weak var fast3: UILabel!
    @IBOutlet weak var fast4: UILabel!
    @IBOutlet weak var fast5: UILabel!
    @IBOutlet weak var fast6: UILabel!
    @IBOutlet weak var fast7: UILabel!
    @IBOutlet weak var sevenFasts: UILabel!
    @IBOutlet weak var supr: UILabel!
    @IBOutlet weak var goalLine: UILabel!
    @IBOutlet weak var started: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var editStartLabel: UILabel!
    @IBOutlet weak var editStopLabel: UILabel!
    @IBOutlet weak var editDeleteLabel: UILabel!
    
    @IBOutlet weak var resetLabel: UIButton!
    @IBAction func reset(_ sender: Any)
    {
        currentlyFasting[0] = "1"
        myButton.sendActions(for: .touchUpInside)
        confirmLabel.sendActions(for: .touchUpInside)
        for i in 0...7
        {
            fastLog.remove(at: 0)
            rawFastLog.remove(at: 0)
            fastGraph.remove(at: 0)
            fastLog.append("")
            rawFastLog.append("")
            fastGraph.append(-1)
        }
        time[0] = 0
        saveDate[0] = Int(NSDate().timeIntervalSince1970)
        defaults.set(fastGraph,         forKey: "savedGraph")
        defaults.set(fastLog,           forKey: "savedLog")
        defaults.set(rawFastLog,        forKey: "savedRawLog")
        defaults.set(currentlyFasting,  forKey: "savedBool")
        defaults.set(saveDate,          forKey: "savedDate")
        defaults.set(time,              forKey: "savedTime")
        displayGraph()
        displayLog()
        fastSlideName.setValue(Float(trueGoal[0]/3600), animated: false)
    }
    @IBOutlet weak var currentFast: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
  
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var toggleLabel: UIButton!
    
    @IBAction func toggleMode(_ sender: Any)
    {
        if(timerLabel.isHidden)
        {
            timerLabel.isHidden = false
            remainingLabel.isHidden = true
//            if(currentlyFasting[0] == "0")
//            {
//                currentFast.text = "TIME SINCE LAST FAST"
//            }
//            else
//            {
//                currentFast.text = "ELAPSED TIME"
//            }
        }
        else
        {
            timerLabel.isHidden = true
            remainingLabel.isHidden = false
            currentFast.text = "REMAINING TIME"
        }
    }
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var startActual: UILabel!
    @IBOutlet weak var goalActual: UILabel!
    @IBOutlet weak var setGoal: UILabel!
    @IBOutlet weak var fastSlideName: UISlider!
    @IBAction func fastSlider(_ sender: UISlider)
    {
        trueGoal[0] = Int(sender.value)*3600
        defaults.set(trueGoal,          forKey: "savedGoal")
        // Displaying the graph constantly when sliding causes lag
        displayGraph()
    }
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var myButton: UIButton!
    @IBAction func start(_ sender: UIButton)
    {
        //print("\nBefore")
        //print("Save Date: " + String(saveDate[0]))
        //saveDate[0] = Int(NSDate().timeIntervalSince1970)
        defaults.set(saveDate,           forKey: "savedDate")
        //print("Fasting: " + currentlyFasting[0])
        // When the start button is pushed, if we're not currently fasting
        currentFast.text = "ELAPSED TIME"
        if(currentlyFasting[0] == "0")
        {
            timer2.invalidate()
            pickDateLabel.isHidden = false
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.action), userInfo: nil, repeats: true)
            sender.setTitle("Stop Fast", for: [])
            //print("Starting Fast")
            currentlyFasting[0] = "1"
            defaults.set(fastGraph,         forKey: "savedGraph")
            defaults.set(fastLog,           forKey: "savedLog")
            defaults.set(rawFastLog,        forKey: "savedRawLog")
            defaults.set(currentlyFasting,  forKey: "savedBool")
            if(saveDate[0] == 0)
            {
                saveDate[0] = Int(NSDate().timeIntervalSince1970)
            }
            defaults.set(trueGoal,          forKey: "savedGoal")
            defaults.set(saveDate,          forKey: "savedDate")
            defaults.set(time,              forKey: "savedTime")
        }
        else if(currentlyFasting[0] == "1") // if we are currently fasting
        {
            if(currentMode != 2)
            {
                currentMode += 1
                sender.setTitle("End Fast?", for: [])
                cancelLabel.isHidden = false
                confirmLabel.isHidden = false
                myButton.isUserInteractionEnabled = false
            }
            if(currentMode == 2)
            {
                currentMode = 0
                myButton.isUserInteractionEnabled = true
                pickDateLabel.isHidden = true
                datePicker.isHidden = true
                for i in 0...buttonsArray.count-1
                {
                    buttonsArray[i].isUserInteractionEnabled = true
                }
                datePicker.date = NSDate() as Date
                saveNewStartLabel.isHidden = true
                cancelStartLabel.isHidden = true
                timer2 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateStartTime), userInfo: nil, repeats: true)
                defaults.set(trueGoal,          forKey: "savedGoal")
                fastSlideName.setValue(Float(trueGoal[0]/3600), animated: false)
                updateGraph()
                updateLog()
                displayLog()
                displayGraph()
                timer.invalidate()
                time[0] = 0
                let hours = Int(time[0]) / 3600
                let minutes = Int(time[0]) / 60 % 60
                let seconds = Int(time[0]) % 60
                
                let token = setGoal.text!.components(separatedBy: " ")

                let hoursRemaining = Int(Int(token[0])!*3600 - time[0]) / 3600
                let minutesRemaining = Int(Int(token[0])!*3600 - time[0]) / 60 % 60
                let secondsRemaining = Int(Int(token[0])!*3600 - time[0]) % 60
                
                timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
                remainingLabel.text = String(format:"%02i:%02i:%02i", hoursRemaining, minutesRemaining, secondsRemaining)
                
                sender.setTitle("Start Fast", for: [])
                //print("Stopping Fast")
                currentlyFasting[0] = "0"
                defaults.set(fastGraph,         forKey: "savedGraph")
                defaults.set(fastLog,           forKey: "savedLog")
                defaults.set(rawFastLog,        forKey: "savedRawLog")
                defaults.set(currentlyFasting,  forKey: "savedBool")
                saveDate[0] = 0
                defaults.set(saveDate,          forKey: "savedDate")
                defaults.set(time,              forKey: "savedTime")
            }
        }
        //print("\nAfter")
        //print("Save Date: " + String(saveDate[0]))
        //print("Fasting: " + currentlyFasting[0])
    }
    //=====================================My Functions=====================================//
    @objc func editFast(_ sender: UIButton)
    {
        editStart(sender)
    }
    @objc func editStart(_ sender: UIButton)
    {
        fastNumber = Int((sender.frame.minY-screenSize.height*0.787)+1) / Int(screenSize.height*0.0298913043 + 1.0)
//        print("Fast Number: " + String(fastNumber + 7*pageNumber))

        if(fastLog[fastNumber + 7*pageNumber] != "" && rawFastLog[fastNumber + 7*pageNumber] != "")
        {
            let rawDateFormatter2 = DateFormatter()
            rawDateFormatter2.locale = Locale(identifier: "en_US_POSIX")
            rawDateFormatter2.dateFormat = "yyyyMMdd hh:mm:ss a"
            rawDateFormatter2.amSymbol = "AM"
            rawDateFormatter2.pmSymbol = "PM"
            
            let unparsedLog = fastLog[fastNumber + 7*pageNumber]
            let unparsedRawLog = rawFastLog[fastNumber + 7*pageNumber]
            
            let delimiter = ","
            let token = unparsedRawLog.components(separatedBy: delimiter)
            
            let delimiter2 = "   "
            let displayToken = fastLog[fastNumber + 7*pageNumber].components(separatedBy: delimiter2)
            
            let myDate = rawDateFormatter2.date(from: String(token[0]))
            
            //print(unparsedRawLog)
            let startDate = Int((myDate?.timeIntervalSince1970)!)
            let endDate = startDate + Int(token[1])!
            //print("End Date: " + "\(endDate)")
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "EE, M/dd, h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            // New date value based on datePicker
            let endDateString: String = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endDate)))
            //print("End Date: " + "\(endDateString)")

            let durDelimiter = ","
            let rawDurationString = rawFastLog[fastNumber + 7*pageNumber].components(separatedBy: durDelimiter)
            
            let rawDuration = Int(rawDurationString[1])
            //print("Log: " + rawFastLog[fastNumber + 7*pageNumber])
            //print("Duration String: " + "\(rawDurationString)")
            //print("Duration: " + "\(rawDuration)")
            let hours = rawDuration! / 3600
            let minutes = rawDuration! / 60 % 60
            let seconds = rawDuration! % 60
            
            if(hours<1)
            {
                editOld.text = "Start Date: " + "\(displayToken[0])" + "\nDuration: " + "\(minutes)" + "min " + "\(seconds)" + "sec"
            }
            else
            {
                editOld.text = "Start Date: " + "\(displayToken[0])" + "\nDuration: " + "\(hours)" + "hr " + "\(minutes)" + "min "
            }
            editStartPickerLabel.isHidden = false
            saveStartArray[0].isHidden = false
            saveStartArray[1].isHidden = false
            editOld.isHidden = false
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            menuLayer.isHidden = false
            CATransaction.commit()
            
            editStartPickerLabel.setDate(myDate!, animated: false)
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = false
            }
        }
        else
        {
            //print("No fast at location " + "\(fastNumber + 7*pageNumber)")
        }
    }
    @objc func editStop(_ sender: UIButton)
    {
        fastNumber = Int((sender.frame.minY-screenSize.height*0.787)+1) / Int(screenSize.height*0.0298913043 + 1.0)
//        print("Fast Number: " + String(fastNumber + 7*pageNumber))
        if(fastLog[fastNumber + 7*pageNumber] != "" && rawFastLog[fastNumber + 7*pageNumber] != "")
        {
            let rawDateFormatter2 = DateFormatter()
            rawDateFormatter2.locale = Locale(identifier: "en_US_POSIX")
            rawDateFormatter2.dateFormat = "yyyyMMdd hh:mm:ss a"
            rawDateFormatter2.amSymbol = "AM"
            rawDateFormatter2.pmSymbol = "PM"
            
            let unparsedLog = fastLog[fastNumber + 7*pageNumber]
            let unparsedRawLog = rawFastLog[fastNumber + 7*pageNumber]
            
            let delimiter = ","
            let token = unparsedRawLog.components(separatedBy: delimiter)
            
            let delimiter2 = "   "
            let displayToken = fastLog[fastNumber + 7*pageNumber].components(separatedBy: delimiter2)
            
            let myDate = rawDateFormatter2.date(from: String(token[0]))
            
            //print(unparsedRawLog)
            let startDate = Int((myDate?.timeIntervalSince1970)!)
            let endDate = startDate + Int(token[1])!
            //print("End Date: " + "\(endDate)")
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "EE, M/dd, h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            // New date value based on datePicker
            let endDateString: String = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endDate)))
            //print("End Date: " + "\(endDateString)")
            
            let endDateActual = Date(timeIntervalSince1970: TimeInterval(endDate))
            
            let durDelimiter = ","
            let rawDurationString = rawFastLog[fastNumber + 7*pageNumber].components(separatedBy: durDelimiter)
            
            let rawDuration = Int(rawDurationString[1])
//            print("Log: " + rawFastLog[fastNumber + 7*pageNumber])
//            print("Duration String: " + "\(rawDurationString)")
//            print("Duration: " + "\(rawDuration)")
            let hours = rawDuration! / 3600
            let minutes = rawDuration! / 60 % 60
            let seconds = rawDuration! % 60
    
            if(hours<1)
            {
                editOld.text = "End Date: " + "\(endDateString)" + "\nDuration: " + "\(minutes)" + "min " + "\(seconds)" + "sec"
            }
            else
            {
                editOld.text = "End Date: " + "\(endDateString)" + "\nDuration: " + "\(hours)" + "hr " + "\(minutes)" + "min "
            }
            editStartPickerLabel.isHidden = false
            saveStartArray[1].isHidden = false
            saveStopArray[0].isHidden = false
            //saveStopArray[1].isHidden = false
            editOld.isHidden = false
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            menuLayer.isHidden = false
            CATransaction.commit()
            
            editStartPickerLabel.setDate(endDateActual, animated: false)
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = false
            }
        }
        else
        {
            //print("No fast at location " + "\(fastNumber + 7*pageNumber)")
        }
    }
    @objc func editDelete(_ sender: UIButton)
    {
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = false
        }
        fastNumber = Int((sender.frame.minY-screenSize.height*0.787)+1) / Int(screenSize.height*0.0298913043 + 1.0)
//        print("Fast Number: " + String(fastNumber + 7*pageNumber))
        if(editOld.isHidden == true)
        {
            editOld.isHidden = false
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            menuLayer.frame = CGRect(x: 0, y: Int(screenSize.height*0.5), width: Int(screenSize.width), height: Int(screenSize.height + screenSize.width)/6)
            menuLayer.isHidden = false
            CATransaction.commit()
            
            
            //screenSize.height*3/4 + screenSize.width/6
            cancelDelete.isHidden = false
            confirmDelete.isHidden = false
            if(fastLog[fastNumber + 7*pageNumber] == "")
            {
                editOld.text = "Fast is empty."
            }
            else
            {
                editOld.text = "Delete this fast?\n" + "\(fastLog[fastNumber + 7*pageNumber])"
            }
        }
        else
        {
            editOld.isHidden = true
            menuLayer.isHidden = true
            cancelDelete.isHidden = true
            confirmDelete.isHidden = true
        }
    }
    @objc func scrollDown()
    {
        if(fastLog[(pageNumber+1)*7] != "")
        {
            pageNumber += 1
        }
        //print(pageNumber)
        //pageLabel.text = String(pageNumber)
        sevenFasts.text = "FASTS " + String(7*pageNumber+1) + " - " + String(7*pageNumber+7)
        displayLog()
        displayGraph()
    }
    @objc func scrollUp()
    {
        if(pageNumber > 0)
        {
            pageNumber -= 1
        }
        //print(pageNumber)
        //pageLabel.text = String(pageNumber)
        sevenFasts.text = "FASTS " + String(7*pageNumber+1) + " - " + String(7*pageNumber+7)
        displayLog()
        displayGraph()
    }
    @objc func saveOldStart()
    {
        let myNewDate = editStartPickerLabel.date                         // GOOD
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EE, M/dd, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        // New date value based on datePicker
        let newDateString: String = dateFormatter.string(from: myNewDate)    // GOOD
        
        // Getting the original duration value
        let delimiter2 = "Duration: "
        let displayToken = editOld.text!.components(separatedBy: delimiter2)
        let myDuration = displayToken[1]
        let durationToken = myDuration.components(separatedBy: " ")
        let fixedDuration = durationToken[0] + durationToken[1]
        // Getting the original duration in the proper units of time
        let delimiter4 = " "
        let twoHalves = myDuration.components(separatedBy: delimiter4)
        let firstHalf = twoHalves[0]
        let secondHalf = twoHalves[1]
        
        let rawDurationString = rawFastLog[fastNumber + 7*pageNumber].components(separatedBy: ",")
        let myOldDuration = Int(rawDurationString[1])                 // GOOD
        
        // Getting the *complete* original date value from raw fast because formatted
        // fast doesn't have all the data
        let myOldRawFastLog = rawFastLog[fastNumber + 7*pageNumber]
        let rawDelimiter = ","
        let oldRawDate = myOldRawFastLog.components(separatedBy: rawDelimiter)

        let rawDateFormatter2 = DateFormatter()
        rawDateFormatter2.locale = Locale(identifier: "en_US_POSIX")
        rawDateFormatter2.dateFormat = "yyyyMMdd hh:mm:ss a"
        rawDateFormatter2.amSymbol = "AM"
        rawDateFormatter2.pmSymbol = "PM"

        let myOldDate = rawDateFormatter2.date(from: oldRawDate[0])     // GOOD?
        
        let myNewDuration = myOldDate!.timeIntervalSince1970 - (myNewDate.timeIntervalSince1970) + Double(myOldDuration!)
        
        let myNewHours = Int(myNewDuration) / 3600
        let myNewMinutes = Int(myNewDuration) / 60 % 60
        let myNewSeconds = Int(myNewDuration) % 60
        
        var myNewDurationString = ""
        if(myNewHours<1)
        {
            myNewDurationString =  "\(myNewMinutes)" + "min " + "\(myNewSeconds)" + "sec"
        }
        else
        {
            myNewDurationString = "\(myNewHours)" + "hr " + "\(myNewMinutes)" + "min "
        }
        
        // TODO!!! FIGURE OUT HOW TO USE FASTNUMBER TO GRAB THE OLD DATE
        //let newerDate = dateFormatter.date(from: String(newDate))
        
//        print("OG Date: " + "\(myOldDate)")
//        print("New Date: " + "\(myNewDate)")
//        print("Old Duration: " + "\(myOldDuration)")
//        print("New Duration: " + "\(myNewDuration)")
//
        let completeString = newDateString + "   " + String(myNewDurationString)//newDuration
      
        fastLog.remove(at: fastNumber + 7*pageNumber)
        fastLog.insert(completeString, at: fastNumber + 7*pageNumber)
        defaults.set(fastLog, forKey: "savedLog")
        
        let rawDateFormatterCommit = DateFormatter()
        rawDateFormatterCommit.locale = Locale(identifier: "en_US_POSIX")
        
        rawDateFormatterCommit.dateFormat = "yyyyMMdd hh:mm:ss a"
        
        rawDateFormatterCommit.amSymbol = "AM"
        rawDateFormatterCommit.pmSymbol = "PM"
        
        let currentRawDateStringCommit: String = rawDateFormatterCommit.string(from: myNewDate)
        rawFastLog.remove(at: fastNumber + 7*pageNumber)
        rawFastLog.insert("\(currentRawDateStringCommit)" + "," + "\(Int(myNewDuration))", at: fastNumber + 7*pageNumber)
        
        defaults.set(rawFastLog, forKey: "savedRawLog")
        
        fastGraph[fastNumber + 7*pageNumber] = Int(myNewDuration)
        defaults.set(fastGraph,         forKey: "savedGraph")
        displayLog()
        displayGraph()
        
        editStartPickerLabel.isHidden = true
        saveStartArray[0].isHidden = true
        saveStartArray[1].isHidden = true
        saveStopArray[0].isHidden = true
        //saveStopArray[1].isHidden = true
        editOld.isHidden = true
        menuLayer.isHidden = true
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    @objc func saveOldEnd()
    {
        // Old Start Date                                                     // GOOD
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EE, M/dd, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        let rawDateFormatterCommit = DateFormatter()
        rawDateFormatterCommit.locale = Locale(identifier: "en_US_POSIX")
        
        rawDateFormatterCommit.dateFormat = "yyyyMMdd hh:mm:ss a"
        
        rawDateFormatterCommit.amSymbol = "AM"
        rawDateFormatterCommit.pmSymbol = "PM"
        
        let ogStart = fastLog[fastNumber + 7*pageNumber].components(separatedBy: "   ")
        let ogRawStart = rawFastLog[fastNumber + 7*pageNumber].components(separatedBy: ",")
        
        let myOldStart = rawDateFormatterCommit.date(from: String(ogRawStart[0]))
        
        // New End Date
        let myNewEnd = editStartPickerLabel.date
       
        // New Duration
        let myNewDuration = myNewEnd.timeIntervalSince1970 - myOldStart!.timeIntervalSince1970
        //print(myNewDuration)
        let myNewHours = Int(myNewDuration) / 3600
        let myNewMinutes = Int(myNewDuration) / 60 % 60
        let myNewSeconds = Int(myNewDuration) % 60
        
        var myNewDurationString = ""
        if(myNewHours<1)
        {
            myNewDurationString =  "\(myNewMinutes)" + "min " + "\(myNewSeconds)" + "sec"
        }
        else
        {
            myNewDurationString = "\(myNewHours)" + "hr " + "\(myNewMinutes)" + "min "
        }
        
        let completeString = dateFormatter.string(from: myOldStart!) + "   " + String(myNewDurationString)
        
        fastLog.remove(at: fastNumber + 7*pageNumber)
        fastLog.insert(completeString, at: fastNumber + 7*pageNumber)
        defaults.set(fastLog, forKey: "savedLog")
        
        let currentRawDateStringCommit: String = rawDateFormatterCommit.string(from: myOldStart!)
        rawFastLog.remove(at: fastNumber + 7*pageNumber)
        rawFastLog.insert("\(currentRawDateStringCommit)" + "," + "\(Int(myNewDuration))", at: fastNumber + 7*pageNumber)
        
        defaults.set(rawFastLog, forKey: "savedRawLog")
        
        fastGraph[fastNumber + 7*pageNumber] = Int(myNewDuration)
        defaults.set(fastGraph,         forKey: "savedGraph")
        displayLog()
        displayGraph()
        
        editStartPickerLabel.isHidden = true
        saveStartArray[0].isHidden = true
        saveStartArray[1].isHidden = true
        saveStopArray[0].isHidden = true
        //saveStopArray[1].isHidden = true
        editOld.isHidden = true
        menuLayer.isHidden = true
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    @objc func cancelOldStart()
    {
        editStartPickerLabel.isHidden = true
        saveStartArray[0].isHidden = true
        saveStartArray[1].isHidden = true
        saveStopArray[0].isHidden = true
        //saveStopArray[1].isHidden = true
        editOld.isHidden = true
        menuLayer.isHidden = true
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    @objc func updateLog()
    {
        let hours = Int(time[0]) / 3600
        let minutes = Int(time[0]) / 60 % 60
        let seconds = Int(time[0]) % 60
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // TODO: fix incorrect spacing if the hour is 1 digit as opposed to 2
        // ex: 2:15 as opposed to 12:15 is spaced differently
        // Possible solution: 7 extra text boxes, split info.
        
        dateFormatter.dateFormat = "EE, M/dd, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let currentDateString: String = dateFormatter.string(from: date-TimeInterval(time[0]))
        if(hours<1)
        {
            fastLog.insert("\(currentDateString)" + "   " + "\(minutes)" + "min " + "\(seconds)" + "sec", at: 0)
            //fastLog[0] = "\(currentDateString)" + "   " + "\(minutes)" + "min " + "\(seconds)" + "sec"
        }
        else
        {
            fastLog.insert("\(currentDateString)" + "   " + "\(hours)" + "hr " + "\(minutes)" + "min ", at: 0)
        }// TODO FIX THE MIN
        
        
        let rawDateFormatter = DateFormatter()
        rawDateFormatter.locale = Locale(identifier: "en_US_POSIX")

        rawDateFormatter.dateFormat = "yyyyMMdd hh:mm:ss a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let currentRawDateString: String = rawDateFormatter.string(from: date-TimeInterval(time[0]))
        rawFastLog.insert("\(currentRawDateString)" + "," + "\(time[0])", at: 0)
    }
    @objc func updateGraph()
    {
        fastGraph.insert(Int(time[0]), at: 0)
    }
    @objc func displayLog()
    {
        // Start Dates
        fast1.text = fastLog[0 + 7*pageNumber].components(separatedBy: "   ").first
        fast2.text = fastLog[1 + 7*pageNumber].components(separatedBy: "   ").first
        fast3.text = fastLog[2 + 7*pageNumber].components(separatedBy: "   ").first
        fast4.text = fastLog[3 + 7*pageNumber].components(separatedBy: "   ").first
        fast5.text = fastLog[4 + 7*pageNumber].components(separatedBy: "   ").first
        fast6.text = fastLog[5 + 7*pageNumber].components(separatedBy: "   ").first
        fast7.text = fastLog[6 + 7*pageNumber].components(separatedBy: "   ").first
        
        // Durations
        dur1.text = fastLog[0 + 7*pageNumber].components(separatedBy: "   ").last
        dur2.text = fastLog[1 + 7*pageNumber].components(separatedBy: "   ").last
        dur3.text = fastLog[2 + 7*pageNumber].components(separatedBy: "   ").last
        dur4.text = fastLog[3 + 7*pageNumber].components(separatedBy: "   ").last
        dur5.text = fastLog[4 + 7*pageNumber].components(separatedBy: "   ").last
        dur6.text = fastLog[5 + 7*pageNumber].components(separatedBy: "   ").last
        dur7.text = fastLog[6 + 7*pageNumber].components(separatedBy: "   ").last
    }
    @objc func displayGraph()
    {
        // Clear out the rectangles to stop lag
        print(layerArray.count)
        if(layerArray.count > 0)
        {
            for i in 0...layerArray.count-1
            {
                layerArray[0].removeFromSuperlayer()
                layerArray.remove(at: 0)
            }
        }
        //print(layerArray.count)
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        topHeight = bottomHeight-Int(screenSize.height*0.244565217)
        var diffHeight = bottomHeight-topHeight
        
        // Gap from edges both sides
        let xPos = Int(screenSize.width*0.0458937198) + barWidth%5
        
        // Draws white rectangle so when bars shift over the previous don't remain and overlap
//        drawBlankRect(myXPos: xPos, myYPos: bottomHeight, myHeight: Int(screenSize.height*0.27173913), myWidth: Int(screenWidth)-2*xPos, myColor: UIColor.white)
        
        // Draws beige bar under red portion//POP//
        drawBlankRect(myXPos: 7, myYPos: Int(screenSize.height*0.283967391), myHeight: 7, myWidth: Int(screenSize.width*0.966183575), myColor: beige)
        
        // Draws lines between previous entries
        for k in 0..<7
        {
            drawBlankRect(myXPos: xPos-2, myYPos: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*k, myHeight: 1, myWidth: Int(screenSize.width) - 2*(xPos-2), myColor: topLine)
        }
        // Draws lines next to 7 Fasts label
        drawBlankRect(myXPos: Int(sevenFasts.center.x*0.1), myYPos: Int(sevenFasts.center.y + 1), myHeight: 1, myWidth: Int(screenSize.width*0.289855072), myColor: topLine)
        drawBlankRect(myXPos: Int(sevenFasts.center.x*1.32), myYPos: Int(sevenFasts.center.y + 1), myHeight: 1, myWidth: Int(screenSize.width*0.289855072), myColor: topLine)
        myGoal = trueGoal[0]     // Sets maximum height of a bar
        
        // If the bar is greater than 10, it adjusts all the bars accordingly.
        for i in 0..<7//fastGraph.count
        {
            if(fastGraph[i + 7*pageNumber] > myGoal)
            {
                myGoal = fastGraph[i + 7*pageNumber]
            }
        }
        // Calculates spacing between bars so it looks nice
        var barSpace = (Int(screenSize.width)-2*xPos - 7*barWidth)/6
        // Draws bars and adjusts based on highest bar
        // so it all stays proportional, including the goal line
        
        for j in 0..<7//fastGraph.count
        {
            drawRect(myXPos: Int(screenWidth)-xPos-barWidth*(j+1)-barSpace*j, myHeight: diffHeight*fastGraph[j + 7*pageNumber]/myGoal)
        }
        if(myGoal>trueGoal[0])
        {
            drawBlankRect(myXPos: xPos+2, myYPos: Int(bottomHeight-diffHeight*(trueGoal[0])/(myGoal)), myHeight: 1, myWidth: Int(screenWidth - CGFloat(2*(xPos+1))), myColor: lowLine)
            goalLine.center.y = CGFloat(bottomHeight - diffHeight*(trueGoal[0])/(myGoal) - Int(screenSize.height*0.0203804348/2))
        }
        else
        {
            drawBlankRect(myXPos: xPos+2, myYPos: topHeight, myHeight: 1, myWidth: Int(screenWidth - CGFloat(2*(xPos+1))), myColor: lowLine)
            goalLine.center.y = CGFloat(topHeight-Int(screenSize.height*0.0203804348/2))
        }
        goalLine.center.x = screenSize.width*0.839190822
        displayGoal()
    }
    @objc func displayGoal()
    {
        setGoal.text = String(Int(trueGoal[0]/3600)) + " HR FAST"
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        startActual.text = formatter.string(from: Date(timeIntervalSince1970: Double(saveDate[0])))
        goalActual.text = formatter.string(from: Date(timeIntervalSince1970: Double(saveDate[0]))+Double(trueGoal[0]))
        let hours = Int(trueGoal[0]) / 3600
        let minutes = Int(trueGoal[0]) / 60 % 60
        let seconds = Int(trueGoal[0]) % 60
        if(hours<1)
        {
            if(minutes<1)
            {
                goalLabel.text = "GOAL:" + "\(trueGoal[0])" + "SEC"
                goalLine.text = "GOAL:" + "\(trueGoal[0])" + "SEC"
            }
            else
            {
                goalLabel.text = "GOAL:" + "\(trueGoal[0] / 60)" + "MIN"
                goalLine.text = "GOAL:" + "\(trueGoal[0] / 60)" + "MIN"
            }
        }
        else
        {
            if(hours == 1)
            {
                goalLabel.text = "GOAL:" + "\(trueGoal[0] / 3600)" + "HR"
                goalLine.text = "GOAL:" + "\(trueGoal[0] / 3600)" + "HR"
            }
            else
            {
                goalLabel.text = "GOAL:" + "\(trueGoal[0] / 3600)" + "HRS"
                goalLine.text = "GOAL:" + "\(trueGoal[0] / 3600)" + "HRS"
            }
        }
    }
    @objc func action()
    {
        if(saveDate.count > 0)
        {
            if(saveDate[0] != 0)
            {
                time[0] = Int(NSDate().timeIntervalSince1970) - saveDate[0]
            }
        }
        if(datePicker.date > NSDate() as Date)
        {
            datePicker.date = NSDate() as Date
        }
        //print("Time: " + String(time[0]))
        displayLog()
        defaults.set(time,              forKey: "savedTime")
        defaults.set(fastGraph,         forKey: "savedGraph")
        defaults.set(fastLog,           forKey: "savedLog")
        defaults.set(rawFastLog,        forKey: "savedRawLog")
        defaults.set(currentlyFasting,  forKey: "savedBool")
        defaults.set(trueGoal,          forKey: "savedGoal")
        let hours = Int(time[0]) / 3600
        let minutes = Int(time[0]) / 60 % 60
        let seconds = Int(time[0]) % 60
        timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        
        let token = setGoal.text!.components(separatedBy: " ")

        
        let hoursRem = Int(Int(token[0])!*3600 - time[0]) / 3600
        let minutesRem = Int(Int(token[0])!*3600 - time[0]) / 60 % 60
        let secondsRem = Int(Int(token[0])!*3600 - time[0]) % 60
        remainingLabel.text = String(format:"%02i:%02i:%02i", hoursRem, minutesRem, secondsRem)
        
    }
    @objc func updateStartTime()
    {
        if(currentlyFasting[0] == "0")
        {
            saveDate[0] = Int(NSDate().timeIntervalSince1970)// - time[0]
            defaults.set(saveDate,          forKey: "savedDate")
            displayGoal()
            
            if(rawFastLog[0] != "")
            {
                let rawDateFormatter2 = DateFormatter()
                rawDateFormatter2.locale = Locale(identifier: "en_US_POSIX")
                rawDateFormatter2.dateFormat = "yyyyMMdd hh:mm:ss a"
                rawDateFormatter2.amSymbol = "AM"
                rawDateFormatter2.pmSymbol = "PM"
                
                let unparsedRawLog = rawFastLog[0]
                
                let delimiter = ","
                let token = unparsedRawLog.components(separatedBy: delimiter)
                let myDate = rawDateFormatter2.date(from: String(token[0]))
                let startDate = Int((myDate?.timeIntervalSince1970)!)
                let endDate = startDate + Int(token[1])!
                
                var previousEndDate = Date(timeIntervalSince1970: TimeInterval(endDate))
                var currentDate = NSDate()
                var timeSinceLastFast = currentDate.timeIntervalSince1970 - previousEndDate.timeIntervalSince1970
                
                let hours = Int(timeSinceLastFast) / 3600
                let minutes = Int(timeSinceLastFast) / 60 % 60
                let seconds = Int(timeSinceLastFast) % 60
                
                timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
                if(!timerLabel.isHidden)
                {
                    currentFast.text = "TIME SINCE LAST FAST"
                }
            }
            else
            {
                let hours = Int(0) / 3600
                let minutes = Int(0) / 60 % 60
                let seconds = Int(0) % 60
                timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
                
                if(!timerLabel.isHidden)
                {
                    currentFast.text = "ELAPSED TIME"
                }
                else
                {
                    currentFast.text = "REMAINING TIME"
                }
            }
        }
        else
        {
            if(!timerLabel.isHidden)
            {
                currentFast.text = "ELAPSED TIME"
            }
            else
            {
                currentFast.text = "REMAINING TIME"
            }
        }
    }

    //=====================================viewDidLoad()=====================================//
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Settings for menuLayer
        menuLayer.frame = CGRect(x: 0, y: Int(screenSize.height*0.5), width: Int(screenSize.width), height: Int(screenSize.height*0.5))
        menuLayer.colors = [topMenu.cgColor, bottomMenu.cgColor]
        view.layer.insertSublayer(menuLayer, at: 0)
        menuLayer.zPosition = 2
        menuLayer.isHidden = true
        
        // Edit Start Buttons
        print("Width: " + String(Int(screenSize.width)))
        print("Height: " + String(Int(screenSize.height)))
        for i in 0...6
        {
            let button = UIButton(frame: CGRect(x: screenSize.width*42/64, y: (CGFloat(screenSize.height*0.0298913043))*CGFloat(i) + screenSize.height*0.787, width: screenSize.width/16, height: screenSize.height*0.025))
            
            button.backgroundColor = UIColor.clear
            
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.setTitle("✎", for: .normal)

            button.setTitleColor(UIColor.blue, for: .normal)
            button.addTarget(self, action: #selector(editStart), for: .touchUpInside)
            button.titleLabel!.adjustsFontSizeToFitWidth = true
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.baselineAdjustment = .alignCenters
            button.titleLabel?.minimumScaleFactor = 0.01
            button.titleLabel?.font = UIFont(name: ((button.titleLabel?.font.fontName)!), size: fastTextSize)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: button.frame.width*0.2, bottom: 0, right: button.frame.width*0.2)
            
            self.view.addSubview(button)
            self.buttonsArray.append(button)
        }
        // Edit Stop Buttons
        for i in 0...6
        {
            let button = UIButton(frame: CGRect(x: screenSize.width*49.5/64, y: (CGFloat(screenSize.height*0.0298913043))*CGFloat(i) + screenSize.height*0.787, width: screenSize.width/16, height: screenSize.height*0.025))
            
            button.backgroundColor = UIColor.clear
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.setTitle("✎", for: .normal)
            
            button.setTitleColor(UIColor.red, for: .normal)
            button.addTarget(self, action: #selector(editStop), for: .touchUpInside)
            button.titleLabel!.adjustsFontSizeToFitWidth = true
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.baselineAdjustment = .alignCenters
            button.titleLabel?.minimumScaleFactor = 0.01
            button.titleLabel?.font = UIFont(name: ((button.titleLabel?.font.fontName)!), size: fastTextSize)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: button.frame.width*0.2, bottom: 0, right: button.frame.width*0.2)

            self.view.addSubview(button)
            self.buttonsArray.append(button)
        }
        // Delete Buttons
        for i in 0...6
        {
            let button = UIButton(frame: CGRect(x: screenSize.width*57/64, y: (CGFloat(screenSize.height*0.0298913043))*CGFloat(i) + screenSize.height*0.787, width: screenSize.width/16, height: screenSize.height*0.025))
            
            button.backgroundColor = UIColor.clear
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.setTitle("✕", for: .normal)
            
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(editDelete), for: .touchUpInside)
            button.titleLabel!.adjustsFontSizeToFitWidth = true
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.baselineAdjustment = .alignCenters
            button.titleLabel?.minimumScaleFactor = 0.01
            button.titleLabel?.font = UIFont(name: ((button.titleLabel?.font.fontName)!), size: fastTextSize)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: button.frame.width*0.2, bottom: 0, right: button.frame.width*0.2)
            
            self.view.addSubview(button)
            self.buttonsArray.append(button)
        }
        // Makes Green left/right arrows to page through past fasts
        for i in 0...1
        {
            let size = CGFloat(1.5)
            if(i == 0)
            {
                //        buttonLabel.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.905797101), height: round(screenSize.height*0.0774456522))
                //buttonLabel.center.x = round(screenSize.width/2)
                //buttonLabel.center.y = round(screenSize.height*0.388586957)
                
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenSize.width*0.0416666667*size, height: screenSize.height*0.025*size))
                button.backgroundColor = UIColor.white
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.black.cgColor
                button.setTitle("→", for: .normal)
                button.addTarget(self, action: #selector(scrollUp), for: .touchUpInside)
                button.setTitleColor(UIColor.green, for: .normal)
                button.layer.cornerRadius = 5
                button.center.x = screenSize.width*0.952898551-(screenSize.width*0.0416666667*size)/2
                button.center.y = screenSize.height*0.456521739
                
                button.titleLabel!.adjustsFontSizeToFitWidth = true
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.baselineAdjustment = .alignCenters
                button.titleLabel?.minimumScaleFactor = 0.01
                button.titleLabel?.font = UIFont(name: ((button.titleLabel?.font.fontName)!), size: fastTextSize)
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self.view.addSubview(button)
                self.buttonsArray.append(button)
            }
            else
            {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenSize.width*0.0416666667*size, height: screenSize.height*0.025*size-1))
                button.backgroundColor = UIColor.white
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.black.cgColor
                button.setTitle("←", for: .normal)
                button.addTarget(self, action: #selector(scrollDown), for: .touchUpInside)
                button.setTitleColor(UIColor.green, for: .normal)
                button.layer.cornerRadius = 5
                button.center.x = screenSize.width*0.0471014495+(screenSize.width*0.0416666667*size)/2
                button.center.y = screenSize.height*0.456521739
                
                button.titleLabel!.adjustsFontSizeToFitWidth = true
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.baselineAdjustment = .alignCenters
                button.titleLabel?.minimumScaleFactor = 0.01
                button.titleLabel?.font = UIFont(name: ((button.titleLabel?.font.fontName)!), size: fastTextSize)
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self.view.addSubview(button)
                self.buttonsArray.append(button)
            }
        }

        // Finished
        let saveOldStartLabel = UIButton(frame: CGRect(x: screenSize.width*3/4, y: screenSize.height*4/6, width: screenSize.width*1/4, height: screenSize.height*1/12))
        saveOldStartLabel.isHidden = true
        saveOldStartLabel.backgroundColor = .clear
        saveOldStartLabel.setTitleColor(UIColor.black, for: .normal)
        saveOldStartLabel.setTitle("✓", for: .normal)
        saveOldStartLabel.layer.zPosition = 2
        saveOldStartLabel.addTarget(self, action: #selector(saveOldStart), for: .touchUpInside)
        saveOldStartLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        saveOldStartLabel.titleLabel?.minimumScaleFactor = 0.01
        saveOldStartLabel.titleLabel?.textAlignment = .center
        saveOldStartLabel.titleLabel?.baselineAdjustment = .alignCenters
        saveOldStartLabel.titleLabel?.font = UIFont(name: (saveOldStartLabel.titleLabel?.font.fontName)!, size: fastTextSize)
        saveOldStartLabel.contentEdgeInsets = UIEdgeInsets(top: 0, left: saveOldStartLabel.frame.width*0.1, bottom: 0, right: saveOldStartLabel.frame.width*0.1)


        self.view.addSubview(saveOldStartLabel)
        self.saveStartArray.append(saveOldStartLabel)
        
        // Finished
        let cancelOldStartLabel = UIButton(frame: CGRect(x: screenSize.width*3/4, y: screenSize.height*11/12, width: screenSize.width*1/4, height: screenSize.height*1/12))
        cancelOldStartLabel.isHidden = true
        cancelOldStartLabel.backgroundColor = .clear
        cancelOldStartLabel.setTitleColor(UIColor.black, for: .normal)
        cancelOldStartLabel.setTitle("✕", for: .normal)
        cancelOldStartLabel.layer.zPosition = 2
        cancelOldStartLabel.addTarget(self, action: #selector(cancelOldStart), for: .touchUpInside)
        cancelOldStartLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelOldStartLabel.titleLabel?.minimumScaleFactor = 0.01
        cancelOldStartLabel.titleLabel?.textAlignment = .center
        cancelOldStartLabel.titleLabel?.baselineAdjustment = .alignCenters
        cancelOldStartLabel.titleLabel?.font = UIFont(name: (cancelOldStartLabel.titleLabel?.font.fontName)!, size: fastTextSize)
        
        self.view.addSubview(cancelOldStartLabel)
        self.saveStartArray.append(cancelOldStartLabel)
        
        // Finished
        let saveOldStopLabel = UIButton(frame: CGRect(x: screenSize.width*3/4, y: screenSize.height*4/6, width: screenSize.width*1/4, height: screenSize.height*1/12))
        saveOldStopLabel.isHidden = true
        saveOldStopLabel.backgroundColor = .clear
        saveOldStopLabel.setTitleColor(UIColor.black, for: .normal)
        saveOldStopLabel.setTitle("✓", for: .normal)
        saveOldStopLabel.layer.zPosition = 2
        saveOldStopLabel.addTarget(self, action: #selector(saveOldEnd), for: .touchUpInside)
        saveOldStopLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        saveOldStopLabel.titleLabel?.minimumScaleFactor = 0.01
        saveOldStopLabel.titleLabel?.textAlignment = .center
        saveOldStopLabel.titleLabel?.baselineAdjustment = .alignCenters
        saveOldStopLabel.titleLabel?.font = UIFont(name: (saveOldStopLabel.titleLabel?.font.fontName)!, size: fastTextSize)
        saveOldStopLabel.contentEdgeInsets = UIEdgeInsets(top: 0, left: saveOldStopLabel.frame.width*0.1, bottom: 0, right: saveOldStopLabel.frame.width*0.1)
        
        self.view.addSubview(saveOldStopLabel)
        self.saveStopArray.append(saveOldStopLabel)
        
        // Hides picker so it isn't open when you initialize the app
        editStartPickerLabel.isHidden = true
        
        currentMode = 0
        cancelLabel.isHidden = true
        confirmLabel.isHidden = true
        //resetLabel.isHidden = false
        resetLabel.backgroundColor = UIColor.cyan
        resetLabel.setTitleColor(UIColor.black, for: .normal)
        resetLabel.frame = CGRect(x: screenSize.width*3/4, y: screenSize.height*7/8, width: screenSize.width*1/4, height: screenSize.height*1/8)
        resetLabel.layer.zPosition = -1
        
        resetLabel.isHidden = true  // temporary hiding to edit other buttons
        
        datePicker.isHidden = true
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
        datePicker.backgroundColor = .clear
        datePicker.setValue(UIColor.black, forKey: "textColor")
        datePicker.frame = CGRect(x: 0, y: screenSize.height*2/3, width: screenSize.width, height: screenSize.height*1/3)
        datePicker.layer.zPosition = 2
        
        pickDateLabel.isHidden = true
        
       
        editStartPickerLabel.backgroundColor = .clear
        editStartPickerLabel.setValue(UIColor.black, forKey: "textColor")
        editStartPickerLabel.frame = CGRect(x: 0, y: screenSize.height*2/3, width: screenSize.width, height: screenSize.height*1/3)
        editStartPickerLabel.layer.zPosition = 2
        editStartPickerLabel.isHidden = true
        
        // Finished
        editOld.backgroundColor = .clear
        editOld.setValue(UIColor.black, forKey: "textColor")
        editOld.frame = CGRect(x: 0, y: screenSize.height*3/6, width: screenSize.width, height: screenSize.height*1/6)
        editOld.layer.zPosition = 2
        editOld.text = "Edit Start Date"
        editOld.font = .systemFont(ofSize: fastTextSize)
        editOld.isHidden = true
        editOld.textAlignment = .center
        editOld.numberOfLines = 3
        editOld.adjustsFontSizeToFitWidth = true
        self.view.addSubview(editOld)

        // Finished
        saveNewStartLabel.isHidden = true
        saveNewStartLabel.backgroundColor = .clear
        saveNewStartLabel.setTitleColor(UIColor.black, for: .normal)
        saveNewStartLabel.frame = CGRect(x: screenSize.width*3/4, y: screenSize.height*4/6, width: screenSize.width*1/4, height: screenSize.height*1/12)
        saveNewStartLabel.layer.zPosition = 2
        saveNewStartLabel.setTitle("✓", for: .normal)
        saveNewStartLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        saveNewStartLabel.titleLabel?.minimumScaleFactor = 0.01
        saveNewStartLabel.titleLabel?.textAlignment = .center
        saveNewStartLabel.titleLabel?.baselineAdjustment = .alignCenters
        saveNewStartLabel.titleLabel?.font = UIFont(name: (saveNewStartLabel.titleLabel?.font.fontName)!, size: fastTextSize)
        saveNewStartLabel.contentEdgeInsets = UIEdgeInsets(top: 0, left: saveNewStartLabel.frame.width*0.1, bottom: 0, right: saveNewStartLabel.frame.width*0.1)
        
        // Finished
        cancelStartLabel.isHidden = true
        cancelStartLabel.backgroundColor = .clear
        cancelStartLabel.setTitleColor(UIColor.black, for: .normal)
        cancelStartLabel.frame = CGRect(x: screenSize.width*3/4, y: screenSize.height*11/12, width: screenSize.width*1/4, height: screenSize.height*1/12)
        cancelStartLabel.layer.zPosition = 2
        cancelStartLabel.setTitle("✕", for: .normal)
        cancelStartLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelStartLabel.titleLabel?.minimumScaleFactor = 0.01
        cancelStartLabel.titleLabel?.textAlignment = .center
        cancelStartLabel.titleLabel?.baselineAdjustment = .alignCenters
        cancelStartLabel.titleLabel?.font = UIFont(name: (cancelStartLabel.titleLabel?.font.fontName)!, size: fastTextSize)

        //=============================================Positions all elements==========================================//
        // Finished
        csvLabel.frame = CGRect(x: screenSize.width*3/4, y: 0, width: round(screenSize.width*0.2), height: round(screenSize.height*0.02))
        csvLabel.center.x = screenSize.width*7/8
        csvLabel.center.y = screenSize.height*0.046875
        csvLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        csvLabel.titleLabel?.textAlignment = .center
        csvLabel.titleLabel?.baselineAdjustment = .alignCenters
        csvLabel.titleLabel?.minimumScaleFactor = 0.01
        csvLabel.titleLabel?.font = UIFont(name: ((csvLabel.titleLabel?.font.fontName)!), size: fastTextSize)
        
        // Finished
        supr.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.09178743961), height: round(screenSize.height*0.0285326087))
        supr.center.x = screenSize.width/2
        supr.center.y = screenSize.height/24
        supr.adjustsFontSizeToFitWidth = true
        supr.textAlignment = .center
        supr.baselineAdjustment = .alignCenters
        supr.minimumScaleFactor = 0.01
        supr.font = UIFont(name: (supr.font.fontName), size: fastTextSize)

        // Finished
        currentFast.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.25), height: round(screenSize.height*0.025))
        currentFast.center.x = screenSize.width/2
        currentFast.center.y = screenSize.height/8
        currentFast.adjustsFontSizeToFitWidth = true
        currentFast.textAlignment = .center
        currentFast.baselineAdjustment = .alignCenters
        currentFast.minimumScaleFactor = 0.01
        currentFast.font = UIFont(name: (currentFast.font.fontName), size: fastTextSize)
        
        // Finished
        timerLabel.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.5), height: round(screenSize.height*0.1))
        timerLabel.center.x = screenSize.width/2
        timerLabel.center.y = screenSize.height*0.179347826
        timerLabel.textAlignment = .center
        timerLabel.baselineAdjustment = .alignCenters
        timerLabel.adjustsFontSizeToFitWidth = true
        timerLabel.minimumScaleFactor = 0.01
        timerLabel.font = UIFont(name: (fast1.font.fontName), size: fastTextSize)
        
        // Finished
        remainingLabel.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.5), height: round(screenSize.height*0.1))
        remainingLabel.center.x = timerLabel.center.x
        remainingLabel.center.y = timerLabel.center.y
        remainingLabel.textAlignment = .center
        remainingLabel.baselineAdjustment = .alignCenters
        remainingLabel.adjustsFontSizeToFitWidth = true
        remainingLabel.minimumScaleFactor = 0.01
        remainingLabel.font = UIFont(name: (fast1.font.fontName), size: fastTextSize)
        remainingLabel.isHidden = true
        
        // Finished
        toggleLabel.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.828502415), height: round(screenSize.height*0.120923913))
        toggleLabel.center.x = timerLabel.center.x
        toggleLabel.center.y = timerLabel.center.y
        toggleLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        toggleLabel.titleLabel?.textAlignment = .center
        toggleLabel.titleLabel?.baselineAdjustment = .alignCenters
        
        // Finished
        startLabel.frame = CGRect(x: round(screenSize.width*0.02057971), y: round(screenSize.height*0.205), width: round(screenSize.width*0.11), height: round(screenSize.height*0.0203804348))
        startLabel.adjustsFontSizeToFitWidth = true
        startLabel.textAlignment = .left
        startLabel.baselineAdjustment = .alignCenters
        startLabel.minimumScaleFactor = 0.01
        startLabel.font = UIFont(name: (startLabel.font.fontName), size: fastTextSize)
        
        // Finished
        startActual.frame = CGRect(x: round(screenSize.width*0.02057971), y: round(screenSize.height*0.231657609), width: round(screenSize.width*0.225), height: round(screenSize.height*0.0366847826))
        startActual.adjustsFontSizeToFitWidth = true
        startActual.textAlignment = .left
        startActual.baselineAdjustment = .alignCenters
        startActual.minimumScaleFactor = 0.01
        startActual.font = UIFont(name: (startActual.font.fontName), size: fastTextSize)
        
        // Finished
        goalLabel.frame = CGRect(x: round(screenSize.width*(0.77942029)), y: round(screenSize.height*0.205), width: round(screenSize.width*0.2), height: round(screenSize.height*0.0203804348))
        goalLabel.adjustsFontSizeToFitWidth = true
        goalLabel.textAlignment = .right
        goalLabel.baselineAdjustment = .alignCenters
        goalLabel.minimumScaleFactor = 0.01
        goalLabel.font = UIFont(name: (goalLabel.font.fontName), size: fastTextSize)
        
        // Finished
        goalActual.frame = CGRect(x: round(screenSize.width*0.75442029), y: round(screenSize.height*0.231657609), width: round(screenSize.width*0.225), height: round(screenSize.height*0.0366847826))
        goalActual.adjustsFontSizeToFitWidth = true
        goalActual.textAlignment = .right
        goalActual.baselineAdjustment = .alignCenters
        goalActual.minimumScaleFactor = 0.01
        goalActual.font = UIFont(name: (goalActual.font.fontName), size: fastTextSize)
        
        // Finished
        pickDateLabel.frame = CGRect(x: round(startActual.frame.maxX), y: startActual.frame.minY, width: startActual.frame.height, height: startActual.frame.height)
        pickDateLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        pickDateLabel.titleLabel?.textAlignment = .center
        pickDateLabel.titleLabel?.baselineAdjustment = .alignCenters
        pickDateLabel.titleLabel?.minimumScaleFactor = 0.01
        pickDateLabel.titleLabel?.font = UIFont(name: ((pickDateLabel.titleLabel?.font.fontName)!), size: fastTextSize)
        self.buttonsArray.append(pickDateLabel)

        // Finished
        setGoal.frame = CGRect(x: round(screenSize.width*0.75442029), y: round(screenSize.height*0.231657609), width: round(screenSize.width*0.3), height: round(screenSize.height*0.04))
        setGoal.center.x = screenSize.width/2
        setGoal.center.y = screenSize.height*0.236413043
        setGoal.adjustsFontSizeToFitWidth = true
        setGoal.textAlignment = .center
        setGoal.baselineAdjustment = .alignCenters
        setGoal.minimumScaleFactor = 0.01
        setGoal.font = UIFont(name: (setGoal.font.fontName), size: fastTextSize)
        
        
        // Finished
        fastSlideName.frame = CGRect(x: round(screenSize.width*0.75442029), y: round(screenSize.height*0.231657609), width: round(screenSize.width*0.285024155), height: round(screenSize.height*0.0407608696))
        fastSlideName.center.x = round(screenSize.width/2)
        fastSlideName.center.y = round(screenSize.height*0.328804347)
       
        // Finished
        buttonLabel.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.905797101), height: round(screenSize.height*0.0774456522))
        buttonLabel.center.x = round(screenSize.width/2)
        buttonLabel.center.y = round(screenSize.height*0.388586957)
        buttonLabel.layer.borderWidth = 1.0
        buttonLabel.layer.borderColor = UIColor.black.cgColor
        buttonLabel.layer.masksToBounds = true
        buttonLabel.backgroundColor = beige
        buttonLabel.layer.cornerRadius = 0
        
        // Finished
        myButton.setTitle("Start Fast", for: .normal)
        myButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: myButton.frame.width*0.2, bottom: 0, right: myButton.frame.width*0.2)
        myButton.titleLabel?.adjustsFontSizeToFitWidth = true
        myButton.titleLabel?.minimumScaleFactor = 0.01
        myButton.titleLabel?.textAlignment = .center
        myButton.titleLabel?.baselineAdjustment = .alignCenters
        myButton.titleLabel?.font = UIFont(name: (myButton.titleLabel?.font.fontName)!, size: fastTextSize)
        self.buttonsArray.append(myButton)
        
        // Finished
        cancelLabel.setTitle("✕", for: .normal)
        cancelLabel.layer.zPosition = 2
        cancelLabel.backgroundColor = .clear
        cancelLabel.frame = CGRect(x: 0, y: 0, width: buttonLabel.frame.height, height: buttonLabel.frame.height)
        cancelLabel.center.x = screenSize.width*1.5/10
        cancelLabel.center.y = buttonLabel.center.y
        cancelLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelLabel.titleLabel?.minimumScaleFactor = 0.01
        cancelLabel.titleLabel?.textAlignment = .center
        cancelLabel.titleLabel?.baselineAdjustment = .alignCenters
        cancelLabel.titleLabel?.font = UIFont(name: (cancelLabel.titleLabel?.font.fontName)!, size: fastTextSize)
        
        // Finished
        confirmLabel.setTitle("✓", for: .normal)
        confirmLabel.layer.zPosition = 2
        confirmLabel.backgroundColor = .clear
        confirmLabel.frame = CGRect(x: 0, y: 0, width: buttonLabel.frame.height, height: buttonLabel.frame.height)
        confirmLabel.center.x = screenSize.width*8.5/10
        confirmLabel.center.y = buttonLabel.center.y
        confirmLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        confirmLabel.titleLabel?.minimumScaleFactor = 0.01
        confirmLabel.titleLabel?.textAlignment = .center
        confirmLabel.titleLabel?.baselineAdjustment = .alignCenters
        confirmLabel.titleLabel?.font = UIFont(name: (confirmLabel.titleLabel?.font.fontName)!, size: fastTextSize)
        
        // Finished
        cancelDelete.setTitle("✕", for: .normal)
        cancelDelete.layer.zPosition = 2
        cancelDelete.backgroundColor = .clear
        cancelDelete.center.x = screenSize.width/5
        cancelDelete.center.y = screenSize.height*3/4
        cancelDelete.frame = CGRect(x: 0, y: screenSize.height*4/6, width: screenSize.width/2, height: screenSize.width/6)
        cancelDelete.setTitleColor(UIColor.black, for: .normal)
        cancelDelete.isHidden = true
        cancelDelete.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelDelete.titleLabel?.minimumScaleFactor = 0.01
        cancelDelete.titleLabel?.textAlignment = .center
        cancelDelete.titleLabel?.baselineAdjustment = .alignCenters
        cancelDelete.titleLabel?.font = UIFont(name: (cancelDelete.titleLabel?.font.fontName)!, size: fastTextSize)

        // Finished
        confirmDelete.setTitle("✓", for: .normal)
        confirmDelete.layer.zPosition = 2
        confirmDelete.backgroundColor = .clear
        confirmDelete.center.x = screenSize.width*4/5
        confirmDelete.center.y = screenSize.height*3/4
        confirmDelete.frame = CGRect(x: screenSize.width/2, y: screenSize.height*4/6, width: screenSize.width/2, height: screenSize.width/6)
        confirmDelete.setTitleColor(UIColor.black, for: .normal)
        confirmDelete.isHidden = true
        confirmDelete.titleLabel?.adjustsFontSizeToFitWidth = true
        confirmDelete.titleLabel?.minimumScaleFactor = 0.01
        confirmDelete.titleLabel?.textAlignment = .center
        confirmDelete.titleLabel?.baselineAdjustment = .alignCenters
        confirmDelete.titleLabel?.font = UIFont(name: (confirmDelete.titleLabel?.font.fontName)!, size: fastTextSize)
        
        // Finished
        sevenFasts.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.2), height: round(screenSize.height*0.025))
        sevenFasts.center.x = screenSize.width/2
        sevenFasts.center.y = screenSize.height*0.456521739
        sevenFasts.text = "FASTS " + String(7*pageNumber+1) + " - " + String(7*pageNumber+7)
        sevenFasts.adjustsFontSizeToFitWidth = true
        sevenFasts.minimumScaleFactor = 0.01
        sevenFasts.textAlignment = .center
        sevenFasts.baselineAdjustment = .alignCenters
        sevenFasts.font = UIFont(name: (sevenFasts.font.fontName), size: fastTextSize)
        
        // Finished
        goalLine.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.18115942), height: round(screenSize.height*0.0203804348))
        goalLine.adjustsFontSizeToFitWidth = true
        goalLine.textAlignment = .center
        goalLine.baselineAdjustment = .alignCenters
        goalLine.minimumScaleFactor = 0.01
        goalLine.font = UIFont(name: (goalLabel.font.fontName), size: fastTextSize)
        
        // Finished
        started.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.171497585), height: round(screenSize.height*0.0203804348))
        started.center.x = screenSize.width*2.125/16
        started.center.y = screenSize.height*0.77
        started.adjustsFontSizeToFitWidth = true
        started.textAlignment = .center
        started.baselineAdjustment = .alignCenters
        started.minimumScaleFactor = 0.01
        started.font = UIFont(name: (started.font.fontName), size: fastTextSize)
        
        // Finished
        
        let xPos = Int(screenSize.width*0.0458937198) + barWidth%5
//        xPos-2 + Int(screenSize.width*0.55*0.65)
        
        duration.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.147342995), height: round(screenSize.height*0.0203804348))
        duration.center.x = CGFloat(xPos-2 + Int(screenSize.width*0.55*0.65)) + round(screenSize.width*0.147342995)/2
        duration.center.y = started.center.y
        duration.adjustsFontSizeToFitWidth = true
        duration.textAlignment = .center
        duration.baselineAdjustment = .alignCenters
        duration.minimumScaleFactor = 0.01
        duration.font = UIFont(name: (duration.font.fontName), size: fastTextSize)
        
        // Finished
        editStartLabel.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.0917874396), height: round(screenSize.height*0.0203804348))
        editStartLabel.center.x = screenSize.width*44/64
        editStartLabel.center.y = started.center.y
        editStartLabel.adjustsFontSizeToFitWidth = true
        editStartLabel.textAlignment = .center
        editStartLabel.baselineAdjustment = .alignCenters
        editStartLabel.minimumScaleFactor = 0.01
        editStartLabel.font = UIFont(name: (duration.font.fontName), size: fastTextSize)
        
        // Finished
        editStopLabel.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.077294686), height: round(screenSize.height*0.0203804348))
        editStopLabel.center.x = screenSize.width*51.5/64
        editStopLabel.center.y = started.center.y
        editStopLabel.adjustsFontSizeToFitWidth = true
        editStopLabel.textAlignment = .center
        editStopLabel.baselineAdjustment = .alignCenters
        editStopLabel.minimumScaleFactor = 0.01
        editStopLabel.font = UIFont(name: (duration.font.fontName), size: fastTextSize)
        
        // Finished
        editDeleteLabel.frame = CGRect(x: 0, y: 0, width: round(screenSize.width*0.106280193), height: round(screenSize.height*0.0203804348))
        editDeleteLabel.center.x = screenSize.width*59/64
        editDeleteLabel.center.y = started.center.y
        editDeleteLabel.adjustsFontSizeToFitWidth = true
        editDeleteLabel.textAlignment = .center
        editDeleteLabel.baselineAdjustment = .alignCenters
        editDeleteLabel.minimumScaleFactor = 0.01
        editDeleteLabel.font = UIFont(name: (duration.font.fontName), size: fastTextSize)
        
        //let xPos = Int(screenSize.width*0.0458937198) + barWidth%5
        
        // Finished
        fast1.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*0, width: Int(screenSize.width*0.55*0.6), height: (Int(screenSize.height*0.0298913043)+1))
        fast1.adjustsFontSizeToFitWidth = true
        fast1.textAlignment = .left
        fast1.baselineAdjustment = .alignCenters
        fast1.font = UIFont(name: fast1.font.fontName, size: fastTextSize)
        
        // Finished
        fast2.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*1, width: Int(screenSize.width*0.55*0.6), height: (Int(screenSize.height*0.0298913043)+1))
        fast2.adjustsFontSizeToFitWidth = true
        fast2.textAlignment = .left
        fast2.baselineAdjustment = .alignCenters
        fast2.font = UIFont(name: fast2.font.fontName, size: fastTextSize)
        
        // Finished
        fast3.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*2, width: Int(screenSize.width*0.55*0.6), height: (Int(screenSize.height*0.0298913043)+1))
        fast3.adjustsFontSizeToFitWidth = true
        fast3.textAlignment = .left
        fast3.baselineAdjustment = .alignCenters
        fast3.font = UIFont(name: fast3.font.fontName, size: fastTextSize)
        
        // Finished
        fast4.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*3, width: Int(screenSize.width*0.55*0.6), height: (Int(screenSize.height*0.0298913043)+1))
        fast4.adjustsFontSizeToFitWidth = true
        fast4.textAlignment = .left
        fast4.baselineAdjustment = .alignCenters
        fast4.font = UIFont(name: fast4.font.fontName, size: fastTextSize)
        
        // Finished
        fast5.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*4, width: Int(screenSize.width*0.55*0.6), height: (Int(screenSize.height*0.0298913043)+1))
        fast5.adjustsFontSizeToFitWidth = true
        fast5.textAlignment = .left
        fast5.baselineAdjustment = .alignCenters
        fast5.font = UIFont(name: fast5.font.fontName, size: fastTextSize)
        
        // Finished
        fast6.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*5, width: Int(screenSize.width*0.55*0.6), height: (Int(screenSize.height*0.0298913043)+1))
        fast6.adjustsFontSizeToFitWidth = true
        fast6.textAlignment = .left
        fast6.baselineAdjustment = .alignCenters
        fast6.font = UIFont(name: fast6.font.fontName, size: fastTextSize)
        
        // Finished
        fast7.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*6, width: Int(screenSize.width*0.55*0.6), height: (Int(screenSize.height*0.0298913043)+1))
        fast7.adjustsFontSizeToFitWidth = true
        fast7.textAlignment = .left
        fast7.baselineAdjustment = .alignCenters
        fast7.font = UIFont(name: fast7.font.fontName, size: fastTextSize)
        
        // Finished
        dur1.frame = CGRect(x: xPos-2 + Int(screenSize.width*0.55*0.65), y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*0, width: Int(screenSize.width*0.55*0.35), height: (Int(screenSize.height*0.0298913043)+1))
        dur1.adjustsFontSizeToFitWidth = true
        dur1.textAlignment = .left
        dur1.baselineAdjustment = .alignCenters
        dur1.font = UIFont(name: fast1.font.fontName, size: fastTextSize)
        self.view.addSubview(dur1)
        
        // Finished
        dur2.frame = CGRect(x: xPos-2 + Int(screenSize.width*0.55*0.65), y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*1, width: Int(screenSize.width*0.55*0.35), height: (Int(screenSize.height*0.0298913043)+1))
        dur2.adjustsFontSizeToFitWidth = true
        dur2.textAlignment = .left
        dur2.baselineAdjustment = .alignCenters
        dur2.font = UIFont(name: fast1.font.fontName, size: fastTextSize)
        self.view.addSubview(dur2)
        
        // Finished
        dur3.frame = CGRect(x: xPos-2 + Int(screenSize.width*0.55*0.65), y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*2, width: Int(screenSize.width*0.55*0.35), height: (Int(screenSize.height*0.0298913043)+1))
        dur3.adjustsFontSizeToFitWidth = true
        dur3.textAlignment = .left
        dur3.baselineAdjustment = .alignCenters
        dur3.font = UIFont(name: fast1.font.fontName, size: fastTextSize)
        self.view.addSubview(dur3)
        
        // Finished
        dur4.frame = CGRect(x: xPos-2 + Int(screenSize.width*0.55*0.65), y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*3, width: Int(screenSize.width*0.55*0.35), height: (Int(screenSize.height*0.0298913043)+1))
        dur4.adjustsFontSizeToFitWidth = true
        dur4.textAlignment = .left
        dur4.baselineAdjustment = .alignCenters
        dur4.font = UIFont(name: fast1.font.fontName, size: fastTextSize)
        self.view.addSubview(dur4)
        
        // Finished
        dur5.frame = CGRect(x: xPos-2 + Int(screenSize.width*0.55*0.65), y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*4, width: Int(screenSize.width*0.55*0.35), height: (Int(screenSize.height*0.0298913043)+1))
        dur5.adjustsFontSizeToFitWidth = true
        dur5.textAlignment = .left
        dur5.baselineAdjustment = .alignCenters
        dur5.font = UIFont(name: fast1.font.fontName, size: fastTextSize)
        self.view.addSubview(dur5)
        
        // Finished
        dur6.frame = CGRect(x: xPos-2 + Int(screenSize.width*0.55*0.65), y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*5, width: Int(screenSize.width*0.55*0.35), height: (Int(screenSize.height*0.0298913043)+1))
        dur6.adjustsFontSizeToFitWidth = true
        dur6.textAlignment = .left
        dur6.baselineAdjustment = .alignCenters
        dur6.font = UIFont(name: fast1.font.fontName, size: fastTextSize)
        self.view.addSubview(dur6)
        
        // Finished
        dur7.frame = CGRect(x: xPos-2 + Int(screenSize.width*0.55*0.65), y: Int(started.center.y) + Int(screenSize.height*0.0163043478) + 1 + (Int(screenSize.height*0.0298913043)+1)*6, width: Int(screenSize.width*0.55*0.35), height: (Int(screenSize.height*0.0298913043)+1))
        dur7.adjustsFontSizeToFitWidth = true
        dur7.textAlignment = .left
        dur7.baselineAdjustment = .alignCenters
        dur7.font = UIFont(name: fast1.font.fontName, size: fastTextSize)
        self.view.addSubview(dur7)
        
        
        // If the NSDefaults aren't empty, copy them
        if(copyCurrentlyFasting.count != 0)
        {
            currentlyFasting = copyCurrentlyFasting
        }
        if(copyFastGraph.count != 0)
        {
            fastGraph = copyFastGraph
        }
        if(copyFastLog.count != 0)
        {
            fastLog = copyFastLog
        }
        if(copyRawFastLog.count != 0)
        {
            rawFastLog = copyRawFastLog
        }
        if(copySaveDate.count != 0)
        {
            saveDate = copySaveDate
        }
        if(copyTime.count != 0)
        {
            time = copyTime
        }
        if(copyTrueGoal.count != 0)
        {
            trueGoal = copyTrueGoal
        }
        if(currentlyFasting[0] == "1")
        {
            if(saveDate.count > 0)
            {
                if(saveDate[0] != 0)
                {
                    time[0] = Int(NSDate().timeIntervalSince1970) - saveDate[0]
                }
            }
            currentlyFasting[0] = "0"
            defaults.set(fastGraph,         forKey: "savedGraph")
            defaults.set(fastLog,           forKey: "savedLog")
            defaults.set(rawFastLog,        forKey: "savedRawLog")
            defaults.set(currentlyFasting,  forKey: "savedBool")
            myButton.sendActions(for: .touchUpInside)
        }
        let tempHr = Int(time[0]) / 3600
        let tempMin = Int(time[0]) / 60 % 60
        let tempSec = Int(time[0]) % 60
        
        let token = setGoal.text!.components(separatedBy: " ")
        
        let remainHr = Int(Int(token[0])!*3600 - time[0]) / 3600
        let remainMin = Int(Int(token[0])!*3600 - time[0]) / 60 % 60
        let remainSec = Int(Int(token[0])!*3600 - time[0]) % 60
        
        timerLabel.text = String(format:"%02i:%02i:%02i", tempHr, tempMin, tempSec)
        remainingLabel.text = String(format:"%02i:%02i:%02i", remainHr, remainMin, remainSec)
        
        fastSlideName.setValue(Float(trueGoal[0]/3600), animated: false)
        displayGraph()
        displayLog()
        let layer2 = CAGradientLayer()
        layer2.frame = CGRect(x: 0, y: 0, width: Int(screenSize.width), height: Int(screenSize.height*0.304347826))
        layer2.colors = [topColor.cgColor, bottomColor.cgColor]
        view.layer.insertSublayer(layer2, at: 0)
        layer2.zPosition = -1
        // Makes sure start time is always up to date
        timer2 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateStartTime), userInfo: nil, repeats: true)
        //print("Loadup")
        //print("Save Date: " + String(saveDate[0]))
        //print()
    }
    //=====================================Rect Functions=====================================//
    func drawRect(myXPos: Int, myHeight: Int)
    {
        var tempHeight = myHeight
        if(tempHeight < 0)
        {
            tempHeight = 0
        }
        let rectangle = UIBezierPath.init()
        var width = 25
        var height = tempHeight
        var xPos = myXPos
        var yPos = bottomHeight
        rectangle.move(to: CGPoint.init(x: xPos, y: yPos))
        rectangle.addLine(to: CGPoint.init(x: xPos+width, y: yPos))
        rectangle.addLine(to: CGPoint.init(x: xPos+width, y: yPos-height))
        rectangle.addLine(to: CGPoint.init(x: xPos, y: yPos-height))
        rectangle.close()
        let layer2 = CAGradientLayer()
        layer2.frame = CGRect(x: xPos, y: yPos-height, width: barWidth, height: height)
        layer2.colors = [topRec.cgColor, lowRec.cgColor]
        layer2.zPosition = -1
        
        view.layer.addSublayer(layer2)
        
        layerArray.append(layer2)
    }
    func drawBlankRect(myXPos: Int, myYPos: Int, myHeight: Int, myWidth: Int, myColor: UIColor)
    {
        var tempHeight = myHeight
        if(tempHeight<0)
        {
            tempHeight = 0
        }
        let rectangle = UIBezierPath.init()
        var width = myWidth
        var height = tempHeight
        var xPos = myXPos
        var yPos = myYPos
        rectangle.move(to: CGPoint.init(x: xPos, y: yPos))
        rectangle.addLine(to: CGPoint.init(x: xPos+width, y: yPos))
        rectangle.addLine(to: CGPoint.init(x: xPos+width, y: yPos-height))
        rectangle.addLine(to: CGPoint.init(x: xPos, y: yPos-height))
        rectangle.close()
        let rec = CAShapeLayer.init()
        rec.path = rectangle.cgPath
        self.view.backgroundColor = UIColor.white
        rec.fillColor = myColor.cgColor
        self.view.layer.addSublayer(rec)
        rec.zPosition = -1
        layerArray.append(rec)
    }
}


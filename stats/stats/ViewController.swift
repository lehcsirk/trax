//
//  ViewController.swift
//  stats
//
//  Created by Cameron Krischel on 3/24/19.
//  Copyright © 2019 Cameron Krischel. All rights reserved.
//

import UIKit
import WebKit
import SwiftSoup

class ViewController: UIViewController
{
    let screenSize = UIScreen.main.bounds
    var isURLReady = false
    var label = UILabel()
    var stats = UILabel()
    
    var image_view: UIImageView!
    
    var leftButton = UIButton()
    var rightButton = UIButton()
    
    var attributedString = NSAttributedString()
    var htmlArray = [String]()
    var tableArray = [String]()
    var weaponArray = [String]()
    var weaponStatsArray: [[String]] = []
    
    var currentWeaponIndex = 0
    
    var weaponNameArray = [String]()
    var statsArray = [[String]]()
    
    var imgArray = [UIImage]()
    var imageView = UIImageView()
   
    var counter = 0
    
    override func viewDidLoad()
    {
        var urlContent = ""
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        label = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height/16))
        label.center = CGPoint(x: screenSize.width/2, y: screenSize.height/32)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        self.view.addSubview(label)
        
        stats = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height*15/16))
        stats.center = CGPoint(x: screenSize.width/2, y: screenSize.height*8.5/16)
        stats.textAlignment = .center
        stats.lineBreakMode = NSLineBreakMode.byWordWrapping
        stats.numberOfLines = 0
        stats.adjustsFontForContentSizeCategory = true
        stats.layer.borderColor = UIColor.black.cgColor
        stats.layer.borderWidth = 1.0
        stats.text = "Stats"
        self.view.addSubview(stats)
        
        rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenSize.width/4, height: screenSize.height/4))
        rightButton.center = CGPoint(x: screenSize.width*7/8, y: screenSize.height*7/8)
        rightButton.titleLabel?.textAlignment = .center
        rightButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        rightButton.titleLabel?.numberOfLines = 0
        rightButton.titleLabel?.adjustsFontForContentSizeCategory = true
        rightButton.layer.borderColor = UIColor.black.cgColor
        rightButton.layer.borderWidth = 1.0
        rightButton.setTitle("->", for: .normal)
        rightButton.setTitleColor(UIColor.black, for: .normal)
        rightButton.addTarget(self, action: #selector(pageRight), for: .touchUpInside)
        self.view.addSubview(rightButton)
        
        leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenSize.width/4, height: screenSize.height/4))
        leftButton.center = CGPoint(x: screenSize.width*1/8, y: screenSize.height*7/8)
        leftButton.titleLabel?.textAlignment = .center
        leftButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        leftButton.titleLabel?.numberOfLines = 0
        leftButton.titleLabel?.adjustsFontForContentSizeCategory = true
        leftButton.layer.borderColor = UIColor.black.cgColor
        leftButton.layer.borderWidth = 1.0
        leftButton.setTitle("<-", for: .normal)
        leftButton.setTitleColor(UIColor.black, for: .normal)
        leftButton.addTarget(self, action: #selector(pageLeft), for: .touchUpInside)
        self.view.addSubview(leftButton)
        
        let urlString = "https://wiki.teamfortress.com/wiki/Weapons"
        let tempURL = URL(string: urlString)
        let url = NSURL(string: urlString)
        
        if url != nil
        {
            let task = URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) -> Void in
                print(data)
                if error == nil
                {
                    urlContent = (NSString(data: data!, encoding: String.Encoding.ascii.rawValue) as NSString!) as String
                    self.attributedString = NSAttributedString(string: urlContent)
                    print("URLCONTENT BEGINS")
                    print(self.attributedString)
                    print("URLCONTENT ENDS")
                    self.isURLReady = true
                }
            })
            task.resume()
        }
        while(!isURLReady)
        {
            //print("NOT READY")
        }
        label.text = urlContent
        label.text = urlContent.slice(from: "<title>", to: "</title>")
        
        do {
            print("ENTERED THE DO")
            let html = try String(contentsOf: tempURL!)
            print("BOOP1")
            let doc: Document = try SwiftSoup.parse(html)
            print("BOOP2")
//            try print(doc.text())
//            print("3")
            let els: Elements = try doc.getElementsByTag("table")
            print("BOOP4")


            

            for link: Element in els.array()
            {
                let imgData: Elements = try link.getElementsByTag("img")
                for img: Element in imgData.array()
                {
                    
                    var fullURL = "https://wiki.teamfortress.com"
                    //fullURL += try img.attr("srcset")//.slice(from: ", ", to: " 2x")!
                    //https://wiki.teamfortress.com/w/images/thumb/1/1b/Item_icon_Scattergun.png/200px-Item_icon_Scattergun.png
                    
                    if let range = (try img.attr("srcset")).range(of: ", ")
                    {
                        fullURL += (try img.attr("srcset"))[range.upperBound...]
                        fullURL.removeLast()
                        fullURL.removeLast()
                        fullURL.removeLast()
                        
                        //                                print("full url")
                        print(fullURL)
                        //                                print("full url end")
                        
                        
                        let imageUrl = URL(string: fullURL)!
                        let imageData = try! Data(contentsOf: imageUrl)
                        let image = UIImage(data: imageData)
                        
                        // Insert image into array so we can page
                        imgArray.append(image!)
                    }
                }
                
                let tableRows: Elements = try link.getElementsByTag("tr")
                for displayTableRows: Element in tableRows.array()
                {
                    //print("=============================TABLE DATA=============================")
                    let tableHeaders: Elements = try displayTableRows.getElementsByTag("th")
                    var columnHeaders = ""
                    for displayTableHeaders: Element in tableHeaders.array()
                    {
                        
                        
                        
                        if(try displayTableHeaders.className() != "header")
                        {
                            print(try displayTableHeaders.text())
                        }
                        else
                        {
                            columnHeaders += try displayTableHeaders.text()
                            if(try displayTableHeaders.hasAttr("rowspan"))
                            {
                                columnHeaders += try displayTableHeaders.attr("rowspan")
                            }
                            else
                            {
                                columnHeaders += "1"
                            }
                            columnHeaders += "*"
                            if(try displayTableHeaders.hasAttr("colspan"))
                            {
                                columnHeaders += try displayTableHeaders.attr("colspan")
                            }
                            else
                            {
                                columnHeaders += "1"
                            }
                            columnHeaders += " "
                        }
                    }
                    print(columnHeaders)
                    
                    let tableData: Elements = try displayTableRows.getElementsByTag("td")
                    for displayTableData: Element in tableData.array()
                    {
                        print(try displayTableData.text())
                        
                        
                    }
                    //print("=============================TABLE DATA=============================")
                }
            }
        }
        catch Exception.Error(let type, let message)
        {
            print(message)
        } catch {
            print("error")
        }
        
        // Stores html data into htmlArray
        urlContent.enumerateLines { line, _ in
            self.htmlArray.append(line)
        }
        
        // Stores table data in tableArray
        var shouldPrint = false
        for i in 0...htmlArray.count-1
        {
            if(htmlArray[i].range(of:"<h2><span class=\"mw-headline\" id=\"") != nil) //"<table class=\"wikitable grid\" width=\"100%\" style=\"text-align: center;\">")
            {
                shouldPrint = true
            }
            if(htmlArray[i] == "</table>")
            {
                shouldPrint = false
            }
            if(shouldPrint)
            {
//                print(htmlArray[i])
                tableArray.append(htmlArray[i])
            }
        }
        
        // Prints tableArray
        for i in 0...tableArray.count-1
        {
            //print(tableArray[i])
            // || (tableArray[i].range(of:"<td> <a href=\"/wiki/") != nil)
            if((tableArray[i].range(of:"<th> <a href=\"/wiki/") != nil) || (tableArray[i].range(of:"<th rowspan=") != nil) || (tableArray[i].range(of:"<td> <a href=\"/wiki/") != nil))
            {
                //print(tableArray[i].slice(from: "<b>", to: "</b>")!)
                if(tableArray[i].range(of:"<b>") != nil)
                {
                    weaponArray.append(tableArray[i].slice(from: "<b>", to: "</b>")!)
                }
            }
        }
        var count = 0
        var tempArray = [String]()
        var beginArray = false
        for i in 0...tableArray.count-1
        {
        
            if(((tableArray[i].range(of:"<td>") != nil) || (tableArray[i].range(of:"<td rowspan=") != nil) || (tableArray[i].range(of:"<td colspan=") != nil)) && (tableArray[i].range(of:"<td> <a href=\"/wiki/") == nil)) //&& (tableArray[i].range(of:"<td> <b>") == nil)) //&& (tableArray[i].range(of:"<span id") == nil))
            {
                tempArray.append(tableArray[i])//.components(separatedBy: "> ").last!)
                //print(tableArray[i])
            }
            if((tableArray[i].range(of:"<th> <a href=\"/wiki/") != nil) || (tableArray[i].range(of:"<th rowspan=") != nil) || (tableArray[i].range(of:"<td> <a href=\"/wiki/") != nil))
            {
                if(beginArray)
                {
                    beginArray = false
                    
                    if(!tempArray.isEmpty)
                    {
                        if(tempArray[0].range(of: "<td rowspan=") != nil)
                        {
                            var tempString = tempArray[0].slice(from: "<td rowspan=\"", to: "\"")
                            var numberOfRepeats = 0
                            numberOfRepeats = Int(tempString!)!
                            for i in 0...Int(numberOfRepeats-1)
                            {
                                for k in 0...tempArray.count-1
                                {
                                    if(tempArray[k].last == ">")
                                    {
                                        tempArray[k].removeLast()
                                    }
                                    tempArray[k] = tempArray[k].components(separatedBy: ">").last!
                                    tempArray[k] = tempArray[k].components(separatedBy: "<").first!
                                }
                                weaponStatsArray.append(tempArray)
                                //print("APPENDED")
                            }
                        }
                        else
                        {
                            for k in 0...tempArray.count-1
                            {
                                if(tempArray[k].last == ">")
                                {
                                    tempArray[k].removeLast()
                                }
                                tempArray[k] = tempArray[k].components(separatedBy: ">").last!
                                tempArray[k] = tempArray[k].components(separatedBy: "<").first!
                                
                            }
                            weaponStatsArray.append(tempArray)
                        }
                    }
                    tempArray.removeAll()
                    count += 1
                }
                if(!beginArray)
                {
                    beginArray = true
                }
            }
        }
        
        stats.text = weaponArray[currentWeaponIndex]
        if(weaponStatsArray[currentWeaponIndex].count - 1 > 0)
        {
            for j in 0...weaponStatsArray[currentWeaponIndex].count - 1
            {
                stats.text?.append("\n")
                stats.text?.append(String(weaponStatsArray[currentWeaponIndex][j]))
            }
        }
        
        imageView = UIImageView(image: imgArray[currentWeaponIndex])
        imageView.isHidden = false
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1.0
        // Center it
        //imageView.frame = CGRect(x: 0, y: 0, width: screenSize.width/4, height: screenSize.width/4)
        imageView.center.x = screenSize.width/2
        imageView.center.y = screenSize.height/6
        
        
        // Add it to subview
        view.addSubview(imageView)

    }
    @objc func pageRight()
    {
        if(currentWeaponIndex < weaponArray.count-1)
        {
            currentWeaponIndex += 1
        }
        else
        {
            currentWeaponIndex = 0
        }
        stats.text = weaponArray[currentWeaponIndex]
        
        if(weaponStatsArray[currentWeaponIndex].count - 1 > 0)
        {
            for j in 0...weaponStatsArray[currentWeaponIndex].count - 1
            {
                stats.text?.append("\n")
                stats.text?.append(String(weaponStatsArray[currentWeaponIndex][j]))
            }
        }
        label.text = String(currentWeaponIndex)
        
        imageView.image = imgArray[currentWeaponIndex]
    }
    @objc func pageLeft()
    {
        if(currentWeaponIndex > 0)
        {
            currentWeaponIndex -= 1
        }
        else
        {
            currentWeaponIndex = weaponArray.count-1
        }
        stats.text = weaponArray[currentWeaponIndex]
        
        if(weaponStatsArray[currentWeaponIndex].count - 1 > 0)
        {
            for j in 0...weaponStatsArray[currentWeaponIndex].count - 1
            {
                stats.text?.append("\n")
                stats.text?.append(String(weaponStatsArray[currentWeaponIndex][j]))
            }
        }
        label.text = String(currentWeaponIndex)
        imageView.image = imgArray[currentWeaponIndex]
    }
}

extension String
{
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

extension StringProtocol where Index == String.Index
{
    func index(of string: Self, options: String.CompareOptions = []) -> Index?
    {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index?
    {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index]
    {
        var result: [Index] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options)
        {
            result.append(range.lowerBound)
            start = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>]
    {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options)
        {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

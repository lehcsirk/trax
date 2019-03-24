//
//  ViewController.swift
//  traẍ
//
//  Created by Cameron Krischel on 3/22/19.
//  Copyright © 2019 Cameron Krischel. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController
{
    let screenSize = UIScreen.main.bounds
    var isURLReady = false
    var webView = UIWebView()
    var label = UILabel()
    var stats = UILabel()
    var finalStats = UILabel()
    var button = UIButton()
    
    var tracking = false
    var time = CGFloat()
    var timer = Timer()
    var startTime = 0
    var initialDamage = CGFloat(0)
    var finalDamage = CGFloat(0)
    
    override func loadView()
    {
        //self.view = webView
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.backgroundColor = UIColor.white
        //self.webView.delegate = self as! UIWebViewDelegate
        self.view.addSubview(webView)
        webView.bounds = CGRect(x: 0, y: screenSize.height/2, width: screenSize.width, height: screenSize.height*3/4)
        webView.center.x = screenSize.width/2
        webView.center.y = screenSize.height*5/8
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    @objc func updateTimer()
    {
        if(tracking)
        {
            time = CGFloat(Int(NSDate().timeIntervalSince1970) - startTime)
        }
        else
        {
            time = 0
        }
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        let timeString = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        button.setTitle(timeString, for: .normal)
    }
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
        
        button = UIButton(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height/16))
        button.center = CGPoint(x: screenSize.width/2, y: screenSize.height*3/32)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
        //button.setTitle("Button", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(displayDoc), for: .touchDown)
        self.view.addSubview(button)
        
        stats = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width/2, height: screenSize.height/8))
        stats.center = CGPoint(x: screenSize.width/4, y: screenSize.height*3/16)
        stats.textAlignment = .center
        stats.lineBreakMode = NSLineBreakMode.byWordWrapping
        stats.numberOfLines = 0
        stats.adjustsFontForContentSizeCategory = true
        stats.layer.borderColor = UIColor.black.cgColor
        stats.layer.borderWidth = 1.0
        stats.text = "Stats"
        self.view.addSubview(stats)
        
        finalStats = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width/2, height: screenSize.height/8))
        finalStats.center = CGPoint(x: screenSize.width*3/4, y: screenSize.height*3/16)
        finalStats.textAlignment = .center
        finalStats.lineBreakMode = NSLineBreakMode.byWordWrapping
        finalStats.numberOfLines = 0
        finalStats.adjustsFontForContentSizeCategory = true
        finalStats.layer.borderColor = UIColor.black.cgColor
        finalStats.layer.borderWidth = 1.0
        finalStats.text = "Final stats"
        self.view.addSubview(finalStats)
        
        var urlString = "https://steamcommunity.com/id/lehcsirk/inventory#440_2_7405166285"//"https://steamcommunity.com/id/lehcsirk/inventory#440_2_7246635891"//"https://bazaar.tf/backpack/76561198026579431"//"https://backpack.tf/item/822091252"//"http://www.tf2items.com/profiles/76561198026579431"//"https://backpack.tf/profiles/76561198026579431"//
        var tempURL = URL(string: urlString)
        var url = NSURL(string: urlString)
        
        if url != nil
        {
            let task = URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) -> Void in
                print(data)
                if error == nil
                {
                    urlContent = (NSString(data: data!, encoding: String.Encoding.utf8.rawValue/*String.Encoding.ascii.rawValue*/) as NSString!) as String
//                    print("URLCONTENT BEGINS")
//                    print(urlContent)
//                    print("URLCONTENT ENDS")
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
        
        
        print("beforerequest")
        webView.loadRequest(NSURLRequest(url: url as! URL) as URLRequest)
        print("afterrequest")
        
        //Page is loaded do what you want
        print("HEREHERE")
        let doc = NSString(string: webView.stringByEvaluatingJavaScript(from: "document.documentElement.innerText")!)
        print(doc)
    }
    @objc func displayDoc(_sender: UIButton!)
    {
        webView.reload()
        let doc = NSString(string: webView.stringByEvaluatingJavaScript(from: "document.documentElement.innerHTML")!)
        print("===================================================================================================")
        print(doc)
        print("===================================================================================================")
        var kills = "nil"
        var ogName = "nil"
        var itemName = "nil"
        var tagName = "nil"
        
        kills = String(doc).slice(from: "Kills: ", to: "</div>") ?? "nil"
        ogName = String(doc).slice(from: "Original name: ", to: "</span>") ?? "nil"
        itemName = String(doc).slice(from: "class=\"\">Strange ", to: " -") ?? "nil"
        tagName = String(doc).slice(from: "alt=\"''", to: "''\">") ?? "nil"
        
        
        print("Kills: \(kills)")
        stats.text = "Kills: \(kills)"//"\nOriginal name: \(ogName)\nItem name: \(itemName)\nTag name: \(tagName)"
        
        if(tracking)
        {
            tracking = false
            finalDamage = CGFloat(Int(kills)!)
//            finalDamage = 20.0
//            initialDamage = 0.0
//            time = 60.0
            var DPS = CGFloat((finalDamage-initialDamage)/time*60)
            
            let formattedDPS = String(format: "%.4f", DPS)
            print(formattedDPS)

            var finalOutputString = "Initial Damage: \(initialDamage)\nFinal Damage: \(finalDamage)\nDuration: \(time)\nKPM: \(formattedDPS)"
            finalStats.text = finalOutputString
            print(finalOutputString)
        }
        else
        {
            tracking = true
            initialDamage = CGFloat(Int(kills)!)
            startTime = Int(NSDate().timeIntervalSince1970)
        }
        
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

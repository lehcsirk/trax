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
    }
    
    override func viewDidLoad()
    {
        var urlContent = ""
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height/16))
        label.center = CGPoint(x: screenSize.width/2, y: screenSize.height/32)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        self.view.addSubview(label)
        
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height/16))
        button.center = CGPoint(x: screenSize.width/2, y: screenSize.height*3/32)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
        button.setTitle("Button", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(displayDoc), for: .touchDown)
        self.view.addSubview(button)
        
        var stats = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height/8))
        stats.center = CGPoint(x: screenSize.width/2, y: screenSize.height*3/16)
        stats.textAlignment = .center
        stats.lineBreakMode = NSLineBreakMode.byWordWrapping
        stats.numberOfLines = 0
        stats.adjustsFontForContentSizeCategory = true
        stats.layer.borderColor = UIColor.black.cgColor
        stats.layer.borderWidth = 1.0
        stats.text = "Stats"
        self.view.addSubview(stats)
        
        var urlString = "https://steamcommunity.com/id/lehcsirk/inventory"//"https://bazaar.tf/backpack/76561198026579431"//"https://backpack.tf/item/822091252"//"http://www.tf2items.com/profiles/76561198026579431"//"https://backpack.tf/profiles/76561198026579431"//
        var tempURL = URL(string: urlString)
        var url = NSURL(string: urlString)
        
        if url != nil
        {
            let task = URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) -> Void in
                print(data)
                if error == nil
                {
                    urlContent = (NSString(data: data!, encoding: String.Encoding.utf8.rawValue/*String.Encoding.ascii.rawValue*/) as NSString!) as String
                    print("URLCONTENT BEGINS")
                    print(urlContent)
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
        let doc = NSString(string: webView.stringByEvaluatingJavaScript(from: "document.documentElement.innerHTML")!)
        print("===================================================================================================")
        print(doc)
        print("===================================================================================================")
        var kills = 0
        kills = Int(String(doc).slice(from: "Kills: ", to: "</div>")!)!
        print("Kills: \(kills)")
        
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

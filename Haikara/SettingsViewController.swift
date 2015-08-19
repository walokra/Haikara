//
//  SettingsViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 7.7.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit
import Alamofire

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var useMobileUrlSwitch: UISwitch!
    @IBOutlet weak var showDescSwitch: UISwitch!
    @IBOutlet weak var countryPicker: UIPickerView!

    let settings = Settings.sharedInstance

    var defaults = NSUserDefaults.standardUserDefaults()
    
    var supportedLanguages = NSMutableOrderedSet()
    var regions = [String]()
    
    //let regions: [String] = ["Finland", "Estonia", "Germany", "United States", "Norway", "Denmark", "Sweden", "Netherlands", "Italian"]
    
    @IBAction func useMobileUrl(sender: UISwitch) {
        settings.useMobileUrl = sender.on
        defaults.setObject(settings.useMobileUrl, forKey: "useMobileUrl")
//        println ("useMobileUrl \(settings.useMobileUrl), sender.on=\(sender.on)")
    }
    
    @IBAction func showDesc(sender: UISwitch) {
        settings.showDesc = sender.on
        defaults.setObject(settings.showDesc, forKey: "showDesc")
//        println ("showDesc \(settings.showDesc), sender.on=\(sender.on)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        listLanguages()
        
        showDescSwitch.on = settings.showDesc
        useMobileUrlSwitch.on = settings.useMobileUrl
        
        countryPicker.dataSource = self
        countryPicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return regions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return regions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        settings.country = regions[row]
        defaults.setObject(settings.country, forKey: "country")
        println ("country \(settings.country)")
        // TODO: Set region specific settings
//        self.highFiEndpoint = "json-private"
//        self.highFiActCategory = "listCategories"
//        self.highFiActUsedLanguage = "usedLanguage"
//        self.useToRetrieveLists = "finnish"
//        self.mostPopularName = "Suosituimmat"
//        self.latestName = "Uutiset"
//        self.domainToUse = "fi.high.fi"
//        self.genericNewsURLPart = "uutiset"
        
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // The list of currently supported by the server. 
    // You should cache this method's return value for min 24h
    // http://high.fi/api/?act=listLanguages&APIKEY=123
    func listLanguages(){
        var endpoint = "http://" + settings.domainToUse + "/api"
        
        Manager.sharedInstance.request(.GET, endpoint, parameters: ["act":"listLanguages", "APIKEY": settings.APIKEY])
            .responseJSON() { (request, response, data, error) in
            #if DEBUG
                println("request: \(request)")
                println("response: \(response)")
//                println("json: \(data)")
            #endif
                    
            if error == nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let responseData = (data!.valueForKey("responseData") as! NSDictionary)
                    let languages = (responseData.valueForKey("supportedLanguages") as! [NSDictionary])
                    .map { Language(
                            language: $0["language"] as! String,
                            country: $0["country"] as! String,
                            domainToUse: $0["domainToUse"] as! String,
                            languageCode: $0["languageCode"] as! String,
                            mostPopularName: $0["mostPopularName"] as! String,
                            latestName: $0["latestName"] as! String,
                            useToRetrieveLists: $0["useToRetrieveLists"] as!	String,
                            genericNewsURLPart: $0["genericNewsURLPart"] as! String
                            )
                    }
                    #if DEBUG
                        println("languages: \(languages.count)")
//                        println("languages: \(languages)")
                    #endif
                
                    dispatch_async(dispatch_get_main_queue()) {
                        // Clear old entries
                        self.supportedLanguages = NSMutableOrderedSet()
                        self.supportedLanguages.addObjectsFromArray(languages)
                        
                        // Put each item in a section
                        for item in self.supportedLanguages {
                            var entry = item as! Language
                            self.regions.append(entry.country)
                            // Sort array
                            self.regions = self.regions.sorted(<)
                        }
                        #if DEBUG
                            println("regions=\(self.regions)")
                        #endif
                        
                        self.countryPicker!.reloadAllComponents()
                        
                        var defaultRowIndex = find(self.regions, self.settings.country)
                        if(defaultRowIndex == nil) { defaultRowIndex = 0 }
                        self.countryPicker.selectRow(defaultRowIndex!, inComponent: 0, animated: false)
                        
                        return
                    }
                }
            } else {
                println("error: \(error)")
            }
        }
    }

}

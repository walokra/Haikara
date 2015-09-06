//
//  SettingsViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 7.7.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var useMobileUrlSwitch: UISwitch!
    @IBOutlet weak var showDescSwitch: UISwitch!
    @IBOutlet weak var countryPicker: UIPickerView!

    let settings = Settings.sharedInstance

    var defaults = NSUserDefaults.standardUserDefaults()
    
    var supportedLanguages: Array<Language> = []
    
    var navigationItemTitle: String = NSLocalizedString("SETTINGS_TITLE", comment: "Title for settings view")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")

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

        self.tabBarController!.title = navigationItemTitle
        self.navigationItem.title = navigationItemTitle
        
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
        return supportedLanguages.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.supportedLanguages[row].country
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let selectedRegion = self.supportedLanguages[row]
        settings.region = selectedRegion.country
        settings.useToRetrieveLists = selectedRegion.useToRetrieveLists
        settings.mostPopularName = selectedRegion.mostPopularName
        settings.latestName = selectedRegion.latestName
        settings.domainToUse = selectedRegion.domainToUse
        settings.genericNewsURLPart = selectedRegion.genericNewsURLPart
        #if DEBUG
            println ("selected region = \(settings.region)")
        #endif

        defaults.setObject(settings.region, forKey: "region")
        defaults.setObject(settings.useToRetrieveLists, forKey: "useToRetrieveLists")
        defaults.setObject(settings.mostPopularName, forKey: "mostPopularName")
        defaults.setObject(settings.latestName, forKey: "latestName")
        defaults.setObject(settings.domainToUse, forKey: "domainToUse")
        defaults.setObject(settings.genericNewsURLPart, forKey: "genericNewsURLPart")
        
        #if DEBUG
            println ("Settings = \(settings.description)")
        #endif
        
        NSNotificationCenter.defaultCenter().postNotificationName("regionChangedNotification", object: nil, userInfo: ["region": selectedRegion]) //userInfo parameter has to be of type [NSObject : AnyObject]?

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
    func listLanguages(){
        HighFiApi.listLanguages(
            { (result: Array<Language>) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    // Clear old entries
                    self.supportedLanguages = Array(result)
                    //                        #if DEBUG
                    //                            println("supportedLanguages=\(self.supportedLanguages)")
                    //                        #endif
                    
                    self.countryPicker!.reloadAllComponents()
                    
                    var defaultRowIndex = 0
                    for (index, element) in enumerate(self.supportedLanguages) {
                        var lang = element as Language
                        if (lang.country == self.settings.region) {
                            defaultRowIndex = index
                        }
                    }
                    #if DEBUG
                        println("self.settings.region=\(self.settings.region), defaultRowIndex=\(defaultRowIndex)")
                    #endif
                    self.countryPicker.selectRow(defaultRowIndex, inComponent: 0, animated: false)
                    
                    return
                }
            }, failureHandler: { (error: String) -> Void in
                self.handleError(error)
        })
    }
    
    func handleError(error: String) {
        #if DEBUG
            println("handleError, error: \(error)")
        #endif
        let alertController = UIAlertController(title: errorTitle, message: error, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true){}
    }

}

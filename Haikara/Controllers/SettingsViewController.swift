//
//  SettingsViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 7.7.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var resetButton: UIButton!
    
    @IBAction func resetAction(sender: AnyObject) {
        
        self.settings.resetToDefaults()
        
        HighFiApi.getCategories(
            { (result) in
                self.settings.categories = result
                
                self.settings.categoriesByLang.updateValue(self.settings.categories, forKey: self.settings.region)
                let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(self.settings.categoriesByLang as Dictionary<String, Array<Category>>)
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(archivedObject, forKey: "categoriesByLang")
                defaults.synchronize()
                
                // Send notification to inform favorite & hide views to refresh
                NSNotificationCenter.defaultCenter().postNotificationName("settingsResetedNotification", object: nil, userInfo: nil)

                return
            }
            , failureHandler: {(error)in
                self.handleError(error)
            }
        )
        
        listLanguages()
        
        showDescSwitch.on = settings.showDesc
        useMobileUrlSwitch.on = settings.useMobileUrl
        useReaderViewSwitch.on = settings.useReaderView
        
        // Notify user
        
        let alertController = UIAlertController(title: resetMessageTitle, message: resetMessage, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true){}
    }
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var useMobileUrlSwitch: UISwitch!
    @IBOutlet weak var showDescSwitch: UISwitch!
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var useReaderViewSwitch: UISwitch!

    let settings = Settings.sharedInstance

    var defaults = NSUserDefaults.standardUserDefaults()
    
    var languages = [Language]()
    
    var navigationItemTitle: String = NSLocalizedString("SETTINGS_TITLE", comment: "Title for settings view")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
    
    let resetMessageTitle: String = NSLocalizedString("SETTINGS_RESET_TITLE", comment: "")
    let resetMessage: String = NSLocalizedString("SETTINGS_RESET_MESSAGE", comment: "")
    
    @IBAction func useMobileUrl(sender: UISwitch) {
        settings.useMobileUrl = sender.on
        defaults.setObject(settings.useMobileUrl, forKey: "useMobileUrl")
        #if DEBUG
            print ("useMobileUrl \(settings.useMobileUrl), sender.on=\(sender.on)")
        #endif
    }
    
    @IBAction func showDesc(sender: UISwitch) {
        settings.showDesc = sender.on
        defaults.setObject(settings.showDesc, forKey: "showDesc")
        #if DEBUG
            print ("showDesc \(settings.showDesc), sender.on=\(sender.on)")
        #endif
    }
    
    @IBAction func useReaderView(sender: UISwitch) {
        settings.useReaderView = sender.on
        defaults.setObject(settings.useReaderView, forKey: "useReaderView")
        #if DEBUG
            print ("useReaderView \(settings.useReaderView), sender.on=\(sender.on)")
        #endif
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self

        self.tabBarController!.title = navigationItemTitle
        self.navigationItem.title = navigationItemTitle
        
        listLanguages()
        
        showDescSwitch.on = settings.showDesc
        useMobileUrlSwitch.on = settings.useMobileUrl
        useReaderViewSwitch.on = settings.useReaderView
        
        countryPicker.dataSource = self
        countryPicker.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        // set the frame of the scroll view to be equal to the frame of the container view
        self.scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)

        self.scrollView.addSubview(contentView)

        self.scrollView.contentSize = self.contentView.bounds.size
//        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width, self.scrollView.frame.height)

//        self.automaticallyAdjustsScrollViewInsets = false;
        
        // Hack
        self.scrollView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 52, right: 0)

        self.scrollView.flashScrollIndicators()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.languages.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.languages[row].country
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let selectedRegion = self.languages[row]
        settings.region = selectedRegion.country
        settings.useToRetrieveLists = selectedRegion.useToRetrieveLists
        settings.mostPopularName = selectedRegion.mostPopularName
        settings.latestName = selectedRegion.latestName
        settings.domainToUse = selectedRegion.domainToUse
        settings.genericNewsURLPart = selectedRegion.genericNewsURLPart
        #if DEBUG
            print ("selected region = \(settings.region)")
        #endif

        defaults.setObject(settings.region, forKey: "region")
        defaults.setObject(settings.useToRetrieveLists, forKey: "useToRetrieveLists")
        defaults.setObject(settings.mostPopularName, forKey: "mostPopularName")
        defaults.setObject(settings.latestName, forKey: "latestName")
        defaults.setObject(settings.domainToUse, forKey: "domainToUse")
        defaults.setObject(settings.genericNewsURLPart, forKey: "genericNewsURLPart")
        
//        #if DEBUG
//            print ("Settings = \(settings.description)")
//        #endif
        
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
        #if DEBUG
            print("settingsView, listLanguages: self.settings.languages=\(self.settings.languages)")
        #endif
        
        if !self.settings.languages.isEmpty {
            #if DEBUG
                print("settingsView, listLanguages: getting languages from settings")
            #endif
            
            if let updated: NSDate = self.settings.languagesUpdated {
                let calendar = NSCalendar.currentCalendar()
                let comps = NSDateComponents()
                comps.day = 1
                let updatedPlusWeek = calendar.dateByAddingComponents(comps, toDate: updated, options: NSCalendarOptions())
                let today = NSDate()
                
                #if DEBUG
                    print("today=\(today), updated=\(updated), updatedPlusWeek=\(updatedPlusWeek)")
                #endif
                
                if updatedPlusWeek!.isLessThanDate(today) {
                    getLanguagesFromAPI()
                    return
                }
            }
            
            self.languages = self.settings.languages
            self.setSelectedRegion()
            return
        }
        
        #if DEBUG
            print("settingsView, listLanguages: getting languages from API")
        #endif
        getLanguagesFromAPI()
    }
    
    func getLanguagesFromAPI() {
        HighFiApi.listLanguages(
            { (result) in
                dispatch_async(dispatch_get_main_queue()) {
                    // Clear old entries
                    self.languages = result
                    self.settings.languages = result

//                  #if DEBUG
//                      println("supportedLanguages=\(self.supportedLanguages)")
//                  #endif
                    
                    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(self.settings.languages as Array<Language>)
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(archivedObject, forKey: "languages")
                    
                    self.settings.languagesUpdated = NSDate()
                    defaults.setObject(self.settings.languagesUpdated, forKey: "languagesUpdated")
                    #if DEBUG
                        print("languages update, \(self.settings.languagesUpdated)")
                    #endif
                    
                    defaults.synchronize()
                    
                    self.setSelectedRegion()
                    
                    return
                }
            }
            , failureHandler: {(error)in
                self.handleError(error)
            }
        )
    }
    
    func setSelectedRegion() {
        dispatch_async(dispatch_get_main_queue()) {
        self.countryPicker!.reloadAllComponents()

        var defaultRowIndex = 0
        for (index, element) in self.languages.enumerate() {
            let lang = element as Language
            if (lang.country == self.settings.region) {
                defaultRowIndex = index
            }
        }
        #if DEBUG
            print("settingsView, setSelectedRegion: region=\(self.settings.region), defaultRowIndex=\(defaultRowIndex)")
        #endif
        self.countryPicker.selectRow(defaultRowIndex, inComponent: 0, animated: false)
        }
    }
    
    func handleError(error: String) {
        #if DEBUG
            print("handleError, error: \(error)")
        #endif
        let alertController = UIAlertController(title: errorTitle, message: error, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true){}
    }

}

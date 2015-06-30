//
//  InfoController.swift
//  Haikara
//
//  Created by Marko Wallin on 28.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class InfoController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var versioLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = Settings()

        infoLabel.text = "Haikara on epävirallinen uutislukija High.fi uutissivustolle. Sovellus on vielä kokeellinen ja kehitysasteeltaan alpha-tasolla."
        versioLabel.text = settings.appID
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ViewController.swift
//  sleepin in the library
//
//  Created by Abdalah on 10/9/1440 AH.
//  Copyright © 1440 AH Abdalah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func grabNewImage(_ sender: Any) {
    setUIEnabled(false)
        getImageFromFlickr()
    }
    private func setUIEnabled(_ enabled: Bool) {
        photoTitleLabel.isEnabled = enabled
        grabImageButton.isEnabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    

        
        private func getImageFromFlickr() {
            
            let methodParameters = [
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ]
            
            let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
            let url = URL(string: urlString)!
            let request = URLRequest(url: url)
            
            // create network request
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // if an error occurs, print it and re-enable the UI
                func displayError(_ error: String) {
                    print(error)
                    print("URL at time of error: \(url)")
                    performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                    }
                }
                
                // no error, woohoo!
                if error == nil {
                    
                    // there was data returned
                    if let data = data {
                        
                        let parsedResult: [String:AnyObject]!
                        do {
                            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                        } catch {
                            displayError("Could not parse the data as JSON: '\(data)'")
                            return
                        }
                        
                        if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] {
                            if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] {
                                
                                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                                let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
                                
                                if let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String, let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String {
                                    let imageURL = URL(string: imageUrlString)
                                    if let imageData = try? Data(contentsOf: imageURL!) {
                                        performUIUpdatesOnMain {
                                            self.photoImageView.image = UIImage(data: imageData)
                                            self.photoTitleLabel.text = photoTitle
                                            self.setUIEnabled(true)
                                        }
                                    }
                                  
                                }
                            }
                        }
                        
                    }
                }
            }
            
            // start the task!
            task.resume()
            
    }
    
    private func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it to vconvert to ascii
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
}


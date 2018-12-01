//
//  ViewController.swift
//  urlSessionDemo
//
//  Created by Nick on 11/29/18.
//  Copyright © 2018 NickOwn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageview1: UIImageView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var progressView1: UIProgressView!
    
    //for data to received
    var receivedData:Data?
    //to saved content length shows on progress view
    var expectedContentLength = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //Session with configuration
    private lazy var session: URLSession = {
      let config = URLSessionConfiguration.default
      config.waitsForConnectivity = true
      
      return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    @IBAction func action_loadImage(_ sender: UIButton) {
        //disable button in case user click twice
        sender.isEnabled = false
        //start loading image
        startLoad()
    }
    
    func startLoad() {
        let url = URL(string: "https://lemulotdotorg.files.wordpress.com/2016/10/dsc00737.jpg")!
        //init data
        receivedData = Data()
        let task = session.dataTask(with: url)
        task.resume()
        
    }
    
    //handle client side error here
    func handleClientError(_ error: Error) {
        print("client side error")
    }
    
    //handle server side error here
    func handleServerError(_ response: URLResponse?) {
        print("server side error")
    }
}

//MARK: - URLSessionDataDelegate
extension ViewController: URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            completionHandler(.cancel)
            return
        }
        
        //get full lenth of your content
        expectedContentLength = Int(response.expectedContentLength)
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        self.receivedData?.append(data)
        
        //count percent and update progress
        if let receivedCount = self.receivedData{
            let percentageDownload = Float(receivedCount.count / self.expectedContentLength)
            DispatchQueue.main.async {
                self.progressView1.progress = percentageDownload
            }
        }
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        
        DispatchQueue.main.async {
            self.button1.isEnabled = true
            self.progressView1.progress = 1.0
            
            if let error = error {
                self.handleClientError(error)
            }
            
            //when completed receive data, put data to imageview
            if let receivedData = self.receivedData {
                self.imageview1.image = UIImage(data: receivedData)
            }
            
        }
    }
    
}

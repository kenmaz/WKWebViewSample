//
//  KMZUIWebViewController.swift
//  WKWebViewSample
//
//  Created by Kentaro Matsumae on 2016/10/26.
//  Copyright © 2016年 Kentaro Matsumae. All rights reserved.
//

import UIKit

final class KMZUIWebViewController: UIViewController {
    
    lazy var webView:UIWebView = {
        let webView = UIWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.delegate = self
        webView.addGestureRecognizer(self.swipeBackGesture)
        self.view.addSubview(webView)
        self.view.sendSubview(toBack: webView)
        return webView
    }()
    
    lazy var swipeBackGesture:UISwipeGestureRecognizer = {
        let ges = UISwipeGestureRecognizer(target: self, action: #selector(swipeBack))
        ges.direction = .right
        return ges
    }()
    
    var timer:DispatchSourceTimer?
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(backButtonDidTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        updateBackButtonStatus()
        
        webView.loadRequest(URLRequest(url: KMZResources.urls.first!))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startBackButtonObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBackButtonObserver()
    }
    
    func close(sender:AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func startBackButtonObserver() {
        if timer == nil {
            timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            timer?.scheduleRepeating(deadline: .now(), interval: .seconds(1))
            timer?.setEventHandler { self.updateBackButtonStatus() }
            timer?.resume()
        }
    }
    
    func stopBackButtonObserver() {
        if timer != nil {
            timer?.cancel()
            timer = nil
        }
    }
    
    @IBAction func urlButtonDidTapped(_ sender: AnyObject) {
        let con = KMZResources.alertViewController {
            self.webView.loadRequest(URLRequest(url: $0))
        }
        present(con, animated: true, completion: nil)
    }
    
    @IBAction func backButtonDidTapped(_ sender: AnyObject) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func reloadButtonDidTapped(_ sender: AnyObject) {
        webView.reload()
    }
    
    @IBAction func clearButtonDidTapped(_ sender: AnyObject) {
        KMZCookie.clearCookies()
    }
    
    func swipeBack(sender:Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    func updateBackButtonStatus() {
        print("update back button..")
        navigationItem.leftBarButtonItem?.isEnabled = webView.canGoBack
    }
}

extension KMZUIWebViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(#function)
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("start")
        KMZCookie.dumpCookies()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("finish")
        KMZCookie.dumpCookies()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error)
    }
}

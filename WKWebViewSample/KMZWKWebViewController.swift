//
//  KMZWKWebViewController.swift
//  WKWebViewSample
//
//  Created by Kentaro Matsumae on 2016/10/26.
//  Copyright © 2016年 Kentaro Matsumae. All rights reserved.
//

import UIKit
import WebKit

final class KMZWKWebViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    
    lazy var webView:WKWebView = {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        self.view.sendSubview(toBack: webView)
        webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
        
        return webView
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        //webviewでbackしてきたときに回り込む問題回避
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(backButtonDidTapped))
        updateBackButtonStatus()
        
        webView.load(URLRequest(url: KMZResources.urls.first!))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath! {
        case "canGoBack":
            updateBackButtonStatus()
            backButton.isEnabled = webView.canGoBack
        default:
            return
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "canGoBack")
    }
    
    @IBAction func backButtonDidTapped(_ sender: AnyObject) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    func goBack(sender:Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @IBAction func doAction(_ sender: AnyObject) {
        let con = KMZResources.alertViewController {
            self.webView.load(URLRequest(url: $0))
        }
        present(con, animated: true, completion: nil)
    }

    @IBAction func reload(_ sender:AnyObject) {
        webView.reload()
    }
    
    @IBAction func clearCache(_ sender:AnyObject) {
        let datastore = webView.configuration.websiteDataStore
        datastore.fetchDataRecords(ofTypes: [WKWebsiteDataTypeCookies]) { (records) in
            records.forEach({ (record) in
                if record.displayName.hasSuffix("kenmaz.net") {
                    datastore.removeData(ofTypes: [WKWebsiteDataTypeCookies], for: [record], completionHandler: { 
                        print("removed \(record)")
                    })
                }
            })
        }
        print("fin")
    }
    
    func updateBackButtonStatus() {
        print("update back button..")
        navigationItem.leftBarButtonItem?.isEnabled = webView.canGoBack
    }
}

extension KMZWKWebViewController:WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start")
        KMZCookie.dumpCookies()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish")
        KMZCookie.dumpCookies()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        print(#function)
        decisionHandler(.allow)
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        print(#function)
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(#function)
    }
}

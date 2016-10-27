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
    
    let urls = [
        URL(string: "http://sakura.kenmaz.net/tmp/cookie.php")!,
        URL(string: "https://www.mangabox.me/browser/store/#/")!,
        URL(string: "https://twitter.com")!,
        URL(string: "https://dena.com/jp/")!,
        URL(string: "http://www.yahoo.co.jp")!,
    ]
    
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
        
        webView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        webView.load(URLRequest(url: urls.first!))
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath! {
        case "canGoBack":
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
        let con = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        urls.forEach { (url) in
            con.addAction(UIAlertAction(title: url.absoluteString, style: .default, handler: { (action) in
                self.webView.load(URLRequest(url: url))
            }))
        }
        con.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
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
}

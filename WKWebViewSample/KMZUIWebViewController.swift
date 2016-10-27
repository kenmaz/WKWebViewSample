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
        self.view.addSubview(webView)
        self.view.sendSubview(toBack: webView)
        return webView
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        webView.loadRequest(URLRequest(url: URL(string: "http://sakura.kenmaz.net/tmp/cookie.php")!))
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
}

extension KMZUIWebViewController: UIWebViewDelegate {
    
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

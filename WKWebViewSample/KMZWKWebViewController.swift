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
    
    static let configuration = WKWebViewConfiguration()
    
    @IBOutlet weak var backButton: UIButton!
    
    lazy var webView:WKWebView = {
        let con = self.setupUserContentController(url: nil)
        configuration.userContentController = con
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        updateBackButtonStatus()
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        self.view.addSubview(webView)
        self.view.sendSubview(toBack: webView)
        
        let url = KMZResources.urls.first!
        loadWebView(url: url)
    }
    
    private func loadWebView(url:URL) {
        //webView.load(URLRequest(url: url))
        //return
        
        //////////////// back1 ///////////
        let req = NSMutableURLRequest(url: url)
        
        //これがないと UIWebViewでjsでdocument.cookieした直後に、WKWebViewロードするとcookieが即反映されない
        if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            req.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        }
        
        let con = setupUserContentController(url: url)
        let config = webView.configuration
        config.userContentController = con
        
        webView.load(req as URLRequest)
        //////////////// ///////////
    }
    
    private func reloadWebView() {
        //webView.reload()
        
        loadWebView(url: webView.url!)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func close(sender:AnyObject) {
        KMZCookie.clearCookies()
        dismiss(animated: true, completion: nil)
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
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.stopLoading()
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
            self.loadWebView(url: $0)
        }
        present(con, animated: true, completion: nil)
    }

    @IBAction func reload(_ sender:AnyObject) {
        reloadWebView()
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
        print(navigationAction.request.url ?? "-")

        let con = setupUserContentController(url: navigationAction.request.url!)
        let config = webView.configuration
        config.userContentController = con
        
        decisionHandler(.allow)
    }
    
    
    func setupUserContentController(url:URL?) -> WKUserContentController {
        let con = WKUserContentController()
        
        if let url = url, let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            cookies.forEach {
                let name = $0.name
                let val = $0.value
                let js = "document.cookie = '\(name)=\(val)';"
                let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                con.addUserScript(script)
            }
        }
        
        con.addUserScript(WKUserScript(source: "alert(document.cookie);", injectionTime: .atDocumentStart, forMainFrameOnly: false))
        con.addUserScript(WKUserScript(source: "console.log(1);", injectionTime: .atDocumentStart, forMainFrameOnly: false))
        return con
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        print(#function)
        
        guard
            let response = navigationResponse.response as? HTTPURLResponse,
            let headers = response.allHeaderFields as? [String:String],
            let url = response.url else {
                decisionHandler(.cancel)
                return
        }

        /////////// hack2 //////////
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
        HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
        
        KMZCookie.dumpCookies()

        if let mjt = (navigationResponse.response as? HTTPURLResponse)?.allHeaderFields["X-MJT"] {
            print("mjt = \(mjt)")
        } else {
            print("no mjt")
        }
        
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

extension KMZWKWebViewController:WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
        print(message)
        completionHandler()
    }
}

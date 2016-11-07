//
//  ViewController.swift
//  WKWebViewSample
//
//  Created by Kentaro Matsumae on 2016/10/26.
//  Copyright © 2016年 Kentaro Matsumae. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let cookie = HTTPCookie(properties: [
            HTTPCookiePropertyKey.name: "key",
            HTTPCookiePropertyKey.value: "hoge",
            HTTPCookiePropertyKey.domain: "sakura.kenmaz.net",
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.expires: Date.distantFuture,
            ]) {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


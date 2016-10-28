//
//  KMZResources.swift
//  WKWebViewSample
//
//  Created by Kentaro Matsumae on 2016/10/28.
//  Copyright © 2016年 Kentaro Matsumae. All rights reserved.
//

import UIKit

struct KMZResources {
    
    static let urls = [
        URL(string: "https://www.mangabox.me/browser/store/#/")!,
        URL(string: "http://anime.kenmaz.net/")!,
        URL(string: "http://sakura.kenmaz.net/tmp/cookie.php")!,
        URL(string: "https://twitter.com")!,
        URL(string: "https://dena.com/jp/")!,
        URL(string: "http://www.yahoo.co.jp")!,
        ]
    
    static func alertViewController(selectHandler:@escaping (_ url:URL)->Void) -> UIAlertController {
        let con = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        KMZResources.urls.forEach { (url) in
            con.addAction(UIAlertAction(title: url.absoluteString, style: .default, handler: { (action) in
                selectHandler(url)
            }))
        }
        con.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        return con
    }
}

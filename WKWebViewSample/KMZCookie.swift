//
//  KMZCookie.swift
//  WKWebViewSample
//
//  Created by Kentaro Matsumae on 2016/10/27.
//  Copyright © 2016年 Kentaro Matsumae. All rights reserved.
//

import Foundation

class KMZCookie {
    
    static func dumpCookies() {
        HTTPCookieStorage.shared.cookies?.forEach {
            //print($0.domain)
            if $0.domain.hasSuffix("kenmaz.net") {
                print($0)
            }
        }
    }
    static func clearCookies() {
        let storage = HTTPCookieStorage.shared
        storage.cookies?.forEach{
            if $0.domain.hasSuffix("kenmaz.net") {
                storage.deleteCookie($0)
                print("delete: \($0)")
            }
        }
    }
}

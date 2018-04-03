//
//  PaywallType.swift
//  highkara
//
//  The MIT License (MIT)
//
//  Copyright (c) 2018 Marko Wallin <mtw@iki.fi>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

var paywallTextAll: String = NSLocalizedString("PAYWALL_TEXT_ALL", comment: "News source paywall type")
var paywallTextFree: String = NSLocalizedString("PAYWALL_TEXT_FREE", comment: "News source paywall type")
var paywallTextPartial: String = NSLocalizedString("PAYWALL_TEXT_PARTIAL", comment: "News source paywall type")
var paywallTextMonthly: String = NSLocalizedString("PAYWALL_TEXT_MONTHLY", comment: "News source paywall type")
var paywallTextStrict: String = NSLocalizedString("PAYWALL_TEXT_STRICT", comment: "News source paywall type")

enum Paywall: String {
    case All = "all"
    case Free = "free"
    case Partial = "partial"
    case Monthly = "monthly-limit"
    case Strict = "strict-paywall"
    
//    func type() -> String {
//        return self.rawValue
//    }

    var type: String {
        switch self {
        case .All: return "all"
        case .Free: return "free"
        case .Partial: return "partial"
        case .Monthly: return "monthly-limit"
        case .Strict: return "strict-paywall"
        }
    }
    
    var description: String {
        switch self {
        case .All: return paywallTextAll
        case .Free: return paywallTextFree
        case .Partial: return paywallTextPartial
        case .Monthly: return paywallTextMonthly
        case .Strict: return paywallTextStrict
        }
    }

}

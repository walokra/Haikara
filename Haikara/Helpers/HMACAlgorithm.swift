//
//  CryptoAlgorithm.swift
//  highkara
//  
// From http://stackoverflow.com/a/27032056/1634162
//

import UIKit

enum HMACAlgorithm {
    case md5, sha1, sha224, sha256, sha384, sha512

    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .md5:
            result = kCCHmacAlgMD5
        case .sha1:
            result = kCCHmacAlgSHA1
        case .sha224:
            result = kCCHmacAlgSHA224
        case .sha256:
            result = kCCHmacAlgSHA256
        case .sha384:
            result = kCCHmacAlgSHA384
        case .sha512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }

    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .md5:
            result = CC_MD5_DIGEST_LENGTH
        case .sha1:
            result = CC_SHA1_DIGEST_LENGTH
        case .sha224:
            result = CC_SHA224_DIGEST_LENGTH
        case .sha256:
            result = CC_SHA256_DIGEST_LENGTH
        case .sha384:
            result = CC_SHA384_DIGEST_LENGTH
        case .sha512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {

	func hmac(_ algorithm: HMACAlgorithm, key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        let length: Int = Int(strlen(cKey!))
        let data: Int = Int(strlen(cData!))
		
		CCHmac(algorithm.toCCHmacAlgorithm(), cKey!,length , cData!, data, &result)

        let hmacData:Data = Data(bytes: UnsafePointer<UInt8>(result), count: (Int(algorithm.digestLength())))

        var bytes = [UInt8](repeating: 0, count: hmacData.count)
        (hmacData as NSData).getBytes(&bytes, length: hmacData.count)

        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02hhx", UInt8(byte))
        }
        return hexString
    }
	
//	func sha256(key: String) -> String {
//        let inputData: NSData = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
//        let keyData: NSData = key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
//
//        let algorithm = HMACAlgorithm.SHA256
//        let digestLen = algorithm.digestLength()
//        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
//
//        CCHmac(algorithm.toCCHmacAlgorithm(), keyData.bytes, Int(keyData.length), inputData.bytes, Int(inputData.length), result)
//        let data = NSData(bytes: result, length: digestLen)
//        result.destroy()
//        return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
//    }
	
    func digest(_ algorithm: HMACAlgorithm, key: String) -> String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength()
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))

        CCHmac(algorithm.toCCHmacAlgorithm(), keyStr!, keyLen, str!, strLen, result)

        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }

        result.deinitialize(count: digestLen)
        return String(hash)
    }
}

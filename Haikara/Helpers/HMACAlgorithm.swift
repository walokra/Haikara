//
//  CryptoAlgorithm.swift
//  highkara
//  
// From http://stackoverflow.com/a/27032056/1634162
//

enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512

    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }

    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {

	func hmac(algorithm: HMACAlgorithm, key: String) -> String {
        let cKey = key.cStringUsingEncoding(NSUTF8StringEncoding)
        let cData = self.cStringUsingEncoding(NSUTF8StringEncoding)
        var result = [CUnsignedChar](count: Int(algorithm.digestLength()), repeatedValue: 0)
        let length: Int = Int(strlen(cKey!))
        let data: Int = Int(strlen(cData!))
		
		CCHmac(algorithm.toCCHmacAlgorithm(), cKey!,length , cData!, data, &result)

        let hmacData:NSData = NSData(bytes: result, length: (Int(algorithm.digestLength())))

        var bytes = [UInt8](count: hmacData.length, repeatedValue: 0)
        hmacData.getBytes(&bytes, length: hmacData.length)

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
	
    func digest(algorithm: HMACAlgorithm, key: String) -> String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = Int(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = algorithm.digestLength()
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        let keyStr = key.cStringUsingEncoding(NSUTF8StringEncoding)
        let keyLen = Int(key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))

        CCHmac(algorithm.toCCHmacAlgorithm(), keyStr!, keyLen, str!, strLen, result)

        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }

        result.destroy()
        return String(hash)
    }
}

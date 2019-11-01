//
//  Mocksswift
//  
//
//  Created by Balazs Szamody on 30/10/19.
//

import Foundation

struct Mocks {
    static var assetURLs: [String: URL] {
        let urls: [URL] = [
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/forward-chevron%401x.png",
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/forward-chevron%402x.png",
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/forward-chevron%403x.png",
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/back-chevron%401x.png",
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/back-chevron%402x.png",
            "https://raw.githubusercontent.com/BalazsSzamody/Eureka/master/Source/Resources/Eureka.bundle/back-chevron%403x.png",
        ]
        .compactMap({ URL(string: $0) })
        
        let fileNames: [String] = [
            "forward-chevron@1x.png",
            "forward-chevron@2x.png",
            "forward-chevron@3x.png",
            "back-chevron@1x.png",
            "back-chevron@2x.png",
            "back-chevron@3x.png",
        ]
        
        let zipped = zip(fileNames, urls)
        
        return Dictionary(uniqueKeysWithValues: zipped)
    }
}

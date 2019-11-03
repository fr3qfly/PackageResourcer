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
            "https://raw.githubusercontent.com/fr3qfly/PackageResourcer/develop/Resources/forward-chevron%401x.png",
            "https://raw.githubusercontent.com/fr3qfly/PackageResourcer/develop/Resources/forward-chevron%402x.png",
            "https://raw.githubusercontent.com/fr3qfly/PackageResourcer/develop/Resources/forward-chevron%403x.png",
            "https://raw.githubusercontent.com/fr3qfly/PackageResourcer/develop/Resources/back-chevron%401x.png",
            "https://raw.githubusercontent.com/fr3qfly/PackageResourcer/develop/Resources/back-chevron%402x.png",
            "https://raw.githubusercontent.com/fr3qfly/PackageResourcer/develop/Resources/back-chevron%403x.png",
            "https://raw.githubusercontent.com/fr3qfly/PackageResourcer/develop/Resources/tomato.colorset/Contents.json"
        ]
        .compactMap({ URL(string: $0) })
        
        let fileNames: [String] = [
            "forward-chevron@1x.png",
            "forward-chevron@2x.png",
            "forward-chevron@3x.png",
            "back-chevron@1x.png",
            "back-chevron@2x.png",
            "back-chevron@3x.png",
            "tomato.colorset"
        ]
        
        let zipped = zip(fileNames, urls)
        
        return Dictionary(uniqueKeysWithValues: zipped)
    }
}

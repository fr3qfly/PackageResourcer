import XCTest
@testable import PackageResourcer

final class PackageResourcerTests: XCTestCase {
    
    var resourcer: PackageResourcer!
    
    var exp: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
    }
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let urls = URL.mock
        exp = expectation(description: "N/A")
        var results: [Data] = []
        resourcer = PackageResourcer(urls: urls, completion: { (result) in
            switch result {
            case .failure(let error):
                XCTFail("Should be successfull, Error: \(error.localizedDescription)")
            case .success(let data):
                results = data
            }
            self.exp.fulfill()
        })
        wait(for: [exp], timeout: 30)
        XCTAssertEqual(results.count, 6)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

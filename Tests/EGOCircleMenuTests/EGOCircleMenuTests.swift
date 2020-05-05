import XCTest
@testable import EGOCircleMenu
import Lottie

final class EGOCircleMenuTests: XCTestCase {
	
    func testExistingAssets() {
		let keys = ["hamburger-open","hamburger-close"]
		for key in keys {
			#warning("Bundle.main should be Bundle.pod, but it doesn't work")
			XCTAssertNotNil(Bundle.main.url(forResource: key, withExtension: "json"), "Could not find asset \(key).json")
		}
    }
	
    static var allTests = [
        ("testExistingAssets", testExistingAssets),
    ]
	
}

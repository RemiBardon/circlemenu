import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EGOCircleMenuTests.allTests),
    ]
}
#endif

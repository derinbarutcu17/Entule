import Foundation

protocol DetectorProtocol {
    var name: String { get }
    func detect() async -> DetectorOutput
}

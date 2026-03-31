import Foundation

protocol Store {
    func loadState() throws -> AppStateModel
    func saveState(_ state: AppStateModel) throws
    func mutate(_ transform: (inout AppStateModel) -> Void) throws -> AppStateModel
}


import Foundation

class DataService {
    static func loadLibraries() -> [Library] {
        if let url = Bundle.main.url(forResource: "Toronto Library Branch Info 2024", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let libraries = try decoder.decode([Library].self, from: data)
                return libraries
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        return []
    }
}

//
//  FocusModel+RestoreDataExtension.swift
//  FocusTask Watch App
//
//  Created by feint on 2023/2/15.
//

import Foundation

/**
 模型数据持久化
 */
extension FocusModel {
    enum CodingKeys: String, CodingKey {
        case items, currentTaskId, taskLinesMap, showTimeline, showSummary
    }

    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
        try container.encode(currentTaskId, forKey: .currentTaskId)
        try container.encode(taskLinesMap, forKey: .taskLinesMap)
        try container.encode(showTimeline, forKey: .showTimeline)
        try container.encode(showSummary, forKey: .showSummary)
    }

    private func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func dataModelURL() -> URL {
        let docURL = documentsDirectory()
        return docURL.appendingPathComponent(self.dataFileName)
    }

    func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            do {
                print(dataModelURL())
                // Save the 'Products' data file to the Documents directory.
                try encoded.write(to: dataModelURL())
            } catch {
                print("Couldn't write to save file: " + error.localizedDescription)
            }
        }
    }

}

extension Bundle {
    func decode(_ file: String) -> FocusModel {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode(FocusModel.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }
        return loaded
    }
}

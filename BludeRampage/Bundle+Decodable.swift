//
//  Bundle.swift
//  BludeRampage
//
//  Created by Saulo Pratti on 03.05.20.
//  Copyright © 2020 Pratti Design. All rights reserved.
//

import Foundation

public extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: StaticString) -> T {
        guard let url = self.url(forResource: "\(file)", withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        return try! JSONDecoder().decode(T.self, from: data)
    }
}

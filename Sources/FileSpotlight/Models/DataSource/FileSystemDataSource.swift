//
//  FileSystemDataSource.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import Foundation

/// Data source per file system
public struct FileSystemDataSource: SpotlightDataSource {
	private let directory: URL
	private let fileExtensions: [String]?
	private let recursive: Bool
	
	public init(directory: URL, fileExtensions: [String]? = nil, recursive: Bool = true) {
		self.directory = directory
		self.fileExtensions = fileExtensions
		self.recursive = recursive
	}
	
	public func allItems() async -> [SpotlightFileItem] {
		var files: [SpotlightFileItem] = []
		let fileManager = FileManager.default
		
		guard let enumerator = fileManager.enumerator(
			at: directory,
			includingPropertiesForKeys: nil,
			options: recursive ? [] : [.skipsSubdirectoryDescendants]
		) else {
			return []
		}
		
		let allURLs = enumerator.allObjects.compactMap { $0 as? URL }
					
		for fileURL in allURLs {
			if !fileURL.hasDirectoryPath {
				if let extensions = fileExtensions {
					if extensions.contains(fileURL.pathExtension) {
						files.append(SpotlightFileItem(url: fileURL))
					}
					
				} else {
					files.append(SpotlightFileItem(url: fileURL))
					
				}
			}
		}
		
		return files
	}
	
	public func search(query: String) async -> [SpotlightFileItem] {
		let all = await allItems()
		guard !query.isEmpty else { return [] }
		return all.filter { $0.displayName.localizedCaseInsensitiveContains(query) }
	}
}

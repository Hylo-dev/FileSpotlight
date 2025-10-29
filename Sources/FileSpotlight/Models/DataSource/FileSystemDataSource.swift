//
//  FileSystemDataSource.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import Foundation

/// A data source that provides spotlight items by scanning a directory on the local file system.
///
/// This struct conforms to `SpotlightDataSource` and is designed to find files within a specified
/// directory. It can be configured to search recursively through subdirectories and to filter
/// files by their extensions.
public struct FileSystemDataSource: SpotlightDataSource {
	
	// MARK: - Properties
	
	/// The root directory URL from which to start the file search.
	private let directory: URL
	
	/// An optional array of file extensions (e.g., "txt", "png") used to filter the results.
	/// If `nil`, files with any extension will be included.
	private let fileExtensions: [String]?
	
	/// A boolean value that indicates whether the search should include subdirectories.
	private let recursive: Bool
	
	// MARK: - Initializer
	
	/// Creates a new file system data source.
	///
	/// - Parameters:
	///   - directory: The URL of the directory to be scanned.
	///   - fileExtensions: An optional list of file extensions to include in the results.
	///   - recursive: If `true`, the scan will include all subdirectories. Defaults to `true`.
	public init(
		directory     : URL,
		fileExtensions: [String]? = nil,
		recursive     : Bool      = true
	) {
		self.directory      = directory
		self.fileExtensions = fileExtensions
		self.recursive      = recursive
	}
	
	// MARK: - Data Source Methods
	
	/// Asynchronously fetches all files from the specified directory that match the configured filters.
	///
	/// - Returns: An array of `SpotlightFileItem` representing the found files.
	public func allItems() async -> [SpotlightFileItem] {
		var files: [SpotlightFileItem] = []
		let fileManager = FileManager.default
		
		// Create a file enumerator to traverse the directory.
		// The options are set based on the 'recursive' flag.
		guard let enumerator = fileManager.enumerator(
			at: directory,
			includingPropertiesForKeys: nil,
			options: recursive ? [] : [.skipsSubdirectoryDescendants]
			
		) else {
			return []
			
		}
		
		// Convert the enumerator's contents to an array of URLs.
		let allURLs = enumerator.allObjects.compactMap { $0 as? URL }
					
		for fileURL in allURLs {
			// Ensure the URL does not point to a directory.
			if !fileURL.hasDirectoryPath {
				if let extensions = fileExtensions {
					// If file extensions are specified, check if the file's extension matches.
					if extensions.contains(fileURL.pathExtension) {
						files.append(SpotlightFileItem(url: fileURL))
					}
					
				} else {
					// If no extensions are specified, add all files.
					files.append(SpotlightFileItem(url: fileURL))
					
				}
			}
		}
		
		return files
	}
	
	/// Asynchronously searches for files whose names contain the given query string.
	///
	/// - Parameter query: The string to search for within file names.
	/// - Returns: An array of `SpotlightFileItem` that match the search query. Returns an empty array if the query is empty.
	public func search(query: String) async -> [SpotlightFileItem] {
		// First, retrieve all possible items.
		let all = await allItems()
		
		// Return an empty array if the search query is empty to avoid showing all results.
		guard !query.isEmpty else { return [] }
		
		// Filter the items based on a case-insensitive search of their display names.
		return all.filter { $0.displayName.localizedCaseInsensitiveContains(query) }
	}
}

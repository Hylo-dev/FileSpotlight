//
//  SpotlightFileItem.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import Foundation

/// A default implementation of the `SpotlightItem` protocol, designed to represent a file.
///
/// This struct holds all the necessary information to display a file in a spotlight search result list,
/// including its name, path (as a subtitle), and an icon.
public struct SpotlightFileItem: SpotlightItem {
	
	// MARK: - Properties
	
	/// A unique identifier for each file item instance, conforming to `Identifiable`.
	public let id = UUID()
	
	/// The primary text displayed for the item, typically the file name.
	public let displayName: String
	
	/// Optional secondary text, usually the file's containing folder path.
	public let subtitle: String?
	
	/// The file URL that this item represents.
	public let url: URL
	
	/// The provider responsible for supplying the item's icon.
	public let iconProvider: SpotlightIconProvider
	
	// MARK: - Initializers
	
	/// Creates a spotlight item directly from a file URL.
	///
	/// This initializer automatically extracts the display name and subtitle from the provided URL.
	/// If a custom icon is not provided, it defaults to using an icon associated with the file's type.
	///
	/// - Parameters:
	///   - url: The `URL` of the file.
	///   - customIcon: An optional `SpotlightIconProvider` to override the default file icon.
	public init(
		url		  : URL,
		customIcon: SpotlightIconProvider? = nil
	) {
		self.url 		  = url
		self.displayName  = url.lastPathComponent
		self.subtitle 	  = url.deletingLastPathComponent().path
		self.iconProvider = customIcon ?? .url(url)
	}
	
	/// Creates a spotlight item with manually specified properties.
	///
	/// This is useful for creating items that may not correspond to an actual file on disk or when you want
	/// full control over the displayed information. A placeholder URL is created internally.
	///
	/// - Parameters:
	///   - name: The display name for the item.
	///   - subtitle: An optional subtitle.
	///   - icon: The `SpotlightIconProvider` to use for the item's icon.
	public init(
		name	: String,
		subtitle: String? = nil,
		icon	: SpotlightIconProvider
	) {
		// Create a placeholder URL as one is required by the protocol's intent.
		self.url 		  = URL(fileURLWithPath: "/\(name)")
		self.displayName  = name
		self.subtitle 	  = subtitle
		self.iconProvider = icon
	}
	
	// MARK: - Equatable Conformance
	
	/// Determines if two `SpotlightFileItem` instances are equal.
	///
	/// Two items are considered equal if they have the same `id` and `url`.
	public static func == (
		lhs: SpotlightFileItem,
		rhs: SpotlightFileItem
	) -> Bool {
		lhs.id == rhs.id && lhs.url == rhs.url
	}
}

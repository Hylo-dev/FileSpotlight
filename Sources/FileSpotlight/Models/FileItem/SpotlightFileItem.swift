//
//  SpotlightFileItem.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import Foundation

/// Implementazione default per file
public struct SpotlightFileItem: SpotlightItem {
	public let id = UUID()
	public let displayName: String
	public let subtitle: String?
	public let url: URL
	public let iconProvider: SpotlightIconProvider
	
	public init(url: URL, customIcon: SpotlightIconProvider? = nil) {
		self.url = url
		self.displayName = url.lastPathComponent
		self.subtitle = url.deletingLastPathComponent().path
		self.iconProvider = customIcon ?? .url(url)
	}
	
	public init(name: String, subtitle: String? = nil, icon: SpotlightIconProvider) {
		self.url = URL(fileURLWithPath: "/\(name)")
		self.displayName = name
		self.subtitle = subtitle
		self.iconProvider = icon
	}
	
	public static func == (lhs: SpotlightFileItem, rhs: SpotlightFileItem) -> Bool {
		lhs.id == rhs.id && lhs.url == rhs.url
	}
}

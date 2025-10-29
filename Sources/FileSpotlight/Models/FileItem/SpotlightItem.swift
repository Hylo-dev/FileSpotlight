//
//  SpotlightItem.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import Foundation

import Foundation

/// A protocol that defines the basic requirements for an item that can be displayed and searched in a spotlight view.
///
/// Conforming types must be `Identifiable`, `Equatable`, and `Sendable` to ensure they can be uniquely identified,
/// compared, and used safely in concurrent environments.
public protocol SpotlightItem: Identifiable, Equatable, Sendable {
	/// A stable and unique identifier for the item.
	var id: UUID { get }
	
	/// The primary text to display for the item, such as a name or title.
	var displayName: String { get }
	
	/// Optional secondary text to display, providing additional context like a path or description.
	var subtitle: String? { get }
	
	/// The provider that specifies the source of the item's icon (e.g., a system symbol or a file URL).
	var iconProvider: SpotlightIconProvider { get }
}

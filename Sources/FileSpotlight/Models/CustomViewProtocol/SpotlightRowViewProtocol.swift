//
//  SpotlightRowViewProtocol.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

/// A protocol that defines the requirements for a custom view used to display a row in a spotlight search results list.
///
/// By conforming to this protocol, developers can create their own SwiftUI views to render search result items,
/// allowing for complete customization of the appearance and layout of each row.
public protocol SpotlightRowViewProtocol: View {
	/// The specific type of `SpotlightItem` that this row view is designed to display.
	/// This allows the view to be strongly typed to its corresponding data model.
	associatedtype Item: SpotlightItem
	
	/// The required initializer for a conforming view.
	///
	/// The spotlight component uses this initializer to create an instance of the row view for each search result.
	///
	/// - Parameters:
	///   - item: The `SpotlightItem` data instance that this row should represent.
	///   - isSelected: A boolean value indicating whether the row is currently selected or highlighted. The view can use this to change its appearance (e.g., background color).
	///   - style: A `SpotlightRowStyle` object that provides styling configuration (e.g., colors, padding).
	///   - onTap: A closure to be executed when the user taps on the row. The view should attach this action to a tap gesture.
	init(
		item      : Item,
		isSelected: Bool,
		style     : SpotlightRowStyle,
		onTap     : @escaping () -> Void
	)
}

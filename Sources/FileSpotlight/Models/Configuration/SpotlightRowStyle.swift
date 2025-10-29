//
//  SpotlightRowStyle.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

/// Defines the visual style for a row in a spotlight results list.
///
/// This structure allows for detailed customization of the appearance of individual result rows,
/// including colors, spacing, and sizing. It is `Sendable`, making it safe to use in concurrent
/// programming contexts.
public struct SpotlightRowStyle: Sendable {
	
	// MARK: - Properties
	
	/// A closure that returns the background color for the row.
	/// It receives a boolean indicating whether the row is currently selected,
	/// allowing for different appearances in selected and unselected states.
	public var backgroundColor: @Sendable (Bool) -> Color
	
	/// The color of the primary text (the item's `displayName`).
	public var textColor: Color
	
	/// The color of the secondary text (the item's `subtitle`).
	public var subtitleColor: Color
	
	/// The corner radius applied to the row's background.
	public var cornerRadius: CGFloat
	
	/// The padding applied inside the row, between its content and its edges.
	public var padding: EdgeInsets
	
	/// The spacing between elements within the row (e.g., between the icon and the text).
	public var spacing: CGFloat
	
	/// The size (width and height) of the icon displayed in the row.
	public var iconSize: CGFloat
	
	// MARK: - Initializer
	
	/// Creates a new row style configuration.
	///
	/// All parameters have sensible default values, so you only need to specify the properties
	/// you wish to customize.
	///
	/// - Parameters:
	///   - backgroundColor: A closure that determines the background color based on the selection state. Defaults to a semi-transparent accent color when selected.
	///   - textColor: The primary text color. Defaults to `.primary`.
	///   - subtitleColor: The subtitle text color. Defaults to `.secondary`.
	///   - cornerRadius: The corner radius for the row. Defaults to 8.
	///   - padding: The inner padding for the row. Defaults to 10 points on all sides.
	///   - spacing: The spacing between internal elements. Defaults to 12.
	///   - iconSize: The size of the icon. Defaults to 26x26.
	public init(
		backgroundColor: @escaping @Sendable (Bool) -> Color = { selected in
			selected ? Color.accentColor.opacity(0.15) : Color.clear
		},
		textColor	 : Color	  = .primary,
		subtitleColor: Color 	  = .secondary,
		cornerRadius : CGFloat	  = 8,
		padding		 : EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10),
		spacing		 : CGFloat	  = 12,
		iconSize	 : CGFloat 	  = 26
	) {
		self.backgroundColor = backgroundColor
		self.textColor 		 = textColor
		self.subtitleColor	 = subtitleColor
		self.cornerRadius 	 = cornerRadius
		self.padding 		 = padding
		self.spacing 		 = spacing
		self.iconSize 		 = iconSize
		
	}
	
	// MARK: - Static Properties
	
	/// A shared instance of `SpotlightRowStyle` with all default values.
	public static let `default` = SpotlightRowStyle()
}

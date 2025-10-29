//
//  DefaultSpotlightRowView.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI


/// A default, standard view for displaying a single item in a spotlight search results list.
///
/// This view conforms to `SpotlightRowViewProtocol` and provides a common layout consisting of an icon,
/// a primary display name, and an optional subtitle. Its appearance can be customized using a `SpotlightRowStyle` object.
public struct DefaultSpotlightRowView<Item: SpotlightItem>: SpotlightRowViewProtocol {
	
	// MARK: - Properties
		
	/// The data item to be displayed in the row.
	let item: Item
		
	/// A boolean indicating whether the row is currently highlighted as the selected item.
	let isSelected: Bool
		
	/// A style configuration object that determines the row's appearance (e.g., colors, padding, icon size).
	let style: SpotlightRowStyle
		
	/// A closure that is executed when the user taps on the row.
	let onTap: () -> Void
	
	/// Creates a new default spotlight row view.
	///
	/// - Parameters:
	///   - item: The `SpotlightItem` data to display.
	///   - isSelected: A flag indicating if the row is selected.
	///   - style: The style configuration for the row's appearance.
	///   - onTap: The action to perform when the row is tapped.
	public init(
		item      : Item,
		isSelected: Bool,
		style     : SpotlightRowStyle,
		onTap     : @escaping () -> Void
	) {
		self.item       = item
		self.isSelected = isSelected
		self.style      = style
		self.onTap      = onTap
		
	}
	
	// MARK: - Body
	
	public var body: some View {
		HStack(alignment: .center, spacing: style.spacing) {
			// The icon for the item.
			iconView
			
			// A vertical stack for the main and subtitle text.
			VStack(alignment: .leading, spacing: 4) {
				Text(item.displayName)
					.font(.headline)
					.foregroundColor(style.textColor)
				
				if let subtitle = item.subtitle {
					Text(subtitle)
						.font(.caption)
						.foregroundColor(style.subtitleColor)
				}
			}
			
			Spacer()
		}
		.padding(style.padding)
		.background(style.backgroundColor(isSelected)) // Background changes based on selection state.
		.cornerRadius(style.cornerRadius)
		.onTapGesture(perform: onTap) // Makes the entire row tappable.
	}
	
	// MARK: - Subviews
	
	/// A helper view that resolves and displays the appropriate icon for the item.
	@ViewBuilder
	private var iconView: some View {
		// Switch on the icon provider type to determine how to create the Image view.
		switch item.iconProvider {
			case .systemImage(let name):
				// Use an SF Symbol if the provider is a system image.
				Image(systemName: name)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: style.iconSize, height: style.iconSize)
					
			case .url(let url):
				// For a URL, fetch the macOS file icon using NSWorkspace.
				// Note: This makes this view specific to macOS.
				Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: style.iconSize, height: style.iconSize)
		}
	}
}

//
//  SpotlightSection.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

/// Represents a customizable section within a spotlight interface, with support for a custom content view.
///
/// Each `SpotlightSection` can have its own identifier, title, icon, and behavior. It is designed to be highly
/// configurable, allowing developers to define custom SwiftUI views for a section's content, specify selection handlers,
/// and control visibility dynamically.
public struct SpotlightSection<Item: SpotlightItem> {
	
	// MARK: - Properties
	
	/// A unique string to identify the section.
	public let id: String
	
	/// An optional title for the section, often used as a placeholder in the search bar when the section is active.
	public let title: String?
	
	/// An optional name of a system image (e.g., from SF Symbols) to represent the section.
	public let icon: String?
	
	/// A closure that is executed when an item from this section is selected.
	/// It is `Sendable` and runs on the main actor to ensure thread safety and proper UI updates.
	public let onSelect: @Sendable @MainActor (Item) -> Void
	
	/// An optional keyboard shortcut that can be used to quickly switch to this section.
	public let keyboardShortcut: KeyEquivalent?
	
	/// A closure that returns a boolean indicating whether the section should be visible.
	/// This allows for dynamically showing or hiding sections based on application state.
	public let isVisible: @Sendable () -> Bool
	
	/// An optional closure that returns a type-erased view (`AnyView`) for the section's content.
	public let view: (() -> AnyView)?
	
	
	// MARK: - Initializer
	
	/// Initializes a section that displays a custom SwiftUI view.
	///
	/// Use this initializer to create a section with a unique user interface, distinct from the standard list of search results.
	///
	/// - Parameters:
	///   - id: A unique string to identify the section.
	///   - title: An optional title for the section.
	///   - icon: An optional system image name for the section's icon.
	///   - view: A `@ViewBuilder` closure that returns the custom `View` to be displayed as the section's content.
	///   - onSelect: The action to perform when an item is selected.
	///   - keyboardShortcut: An optional keyboard shortcut for quick access.
	///   - isVisible: A closure to determine if the section should be visible. Defaults to `true`.
	public init<Content: View>(
		id				 : String,
		title			 : String? = nil,
		icon			 : String? = nil,
		@ViewBuilder view: @escaping () -> Content,
		onSelect		 : @escaping @Sendable @MainActor (Item) -> Void,
		keyboardShortcut : KeyEquivalent? = nil,
		isVisible		 : @escaping @Sendable () -> Bool = { true }
	) {
		self.id    = id
		self.title = title
		self.icon  = icon
		
		// The custom view is type-erased to AnyView for storage.
		self.view 			  = { AnyView(view()) }
		self.onSelect		  = onSelect
		self.keyboardShortcut = keyboardShortcut
		self.isVisible		  = isVisible
	}
	
	// MARK: - View Builder
	
	/// Constructs and returns the section's custom view.
	///
	/// This helper method safely unwraps the `view` closure provided during initialization and executes it.
	/// If no custom view was defined for this section, it returns an `EmptyView`.
	/// - Returns: The custom SwiftUI view for the section or an `EmptyView`.
	@ViewBuilder
	public func buildView() -> some View {
		if let builder = view {
			builder()
			
		} else {
			EmptyView()
			
		}
	}
}

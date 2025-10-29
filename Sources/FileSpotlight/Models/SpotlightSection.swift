//
//  SpotlightSection.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

import SwiftUI

/// Sezione personalizzabile dello spotlight con supporto per custom view
public struct SpotlightSection<Item: SpotlightItem> {
	public let id: String
	public let title: String?
	public let icon: String?
	public let onSelect: @Sendable @MainActor (Item) -> Void
	public let keyboardShortcut: KeyEquivalent?
	public let isVisible: @Sendable () -> Bool
	public let view: (() -> AnyView)?
	
	
	// Inizializzatore per sezioni con custom view
	public init<Content: View>(
		id: String,
		title: String? = nil,
		icon: String? = nil,
		@ViewBuilder view: @escaping () -> Content,
		onSelect: @escaping @Sendable @MainActor (Item) -> Void,
		keyboardShortcut: KeyEquivalent? = nil,
		isVisible: @escaping @Sendable () -> Bool = { true }
	) {
		self.id = id
		self.title = title
		self.icon = icon
		self.view = { AnyView(view()) }
		self.onSelect = onSelect
		self.keyboardShortcut = keyboardShortcut
		self.isVisible = isVisible
	}
	
	@ViewBuilder
	public func buildView() -> some View {
		if let builder = view {
			builder()
			
		} else {
			EmptyView()
		}
	}
}

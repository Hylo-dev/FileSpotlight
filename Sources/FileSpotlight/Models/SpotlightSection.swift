//
//  SpotlightSection.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import SwiftUI

/// Sezione personalizzabile dello spotlight
public struct SpotlightSection<Item: SpotlightItem> {
	public let id: String
	public let title: String?
	public let icon: String?
	public let items: @Sendable () -> [Item]
	public let onSelect: @Sendable @MainActor (Item) -> Void
	public let keyboardShortcut: KeyEquivalent?
	public let isVisible: @Sendable () -> Bool
	
	public init(
		id: String,
		title: String? = nil,
		icon: String? = nil,
		items: @escaping @Sendable () -> [Item],
		onSelect: @escaping @Sendable @MainActor (Item) -> Void,
		keyboardShortcut: KeyEquivalent? = nil,
		isVisible: @escaping @Sendable () -> Bool = { true }
	) {
		self.id = id
		self.title = title
		self.icon = icon
		self.items = items
		self.onSelect = onSelect
		self.keyboardShortcut = keyboardShortcut
		self.isVisible = isVisible
	}
}

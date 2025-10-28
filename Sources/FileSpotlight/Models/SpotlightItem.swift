//
//  SpotlightItem.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/10/25.
//

import Foundation

/// Protocollo base per gli item searchabili
public protocol SpotlightItem: Identifiable, Equatable, Sendable {
	var id: UUID { get }
	var displayName: String { get }
	var subtitle: String? { get }
	var iconProvider: SpotlightIconProvider { get }
}

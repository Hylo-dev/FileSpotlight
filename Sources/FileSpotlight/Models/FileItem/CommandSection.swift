//
//  CommandSection.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 31/10/25.
//

import SwiftUI

/// Represents a keyboard shortcut command.
///
/// This struct holds the specific key and any modifier keys (e.g., Command, Shift)
/// that together trigger a specific action in the application.
public struct CommandSection {
	/// The actual key to be pressed.
	/// It's of type `KeyEquivalent`, which represents a single character on the keyboard.
	let keyCommand: KeyEquivalent

	/// The modifier keys that must be held down along with the keyCommand.
	/// This is an `EventModifiers` option set, which can include keys like `.command`, `.shift`, etc.
	let modifiers: EventModifiers
}

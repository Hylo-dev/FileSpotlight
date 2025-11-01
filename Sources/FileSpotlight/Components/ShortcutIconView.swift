//
//  ShortcutIcon.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 01/11/25.
//

import SwiftUI

struct ShortcutIconView: View {
	let sectionIndex: Int
	let shortcut	: CommandSection?
	
	var body: some View {
		let isNil = shortcut == nil
		let key   = isNil ?
						String(sectionIndex) :
						String(shortcut!.keyCommand.character)

		let modifiers  = isNil ?
							EventModifiers.command :
							shortcut!.modifiers

		return HStack(spacing: 4) {
			
			if modifiers.contains(.control) {
				Image(systemName: "control")
					.frame(width: 15, height: 15)
					.padding(5)
					.background(.thinMaterial)
					.cornerRadius(7)
				
			}
			
			if modifiers.contains(.option) {
				Image(systemName: "option")
					.frame(width: 15, height: 15)
					.padding(5)
					.background(.thinMaterial)
					.cornerRadius(7)
				
			}
			
			if modifiers.contains(.shift) {
				Image(systemName: "shift")
					.frame(width: 15, height: 15)
					.padding(5)
					.background(.thinMaterial)
					.cornerRadius(7)
				
			}
			
			if modifiers.contains(.command) {
				Image(systemName: "command")
					.frame(width: 15, height: 15)
					.padding(5)
					.background(.thinMaterial)
					.cornerRadius(7)
				
			}
			
			Text(key)
				.frame(width: 15, height: 15)
				.padding(5)
				.background(.thinMaterial)
				.cornerRadius(7)
				.id(key)
			
		}
		.font(.headline)
		.foregroundColor(.secondary)
		.transition(.opacity.animation(.easeOut(duration: 0.1)))
		
	}
}

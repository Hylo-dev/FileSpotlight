//
//  SectionView.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 01/11/25.
//

import SwiftUI

/// The view that displays the icons for switching between sections.
struct SectionView<Item: SpotlightItem>: View {
	@Binding var state			: SpotlightState
 	@Binding var selectedSection: Int
	
	let sections  : [SpotlightSection<Item>]
	let sizeIcon  : Font
	let sizeButton: CGFloat
	
	var body: some View {
		
		// Iterate over all visible sections to create an icon for each.
		// The `enumerated()` call provides the index, which is used to identify the section.
		// The first section (index 0) is skipped as it's the main search view.
		ForEach(sections.enumerated(), id:\.element.id) { index, section in
			
			if index != 0 {
				sectionView(section, index)
					.transition(
						.asymmetric(
							insertion: .move(edge: .leading)
								.combined(with: .opacity)
								.combined(with: .scale(scale: 0.8)),
							removal: .move(edge: .leading)
								.combined(with: .opacity)
						)
					)
					.animation(
						.spring(response: 0.5, dampingFraction: 0.8)
							.delay(Double(index) * 0.15),
						
						value: sections.count
					)
			}
		}
	}
	
	/// Builds a single circular button for a given section.
	/// - Parameters:
	///   - section: The `SpotlightSection` data for which to create the view.
	///   - index: The index of the section.
	/// - Returns: A button view for the section.
	private func sectionView(_ section: SpotlightSection<Item>, _ index: Int) -> some View {
		let isSelected = selectedSection == index
		
		return Button {
			// When tapped, animate the selection of the new section.
			withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
				
				self.state 			 = .focusSection
				self.selectedSection = index
				
			}
			
		} label: {
			Image(systemName: section.icon ?? "gearshape")
				.font(self.sizeIcon)
			
		}
		.frame(width: self.sizeButton, height: self.sizeButton)
		.buttonStyle(.plain)
		.glassEffect(
			// Apply a tint to the glass effect if this section is currently selected.
			.regular.tint(
				isSelected ? Color.accentColor : Color.clear
			),
			in: .circle
		)
		.clipShape(Circle())
	}
}

//
//  ResultsView.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 01/11/25.
//

import SwiftUI

/// The view that displays the content for the currently selected section.
/// This could be a list of search results or a custom view.
struct ResultsView<Item: SpotlightItem>: View {
	@Binding var listSelectedIndex: Int
	
	let indexSection 	: Int
	let spotlightSection: SpotlightSection<Item>
	let searchResults	: [Item]
	let rowStyle	 	: SpotlightRowStyle
	let maxHeight	 	: CGFloat
	
	let selectCurrentRow: () -> Void
	
	var body: some View {
		
		// `ScrollViewReader` allows programmatically scrolling to a specific view inside the `ScrollView`.
		ScrollViewReader { proxy in
			ScrollView {
				
				// Switch on the selected section index to determine what content to show.
				switch self.indexSection {
				case 0:
					// For the primary section (index 0), display the search results.
					LazyVStack(spacing: 8) {
						ForEach(searchResults.enumerated(), id: \.element.id) { index, item in
							let isSelected = index == self.listSelectedIndex

							// Use a standard row view to display the item.
							DefaultSpotlightRowView(
								item	  : item,
								isSelected: isSelected,
								style	  : self.rowStyle,
								onTap: {
									// On tap, update the selection and execute the item's action.
									self.listSelectedIndex = index
									self.selectCurrentRow()
								}
								
							)
						}
					}
					.padding()

				default:
					// For all other sections, delegate view construction to the section itself.
					// This allows for custom, non-list views in different sections.
					self.spotlightSection.buildView()
						
				}
			}
			.frame(maxHeight: self.maxHeight) // Constrain the scrollable area's height.
			.onChange(of: self.listSelectedIndex) { _, newIndex in
				// When the selected index changes (e.g., via arrow keys), scroll the list
				// to make the newly selected item visible.
				withAnimation(.easeInOut(duration: 0.3)) {
					proxy.scrollTo(newIndex, anchor: .center)
				}
			}
		}
		.transition(
			// Define a custom animation for when the results view appears and disappears.
			.asymmetric(
				insertion: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity),
				removal: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity)
			)
		)
	}
}

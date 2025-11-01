//
//  SearchBar.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 01/11/25.
//

import SwiftUI

/// The search bar view, including an icon and a text field.
struct SearchBarView: View {
	let title: String
	let icon : String
	var focusState: FocusState<Bool>.Binding?
	
	@Binding var searchText: String
	
	var body: some View {
		Image(systemName: icon)
			.foregroundColor(.secondary)
			.font(.title2)

		if let focus = focusState {
			TextField(
				title,
				text: $searchText
			)
			.textFieldStyle(.plain)
			.font(.title2)
			.focused(focus)
			
		} else {
			TextField(
				title,
				text: $searchText
			)
			.textFieldStyle(.plain)
			.font(.title2)
			
		}		
	}
}

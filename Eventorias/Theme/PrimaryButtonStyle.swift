//
//  PrimaryButtonStyle.swift
//  Eventorias
//
//  Created by Hugues Fils Caparos on 11/05/2026.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(Color.evenRed)
            .clipShape(.rect(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var eventoriasPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

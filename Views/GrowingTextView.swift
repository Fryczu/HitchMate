//
//  GrowingTextView.swift
//  HitchMate 3.0
//
//  Created by Kacper Fryczak on 10/09/2023.
//

import SwiftUI

struct GrowingTextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.textContainer.lineBreakMode = .byWordWrapping // Ustawienie trybu łamania wierszy
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextView

        init(_ parent: GrowingTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

/*struct GrowingTextView_Previews: PreviewProvider {
    static var previews: some View {
        GrowingTextView()
    }
}*/

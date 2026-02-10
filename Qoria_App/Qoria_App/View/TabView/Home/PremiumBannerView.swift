//
//  PremiumBannerView.swift
//  qoria_dev
//

import SwiftUI

struct PremiumBannerView: View {
    
    var onDismiss: () -> Void

    @State private var showUnderDevelopment = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(alignment: .top, spacing: 12) {
                Image("ic_bannerProBadgeFrame")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
                    .fixedSize(horizontal: true, vertical: false)

                Text("Try one month of Qoria Premium")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.Text.onDark)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                
                Spacer(minLength: 0)

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.Text.onDark.opacity(0.6))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }

            Text("Unlimited premium content, competitions, and direct support for creators.")
                .font(.subheadline)
                .foregroundStyle(Color.Text.onDark.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {
                self.showUnderDevelopment = true
            }) {
                Text("Start Free Trial")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(LinearGradient(colors: [.white.opacity(0.9), .white.opacity(0.7)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 22))
            }
            .buttonStyle(.plain)
            .padding(.top, 6) 
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [Color.Gradient.bannerLeft, Color.Gradient.bannerMiddle, Color.Gradient.bannerRight], startPoint: .leading, endPoint: .trailing)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        )
        .padding(.all, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Surface.post)
        .frame(maxWidth: .infinity)
        .alert("Under development", isPresented: $showUnderDevelopment) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Premium upgrade is under development.")
        }
    }
}

#Preview {
    PremiumBannerView(onDismiss: {})
        .background(Color.Surface.appBar)
}

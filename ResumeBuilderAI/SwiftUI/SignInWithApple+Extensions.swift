// Software Developed by Kody Deda.

import AuthenticationServices
import CryptoKit
import SwiftUI

struct SignInWithAppleToken: Equatable {
  let appleID: String
  let nonce: String
}

extension SignInWithAppleButton {
  init(
    _ label: Self.Label = .continue,
    onCompletion: @escaping (SignInWithAppleToken) -> Void
  ) {
    let currentNonce = generateRandomNonce()

    self = Self(
      label,
      onRequest: {
        $0.requestedScopes = [.fullName, .email]
        $0.nonce = SHA256.hash(data: Data(currentNonce.utf8))
          .compactMap { String(format: "%02x", $0) }
          .joined()
      },
      onCompletion: {
        guard let token = try? ($0.map(\.credential).get() as? ASAuthorizationAppleIDCredential)
          .flatMap(\.identityToken)
          .flatMap({ String(data: $0, encoding: .utf8) })
          .flatMap({ SignInWithAppleToken(appleID: $0, nonce: currentNonce) }) else
        {
          return
        }
        onCompletion(token)
      }
    )
  }
}

// MARK: - Helpers

private func generateRandomNonce(length: Int = 32) -> String {
  precondition(length > 0)
  let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }
      return random
    }
    randoms.forEach { random in
      if length == 0 {
        return
      }
      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }
  return result
}

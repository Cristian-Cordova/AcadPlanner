//
//  GoogleAuthService.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 03/06/26.
//

import Foundation
import GoogleSignIn
import UIKit

final class GoogleAuthService {
    private let calendarEventsScope = "https://www.googleapis.com/auth/calendar.events"

    func signIn() async throws -> String {
        guard let presentingViewController = await UIApplication.shared.rootViewController else {
            throw GoogleAuthError.missingPresentingViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: nil,
            additionalScopes: [calendarEventsScope]
        )

        guard let accessToken = result.user.accessToken.tokenString.nilIfEmpty else {
            throw GoogleAuthError.missingAccessToken
        }

        return accessToken
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}

enum GoogleAuthError: LocalizedError {
    case missingPresentingViewController
    case missingAccessToken

    var errorDescription: String? {
        switch self {
        case .missingPresentingViewController:
            return "Unable to present Google Sign-In."
        case .missingAccessToken:
            return "Unable to retrieve Google access token."
        }
    }
}

private extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

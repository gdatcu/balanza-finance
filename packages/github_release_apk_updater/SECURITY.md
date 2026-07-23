# Security Policy

## Supported Versions

Only the latest stable release of `github_release_apk_updater` receives security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | ✅ Yes             |
| < 1.0   | ❌ No              |

## Reporting a Vulnerability

We take the security of this package seriously. If you discover a security vulnerability, **please do not open a public GitHub issue**.

### How to Report

Report security vulnerabilities privately via **GitHub Security Advisories**:

1. Go to the [Security tab](https://github.com/dozmaz/github_release_apk_updater/security/advisories) of this repository.
2. Click **"New draft security advisory"**.
3. Fill in all relevant details (description, impact, reproduction steps, and suggested fix if any).

Alternatively, you may contact the maintainer directly at the email listed in the [pub.dev package page](https://pub.dev/packages/github_release_apk_updater).

### What to Include

Please provide as much of the following information as possible:

- **Type of vulnerability** (e.g., man-in-the-middle, token exposure, path traversal)
- **Affected version(s)**
- **Step-by-step reproduction instructions**
- **Impact assessment** (what data or functionality is at risk)
- **Suggested mitigation or fix** (optional but very helpful)

### Response Timeline

| Stage                         | Target Timeframe |
| ----------------------------- | ---------------- |
| Acknowledgment of report      | Within 72 hours  |
| Initial assessment            | Within 7 days    |
| Security fix released         | Within 30 days   |
| Public disclosure (CVE, etc.) | After fix ships  |

## Security Considerations for Users

This plugin handles potentially sensitive data. Please review the following practices when integrating it:

### GitHub Token Handling
- **Never hardcode** your GitHub token directly in your source code.
- Store tokens securely using tools like [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) or environment variables at build time.
- Use **fine-grained personal access tokens** with the minimum required scopes (`contents: read` for release access).
- Rotate tokens regularly and revoke immediately if compromised.

### APK Download Integrity
- Downloads go to the device's external storage directory; ensure your `FileProvider` paths are scoped correctly.
- Consider verifying SHA checksums of downloaded APKs against values published in your GitHub release notes.
- Only install APKs from trusted, controlled GitHub repositories.

### Network Security
- All GitHub API and asset download requests are made over HTTPS.
- Avoid passing raw tokens in URLs; this plugin uses `Authorization` headers.

## Scope

The following are **in scope** for security reports:

- Token/credential leakage through logs, network requests, or storage
- Man-in-the-middle vulnerabilities in the download pipeline
- Path traversal or unsafe file writes during APK download
- Insecure intents when launching the APK installer

The following are **out of scope**:

- Security issues in third-party dependencies (report those upstream)
- Issues in apps *built using* this plugin (not the plugin itself)
- Social engineering or phishing attacks

## Disclosure Policy

We follow **coordinated disclosure**: once a fix is released, we will publish a security advisory crediting the reporter (unless anonymity is requested).

---

Thank you for helping keep `github_release_apk_updater` and its users safe. 🙏

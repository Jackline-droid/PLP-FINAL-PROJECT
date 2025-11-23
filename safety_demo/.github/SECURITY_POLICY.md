# Security Policy

## Supported Versions

This is a demonstration/educational project. Security updates are provided as needed.

## Reporting a Vulnerability

If you discover a security vulnerability, please:

1. **Do NOT** create a public GitHub issue
2. Email the project maintainer directly
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Security Best Practices

### For Users
- Always use your own Firebase project credentials
- Never commit `firebase_options.dart` or `google-services.json` to version control
- Configure Firebase API key restrictions in Firebase Console
- Use Firebase Security Rules to protect data
- Rotate keys if they've been exposed

### For Developers
- Review `SECURITY.md` for detailed security information
- Use environment variables for sensitive configuration
- Implement proper authentication and authorization
- Follow OWASP mobile security guidelines

## Known Security Considerations

1. **Firebase API Keys**: Client-side keys are public by design but should have restrictions configured
2. **Encryption Key**: Demo uses static key - replace with secure key derivation in production
3. **Local Storage**: Data stored locally using Hive - consider encryption at rest for sensitive data

---

**Note**: This is a demonstration project. For production use, implement all recommended security measures.


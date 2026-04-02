# Auth0 Integration with KrakenD

## Overview

This guide provides comprehensive steps to integrate Auth0 with KrakenD for securing APIs using JWT authentication. This setup enables robust authentication and authorization for your API gateway.

## Key Features of This Configuration

### Custom Authentication Header
This setup uses `X-Custom-Auth` instead of the standard `Authorization` header for JWT tokens. This provides:
- Additional security through obscurity
- Flexibility in client implementation
- Ability to use standard Authorization header for other purposes

### Claim Propagation
The configuration automatically forwards JWT claims as HTTP headers to backend services:
- `https://myapp.com/email` → `x-email` header
- Additional claims can be easily added to the `propagate_claims` array

### Auth0 Management API Integration
The configuration uses Auth0's Management API as the audience, which provides access to Auth0's user management features.

---

## Prerequisites

- Auth0 account with configured Application and API
- KrakenD API Gateway installed
- Basic understanding of JWT tokens and API security

---

## KrakenD Configuration

### Basic JWT Validation Setup

Create or update your `krakend.json` configuration file:

```json
{
  "version": 3,
  "timeout": "3s",
  "cache_ttl": "300s",
  "endpoints": [
    {
      "endpoint": "/auth0-protected",
      "method": "GET",
      "extra_config": {
        "auth/validator": {
          "auth_header_name": "X-Custom-Auth",
          "propagate_claims": [
            ["https://myapp.com/email", "x-email"]
          ],
          "alg": "RS256",
          "audience": [
            "https://YOUR_DOMAIN.auth0.com/api/v2/"
          ],
          "jwk_url": "https://YOUR_DOMAIN.auth0.com/.well-known/jwks.json",
          "operation_debug": true
        }
      },
      "backend": [
        {
          "host": ["http://localhost:8080"],
          "url_pattern": "/__health"
        }
      ]
    }
  ]
}
```

### Configuration Parameters

Replace the following placeholder values with your Auth0 settings:

| Parameter | Description | Where to Find |
|-----------|-------------|---------------|
| `auth_header_name` | Custom header name for JWT token | Define as needed (e.g., `X-Custom-Auth`) |
| `audience` | Auth0 Management API Identifier | Auth0 Dashboard → APIs → Management API → Identifier |
| `jwk_url` | JSON Web Key Set URL | `https://[YOUR_DOMAIN]/.well-known/jwks.json` |
| `alg` | Signing Algorithm | Auth0 Dashboard → APIs → [Your API] → Signing Algorithm |
| `propagate_claims` | Maps JWT claims to backend headers | Custom configuration for claim forwarding |

---

## Auth0 Setup

### 1. Application Configuration

Navigate to **Applications** → **[Your Application]** in the Auth0 Dashboard:

1. **Domain**: Copy this value for your `jwk_url`
2. **Client ID**: Required for frontend authentication
3. **Client Secret**: Keep secure, used for server-side operations

### 2. API Configuration

Navigate to **APIs** → **Management API** (or your custom API):

1. **Identifier**: Use as the `audience` value in KrakenD (typically `https://YOUR_DOMAIN.auth0.com/api/v2/`)
2. **Signing Algorithm**: Typically `RS256`
3. **Token Expiration**: Configure as needed

**Note**: The example configuration uses the Auth0 Management API (`/api/v2/`) as the audience. If you're using a custom API, replace this with your custom API identifier.

### 3. Application URLs

Ensure the following URLs are configured in your Application settings:

- **Allowed Callback URLs**: `http://localhost:3000/callback` (adjust for your app)
- **Allowed Logout URLs**: `http://localhost:3000` (adjust for your app)
- **Allowed Web Origins**: `http://localhost:3000` (adjust for your app)

---

## Custom Claims Setup

### Post-Login Action

Create a Post-Login Action in Auth0 to add custom claims to JWT tokens:

1. Navigate to **Actions** → **Flows** → **Login**
2. Create a new Action with the following code:

```javascript
/**
 * Handler that will be called during the execution of a PostLogin flow.
 *
 * @param {Event} event - Details about the user and the context in which they are logging in.
 * @param {PostLoginAPI} api - Interface whose methods can be used to change the behavior of the login.
 */
exports.onExecutePostLogin = async (event, api) => {
  // Define your custom claims namespace (must be a valid URI)
  const namespace = 'https://myapp.com/';
  
  /**
   * Helper function to safely extract and validate string values
   * @param {*} value - The value to validate
   * @returns {string|null} - Trimmed string or null if invalid
   */
  const getString = (value) => {
    if (typeof value === 'string' && value.trim()) {
      return value.trim();
    }
    return null;
  };

  // Extract name components with fallback logic
  let firstName = getString(event.user.given_name);
  let lastName = getString(event.user.family_name);

  // Apply intelligent fallbacks if both names are missing
  if (!firstName && !lastName) {
    const fullName = getString(event.user.name);
    const nickname = getString(event.user.nickname);
    const emailUsername = event.user.email 
      ? event.user.email.split('@')[0].trim() 
      : null;

    if (fullName) {
      // Split full name into components
      const nameParts = fullName.split(/\s+/);
      firstName = nameParts[0] || null;
      lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : null;
    } else if (nickname) {
      firstName = nickname;
      lastName = null;
    } else if (emailUsername) {
      firstName = emailUsername;
      lastName = null;
    }
  }

  // Ensure string values (not null) to prevent token issues
  firstName = firstName || '';
  lastName = lastName || '';

  // Build comprehensive user profile object
  const userProfile = {
    email: getString(event.user.email),
    email_verified: Boolean(event.user.email_verified),
    first_name: firstName,
    last_name: lastName,
    image: getString(event.user.picture),
    name: getString(event.user.name),
    created_at: event.user.created_at || null,
    updated_at: event.user.updated_at || null,
    // Application-specific fields
    company: null,
    designation: null,
    active: false,
    is_admin: false,
    address_updated: false,
    quotas: null,
    used_demo: false,
    reference: null
  };

  try {
    // Add each profile field as a custom claim
    Object.entries(userProfile).forEach(([key, value]) => {
      api.accessToken.setCustomClaim(`${namespace}${key}`, value);
    });

    // Add user roles if available
    const userRoles = event.authorization?.roles || [];
    api.accessToken.setCustomClaim(`${namespace}roles`, userRoles);

    console.log('Custom claims successfully added to token');
    
  } catch (error) {
    console.error('Error setting custom claims:', error);
    
    // Decide whether to fail the login or continue
    // For critical claims, you might want to use api.access.deny()
    // For non-critical claims, allow login to continue
    
    // Optional: Add error information to token for debugging
    api.accessToken.setCustomClaim(`${namespace}claims_error`, error.message);
  }
};
```

### 3. Deploy the Action

1. Save the Action code
2. Deploy it to your Login flow
3. Test the integration with a test user

---

## Testing the Integration

### 1. Obtain Access Token

Use Auth0's authentication flow to obtain a JWT token:

```bash
curl --request POST \
  --url https://YOUR_DOMAIN.auth0.com/oauth/token \
  --header 'content-type: application/json' \
  --data '{
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "audience": "https://YOUR_DOMAIN.auth0.com/api/v2/",
    "grant_type": "client_credentials"
  }'
```

### 2. Test Protected Endpoint

Use the obtained token to access your protected KrakenD endpoint:

```bash
curl --request GET \
  --url http://localhost:8080/auth0-protected \
  --header 'X-Custom-Auth: Bearer YOUR_JWT_TOKEN'
```

---

## Advanced Configuration

### Custom Validation Rules

Add additional validation in KrakenD configuration:

```json
{
  "auth/validator": {
    "auth_header_name": "X-Custom-Auth",
    "alg": "RS256",
    "audience": ["https://YOUR_DOMAIN.auth0.com/api/v2/"],
    "jwk_url": "https://YOUR_DOMAIN.auth0.com/.well-known/jwks.json",
    "roles_key": "https://myapp.com/roles",
    "roles": ["admin", "user"],
    "operation_debug": true,
    "propagate_claims": [
      ["https://myapp.com/email", "x-email"],
      ["https://myapp.com/roles", "x-user-roles"],
      ["https://myapp.com/first_name", "x-first-name"],
      ["https://myapp.com/last_name", "x-last-name"]
    ]
  }
}
```

### Error Handling and Claim Propagation

The `propagate_claims` feature forwards JWT claims as HTTP headers to your backend services:

```json
{
  "auth/validator": {
    "auth_header_name": "X-Custom-Auth",
    "alg": "RS256",
    "audience": ["https://YOUR_DOMAIN.auth0.com/api/v2/"],
    "jwk_url": "https://YOUR_DOMAIN.auth0.com/.well-known/jwks.json",
    "operation_debug": true,
    "propagate_claims": [
      ["https://myapp.com/email", "x-email"],
      ["https://myapp.com/first_name", "x-first-name"],
      ["https://myapp.com/last_name", "x-last-name"],
      ["https://myapp.com/is_admin", "x-is-admin"],
      ["https://myapp.com/roles", "x-user-roles"]
    ]
  }
}
```

**How it works:**
- First value: JWT claim path (from your Auth0 custom claims)
- Second value: HTTP header name sent to backend
- Your backend services will receive these headers with user information

---

## Troubleshooting

### Common Issues

1. **Invalid Audience**: Ensure the `audience` in KrakenD matches your Auth0 API identifier (e.g., `https://YOUR_DOMAIN.auth0.com/api/v2/`)
2. **Custom Header Not Found**: Verify your client is sending the JWT in the `X-Custom-Auth` header instead of the standard `Authorization` header
3. **JWK URL Issues**: Verify your Auth0 domain is correct in the `jwk_url`
4. **Custom Claims Not Present**: Check that your Post-Login Action is deployed and active
5. **Token Expiration**: Verify token hasn't expired and refresh as needed
6. **Claims Not Propagating**: Ensure the claim paths in `propagate_claims` match exactly with your Auth0 custom claims namespace

### Debug Mode

Enable debug mode in KrakenD for detailed logging:

```json
{
  "extra_config": {
    "auth/validator": {
      "operation_debug": true
    }
  }
}
```

### Logs Analysis

Check KrakenD logs for authentication errors:

```bash
# View KrakenD logs
docker logs krakend-container

# Or if running directly
tail -f /var/log/krakend.log
```

---

## Security Best Practices

1. **Use HTTPS**: Always use HTTPS in production
2. **Token Expiration**: Set appropriate token expiration times
3. **Audience Validation**: Always validate the audience claim
4. **Rate Limiting**: Implement rate limiting on authentication endpoints
5. **Monitor Logs**: Regularly monitor authentication logs for suspicious activity
6. **Rotate Secrets**: Regularly rotate client secrets and signing keys

---

## Conclusion

This integration provides a robust authentication layer for your APIs using Auth0 and KrakenD. The custom claims setup allows for rich user context to be passed through to your backend services while maintaining security best practices.
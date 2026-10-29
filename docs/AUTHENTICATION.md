# Authentication

hxDiscordSocial supports Discord OAuth2 through the Social SDK. Rich Presence
does not require authentication; use it only when the application needs an
identified Discord user or another authorized SDK service.

## Public-client flow

The Windows backend performs this sequence:

1. generate a PKCE verifier and challenge;
2. open Discord's authorization prompt;
3. exchange the returned code through `Client::GetToken`;
4. emit `Authenticated` with both tokens, expiry and scopes;
5. install the access token, connect and resolve the current user;
6. emit `AuthenticationReady`.

Enable **Public Client** on the application's OAuth2 page before using this
flow. It is useful for local tools and early integration work. Discord advises
most shipped games to use a server-backed confidential-client flow instead.

```haxe
Discord.initialize(applicationId);
Discord.poll();
Discord.authorize(); // requests the default presence scopes
```

Pass a custom scope string only when extra permissions are genuinely needed.

## Restoring and refreshing

Store the tokens after `Authenticated`. At the next launch:

```haxe
Discord.initialize(applicationId);
Discord.restoreToken(loadAccessTokenSecurely());
```

On `TokenRefreshRequired`, call `refreshToken` with the stored refresh token.
Refresh tokens can rotate, so replace both stored values every time another
`Authenticated` event arrives. If refresh returns an invalid grant, delete the
credentials and ask the user to authorize again.

`logout()` disconnects the SDK and clears in-memory authentication state. The
application must also delete its stored tokens. Local logout does not revoke
the grant shown on Discord's Authorized Apps page.

## Production server flow

A confidential client sends the authorization code and PKCE verifier to a
backend over HTTPS. That backend exchanges and refreshes tokens using the
client secret. Never ship the secret in Haxe, C++, assets or Android resources.

Discord login is an identity layer, not a settings database. Cross-device
settings require an application backend and database. Keep local settings
usable offline and resolve conflicts with a revision or `updatedAt` field.

## Token storage

Use Windows Credential Manager on Windows and Keystore-backed storage on
Android. Plain JSON, save files, registry strings and environment variables are
not suitable for refresh tokens.

The library deliberately does not write tokens to disk. Storage policy belongs
to the host application and differs by platform and threat model.

# Security notes

- Treat access and refresh tokens as secrets.
- Never log tokens or include them in crash reports.
- Never place a Discord client secret in a distributed application.
- Request the smallest useful OAuth scope set.
- Use HTTPS for backend exchanges and cloud-setting APIs.
- Validate URLs and join secrets supplied by mods or user content.
- Give users separate controls for disabling Presence and hiding details.
- Clear local credentials when the user logs out or revokes account linking.

Rich Presence is public social data. Level names, project names, servers or
editor filenames can reveal more than expected. Applications should use a
conservative default and document which fields are shared.

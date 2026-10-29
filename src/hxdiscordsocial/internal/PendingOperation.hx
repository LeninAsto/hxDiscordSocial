package hxdiscordsocial.internal;

import hxdiscordsocial.Presence;

enum PendingOperation {
	Set(presence:Presence);
	Clear;
}

#pragma once

#include <cstdint>

#if defined(_WIN32)
#define HDS_EXPORT extern "C" __declspec(dllexport)
#else
#define HDS_EXPORT extern "C" __attribute__((visibility("default")))
#endif

enum HdsEventType {
    HDS_EVENT_NONE = 0,
    HDS_EVENT_READY = 1,
    HDS_EVENT_PRESENCE_UPDATED = 2,
    HDS_EVENT_PRESENCE_CLEARED = 3,
    HDS_EVENT_DISCONNECTED = 4,
    HDS_EVENT_ERROR = 5,
    HDS_EVENT_AUTHORIZATION_STARTED = 6,
    HDS_EVENT_AUTHENTICATED = 7,
    HDS_EVENT_AUTH_READY = 8,
    HDS_EVENT_TOKEN_EXPIRING = 9,
    HDS_EVENT_LOGGED_OUT = 10,
};

enum HdsOperation {
    HDS_OPERATION_NONE = 0,
    HDS_OPERATION_INITIALIZE = 1,
    HDS_OPERATION_SET_PRESENCE = 2,
    HDS_OPERATION_CLEAR_PRESENCE = 3,
    HDS_OPERATION_AUTHORIZE = 4,
    HDS_OPERATION_RESTORE_TOKEN = 5,
    HDS_OPERATION_REFRESH_TOKEN = 6,
    HDS_OPERATION_LOGOUT = 7,
};

HDS_EXPORT bool hds_initialize(const char* application_id);
HDS_EXPORT bool hds_set_presence(const char* name,
                                 int activity_type,
                                 int status_display_type,
                                 const char* details,
                                 const char* details_url,
                                 const char* state,
                                 const char* state_url,
                                 const char* large_image,
                                 const char* large_text,
                                 const char* large_url,
                                 const char* small_image,
                                 const char* small_text,
                                 const char* small_url,
                                 const char* invite_cover_image,
                                 std::int64_t start_timestamp,
                                 bool has_start_timestamp,
                                 std::int64_t end_timestamp,
                                 bool has_end_timestamp,
                                 const char* button_one_label,
                                 const char* button_one_url,
                                 const char* button_two_label,
                                 const char* button_two_url,
                                 const char* party_id,
                                 int party_current_size,
                                 int party_max_size,
                                 int party_privacy,
                                 const char* join_secret,
                                 int supported_platforms);
HDS_EXPORT bool hds_clear_presence();
HDS_EXPORT bool hds_authorize(const char* scopes);
HDS_EXPORT bool hds_restore_token(const char* access_token);
HDS_EXPORT bool hds_refresh_token(const char* refresh_token);
HDS_EXPORT bool hds_logout();
HDS_EXPORT void hds_run_callbacks();
HDS_EXPORT void hds_shutdown();

HDS_EXPORT int hds_pop_event();
HDS_EXPORT int hds_event_operation();
HDS_EXPORT const char* hds_event_message();
HDS_EXPORT bool hds_event_retryable();
HDS_EXPORT const char* hds_event_data(int index);
HDS_EXPORT int hds_event_number();
HDS_EXPORT const char* hds_last_error();

HDS_EXPORT int hds_version_major();
HDS_EXPORT int hds_version_minor();
HDS_EXPORT int hds_version_patch();

HDS_EXPORT bool hds_credential_write(const char* key, const char* value);
HDS_EXPORT const char* hds_credential_read(const char* key);
HDS_EXPORT bool hds_credential_delete(const char* key);


#define DISCORDPP_IMPLEMENTATION
#include "discordpp.h"
#include "HxDiscordSocialBridge.h"

#include <atomic>
#include <cstdint>
#include <deque>
#include <memory>
#include <mutex>
#include <optional>
#include <stdexcept>
#include <string>
#include <utility>

namespace {
struct BridgeEvent {
    int type = HDS_EVENT_NONE;
    int operation = HDS_OPERATION_NONE;
    std::string message;
    bool retryable = false;
};

std::shared_ptr<discordpp::Client> g_client;
std::deque<BridgeEvent> g_events;
BridgeEvent g_current_event;
std::string g_last_error;
std::mutex g_mutex;
std::atomic<std::uint64_t> g_generation{0};

void setLastError(std::string message) {
    std::lock_guard<std::mutex> lock(g_mutex);
    g_last_error = std::move(message);
}

void pushEvent(int type,
               int operation = HDS_OPERATION_NONE,
               std::string message = {},
               bool retryable = false) {
    std::lock_guard<std::mutex> lock(g_mutex);
    g_events.push_back({type, operation, std::move(message), retryable});
}

std::optional<std::string> optionalString(const char* value) {
    if (value == nullptr || value[0] == '\0') {
        return std::nullopt;
    }
    return std::string(value);
}

std::uint64_t parseApplicationId(const char* value) {
    if (value == nullptr || value[0] == '\0') {
        throw std::invalid_argument("Application ID is empty");
    }
    const std::string text(value);
    std::size_t parsed = 0;
    const auto result = std::stoull(text, &parsed, 10);
    if (result == 0 || parsed != text.size()) {
        throw std::invalid_argument("Application ID is not a positive decimal integer");
    }
    return result;
}
}

bool hds_initialize(const char* application_id) {
    try {
        const auto id = parseApplicationId(application_id);
        hds_shutdown();

        const auto generation = ++g_generation;
        auto client = std::make_shared<discordpp::Client>();
        client->AddLogCallback(
          [generation](std::string message, discordpp::LoggingSeverity severity) {
              if (generation != g_generation.load()) {
                  return;
              }
              if (severity == discordpp::LoggingSeverity::Error) {
                  setLastError(std::move(message));
              }
          },
          discordpp::LoggingSeverity::Error);
        client->SetApplicationId(id);
        g_client = std::move(client);
        setLastError({});
        pushEvent(HDS_EVENT_READY, HDS_OPERATION_INITIALIZE);
        return true;
    } catch (const std::exception& error) {
        setLastError(error.what());
        return false;
    } catch (...) {
        setLastError("Unknown Discord SDK initialization failure");
        return false;
    }
}

bool hds_set_presence(const char* name,
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
                      int supported_platforms) {
    if (!g_client) {
        setLastError("Discord SDK is not initialized");
        return false;
    }
    if ((has_start_timestamp && start_timestamp < 0)
        || (has_end_timestamp && end_timestamp < 0)) {
        setLastError("Presence timestamps cannot be negative");
        return false;
    }
	if (activity_type < 0 || activity_type > 6
		|| status_display_type < -1 || status_display_type > 2
		|| party_privacy < 0 || party_privacy > 1) {
		setLastError("Presence contains an invalid enum value");
		return false;
	}

    try {
        discordpp::Activity activity;
        activity.SetType(static_cast<discordpp::ActivityTypes>(activity_type));
        if (const auto value = optionalString(name)) {
            activity.SetName(*value);
        }
		if (status_display_type >= 0) {
			activity.SetStatusDisplayType(
			  static_cast<discordpp::StatusDisplayTypes>(status_display_type));
		}
        activity.SetDetails(optionalString(details));
        activity.SetDetailsUrl(optionalString(details_url));
        activity.SetState(optionalString(state));
        activity.SetStateUrl(optionalString(state_url));

        const auto largeImage = optionalString(large_image);
        const auto largeText = optionalString(large_text);
        const auto largeUrl = optionalString(large_url);
        const auto smallImage = optionalString(small_image);
        const auto smallText = optionalString(small_text);
        const auto smallUrl = optionalString(small_url);
        const auto inviteCoverImage = optionalString(invite_cover_image);
        if (largeImage || largeText || largeUrl || smallImage || smallText
            || smallUrl || inviteCoverImage) {
            discordpp::ActivityAssets assets;
            assets.SetLargeImage(largeImage);
            assets.SetLargeText(largeText);
            assets.SetLargeUrl(largeUrl);
            assets.SetSmallImage(smallImage);
            assets.SetSmallText(smallText);
            assets.SetSmallUrl(smallUrl);
            assets.SetInviteCoverImage(inviteCoverImage);
            activity.SetAssets(assets);
        }

        if (has_start_timestamp || has_end_timestamp) {
            discordpp::ActivityTimestamps timestamps;
            if (has_start_timestamp) {
                timestamps.SetStart(static_cast<std::uint64_t>(start_timestamp));
            }
            if (has_end_timestamp) {
                timestamps.SetEnd(static_cast<std::uint64_t>(end_timestamp));
            }
            activity.SetTimestamps(timestamps);
        }

		const auto addButton = [&activity](const char* label, const char* url) {
			if (label != nullptr && label[0] != '\0' && url != nullptr && url[0] != '\0') {
				discordpp::ActivityButton button;
				button.SetLabel(label);
				button.SetUrl(url);
				activity.AddButton(std::move(button));
			}
		};
		addButton(button_one_label, button_one_url);
		addButton(button_two_label, button_two_url);

		if (party_id != nullptr && party_id[0] != '\0') {
			discordpp::ActivityParty party;
			party.SetId(party_id);
			party.SetCurrentSize(party_current_size);
			party.SetMaxSize(party_max_size);
			party.SetPrivacy(static_cast<discordpp::ActivityPartyPrivacy>(party_privacy));
			activity.SetParty(std::move(party));
		}
		if (join_secret != nullptr && join_secret[0] != '\0') {
			discordpp::ActivitySecrets secrets;
			secrets.SetJoin(join_secret);
			activity.SetSecrets(std::move(secrets));
		}
		if (supported_platforms != 0) {
			activity.SetSupportedPlatforms(
			  static_cast<discordpp::ActivityGamePlatforms>(supported_platforms));
		}

        const auto generation = g_generation.load();
        g_client->UpdateRichPresence(
          std::move(activity),
          [generation](discordpp::ClientResult result) {
              if (generation != g_generation.load()) {
                  return;
              }
              if (result.Successful()) {
                  pushEvent(HDS_EVENT_PRESENCE_UPDATED,
                            HDS_OPERATION_SET_PRESENCE);
              } else {
                  const auto message = result.Error().empty()
                                         ? result.ToString()
                                         : result.Error();
                  setLastError(message);
                  pushEvent(HDS_EVENT_ERROR,
                            HDS_OPERATION_SET_PRESENCE,
                            message,
                            result.Retryable());
              }
          });
        setLastError({});
        return true;
    } catch (const std::exception& error) {
        setLastError(error.what());
        return false;
    } catch (...) {
        setLastError("Unknown Rich Presence submission failure");
        return false;
    }
}

bool hds_clear_presence() {
    if (!g_client) {
        setLastError("Discord SDK is not initialized");
        return false;
    }
    try {
        g_client->ClearRichPresence();
        setLastError({});
        pushEvent(HDS_EVENT_PRESENCE_CLEARED,
                  HDS_OPERATION_CLEAR_PRESENCE);
        return true;
    } catch (const std::exception& error) {
        setLastError(error.what());
        return false;
    } catch (...) {
        setLastError("Unknown Rich Presence clear failure");
        return false;
    }
}

void hds_run_callbacks() {
    if (!g_client) {
        return;
    }
    try {
        discordpp::RunCallbacks();
    } catch (const std::exception& error) {
        setLastError(error.what());
        pushEvent(HDS_EVENT_ERROR,
                  HDS_OPERATION_NONE,
                  error.what(),
                  true);
    } catch (...) {
        setLastError("Unknown Discord callback failure");
        pushEvent(HDS_EVENT_ERROR,
                  HDS_OPERATION_NONE,
                  "Unknown Discord callback failure",
                  true);
    }
}

void hds_shutdown() {
    ++g_generation;
    if (g_client) {
        try {
            g_client->ClearRichPresence();
            discordpp::RunCallbacks();
        } catch (...) {
        }
        g_client.reset();
    }
    std::lock_guard<std::mutex> lock(g_mutex);
    g_events.clear();
    g_current_event = {};
}

int hds_pop_event() {
    std::lock_guard<std::mutex> lock(g_mutex);
    if (g_events.empty()) {
        g_current_event = {};
        return HDS_EVENT_NONE;
    }
    g_current_event = std::move(g_events.front());
    g_events.pop_front();
    return g_current_event.type;
}

int hds_event_operation() {
    std::lock_guard<std::mutex> lock(g_mutex);
    return g_current_event.operation;
}

const char* hds_event_message() {
    std::lock_guard<std::mutex> lock(g_mutex);
    return g_current_event.message.c_str();
}

bool hds_event_retryable() {
    std::lock_guard<std::mutex> lock(g_mutex);
    return g_current_event.retryable;
}

const char* hds_last_error() {
    std::lock_guard<std::mutex> lock(g_mutex);
    return g_last_error.c_str();
}

int hds_version_major() {
    return discordpp::Client::GetVersionMajor();
}

int hds_version_minor() {
    return discordpp::Client::GetVersionMinor();
}

int hds_version_patch() {
    return discordpp::Client::GetVersionPatch();
}


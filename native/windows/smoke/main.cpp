#define DISCORDPP_IMPLEMENTATION
#include "discordpp.h"

#include <atomic>
#include <chrono>
#include <cstdint>
#include <exception>
#include <iostream>
#include <memory>
#include <string>
#include <thread>

namespace {
std::uint64_t parseApplicationId(const char* value) {
    std::size_t parsed = 0;
    const std::string text(value == nullptr ? "" : value);
    const auto result = std::stoull(text, &parsed, 10);
    if (result == 0 || parsed != text.size()) {
        throw std::invalid_argument("application ID must be a positive decimal integer");
    }
    return result;
}
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: hxdiscordsocial-smoke <application-id> [timeout-seconds]\n";
        return 64;
    }

    try {
        const auto applicationId = parseApplicationId(argv[1]);
        const int timeoutSeconds = argc >= 3 ? std::max(1, std::stoi(argv[2])) : 8;

        std::cout << "Discord Social SDK " << discordpp::Client::GetVersionMajor() << '.'
                  << discordpp::Client::GetVersionMinor() << '.'
                  << discordpp::Client::GetVersionPatch() << '\n';

        auto client = std::make_shared<discordpp::Client>();
        client->AddLogCallback(
          [](std::string message, discordpp::LoggingSeverity severity) {
              if (severity == discordpp::LoggingSeverity::Error
                  || severity == discordpp::LoggingSeverity::Warning) {
                  std::cerr << "[Discord] " << message << '\n';
              }
          },
          discordpp::LoggingSeverity::Warning);
        client->SetApplicationId(applicationId);

        discordpp::Activity activity;
        activity.SetType(discordpp::ActivityTypes::Playing);
        activity.SetDetails("hxDiscordSocial native smoke test");
        activity.SetState("Validating Windows x64 bridge");

        discordpp::ActivityTimestamps timestamps;
        timestamps.SetStart(static_cast<std::uint64_t>(std::time(nullptr)));
        activity.SetTimestamps(timestamps);

        std::atomic<bool> completed{false};
        std::atomic<bool> successful{false};
        std::string error;
        client->UpdateRichPresence(
          std::move(activity),
          [&](discordpp::ClientResult result) {
              successful.store(result.Successful());
              if (!result.Successful()) {
                  error = result.Error();
              }
              completed.store(true);
          });

        const auto deadline = std::chrono::steady_clock::now()
                              + std::chrono::seconds(timeoutSeconds);
        while (!completed.load() && std::chrono::steady_clock::now() < deadline) {
            discordpp::RunCallbacks();
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }

        if (!completed.load()) {
            std::cerr << "Timed out waiting for UpdateRichPresence callback.\n";
            client->ClearRichPresence();
            return 2;
        }
        if (!successful.load()) {
            std::cerr << "UpdateRichPresence failed: " << error << '\n';
            client->ClearRichPresence();
            return 3;
        }

        std::cout << "Rich Presence update confirmed.\n";
        client->ClearRichPresence();
        for (int i = 0; i < 20; ++i) {
            discordpp::RunCallbacks();
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }
        std::cout << "Presence cleared; smoke test passed.\n";
        return 0;
    } catch (const std::exception& error) {
        std::cerr << "Smoke test error: " << error.what() << '\n';
        return 65;
    }
}


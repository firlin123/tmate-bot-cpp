#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <exception>
#include <string>

#include <tgbot/tgbot.h>

std::string exec(const char* cmd) {
    std::array<char, 128> buffer;
    std::string result;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
    if (!pipe) {
        throw std::runtime_error("popen() failed!");
    }
    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
    }
    return result;
}

const std::string currentDateTime() {
    time_t     now = time(0);
    struct tm  tstruct;
    char       buf[80];
    tstruct = *localtime(&now);
    // Visit http://en.cppreference.com/w/cpp/chrono/c/strftime
    // for more information about date/time format
    strftime(buf, sizeof(buf), "[%Y.%m.%d %X]", &tstruct);

    return buf;
}

using namespace std;
using namespace TgBot;

int main() {
    string token(getenv("TOKEN"));
    printf("%s Token: %s\n", currentDateTime().c_str(), token.c_str());

    Bot bot(token);
    bot.getEvents().onCommand("start", [&bot](Message::Ptr message) {
        bot.getApi().sendMessage(message->chat->id, "Hi!");
    });
    bot.getEvents().onAnyMessage([&bot](Message::Ptr message) {
        printf("%s User wrote %s\n", currentDateTime().c_str(), message->text.c_str());
        
        if (StringTools::startsWith(message->text, "/ssh")) {
            string sh=exec((string("/root/tgbot-cpp/samples/echobot/allowed.sh ") + to_string(message->from->id)).c_str());
            if(!StringTools::startsWith(sh, "allowed"))
            {
                bot.getApi().sendMessage(message->chat->id, "Not allowed");
                return;
            }
            string ssh_key=exec("/root/tgbot-cpp/samples/echobot/tmate.sh"); // + " id: " + to_string(message->from->id);
            bot.getApi().sendMessage(message->chat->id, ssh_key);
            return;
        }
        if (StringTools::startsWith(message->text, "/start")) {
            return;
        }
        //bot.getApi().sendMessage(message->chat->id, "Your message is: " + message->text);
    });

    signal(SIGINT, [](int s) {
        printf("%s SIGINT got\n", currentDateTime().c_str());
        exit(0);
    });

    try {
        printf("%s Bot username: %s\n", currentDateTime().c_str(), bot.getApi().getMe()->username.c_str());
        bot.getApi().deleteWebhook();

        TgLongPoll longPoll(bot);
        while (true) {
            printf("%s Long poll started\n", currentDateTime().c_str());
            longPoll.start();
        }
    } catch (exception& e) {
        printf("%s error: %s\n", currentDateTime().c_str(), e.what());
    }

    return 0;
}

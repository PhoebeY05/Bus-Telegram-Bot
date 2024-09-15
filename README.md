# Bus Telegram Bot
Allows users to set 2 bus stops they frequently use and sends message through Telegram about the bus arrival time of a bus at the bus stop closer to user's location
## Inspiration
- Modified from example code given in NUSHackers' "Beginners' Guide to the Terminal" Hackers Toolbox session
- Single-purpose tool meant to streamline the normal checking of bus arrival time process
  - Instead of having to open the app, scroll to the bus stop and find the bus of interest, we can just run this preset script that is already customised to user's preferences
# Variables to set
1. `TELEGRAM_BOT_TOKEN` = Obtained from BotFather Telegram bot
2. `CHAT_ID` = Obtained from Get My ID bot (@getmyid_bot)
3. `KEY` = Obtained from ipapi website after registering account
4. `host_ipv6` = Obtained from ipapi Quick Start Guide
5. `place` = User's alias for the bus stop
6. `id` = Obtained from MyTransport app (or any other bus app)
7. `index` = Observed from JSON result of [ArriveLah](https://github.com/cheeaun/arrivelah) API call
8. `latitude_int`, `longitude_int`,`latitude_home`, `longitude_home` = Obtained from [One Map](https://www.onemap.gov.sg/) (Fill into [coordinates.json](/coordinates.json))

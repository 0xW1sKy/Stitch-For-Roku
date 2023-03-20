# Stitch (for Roku)

A Homebrew Twitch app for Roku. Still buggy, so feel free to suggest improvements or make pull requests.

Issues, Feature Requests, Etc should all be done via github.

## Discord

Because people have been asking for it, here is a discord server you can join for discussion and announcements

[![Discord](https://discordapp.com/api/guilds/1056784102084313179/widget.png?style=banner4)](https://discord.gg/KsdejA43SD)

## Support

Best way to support Stitch is interaction with this project. Contributions are welcome.

## How to Install

### (Easy) With Access Code

Stitch *uncertified* : LL5GKQ (<https://my.roku.com/account/add?channel=LL5GKQ>)

### (Less Easy) Manual Developer Install

1. [Enable developer mode for Roku](https://blog.roku.com/developer/developer-setup-guide)

2. Log into your Roku from your browser using IP from previous step (http://192.168.x.x)

3. ZIP (into a ZIP file) all contents of this repo (you do not have to include README.md) (using 7-Zip, WinRAR, etc.). Do not include extra top level directories in the ZIP file, otherwise you may get the error: "```Install Failure: No manifest. Invalid package.```". Alternatively, you can download this ZIP file from the releases section.

4. Upload previous ZIP file in Roku Development Application Installer (step 2)

5. Press Install

6. Stitch should now be installed on your Roku. You should see it at the end of your channel list

## URLs used by app (may need to be allowed in pihole, etc)

* <https://*.hls.ttvnw.net>               # Twitch Stream Server
* <https://usher.ttvnw.net>               # Twitch Stream Server
* <https://gql.twitch.tv>                 # Twitch Stream Access
* <https://id.twitch.tv>                  # Twitch Login
* <https://static-cdn.jtvnw.net>          # Twitch Emotes
* <https://cdn.betterttv.net>             # BetterTTV Emotes
* <https://api.twitch.tv>                 # Twitch API
* <https://badges.twitch.tv>              # Badges for Chat
* <https://api.betterttv.net>             # BetterTTV Emotes
* <irc.chat.twitch.ttv:6667>              # Twitch Chat

## Message from the repo owner

If you work at Twitch, go make a twitch app so I dont have to. If you want this one you can have it.

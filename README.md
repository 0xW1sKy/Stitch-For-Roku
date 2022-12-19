# 🔮 Stitch (for Roku)

An Improvable™ Twitch app for Roku. Still buggy, so feel free to suggest improvements (and code and features). U

Also, the original devs have not been very active with this project recently.
So if you can contribute, please do.

Issues, Feature Requests, Etc should all be done via github issues for public tracking.

## Support

Best way to support Stitch is interaction with this project. Contributions are welcome.

## How to Install

### With Access Code

Stitch *uncertified* : LL5GKQ (<https://my.roku.com/account/add?channel=LL5GKQ>)

### Manual Developer Install

1. [Enable developer mode for Roku](https://blog.roku.com/developer/developer-setup-guide)

2. Log into your Roku from your browser using IP from previous step (http://192.168.x.x)

3. ZIP (into a ZIP file) all contents of this repo (you do not have to include README.md) (using 7-Zip, WinRAR, etc.). Do not include extra top level directories in the ZIP file, otherwise you may get the error: "```Install Failure: No manifest. Invalid package.```". Alternatively, you can download this ZIP file from the releases section.

4. Upload previous ZIP file in Roku Development Application Installer (step 2)

5. Press Install

6. Stitch should now be installed on your Roku. You should see it at the end of your channel list

## Notable Unsupported Features

* Ad-blocking
* View-As-User (removal of ads via subscription/etc)

## URLs used by app (may need to be allowed in pihole, etc)

* <https://*.hls.ttvnw.net>               # Twitch Stream Server
* <https://usher.ttvnw.net>               # Twitch Stream Server
* <https://gql.twitch.tv>                 # Twitch Stream Access
* <https://id.twitch.tv>                  # Twitch Login
* <https://cdnjs.cloudflare.com>          # BootStrap for Web Auth
* <https://vod-secure.twitch.tv>          # Missing VOD Image
* <https://static-cdn.jtvnw.net>          # Twitch Emotes
* <https://cdn.betterttv.net>             # BetterTTV Emotes
* <https://api.twitch.tv>                 # Twitch API
* <https://badges.twitch.tv>              # Badges for Chat
* <https://api.betterttv.net>             # BetterTTV Emotes
* <irc.chat.twitch.ttv:6667>              # Twitch Chat
* <https://twitch.k10labs.workers.dev>    # Stream Broker
* <https://oauth.k10labs.workers.dev>     # Authentication Broker

## Message from the repo owner

Hey There.

I'm not a roku developer, so you might see some weird stuff in this repo. Feel free to submit a PR to fix/improve it!
there are a couple of folders like [hls_processor](./hls_processor/) and [oauth](./oauth/) that are [CloudFlare Workers](https://workers.cloudflare.com) Functions allowing the web services to be serverless in nature as well as highly performant by distribution via their CDN. Additionally, by handling this part of the service properly, I should be able to keep this as something that doesnt personally cost me money to host for others. If anything starts costing money, I'll let you know.

If you have a more dedicated team interested in maintaining this end to end, open an issue regarding that and I will reach out to you to discuss options. I'm currently maintaining this repo as the original project that this is forked from [Twoku](https://github.com/worldreboot/twitch-reloaded-roku) was the #1 watched thing in my household, and I needed the ability to more easily fix bugs and add new features. Additionally, I wanted to have more development/improvment efforts happening publically and collaboratively via github's contribution systems.

## FAQ

Please see our FAQ [here](./FAQ.md)

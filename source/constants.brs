' Set global constants
sub setConstants()
    globals = m.screen.getGlobalNode()

    ' Set Global Constants
    globals.addFields({
        constants: {
            colors: {
                muted: {
                    black: "0x020202FF"
                    ice: "0xd6e4ffFF"
                    cupcake: "0xffa3eeFF"
                    min: "0x5cffbeFF"
                    sky: "0x7aa7ffFF"
                    blush: "0xffcdccFF"
                    canary: "0xebeb00FF"
                    smoke: "0xd3d3d9FF"
                    lavender: "0xd1b3ffFF"
                    mustard: "0xffd37aff"
                    emerald: "0x00f593ff"
                    coral: "0xff8280ff"
                    ocean: "0x1345aaff"
                }
                accent: {
                    twitch: "0x9147ffFF"
                    grape: "0x5c16c5ff"
                    dragonfruit: "0xff38dbff"
                    carrot: "0xe69900ff"
                    sun: "0xebeb00ff"
                    lime: "0x00f593ff"
                    turquoise: "0x00f0f0ff"
                    eggplant: "0x451093ff"
                    wine: "0xae1392ff"
                    slime: "0x00f593ff"
                    seafoam: "0x5cffbeff"
                    cherry: "0xeb0400ff"
                    marine: "0x1f69ffff"
                    seaweed: "0x00a3a3ff"
                    pebble: "0x848494ff"
                    moon: "0xefeff1ff"
                    fiji: "0x5cffbeff"
                    blueberry: "0x1f69ffff"
                    arctic: "0x00f0f0ff"
                    highlighter: "0xf5f500ff"
                    flamingo: "0xff38dbff"
                    ruby: "0xeb0400ff"
                    punch: "0xffcdccff"
                    creamsicle: "0xffd37aff"
                }
                twitch: {
                    purple: "0x9147ffff"
                    purple1: "0x040109ff"
                    purple2: "0x0d031cff"
                    purple3: "0x15052eff"
                    purple4: "0x24094eff"
                    purple5: "0x330c6eff"
                    purple6: "0x451093ff"
                    purple7: "0x5c16c5ff"
                    purple8: "0x772ce8ff"
                    purple9: "0x9147ffff"
                    purple10: "0xa970ffff"
                    purple11: "0xbf94ffff"
                    purple12: "0xd1b3ffff"
                    purple13: "0xe3d1ffff"
                    purple14: "0xede0ffff"
                    purple15: "0xf3ebffff"
                }
                hinted: {
                    grey1: "0x0e0e10ff"
                    grey2: "0x18181bff"
                    grey3: "0x1f1f23ff"
                    grey4: "0x26262cff"
                    grey5: "0x323239ff"
                    grey6: "0x3b3b44ff"
                    grey7: "0x53535fff"
                    grey8: "0x848494ff"
                    grey9: "0xadadb8ff"
                    grey10: "0xc8c8d0ff"
                    grey11: "0xd3d3d9ff"
                    grey12: "0xdedee3ff"
                    grey13: "0xe6e6eaff"
                    grey14: "0xefeff1ff"
                    grey15: "0xf7f7f8ff"
                }
                transparent: "0x00000000"
                opac: {
                    black1: "0x0000000d" '  5%
                    black2: "0x00000014" '  8%
                    black3: "0x00000021" '  13%
                    black4: "0x00000029" '  16%
                    black5: "0x00000038" '  22%
                    black6: "0x00000047" '  28%
                    black7: "0x00000066" '  40%
                    black8: "0x00000080" '  50%
                    black9: "0x00000099" '  60%
                    black10: "0x000000b3" ' 70%
                    black11: "0x000000bf" ' 75%
                    black12: "0x000000cc" ' 80%
                    black13: "0x000000d9" ' 85%
                    black14: "0x000000e6" ' 90%
                    black15: "0x000000f2" ' 95%
                    darkgrey1: "0x53535f61" ' 38%
                    darkgrey2: "0x53535f7a" ' 48%
                    darkgrey3: "0x53535f8c" ' 55%
                    darkgrey4: "0x3232399e" ' 62%
                    darkgrey5: "0x323239f2" ' 95%
                    lightgrey1: "0xadadb838" ' 22%
                    lightgrey2: "0xadadb859" ' 35%
                    lightgrey3: "0xadadb86e" ' 43%
                    lightgrey4: "0xdedee366" ' 40%
                    lightgrey5: "0xdedee3f2" ' 95%
                    white1: "0xFFFFFF0d" '  5%
                    white2: "0xFFFFFF14" '  8%
                    white3: "0xFFFFFF21" '  13%
                    white4: "0xFFFFFF29" '  16%
                    white5: "0xFFFFFF38" '  22%
                    white6: "0xFFFFFF47" '  28%
                    white7: "0xFFFFFF66" '  40%
                    white8: "0xFFFFFF80" '  50%
                    white9: "0xFFFFFF99" '  60%
                    white10: "0xFFFFFFb3" ' 70%
                    white11: "0xFFFFFFbf" ' 75%
                    white12: "0xFFFFFFcc" ' 80%
                    white13: "0xFFFFFFd9" ' 85%
                    white14: "0xFFFFFFe6" ' 90%
                    white15: "0xFFFFFFf2" ' 95%
                    purple1: "0x5c16c50d" '  5%
                    purple2: "0x5c16c514" '  8%
                    purple3: "0x5c16c521" '  13%
                    purple4: "0x5c16c529" '  16%
                    purple5: "0x5c16c538" '  22%
                    purple6: "0x5c16c547" '  28%
                    purple7: "0x5c16c566" '  40%
                    purple8: "0x5c16c580" '  50%
                    purple9: "0x5c16c599" '  60%
                    purple10: "0x5c16c5b3" ' 70%
                    purple11: "0x5c16c5bf" ' 75%
                    purple12: "0x5c16c5cc" ' 80%
                    purple13: "0x5c16c5d9" ' 85%
                    purple14: "0x5c16c5e6" ' 90%
                    purple15: "0x5c16c5f2" ' 95%
                }
                orange1: "0x050301FF"
                orange2: "0x090601FF"
                orange3: "0x120d02FF"
                orange4: "0x251a04FF"
                orange5: "0x372706FF"
                orange6: "0x453008FF"
                orange7: "0x65470bFF"
                orange8: "0x7c570eFF"
                orange9: "0x9e6900FF"
                orange10: "0xc28100FF"
                orange11: "0xe69900FF"
                orange12: "0xffb31aFF"
                orange13: "0xffd37aFF"
                orange14: "0xffdf9eFF"
                orange15: "0xffebc2FF"
                yellow1: "0x050501FF"
                yellow2: "0x090901FF"
                yellow3: "0x0e0e02FF"
                yellow4: "0x1c1c03FF"
                yellow5: "0x292905FF"
                yellow6: "0x373706FF"
                yellow7: "0x4e4e09FF"
                yellow8: "0x60600bFF"
                yellow9: "0x7a7a00FF"
                yellow10: "0x949400FF"
                yellow11: "0xadad00FF"
                yellow12: "0xc7c700FF"
                yellow13: "0xe0e000FF"
                yellow14: "0xebeb00FF"
                yellow15: "0xf5f500FF"
                green1: "0x010503FF"
                green2: "0x010906FF"
                green3: "0x02120cFF"
                green4: "0x042015FF"
                green5: "0x063221FF"
                green6: "0x074029FF"
                green7: "0x0a5738FF"
                green8: "0x016b40FF"
                green9: "0x018852FF"
                green10: "0x00a865FF"
                green11: "0x00c274FF"
                green12: "0x00db84FF"
                green13: "0x00f593FF"
                green14: "0x5cffbeFF"
                green15: "0xa8ffdcFF"
                cyan1: "0x010505FF"
                cyan2: "0x010909FF"
                cyan3: "0x021212FF"
                cyan4: "0x042020FF"
                cyan5: "0x052e2eFF"
                cyan6: "0x073c3cFF"
                cyan7: "0x095353FF"
                cyan8: "0x0c6a6aFF"
                cyan9: "0x018383FF"
                cyan10: "0x00a3a3FF"
                cyan11: "0x00b8b8FF"
                cyan12: "0x00d6d6FF"
                cyan13: "0x00f0f0FF"
                cyan14: "0x2effffFF"
                cyan15: "0x94ffffFF"
                blue1: "0x010205FF"
                blue2: "0x020712FF"
                blue3: "0x040d20FF"
                blue4: "0x071a40FF"
                blue5: "0x0a255cFF"
                blue6: "0x0d3177FF"
                blue7: "0x1345aaFF"
                blue8: "0x1756d3FF"
                blue9: "0x1f69ffFF"
                blue10: "0x528bffFF"
                blue11: "0x7aa7ffFF"
                blue12: "0xa3c2ffFF"
                blue13: "0xc7daffFF"
                blue14: "0xd6e4ffFF"
                blue15: "0xe5eeffFF"
                magenta1: "0x050104FF"
                magenta2: "0x12020fFF"
                magenta3: "0x20041bFF"
                magenta4: "0x37062eFF"
                magenta5: "0x4e0941FF"
                magenta6: "0x650b55FF"
                magenta7: "0x8a0f73FF"
                magenta8: "0xae1392FF"
                magenta9: "0xc516a5FF"
                magenta10: "0xff38dbFF"
                magenta11: "0xff75e6FF"
                magenta12: "0xffa3eeFF"
                magenta13: "0xffc7f5FF"
                magenta14: "0xffd6f8FF"
                magenta15: "0xffe5faFF"
                red1: "0x050101FF"
                red2: "0x120202FF"
                red3: "0x200404FF"
                red4: "0x3c0807FF"
                red5: "0x530a09FF"
                red6: "0x6e0e0cFF"
                red7: "0x971311FF"
                red8: "0xbb1411FF"
                red9: "0xeb0400FF"
                red10: "0xff4f4dFF"
                red11: "0xff8280FF"
                red12: "0xffaaa8FF"
                red13: "0xffcdccFF"
                red14: "0xffdcdbFF"
                red15: "0xffe6e5FF"
                third_party: {
                    twitter: "0x1da1f2ff"
                    facebook: "0x3b5998ff"
                    reddit: "0xff4500ff"
                    snapchat: "0xfffc00ff"
                    instagram: "0x405de6ff"
                    youtube: "0xcd201fff"
                    paypal: "0x009cdeff"
                    paypalblue: "0x009cdeff"
                    paypalyellow: "0xfcc439ff"
                    venmo: "0x008cffff"
                    vk: "0x45668eff"
                    amazon: "0xfad677ff"
                    primeblue: "0x0e9bd8FF"
                }
                status: {
                    error: "0xeb0400FF"
                    warn: "0xffd37aFF"
                    success: "0x00f593FF"
                    info: "0x1f69ffFF"
                }
                darker: {
                    red: "0xbb1411FF"
                    green: "0x00ad96FF"
                }
                white: "0xffffffFF"
                black: "0x000000FF"
                red: "0xe91916FF"
                orange: "0xffd37aFF"
                yellow: "0xffd37aFF"
                green: "0x00f593FF"
                blue: "0x1f69ffFF"
                magenta: "0xc53dffFF"
            }
            icons: {
                arrow_down: "pkg:/images/icons/chevron-up.png",
                arrow_up: "pkg:/images/icons/chevron-down.png",
                back: "pkg:/images/icons/reply.png",
                login: "pkg:/images/icons/sign-in.png",
                messages: "pkg:/images/icons/comments.png",
                options: "pkg:/images/icons/sliders.png",
                pause: "pkg:/images/icons/pause.png",
                play: "pkg:/images/icons/play.png",
                search: "pkg:/images/icons/search.png",
                time_travel: "pkg:/images/icons/clock.png",
            }
        }
    })
end sub
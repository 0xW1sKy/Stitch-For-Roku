$pat = @{
    operationName = "PlaybackAccessToken"
    extensions    = @{
        persistedQuery = @{
            version    = 1
            sha256Hash = "0828119ded1c13477966434e15800ff57ddacf13ba1911c129dc2200705b0712"
        }
    }
    variables     = @{
        isLive     = $true
        login      = "hasanabi"
        isVod      = $false
        vodID      = ""
        playerType = "frontpage"
    }
} | ConvertTo-Json -Depth 100
$playbackaccesstoken = $(get-twitchgql $pat).data.streamPlaybackAccessToken
$id = "hasanabi"
$localHeaders = @{
    "client-id"     = "kimne78kx3ncx6brgo4mv6wki5h1ko"
    "accept"        = "application/x-mpegURL, application/vnd.apple.mpegurl, application/json, text/plain"
    "authorization" = "OAuth uk5seeh033g141pr69vdw7f8s1y0b7"
}
$schema = @'

'@


$test = "https://usher.ttvnw.net/api/channel/hls/$id.m3u8?" `
    + "client_id=$($localheaders["client-id"])" `
    + "&token=$($playbackaccessToken.value)" `
    + "&sig=$($playbackaccessToken.signature)" `


$resb = Invoke-RestMethod -Uri $test -Headers $localHeaders

# var headers = {
#             'Client-id': clientId
#         }
# let response = await fetch(uri, {
#         method: 'GET', // or 'PUT'
#         headers: globalHeaders,
#     }).then(processChunkedResponse)
# return String(response)

# }
# console.log(res)
# try{
#     if (isVod) {
#         return res.data.videoPlaybackAccessToken
#     } else {
#         return res.data.streamPlaybackAccessToken
#     }
# }catch{
#     return res
# }

function get-twitchgql($body) {

    $localHeaders = @{
        "client-id"     = "kimne78kx3ncx6brgo4mv6wki5h1ko"
        "accept"        = "*/*"
        "authorization" = "OAuth uk5seeh033g141pr69vdw7f8s1y0b7"
    }

    return Invoke-RestMethod -Uri "https://gql.twitch.tv/gql" -Method Post -Headers $localHeaders -Body $body
}


$body = '[{"operationName":"updateUserViewedVideo","variables":{"input":{"userID":"116527123","position":29430,"videoID":"40194805512","videoType":"LIVE"}},"extensions":{"persistedQuery":{"version":1,"sha256Hash":"bb58b1bd08a4ca0c61f2b8d323381a5f4cd39d763da8698f680ef1dfaea89ca1"}}}]'





$pat = @{
    operationName = "PlaybackAccessToken"
    extensions    = @{
        persistedQuery = @{
            version    = 1
            sha256Hash = "0828119ded1c13477966434e15800ff57ddacf13ba1911c129dc2200705b0712"
        }
    }
    variables     = @{
        isLive     = $true
        login      = "hasanabi"
        isVod      = $false
        vodID      = ""
        playerType = "roku"
    }
} | ConvertTo-Json -Depth 100
get-twitchgql $pat




$query = "hasanabi"
$searchBody = @{
    "operationName" = "SearchResultsPage_SearchResults"
    "variables"     = @{
        "query" = "$query"
    }
    "extensions"    = @{
        "persistedQuery" = @{
            "version"    = 1
            "sha256Hash" = "6ea6e6f66006485e41dbe3ebd69d5674c5b22896ce7b595d7fce6411a3790138"
        }
    }
}
get-twitchgql $searchBody


$various = @'

  {
    "operationName": "Consent",
    "variables": {
      "id": "388774b2-e939-4b7f-9004-6d2dd20fc126",
      "includeNewCookieConsentFields": true,
      "includeTCData": true
    },
    "extensions": {
      "persistedQuery": {
        "version": 1,
        "sha256Hash": "d6ccab80d28a5b199d5f8a9c3e3b2673e524b925d8e40912fd2d12a781cfb76c"
      }
    }
  },
  {
    "operationName": "Ads_Components_AdManager_User",
    "variables": {},
    "extensions": {
      "persistedQuery": {
        "version": 1,
        "sha256Hash": "1fd9eeac7ab98004ee00dc6554e88759f1fa66ea94b97487f69b1ddf3a9d215b"
      }
    }
  },
  {
    "operationName": "Prime_PrimeOffers_CurrentUser",
    "variables": {},
    "extensions": {
      "persistedQuery": {
        "version": 1,
        "sha256Hash": "a773b7efefe390d49753520f7db73d03794b008af6acc22c06a2c630d46d5518"
      }
    }
  },
  {
    "operationName": "UserMenuCurrentUser",
    "variables": {},
    "extensions": {
      "persistedQuery": {
        "version": 1,
        "sha256Hash": "3cff634f43c5c78830907a662b315b1847cfc0dce32e6a9752e7f5d70b37f8c0"
      }
    }
  },
  {
    "operationName": "TopNav_CurrentUser",
    "variables": {},
    "extensions": {
      "persistedQuery": {
        "version": 1,
        "sha256Hash": "80c8ad4839b2922ac5ea7a6e38d8c88ab4c0462cf1c7f2d4d86542736ff3f916"
      }
    }
  },
  {
    "operationName": "PersonalSections",
    "variables": {
      "input": {
        "sectionInputs": [
          "RECS_FOLLOWED_SECTION",
          "RECOMMENDED_SECTION"
        ],
        "recommendationContext": {
          "platform": "web",
          "clientApp": "twilight",
          "channelName": null,
          "categoryName": null,
          "lastChannelName": null,
          "lastCategoryName": null,
          "pageviewContent": null,
          "pageviewContentType": null,
          "pageviewLocation": null,
          "pageviewMedium": null,
          "previousPageviewContent": null,
          "previousPageviewContentType": null,
          "previousPageviewLocation": null,
          "previousPageviewMedium": null
        }
      },
      "creatorAnniversariesExperimentEnabled": false,
      "sideNavActiveGiftExperimentEnabled": false
    },
    "extensions": {
      "persistedQuery": {
        "version": 1,
        "sha256Hash": "469b047f12eef51d67d3007b7c908cf002c674825969b4fa1c71c7e4d7f1bbfb"
      }
    }
  },
  {
    "operationName": "DropCurrentSessionContext",
    "variables": {},
    "extensions": {
      "persistedQuery": {
        "version": 1,
        "sha256Hash": "2e4b3630b91552eb05b76a94b6850eb25fe42263b7cf6d06bee6d156dd247c1c"
      }
    }
  }
]
'@



$integrityToken = "https://gql.twitch.tv/integrity"
$method = "Post"
$headers = @{
    "authorization" = "oauth"
    "X-Device-Id"   = "lguloVHccQYVI6zAxb05SjoUWcZ2AhDJ"
    "client-id"     = "client"
}
$response = @'
{
    "token": "v4.public.eyJjbGllbnRfaWQiOiJraW1uZTc4a3gzbmN4NmJyZ280bXY2d2tpNWgxa28iLCJjbGllbnRfaXAiOiIxMDcuNzcuMjA3LjE1NSIsImRldmljZV9pZCI6ImxndWxvVkhjY1FZVkk2ekF4YjA1U2pvVVdjWjJBaERKIiwiZXhwIjoiMjAyMi0xMi0xOVQxNDowMDo1NloiLCJpYXQiOiIyMDIyLTEyLTE4VDIyOjAwOjU2WiIsImlzX2JhZF9ib3QiOiJmYWxzZSIsImlzcyI6IlR3aXRjaCBDbGllbnQgSW50ZWdyaXR5IiwibmJmIjoiMjAyMi0xMi0xOFQyMjowMDo1NloiLCJ1c2VyX2lkIjoiMTE2NTI3MTIzIn06lXY5aJ0EoOMXFyLVjNB8kD60n2Fcvop5xAO_JTTYSOxoZxmMQVDzmpyMel0cEADzm25p6_WpQMKDEeuK6VkI",
    "expiration": 1671458456642,
    "request_id": "01GMKM2720XT6FMRD9ZGKMV0Z0"
}
'@

@'
🔰: $resb
#EXTM3U
#EXT-X-TWITCH-INFO:
    NODE="video-edge-dc3ca6.ord56",
    MANIFEST-NODE-TYPE="weaver_cluster",
    MANIFEST-NODE="video-weaver.ord03",
    SUPPRESS="true",
    SERVER-TIME="1671400638.09",
    TRANSCODESTACK="2017TranscodeQS_V2",
    USER-IP="107.77.207.155",
    SERVING-ID="84650f700cc748a7a795f24edcd0ebf1",
    CLUSTER="ord56",
    ABS="false",
    VIDEO-SESSION-ID="3926827536944911852",
    BROADCAST-ID="41623397387",
    STREAM-TIME="8912.086118",
    B="false",
    USER-COUNTRY="US",
    MANIFEST-CLUSTER="ord03",
    ORIGIN="pdx05",
    C="aHR0cHM6Ly92aWRlby1lZGdlLTgwNDg0ZS5wZHgwMS5hYnMuaGxzLnR0dm53Lm5ldC92MS9zZWdtZW50L0NvS0Iya25rSzNZaUktTENwOEdDNkJMd3BSdHVmcTBOTVdhbnVtV1RkclRwVXRXb25CRlVHRUdnQjJFLXljLWdXVHUxWkZzc2djcWcxUTl5QlZmZkh6MzZUT2szX09kdS1mLWRSU2ZrY3pBeEFwdXJDckhnZ2Zlb2E0dVN6QjhMSm9qQW8yVWhYZFV1U1lMUFBMRDkzTnFzWnVPZGZpejVfcnh4WU9vdHFLRWlOdFI1UHhJSjZkYmtoTE81TE91dWM4QXg2S0ZSMmcycDdjanNJUVR3S1hvRG02RE10STFUZGp2dzJvMDRKYmhYM3AtTnJJcVUtVWRxYjdDblFseEY0WmJCdnNDWS1FUlc1WVBEVkVmWHR3Y1Yzem5ycHhSTlVxRWlWWlpCSEx3Z25NTVNqTkpldlZvczFzQWY4LXBTRnJKOThIOG82LTdpN3hsMDE2TFh4WkxFc1JVNWg3bWlmX3gxRU9oSEtEOGIxcEhFTHh0dk80LWlHQVlRZzlmdXl4R2FkbXo5QTN2RUpPVUFRYjltdmI0Tjd1QzhJY3hXTkxwZXY1T0xuNEhXTlZ1aGFCQmJvODNQeEUyQkdvSU5VOUIxMWJOcWhpaHQxVkJ0T2lXeFBtZ3E0d1ZMeGt6VTBwc0dTRzJnRzdKVk1FclB3N0tzVWJBV0NnWFo3UzFhSkYtWFJ5c1AyWnNlYUZEU3FCcVY1S1lkN1hIVVItaVRNdlFOTUVTd2hSaXQzMHdhM3RUQlc4VExuR2lXTlRSYzB6a1lGV3BkYmlHc3NWUWluUVltRjRYMktnRDFyTTlOUE9Oa0o4NWxkYldxMU5xQnY1cThSOHFaQ2JIYm9WUFUyeU8zUlJpb2Jxb3F4V05MejVaNG5LOEI4Vkl0aVdncWxubml4SnpqM1FXQXBpd2QyVHNza3VtTmJrRTFGdjB4OWVvY3R2U1l5R2lLRk5POXpTY09BV3V1cXE0OXBSMmQ0eFpQXzU3YVdXVTVmbGlEaUxicGNpUXdabEdpdm11bG0xODJaNHFHLVpONm9pOUpGRVlvTVZiUDQudHM",
    D="false"
#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="chunked",NAME="1080p60 (source)",AUTOSELECT=YES,DEFAULT=YES
#EXT-X-STREAM-INF:BANDWIDTH=6848504,RESOLUTION=1920x1080,CODECS="avc1.64002A,mp4a.40.2",VIDEO="chunked",FRAME-RATE=60.000
https://video-weaver.ord03.hls.ttvnw.net/v1/playlist/CpYELv-pMaPW-0im8UxyI4HEX6soWRwnx_XUp3aNu83U6ENQjmY1GD4iKb5lCoKHTs8ejHen99bcDvGZUjVduuo5m-1AhELZhZ-f8yofaVsVuyszRSE_6imYxBYdmH_EWEcyUTJwrgiErn7GEJKsPADBjP9brFnNXqEBd4dnucuNX7v5mi8zUcUs0A2kzurLVdW_v4CZk8r0cfkxT95Csfi6gKFcCIMZcbDjfiYZn1-NvafDCdtwKlIwkQtrbHuzLmFJ0UMguLQe6czQoVM2zp4JJ3vrQsE_IFcTpsjo51h7xzfaPNFtf93fiQOJT_1AL6xa5P8CUgTacThrSLzFsHD2uGz3hGzOJkAjU9G8uN_famxtuu9GdJESPRzD35kQTs9IKZ2EQAJmBRENfp1egvkqACQNyq1POvMhg-jkdJSZUCLg2viKmK-LkvSMjWoT3AyqRKNPHnMkEqqPhMiRpF74cvdw91Mw7krD6arjIGj_X_-ai4Qj0SkW4lEchckZcy3fIsd1yvOd-0flqZMgp5lFjh8CgoY79t60-sbfIWqhPQc6lYjv56GXAGt8uouZhsGInl5iq4Wp7cc1DS2nygcMmdGbfdM1X0wppzbVF_fz9a5Cbrg_6RC08GtK-iNWVwD0GHU_eJjV8iiWFMLC56L3Hr6vAn8MW0G4wsQrM-lFIc0PXdL_4tyVqEHY0QKo09hNxldgQYNGGgwuFfzSWFHroTokoKUgASoJdXMtd2VzdC0yMLUF.m3u8
#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="720p60",NAME="720p60",AUTOSELECT=YES,DEFAULT=YES
#EXT-X-STREAM-INF:BANDWIDTH=3422999,RESOLUTION=1280x720,CODECS="avc1.4D401F,mp4a.40.2",VIDEO="720p60",FRAME-RATE=60.000
https://video-weaver.ord03.hls.ttvnw.net/v1/playlist/CpQEy9GAXGItP-hjEQJqUN_xuJ9UWkfUv6t0HV8Vyt1jmJDUhDpgGEHa_Eqwt09TJKbW1fm87e3zopRLJI9nZWzFS2lp2FBCWu-tXzTB9SiRISqeDk2JSXsuTIcDuYRi1Ida3TZ_C8xgqSAw66oXYRgdxBErni21pd8Br9THkOtyfHMuTke6fO2mmHiPAyhwKIES0c6wIkOnARfr4_QScrU25z_SyrH8H02aXBs_PXsAnvAo3zJ--iLfHGQLuohDNqA7ANfk7REZNqPNLmNDiG9hQdZ1Rvo2BY_U_uiaDC5T-43GZHu5TGt11eC-Om1nSZmKKsQ9lYyYh4WZXnboSFNvGERQUhai8FNGrFcUeHnKZU19UMcCwCOSS-pJduWzISvZxd5TzE3bdLOI0f-KNbXVyIPHkKsboidcAHu7zds1qjypJCxjBkfBR-izEjOhE8726QEKROhLXYorwWOcUkDXN3DKeGyynZvQ5LsDWfbsRciGoho-cc0fx8PvqC1mOJ5Fiu4xLqgFqE2cQEOvmf3jIjRSE3yoJQKiNei-PG8SQWbbTVwDKE7z2f1Lmnc3uE6eAirZTx6vIzGiXFmSh4xigf7YEjWVGSkGA2YMTfQg3nJZSLAt7z0D4Iy--v0FNxK64kVS81tlAiSAXJwAIGbZy501aiRLlZOi6YZfwQ6PiCCAmbZhFks2kxtKSqWOMSCCSqPTiBoMvBPp9_OmmlmU9YQ_IAEqCXVzLXdlc3QtMjC1BQ.m3u8
#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="480p30",NAME="480p",AUTOSELECT=YES,DEFAULT=YES
#EXT-X-STREAM-INF:BANDWIDTH=1427999,RESOLUTION=852x480,CODECS="avc1.4D401F,mp4a.40.2",VIDEO="480p30",FRAME-RATE=30.000
https://video-weaver.ord03.hls.ttvnw.net/v1/playlist/CpQEWIkpcPE7xEq7b-TgJVmIjzmJIbrDXK8R7c2QMVcJuc9hXKmWtVqTS4EPodRfgFr2_Of3sPTSIeBQ6QEZhwFXWOnXOwdVUgRwsBhNlke4z0ccTZGVBZzxmCetObR3WNND8b2FoyHyg5TbRiPaBQYGOEW0yr7125K08LOHTyDfA0Ln5hqlaq3TIPAtsLMTQYvI0hgWsjT1wYcas5Pgq6hOpIcSVPtHPFmb8JFeR9zSX352on3vCwI1L1GYYCTNI_8-oRn4tjz6kF9OyW4sbKvRky7CIAfJgXSnMv9ANXu9z-TcDUlsqW0lb7u6_IAoRnO8dYwwZqWWcRa5lH6bIJaKTapBBDwLRSu4T3YD5o2u6ceJMTBdMtdxMAvwHkQfgyMY2RX1BF2SqMw0x5TeqnscIg8H1x5Ly4LTlYHZF8a0kH3OPLFMOoyICatkhw1ij4UMDFLBG-mvtZWQvHYB8ST8i3QCexVTS11OoF1eCP-_AokUjQm90H0ZK3WKp9eY-8_cqU3_1SD4BHbWeZ89PSS0q6f8pZKDrVcp-CxH9pV7oeLbW9y4wAt9Ym-i_AtXQ_LdQgu7s5BAyYza1imydwJSR7BGqECIGZam25Kk5lq4xgjWg5wTk4u3Buip1ArU-BdcO-h_CVvQdAcobOQR-7bsXvQezb7ZRAsAS-iVYLfKBDcaQEb9ZeV0iZ3MbKRsaeZ88rhDaBoMyc4bX8LBpi5RDWQQIAEqCXVzLXdlc3QtMjC1BQ.m3u8
#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="360p30",NAME="360p",AUTOSELECT=YES,DEFAULT=YES
#EXT-X-STREAM-INF:BANDWIDTH=630000,RESOLUTION=640x360,CODECS="avc1.4D401F,mp4a.40.2",VIDEO="360p30",FRAME-RATE=30.000
https://video-weaver.ord03.hls.ttvnw.net/v1/playlist/CpQEPADqvQat88lzzt9tpNTeg15josMFb8yYeR2yYdeWkBUcLu7HjGyUVCvMiRxws7AOLZDtRbQKGiYQlcnaEx8UA6oBfz2Fr-cJU_A7kIsMBVZJ5C4ZgyTekA4JHJ89u3iMEvINM-2LAPLsTIpwk_R7pCYSuXzhvDcpFKPn7WY7_aNtXZdj_TSXUQPDGDpBrsw9KhkxdQX2ZOlYot6zFzgEN6PFCQUx1Rc3OQygASI28rNMVyxZxBqHjBcS0dPtB07DVy4tiZ7L9ZPsEf6aStvPvSR3xxK3dDRRUKL1oQMD5ITwCtooIWPMX9v82gNPT-sfXms-q-hxHulOQG_2bjosE6FRBu61WR7scA87_dS8mlf7ftThk0vLQQWCXXv6HsAAP0IUjX03gamDFWT87KHxmHoS8VfEKSrOnGMqI_RNin2qOKI2X1BLY0N50Oonyai1lNJ7c38J0ta4SBPJxhANbErfs0j_CZzLtMxdzEXJfJAc1QkfYPpWdlsC0Sa2MofaLBFXR5LdiMw_tqeh8jL7t_vei7Zeua0OOA8mbawNwsftFhU5T_hkCZHMUGLzeQf03zOb_aayO84vq4Y5cV5FNIeV7ALwW1Y_Idh3pZ_nxMqx0YQ6L3WZCRMYRblzXJwiWyhqeT62qchJtiOG1gniFw02vli_5J8Fr6QjolWp1qiR7PHfXjgV6jsGS6_88G3tFPIt9hoM7w8Tav0zzanrloX4IAEqCXVzLXdlc3QtMjC1BQ.m3u8
#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="160p30",NAME="160p",AUTOSELECT=YES,DEFAULT=YES
#EXT-X-STREAM-INF:BANDWIDTH=230000,RESOLUTION=284x160,CODECS="avc1.4D401F,mp4a.40.2",VIDEO="160p30",FRAME-RATE=30.000
https://video-weaver.ord03.hls.ttvnw.net/v1/playlist/CpQEPXt0KQccdGt5dVYrW_hb49Vsqb5pEYEuyPgBzQc1EEXbTK8pZBqEzGY8FJnNAqjC0GitkClodjC8tFuotivHFr0YaBDxzJL5WgJbl8c7IenwBhm-k8LStWdqIHReMCj_XDdQh3e5d6Z5b6nrd8I7upqy5vxayAycSXlqIw5UpU21Lk-t7xPEtiSxmHS5GYj2SP89USDRbhiFHG90g3rDpXSyFAHHq46q3s8-76_12puX-aOZw8NgIGSylIL6GADyVdDddUOP3hnqt7-UTls-IBrk214YfUMUjZAcQUAlIhhN85FoUfZ_5ZM47-CqnXfTX3QwOFQoozIkS4O_TSIv6WAigoDg4h8kd_gLFti-3nsxvwxl0Ln0EPZAt2O6sGHabv8ZZeMzcXCXzn8g49HxYBY7dvgEnqnnIDdPLTuRfPYBQm8qQ02pO3Q994NVks6TwkR-3PKhFDZDkPA7YF2Liy8FCa5XUm0_O9AndwK0onQu0i3ahqpzzjXgRUggaAXqrzeIuXwqP5U9a8xJcqxy3j6Fh4boF1Z7e8m_r_3u1_ad3tRZ69WcbC1yT-6fbx-xlw72faylitv3AXdxVJC_e_r54ZcKJc-yFkrDFurp8KXVw5cu0hXK0dIwOWpYKAYPc80LF9BjwRTXLzjcCSgW2MFd0ZiQJiVy07IiKTHTuTIERmPjOrpF85Zw_Pge840Hyo968RoMfMUhplQXpQ-YahcZIAEqCXVzLXdlc3QtMjC1BQ.m3u8
#EXT-X-MEDIA:TYPE=VIDEO,GROUP-ID="audio_only",NAME="audio_only",AUTOSELECT=NO,DEFAULT=NO
#EXT-X-STREAM-INF:BANDWIDTH=160000,CODECS="mp4a.40.2",VIDEO="audio_only"
https://video-weaver.ord03.hls.ttvnw.net/v1/playlist/CpYEwvOjQ34CIgr-ag_9PN8hWFpoQq_QRDWLq4XK-7MtjP7MXNgbQV5dSBp8kBFPSqalwJvRf8QfOa29IfjcKg99d7iZyZT8DgOxt5xuhRcV3s7JRzanQocNrgfWOa5vYI51JVs5QH6q2Cx9YQLyGEhJYvZsvx_kzInPeFJ34kKUpVpeHUD7mVrBFU1rNmK1L0-pX-l4wnFMZn2hm4DgGi71PZoq1L_0Xpz-nGLaUtBEBo6gVzseBFn3WE23xXoEp9d8W9VfyAuAZrszc9yMthmHyr_d2Mf6iXJyPmp1AOfQ3EMEioVekTCMrFbrSc3U823nI0G8x78IYH_mGOt7GBH5SBhLHvt9xwCApoei032G2J_94czyqdZqNLUqg9mOnvMejvnqsJKyq2Rg_fIHKcIsXuap1JAtkPN33Fvpw1MpBMPhrJoY8xvdMtARYWgk-YwcvE8WCzDI7ZZ8ZbSUxHv-NrOhIwEvr9PGQoPhc2QC4-uGxpRfFPMwzFfiQ7swPFf80Y5oWZ2dlfX5MWnGPwzA6p4tDj6AZvfswxq2_DG7JbxFnyHrwP1dhwNAkNO8I9eIBirPVxT18r6Ewfp8B95uH41QKC641Esju9AvYiUriTXWTZKgVjm_p2wGuqI6hYwNbE4iL78D4afMmTMDQ267QnT7G24MUzWsc77fXAJ4k8P9r8-mblitm0EcXzj12qjq3ecXcLCXGgx2fp1XdbJ1wSIhVVIgASoJdXMtd2VzdC0yMLUF.m3u8
'@
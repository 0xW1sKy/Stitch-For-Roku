addEventListener("fetch", (event) => {
    event.respondWith(
        handleRequest(event.request).catch(
            (err) => new Response(err.stack, { status: 500 })
        )
    );
});


async function handleRequest(request) {
    const url = request.url

    // Function to parse query strings
    function getParameterByName(name) {
        name = name.replace(/[\[\]]/g, '\\$&')
        name = name.replace(/\//g, '')
        var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
            results = regex.exec(url)

        if (!results) return null
        else if (!results[2]) return ''
        else if (results[2]) {
            results[2] = results[2].replace(/\//g, '')
        }

        return decodeURIComponent(results[2].replace(/\+/g, ' '));
    }

    var isLive = false
    if (request.headers) {
        let headersObject = Object.fromEntries(request.headers)
        if (headersObject["client-id"]) {
            if (headersObject["authorization"]) {
                clientId = headersObject["client-id"]
                authHeader = headersObject["authorization"]
            }
        }
    }
    // Usage example
    var channel = getParameterByName('streamer')
    var vodRequest = getParameterByName('vod')
        // TODO: resource = vodRequest not null ? vodrequest : channel
    var isVod = false
    var resource = channel
    var raw = true
    var rawparam = getParameterByName('json')
    if (rawparam === "true") raw = false
    if (vodRequest) {
        isVod = true
        resource = vodRequest
    }
    var searchRequest = getParameterByName('search')
    if (searchRequest) {
        clientId = "kimne78kx3ncx6brgo4mv6wki5h1ko"; // generic
        let searchResult = await getSearchResults(searchRequest)
        return new Response(searchResult, { status: 200 })
    }
    if (channel || vodRequest) {
        let accessToken = await getAccessToken(resource, isVod)
        let playlist = await getPlaylist(resource, accessToken, isVod)
        if (!raw) playlist = JSON.stringify(parsePlaylist(playlist))
        return new Response(playlist, { status: 200 })
    } else {
        return new Response("OK", { status: 200 })
    }
}
var authHeader = ""

var clientId = "kimne78kx3ncx6brgo4mv6wki5h1ko"; // generic

async function getAccessToken(id, isVod) {
    const data = {
        operationName: "PlaybackAccessToken",
        extensions: {
            persistedQuery: {
                version: 1,
                sha256Hash: "0828119ded1c13477966434e15800ff57ddacf13ba1911c129dc2200705b0712"
            }
        },
        variables: {
            isLive: !isVod,
            login: (isVod ? "" : id),
            isVod: isVod,
            vodID: (isVod ? id : ""),
            playerType: (isVod ? "embed" : "roku")
        }
    };
    var headers = {
        'Client-id': clientId
    }
    let res = await fetch('https://gql.twitch.tv/gql', {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(data),
        }).then((response) => response.json())
        // console.log(JSON.stringify(res))
    try {
        if (isVod) {
            return res.data.videoPlaybackAccessToken
        } else {
            return res.data.streamPlaybackAccessToken
        }
    } catch {
        return res
    }

}


async function getSearchResults(query) {
    const data = {
        "operationName": "SearchResultsPage_SearchResults",
        "variables": {
            "query": `${query}`
        },
        "extensions": {
            "persistedQuery": {
                "version": 1,
                "sha256Hash": "6ea6e6f66006485e41dbe3ebd69d5674c5b22896ce7b595d7fce6411a3790138"
            }
        }
    };
    let res = await fetch('https://gql.twitch.tv/gql', {
        method: 'POST',
        headers: {
            'Client-id': clientId
        },
        body: JSON.stringify(data),
    }).then((response) => response.json())
    return JSON.stringify(res)
}

async function getPlaylist(id, accessToken, vod) {
    var uri = encodeURI(`https://usher.ttvnw.net/${vod ? 'vod' : 'api/channel/hls'}/${id}.m3u8?client_id=${clientId}&token=${accessToken.value}&sig=${accessToken.signature}&allow_source=true&allow_audio_only=true&allow_spectre=true&type=any&playlist_include_framerate=true&player_backend=mediaplayer&player_type=channel_home_live`)
    let response = await fetch(uri, {
        method: 'GET', // or 'PUT'
    }).then(processChunkedResponse)
    return String(response)

}

function parsePlaylist(playlist) {
    const parsedPlaylist = [];
    const lines = String(playlist).split('\n');
    for (let i = 4; i < lines.length; i += 3) {
        parsedPlaylist.push({
            quality: lines[i - 2].split('NAME="')[1].split('"')[0],
            resolution: (lines[i - 1].indexOf('RESOLUTION') != -1 ? lines[i - 1].split('RESOLUTION=')[1].split(',')[0] : null),
            url: lines[i]
        });
    }
    return parsedPlaylist
}


function processChunkedResponse(response) {
    var text = '';
    var reader = response.body.getReader()
    var decoder = new TextDecoder();

    return readChunk();

    function readChunk() {
        return reader.read().then(appendChunks);
    }

    function appendChunks(result) {
        var chunk = decoder.decode(result.value || new Uint8Array, { stream: !result.done });
        // console.log('got chunk of', chunk.length, 'bytes')
        text += chunk;
        // console.log('text so far is', text.length, 'bytes\n');
        if (result.done) {
            //   console.log('returning')
            return text;
        } else {
            //   console.log('recursing')
            return readChunk();
        }
    }
}
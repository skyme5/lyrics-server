/*----------------------------------------------
Date: 2016/09/06
Author: sky
----------------------------------------------*/

var xmlHttp = new ActiveXObject('Msxml2.ServerXMLHTTP.6.0');

function get_my_name() {
  return 'Sky';
}

function get_version() {
  return '0.0.2';
}

function get_author() {
  return 'sky';
}

function start_search(info, callback) {
  var searchUrl = 'http://127.0.0.1:3236/search' + '?artist=' + info.Artist + '&title=' + info.Title;

  try {
    xmlHttp.open('GET', searchUrl, false);
    xmlHttp.send();
  } catch (e) {
    return;
  }

  var lyrics = callback.CreateLyric();

  if (xmlHttp.readyState === 4 && xmlHttp.status === 200) {
    var lyricsResponse = xmlHttp.responseText;
    if (lyricsResponse.length > 0) {
      lyrics.Title = info.Title;
      lyrics.Artist = info.Artist;
      lyrics.Source = get_my_name();
      lyrics.Location = searchUrl;
      lyrics.LyricText = lyricsResponse;
      callback.AddLyric(lyrics);
    }
  }
  lyrics.Dispose();
}

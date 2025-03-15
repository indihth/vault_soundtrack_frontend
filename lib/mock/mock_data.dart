import '../models/listening_history_item.dart';

class MockData {
  static List<ListeningHistoryItem> getMockListeningHistory() {
    return [
      ListeningHistoryItem(
        id: '1',
        artistName: 'The Beatles',
        songName: 'Let It Be',
        albumName: 'Let It Be',
        albumArtworkUrl:
            'https://upload.wikimedia.org/wikipedia/en/2/25/LetItBe.jpg',
      ),
      ListeningHistoryItem(
        id: '2',
        artistName: 'Queen',
        songName: 'Bohemian Rhapsody',
        albumName: 'A Night at the Opera',
        albumArtworkUrl:
            'https://upload.wikimedia.org/wikipedia/en/4/4d/Queen_A_Night_At_The_Opera.png',
      ),
      ListeningHistoryItem(
        id: '3',
        artistName: 'Pink Floyd',
        songName: 'Comfortably Numb',
        albumName: 'The Wall',
        albumArtworkUrl:
            'https://upload.wikimedia.org/wikipedia/commons/b/b1/The_Wall_Cover.svg',
      ),
      ListeningHistoryItem(
        id: '4',
        artistName: 'Led Zeppelin',
        songName: 'Stairway to Heaven',
        albumName: 'Led Zeppelin IV',
        albumArtworkUrl:
            'https://upload.wikimedia.org/wikipedia/en/2/26/Led_Zeppelin_-_Led_Zeppelin_IV.jpg',
      ),
      ListeningHistoryItem(
        id: '5',
        artistName: 'Michael Jackson',
        songName: 'Billie Jean',
        albumName: 'Thriller',
        albumArtworkUrl:
            'https://upload.wikimedia.org/wikipedia/en/5/55/Michael_Jackson_-_Thriller.png',
      ),
      ListeningHistoryItem(
        id: '6',
        artistName: 'Bob Dylan',
        songName: 'Like a Rolling Stone',
        albumName: 'Highway 61 Revisited',
        albumArtworkUrl:
            'https://upload.wikimedia.org/wikipedia/en/9/95/Bob_Dylan_-_Highway_61_Revisited.jpg',
      ),
      ListeningHistoryItem(
        id: '7',
        artistName: 'Nirvana',
        songName: 'Smells Like Teen Spirit',
        albumName: 'Nevermind',
        albumArtworkUrl:
            'https://upload.wikimedia.org/wikipedia/en/b/b7/NirvanaNevermindalbumcover.jpg',
      ),
      ListeningHistoryItem(
        id: '8',
        artistName: 'David Bowie',
        songName: 'Space Oddity',
        albumName: 'David Bowie',
        albumArtworkUrl:
            'https://upload.wikimedia.org/wikipedia/en/3/33/DavisBowieTheManWhoSoldTheWorld.jpg',
      ),
    ];
  }
}

const Map<String, String> markerIcons = {
  "accident": "assets/markers/gifs/accident.webp",
  "crash": "assets/markers/gifs/car-crash.webp",
  "fire": "assets/markers/gifs/fire.webp",

  ///
  "medical": "assets/markers/gifs/medicine.webp",
  "gun": "assets/markers/gifs/vandalism.webp",
  "protest": "assets/markers/gifs/protesters.webp",
  //
  "knife": "assets/markers/gifs/public_safty_alert.webp",
  "fight": "assets/markers/gifs/fight.webp",
  "police": "assets/markers/gifs/police1.webp",

  ///
  "floods": "assets/markers/gifs/floods.webp",
  "road-block": "assets/markers/gifs/road-block.webp",
  "storm": "assets/markers/gifs/storm.webp",

  ///
  "snow": "assets/markers/gifs/snow.webp",
  "earthquake": "assets/markers/gifs/earthquake.webp",
  "icon": "assets/markers/gifs/weather1.webp",
  "weather": "assets/markers/gifs/weather1.webp",
  // "nomarker": "assets/markers/marker-icons/no_marker.png",
  "nomarker": "assets/markers/gifs/car-crash.webp",
};

final List<Map<String, String>> alertTypes = [
  {
    'type': 'accident',
    'icon': 'assets/markers/gifs/accident.webp',
    'label': 'Accident',
  },
  {
    'type': 'crash',
    'icon': 'assets/markers/gifs/car-crash.webp',
    'label': 'Crash',
  },
  {
    'type': 'fire',
    'icon': 'assets/markers/gifs/fire.webp',
    'label': 'Fire Alert',
  },
  {'type': 'fight', 'icon': 'assets/markers/gifs/fight.webp', 'label': 'Fight'},
  {
    'type': 'knife',
    'icon': 'assets/markers/gifs/public_safty_alert.webp',
    'label': 'Safety Alert'
  },
  {
    'type': 'gun',
    'icon': 'assets/markers/gifs/vandalism.webp',
    'label': 'Vandalism'
  },
  {
    'type': 'medical',
    'icon': 'assets/markers/gifs/medicine.webp',
    'label': 'Medical',
  },
  {
    'type': 'protest',
    'icon': 'assets/markers/gifs/protesters.webp',
    'label': 'Protest',
  },
  {
    'type': 'police',
    'icon': 'assets/markers/gifs/police1.webp',
    'label': 'Police',
  },
  {
    'type': 'weather',
    'icon': 'assets/markers/gifs/weather1.webp',
    'label': 'Weather',
  },
  {
    'type': 'snow',
    'icon': 'assets/markers/gifs/snow.webp',
    'label': 'Snow',
  },
  {
    'type': 'earthquake',
    'icon': 'assets/markers/gifs/earthquake.webp',
    'label': 'Earthquake',
  },
];

final Map<String, String> burstIcons = {
  "accident": "assets/markers/bg-removed/bg-removed-accident.png",
  "crash": "assets/markers/bg-removed/bg-removed-crash.png",
  "fire": "assets/markers/bg-removed/bg-removed-fire.png",
  "medical": "assets/markers/bg-removed/bg-removed-medicine.png",
  //
  "gun": "assets/markers/bg-removed/bg-removed-vandalism.png",
  "protest": "assets/markers/bg-removed/bg-removed-protest.png",
  "knife": "assets/markers/bg-removed/bg-removed-vandalism.png",
  "fight": "assets/markers/bg-removed/bg-removed-fight.png",
  //
  "content": "assets/markers/bg-removed/bg-removed-crash.png",
  "police": "assets/markers/bg-removed/bg-removed-police.png",
  "floods": "assets/markers/bg-removed/bg-removed-flood.png",
  "storm": "assets/markers/bg-removed/bg-removed-storm.png",
  "earthquake": "assets/markers/bg-removed/bg-removed-earthquake.png",
  "road-block": "assets/markers/bg-removed/bg-removed-road-block.png",
  "snow": "assets/markers/bg-removed/bg-removed-snow.png",
};

const List<String> alertTypeFilter = [
  'Alerts',
  'Accident',
  'Crash',
  'Fire Alert',
  'Fight',
  'Safety Alert',
  'Vandalism',
  'Medical',
  'Protest',
  'Police',
  'Weather',
  'Snow',
  'Earthquake',
];

const List<String> distanceFilter = [
  // '1 mile',
  '2 miles',
  '5 miles',
  '10 miles',
  // '15 miles',
  // '20 miles',
  // '25 miles',
  // '30 miles',
  // '50 miles',
];

const List<String> categoryFilter = [
  'Category',
  'Latest',
  'Crime',
  'Event',
  'Political',
  'Celebrity',
  'Sports',
];

'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "canvaskit/canvaskit.js": "2bc454a691c631b07a9307ac4ca47797",
"canvaskit/profiling/canvaskit.js": "38164e5a72bdad0faa4ce740c9b8e564",
"canvaskit/profiling/canvaskit.wasm": "95a45378b69e77af5ed2bc72b2209b94",
"canvaskit/canvaskit.wasm": "bf50631470eb967688cca13ee181af62",
"main.dart.js": "9417a20ac4196af60ce3fbba31530b42",
"assets/AssetManifest.json": "912777ddd0f3536e6d4574be6048491f",
"assets/assets/fonts/siyuan.ttf": "ab9cd3182064e6fbf8dde157eeb1cd43",
"assets/assets/friend/1620024707620.png": "48c3dff4506ec3c4288d17741172f15a",
"assets/assets/friend/1620024706607.png": "7f9e198a3e6d7279202ba79dbf578c4a",
"assets/assets/friend/1621349049294.png": "389671b460102bd8b905e3c6c010b005",
"assets/assets/friend/1620024707399.png": "72d4eb7bbc70582dc7d02c41f44c1bc2",
"assets/assets/friend/1663247766107.png": "f6282d1ce617cc4c0d378bbf301bf6c1",
"assets/assets/friend/1620024708336.png": "f487acdc612ab494ed68608f9a3ac48f",
"assets/assets/friend/1620024708735.png": "d17f49d190e0931db9f920a1a5a22bbd",
"assets/assets/friend/1620024708528.png": "b7b4181c018a0fd28bb20e83e0f152ce",
"assets/assets/music/109951163341188750.jpg": "77b494d6a3d4bcb1ca61cfa03b2595a9",
"assets/assets/music/109951165332759683.jpg": "d65e294a2024a31d62dda72e4ecdd8cf",
"assets/assets/music/5680077069158217.jpg": "3c8ff235966f74ac93af84b200dafb9b",
"assets/assets/music/31134621.mp3": "6915b97b7dcdf7af5ec84846973182fc",
"assets/assets/music/1455200688.mp3": "26c2f9f7e16220e97decfc9aedc4f178",
"assets/assets/music/1820673129.mp3": "77e0de55dbcfea9f0820ae393b621542",
"assets/assets/music/1483391358.mp3": "aa013903eda0f409b2da33226cc48ffe",
"assets/assets/music/109951165353326032.jpg": "db22303d655a7d4d14e6c6aba86d0c7d",
"assets/assets/music/18241997416865263.jpg": "9960ca62533eb7b8ed488668ce67f419",
"assets/assets/music/109951162955989745.jpg": "526822069b803643e97838930d638b0e",
"assets/assets/music/572182643.mp3": "bdead084aaf71cbebee9d51c9d2d4a76",
"assets/assets/music/1384026889.mp3": "5fcded78c7a8df3f91e404ddbdaf226b",
"assets/assets/music/109951163256736819.jpg": "3b6ae7bfd406bae20385b6dd46db98dd",
"assets/assets/music/427606780.mp3": "796fe571db34a5793d6213d7c3a21c70",
"assets/assets/music/109951163942046079.jpg": "c6c3d25c74a981d70bbc7b4b7552a865",
"assets/assets/music/1811445719.mp3": "1c56d7f37803826b8876ad383fbd7463",
"assets/assets/music/1316330689.mp3": "4ef430aaa892444843ca59f35da557ce",
"assets/assets/music/554308724.mp3": "3c95b474b425756a52459e425e6b9b2b",
"assets/assets/music/1353301300.mp3": "6e2606ab8f0d1ca805e61cd7a262def1",
"assets/assets/music/109951164291347934.jpg": "a3acc4f11e4cb5c3957052c3bd7b8752",
"assets/assets/music/509720124.mp3": "e7400dc0d8c0e7351e4f6b660adfe2ea",
"assets/assets/music/109951165623862479.jpg": "2931b09cab4f4b78066dd9116e998f94",
"assets/assets/music/109951165731319422.jpg": "5fd78bb6af45502fd4d9fbb7293088e2",
"assets/assets/music/109951165685423491.jpg": "89dccbfa8bf08cfeb1b9a7a1a16ec628",
"assets/assets/music/20110049.mp3": "7b00f836855255459e36b057c4876be2",
"assets/assets/music/109951163036196252.jpg": "64125484c5592f57e00b4a915131d97f",
"assets/assets/music/28828074.mp3": "0090bebf70082a47588e6c91beaeaa39",
"assets/assets/music/109951165567814766.jpg": "4c5f0140a7dbdf4b95845190a3090014",
"assets/assets/img/juejin.png": "e4f98e20c16cf47e62687e4d01afc8a0",
"assets/assets/img/play_1.png": "ab7843982d217ab0ffa1ef29450eb505",
"assets/assets/img/retrofit.png": "510ea2f828ec235350204a1823f0c695",
"assets/assets/img/api_1.png": "acf11ff0bdcd9b78eaee9acf31dd01a8",
"assets/assets/img/changlu.png": "db45516660102ce479929d3cf0e6f6e7",
"assets/assets/img/wish_list.png": "2e5fcc14d0f0ce01d7c11729b5654bbd",
"assets/assets/img/room_database.png": "12f7230c70accfbdf91701f000f52758",
"assets/assets/img/pic_text.png": "0e25c49ff018216c4b2845514c427c7e",
"assets/assets/img/sleep_early.png": "8bf9bc403d04984d83062fd17afc54ed",
"assets/assets/img/kotlin_1.png": "79e75e57505c9d9f6bd27d7298594f53",
"assets/assets/img/chat_something.png": "f0cb4fe76874e5a835ce8a27c676d95b",
"assets/assets/img/handler.png": "112b31ff1270758d4309f61813800009",
"assets/assets/img/wechat_pay.png": "a2f2b42b37b353a720aa841bb1fd21c7",
"assets/assets/img/activity_start.png": "9a4f43d4ba9a6f7a103eef7e79b1e022",
"assets/assets/img/activity_start.jpg": "f16911813e2aea064a9bbd885212d8cb",
"assets/assets/img/kotlin_2.png": "06bc549c3551be9b1832315ae62fd4a0",
"assets/assets/img/data_binding.png": "7a57e06fe3d1c5e4b561f40bd1077b64",
"assets/assets/img/wechat.png": "f93e5cd8ec449e4cfc0b8371f97414fe",
"assets/assets/img/flutter_04.png": "aba419355e14a84123be52bad4f9356e",
"assets/assets/img/flutter_01.png": "04eca5a5cf95fc6fc24a53587601a76e",
"assets/assets/img/bugly.png": "a69b853aa47cbbca2c3a945dfa1cccd2",
"assets/assets/img/study_flutter.png": "3714e5aecf50aea98829c51ef365fca7",
"assets/assets/img/flutter_02.png": "407e825825d6ca4e2b6e4671d3ae9bfd",
"assets/assets/img/zongjie_2019.png": "9dc758759d0209893880d2fecd717c39",
"assets/assets/img/kotlin_4.png": "08bee753c19dc3c38a5e4164c80a9701",
"assets/assets/img/box4.png": "666ed7b0e4e90de9f2be65886ebd4155",
"assets/assets/img/flutter_03.png": "30c68ee694f153a8e96ca4fafae2902f",
"assets/assets/img/kotlin_3.png": "8bce1b30e211e137b1f29e2c13afcfdf",
"assets/assets/img/my_idea.png": "67338b884252a1fc2be773c471a3d0fa",
"assets/assets/img/view_step.png": "26c6a21b48dcd7601bd0e44048ad4057",
"assets/assets/img/lock.png": "b1c8da3b7b41c423315097f88c43279b",
"assets/assets/img/touch_event.png": "bf09a69aefa57857971cbc417b010a9e",
"assets/assets/img/2021_05_22.png": "b225b5bee0f438e530c0c021e7131328",
"assets/assets/img/guoqing_2019.png": "684191c50b526645af8e39f29f0b3627",
"assets/assets/img/new_day.png": "9a384a085357d08e1fb736c0fefa96b9",
"assets/assets/img/eventbus.png": "0c965a283da2cffb491269c9adf48b1d",
"assets/assets/img/hashmap.png": "e8fb0a971fcd6f8da76982245395bf08",
"assets/assets/img/head.png": "fa6f72c9c43b793bb115da3585da0031",
"assets/assets/img/steam.png": "4d601f62031ddc22684d3d2925005b47",
"assets/assets/img/kill_that_man.jpg": "fdd2bcf1314fe90df6d95b170628cd77",
"assets/assets/img/daily_dictation.jpg": "d1d4105d93b8462866c09baa8a315f6d",
"assets/assets/img/create_mvp.png": "46d86678abc625a0f12621cd00264cf2",
"assets/assets/img/kotlin_5.png": "4b91717f23bbe0207c589df77e5969d2",
"assets/assets/img/api_2.png": "1e29f9a37e5d4ee0ed703d777e9db36f",
"assets/assets/img/github.png": "8e19edd9c39ab207200c51a5f2a95441",
"assets/assets/img/mourn.png": "ff04d13fb859b0c50bdf6945615e7c36",
"assets/assets/img/flutter_05.png": "2501b597c2b808cca8bbb7f2001f116c",
"assets/assets/jsons/article_tag.json": "11b1449edf9e9bcebe8740d09b8ad7af",
"assets/assets/jsons/article_collection.json": "5b4f55388f86ec7e1a969fed5825bd0b",
"assets/assets/jsons/article_topic.json": "a2936ac9067f8e301bc41e2644a1a455",
"assets/assets/jsons/music.json": "a9a87b68e0476c795e3c58d6e4889f4a",
"assets/assets/jsons/game_screens.json": "e736cc0343b7ac330e7c8a98f7ce1baa",
"assets/assets/jsons/article_study.json": "bf1f652d0036b2e66d3630c0cddbe42f",
"assets/assets/jsons/one_line.json": "c1b6b1cde8374bfc666c88e9924b41b4",
"assets/assets/jsons/friend.json": "2232881667bd227258bfe29fdb8dbac1",
"assets/assets/jsons/article_life.json": "117b9a402310ab1d68991d09237ece20",
"assets/assets/jsons/article_all.json": "2c85c4e8fe7f80bf284d3cda6172e586",
"assets/assets/svgs/icon_gmail.svg": "13ed9b45c04daa95a569f37f57200fdd",
"assets/assets/svgs/music_last.svg": "e8feea14f95fd5f3f0e6ec15b8823434",
"assets/assets/svgs/home_1.svg": "5a5b4720b87ae79c77324f6a0ac07449",
"assets/assets/svgs/home_5.svg": "4afbf3b5ff8e2400e37abb4d1fb8b64c",
"assets/assets/svgs/bg_playstation.svg": "6fd12195d66b50a5f5e2bf7c41317858",
"assets/assets/svgs/bg_steam.svg": "aec3aa55aae6db1e831c46e4cb4d8afd",
"assets/assets/svgs/icon_github.svg": "302c066a6d04e6ef2b9d55a2b3aab250",
"assets/assets/svgs/home_4.svg": "18c809882aea7f7b02a847bde6f69e1c",
"assets/assets/svgs/noon.svg": "a02bdb92af6ee95359b9c332fba11a17",
"assets/assets/svgs/bg_github.svg": "dcc749ba2f6566325769ec6a8bd4a58d",
"assets/assets/svgs/music_cycle_one.svg": "d6738471c8637ba18c91cbbd4feb5b66",
"assets/assets/svgs/music_list.svg": "0bf2c80cb3c9ee14c63c222c5aa2a9c3",
"assets/assets/svgs/icon_ps.svg": "600ed655c9252b068bf96d51112e5724",
"assets/assets/svgs/music_cycle_list.svg": "ba3113dd10b4928cbfd3140c2f83fcbb",
"assets/assets/svgs/random.svg": "3f8af89517f2f0440433649e2c61ae68",
"assets/assets/svgs/icon_steam.svg": "6f938f6c93de35f92a72b8e0a0e11766",
"assets/assets/svgs/music_play.svg": "e815c38379384e7011ea7eb8b46604aa",
"assets/assets/svgs/afternoon.svg": "9db64b56aab73ef5e49a4a5d24915a9d",
"assets/assets/svgs/home_6.svg": "a2141bbe8d09ca455a341402dfcad158",
"assets/assets/svgs/icon_flutter.svg": "1446c7825a4bb5815e851eba4a7d7008",
"assets/assets/svgs/icon_xbox.svg": "5c82704fabbacc42339b1a1dd56ce77d",
"assets/assets/svgs/home.svg": "dcad052eafeac37f097c0c33d414f6fa",
"assets/assets/svgs/bg_gmail.svg": "60c9832223b816064d6fef37bbbfa576",
"assets/assets/svgs/bg_xbox.svg": "1ab1cb1f705a44db1dc06748c58453f0",
"assets/assets/svgs/quote.svg": "638a011e8d0fa5f626ca30dca4b10c07",
"assets/assets/svgs/home_3.svg": "f24b2ef606f4a3241a448cf3f59cc58b",
"assets/assets/svgs/article_bg.svg": "aad61cc0e54cf220f29c0f3c4fbe45a6",
"assets/assets/svgs/night.svg": "583799b35dcb722560720a9172e1745f",
"assets/assets/svgs/music_pause.svg": "b716e641c14d3911a5e73b35be4f1451",
"assets/assets/svgs/music_next.svg": "ed0a5e2ea014a33043c33293411feacf",
"assets/assets/svgs/home_2.svg": "7d733ed99bc098c8d99018e5d72ae50d",
"assets/assets/game_screens/sekiro/20190331143226_1.jpg": "cc7da299e046311d0aead18c97c5ec11",
"assets/assets/game_screens/sekiro/20190331140916_1.jpg": "ac183904c3950d119f940e02e33293b1",
"assets/assets/game_screens/sekiro/20190325203326_1.jpg": "12115f88376760288683eb21e6b625a4",
"assets/assets/game_screens/sekiro/20190405190414_1.jpg": "54aec0b4c3bae9efd56e4f45fba9d036",
"assets/assets/game_screens/sekiro/20190423152559_1.jpg": "f8700083f19c522a37ac54328c548b97",
"assets/assets/game_screens/sekiro/gameThumb.jpeg": "ca8af6d92c6ffecdd45470793d60bb54",
"assets/assets/game_screens/sekiro/20190330181956_1.jpg": "35dc3adae3037b42bb955770ebf89617",
"assets/assets/game_screens/sekiro/20190325203522_1.jpg": "46fbec0109b76d2ebbc54a17d84bc4eb",
"assets/assets/game_screens/sekiro/20190404231148_1.jpg": "373933a62bf9e43eec529b530a95f4cb",
"assets/assets/game_screens/sekiro/20190404231105_1.jpg": "cd929568a9ee603b35e9a0eacd639699",
"assets/assets/game_screens/sekiro/gameBackground.jpeg": "210da88db478ea14dfca9f1817b0e61d",
"assets/assets/game_screens/sekiro/20190331150020_1.jpg": "08e3a42de759274dbc2cb79837d62458",
"assets/assets/game_screens/sekiro/20190402005428_1.jpg": "6eac45dd2b164af0c3d85525205444c8",
"assets/assets/game_screens/sekiro/20190325192110_1.jpg": "ac2d2f7050bd239ae2157bf09b4db2ba",
"assets/assets/game_screens/sekiro/20190402003651_1.jpg": "49247927df6d484c0dd1eda156feda1c",
"assets/assets/game_screens/sekiro/20190404192256_1.jpg": "34b3e6f096dcef34af8b35fcb85a9d72",
"assets/assets/game_screens/sekiro/20190404183237_1.jpg": "e881acd28d51ebd3990f13d7df5f76fb",
"assets/assets/game_screens/sekiro/20190331143312_1.jpg": "0e36b505f605bf32d18da83e60f291da",
"assets/assets/game_screens/sekiro/20190331142925_1.jpg": "590d756076d946ca45d11b2fb7c34e61",
"assets/assets/game_screens/sekiro/20190404192517_1.jpg": "d172b14cade0ecbfada8247912491f86",
"assets/assets/game_screens/sekiro/thumbnails/20190331143226_1.jpg": "5887ddd0ad81fdc78939ef96fa915e47",
"assets/assets/game_screens/sekiro/thumbnails/20190331140916_1.jpg": "578cd09341a4933c0adba7e9ebb2b70a",
"assets/assets/game_screens/sekiro/thumbnails/20190325203326_1.jpg": "7f5c9ac8be0eb61e2df1ba0ac1c757f3",
"assets/assets/game_screens/sekiro/thumbnails/20190405190414_1.jpg": "1a74d59db6c760a93d29e85d0c19924c",
"assets/assets/game_screens/sekiro/thumbnails/20190423152559_1.jpg": "b57a948247fbe051f276a653ae4bd6c2",
"assets/assets/game_screens/sekiro/thumbnails/20190330181956_1.jpg": "305faa3142c52af330fe89f110e4113e",
"assets/assets/game_screens/sekiro/thumbnails/20190325203522_1.jpg": "0da7281ff3575cba0af569b16e7dd09f",
"assets/assets/game_screens/sekiro/thumbnails/20190404231148_1.jpg": "3a12e9c032acb4cddf9410ee3080b2c1",
"assets/assets/game_screens/sekiro/thumbnails/20190404231105_1.jpg": "258a14cba50380c7a5045bec0aaef5a9",
"assets/assets/game_screens/sekiro/thumbnails/20190331150020_1.jpg": "6af41777d03dacf8ca8c12bff414700b",
"assets/assets/game_screens/sekiro/thumbnails/20190402005428_1.jpg": "8d99dce0b40a6fcbd4147d0f86037781",
"assets/assets/game_screens/sekiro/thumbnails/20190325192110_1.jpg": "f50f78fd8aa9bcb8d1977c2d23e2227d",
"assets/assets/game_screens/sekiro/thumbnails/20190402003651_1.jpg": "dd6020fd94392af05c02a6ea0c126eed",
"assets/assets/game_screens/sekiro/thumbnails/20190404192256_1.jpg": "b435b0d49734e833915d99177ce76fa1",
"assets/assets/game_screens/sekiro/thumbnails/20190404183237_1.jpg": "85d656f1c0957e5ea0465388308ebdfd",
"assets/assets/game_screens/sekiro/thumbnails/20190331143312_1.jpg": "36a2d0ec21208efff96b480dce2f7194",
"assets/assets/game_screens/sekiro/thumbnails/20190331142925_1.jpg": "cde6945b68cea16c7f7c2d657fa79ae3",
"assets/assets/game_screens/sekiro/thumbnails/20190404192517_1.jpg": "f9588c56b63625dbed72d07dca3606b4",
"assets/assets/game_screens/sekiro/thumbnails/20190331143303_1.jpg": "fda41dd748eeda40fc5cffe92046709e",
"assets/assets/game_screens/sekiro/thumbnails/20190401185429_1.jpg": "365720547ad6688454d7e2a2e521cc2f",
"assets/assets/game_screens/sekiro/20190331143303_1.jpg": "a399f047bed5cb1a2c6ffcc261f4c5d7",
"assets/assets/game_screens/sekiro/20190401185429_1.jpg": "4a4e0b8fe9e1063f7123a6e5258de776",
"assets/assets/game_screens/trine4/gameThumb.jpeg": "2d3d08ffb03065228846d43fce10dbe8",
"assets/assets/game_screens/trine4/20191116165020_1.jpg": "5866f22ad4a6776441be37b9e1c8a3d4",
"assets/assets/game_screens/trine4/20191117122916_1.jpg": "fcfe634241722993a98df80588f85f85",
"assets/assets/game_screens/trine4/gameBackground.jpeg": "cba55a44d0d140ba19a299d0b7ba03af",
"assets/assets/game_screens/trine4/20191117221042_1.jpg": "e342a632d815643f8eea1eb43219aa42",
"assets/assets/game_screens/trine4/20191116191214_1.jpg": "e1ea1eed09b42c9f87d2e7fae3b4464d",
"assets/assets/game_screens/trine4/thumbnails/20191116165020_1.jpg": "241d7e41f1fc89a81929785a9c48ce5a",
"assets/assets/game_screens/trine4/thumbnails/20191117122916_1.jpg": "a26e94c8f255cf8fdac93d0a2bb119de",
"assets/assets/game_screens/trine4/thumbnails/20191117221042_1.jpg": "d77f55c17d3af09b55d7583a469229fc",
"assets/assets/game_screens/trine4/thumbnails/20191116191214_1.jpg": "61ce5f0ebb815195e0feafbc24bc2e48",
"assets/assets/game_screens/trine4/thumbnails/20191117221137_1.jpg": "1e9eada900568ccdebd602f8205e8f1c",
"assets/assets/game_screens/trine4/20191117221137_1.jpg": "44f487789124cde5f43fa8358b90547d",
"assets/assets/game_screens/myTimeAtPortia/20190121214711_1.jpg": "a7527748017d3a02c34cf70b1dfdc3f3",
"assets/assets/game_screens/myTimeAtPortia/gameThumb.jpeg": "dda6bc2fa275feed1d48b6d6f5ceed89",
"assets/assets/game_screens/myTimeAtPortia/20190124195008_1.jpg": "40fc33c20b19d24caf5ed72c881c963d",
"assets/assets/game_screens/myTimeAtPortia/20190121213940_1.jpg": "7a9d803c35f07aacf0e7507fd3929792",
"assets/assets/game_screens/myTimeAtPortia/20190121214717_1.jpg": "383f651bbaa549caa1aab253284d9927",
"assets/assets/game_screens/myTimeAtPortia/20190124195030_1.jpg": "eaa0c5a6f664f4f10dd449bb525df2fa",
"assets/assets/game_screens/myTimeAtPortia/20190121222320_1.jpg": "eff748b6f7c857b49ca8622ccb70b9d7",
"assets/assets/game_screens/myTimeAtPortia/gameBackground.jpeg": "d6c3f6ef2c5e29284c48f8edf3f68836",
"assets/assets/game_screens/myTimeAtPortia/20190124195033_1.jpg": "81cefe5fdd22d25ad1665ae5b194edb3",
"assets/assets/game_screens/myTimeAtPortia/20190121220957_1.jpg": "44ad57acaea62fb88e6c232ba7c83dfd",
"assets/assets/game_screens/myTimeAtPortia/thumbnails/20190121214711_1.jpg": "83382ba82637b3a6075f77df82347566",
"assets/assets/game_screens/myTimeAtPortia/thumbnails/20190124195008_1.jpg": "7ee0c5b9a3eaae77a6678c9c31324047",
"assets/assets/game_screens/myTimeAtPortia/thumbnails/20190121213940_1.jpg": "a473f974d796043675a776cf40b1bf3a",
"assets/assets/game_screens/myTimeAtPortia/thumbnails/20190121214717_1.jpg": "4bdfa99aa1690150c9481a9cd482aadc",
"assets/assets/game_screens/myTimeAtPortia/thumbnails/20190124195030_1.jpg": "6a6b00d4d207af5a572d1b79e8d9eac2",
"assets/assets/game_screens/myTimeAtPortia/thumbnails/20190121222320_1.jpg": "704d11b08704d130448f892b9b463238",
"assets/assets/game_screens/myTimeAtPortia/thumbnails/20190124195033_1.jpg": "57788d25e27f48b3d6788f418d1124c7",
"assets/assets/game_screens/myTimeAtPortia/thumbnails/20190121220957_1.jpg": "bdae9eae773c5f1eb5918266d981371e",
"assets/assets/game_screens/theWitcher3/1b8461a3-5edb-4130-8973-02ee07519674.png": "2f571998d92767826b751d07f96675d2",
"assets/assets/game_screens/theWitcher3/49a1451a-ef76-4f6f-b785-a9af4eebf6e4_0.png": "d312887349929841206cd4919e90a201",
"assets/assets/game_screens/theWitcher3/84907c67-fc83-45d0-a489-df42288dbbef.png": "c6303a11daf3778768c9d99bca088196",
"assets/assets/game_screens/theWitcher3/ee3c3952-33f3-4737-a44d-b4ec59f5eefd.png": "057e25d2f876fd156502f16bc3b9cfcf",
"assets/assets/game_screens/theWitcher3/62627be6-4c70-4625-b3cb-5019769a6e3c.png": "8f06532842eec08e7fa9b636d2d9ef71",
"assets/assets/game_screens/theWitcher3/2d3b513d-e2b8-4d73-a4b6-5f8151bb57e2.png": "8caf479f11ec306ad356e2e68be151ac",
"assets/assets/game_screens/theWitcher3/66c0eea6-ad54-4a48-b8a0-cad82235dab1.png": "750994bd6bfafdf9c55f2c28c58e3109",
"assets/assets/game_screens/theWitcher3/371155c2-ade5-4581-bfcc-2ad80ad6541e.png": "9d4b9f4ebb0197df9379ba1fd3bf3a0c",
"assets/assets/game_screens/theWitcher3/c4707fdf-df9d-4d0e-b341-4cf63b98edfc.png": "d741daa2550e2e3a1b9f0d66c4f4ae2d",
"assets/assets/game_screens/theWitcher3/gameThumb.png": "55c9e027b30cc65e1fb39881252d08e4",
"assets/assets/game_screens/theWitcher3/bf573185-8ed1-4dc9-9521-64984e76d249.png": "df201a1e8e0308c3d64d215e35cb82a4",
"assets/assets/game_screens/theWitcher3/47f2ce8d-d3a5-490f-bdaa-508144fd822f_0.png": "0cd2dc19b8a998d2027ff7ab1cdc3960",
"assets/assets/game_screens/theWitcher3/ef738eac-880e-4722-b762-e5fa86edaf0b_0.png": "6544209acf91eec66d9e9f96ef7bf078",
"assets/assets/game_screens/theWitcher3/cb3d04bd-4535-4941-8348-04ca26809a9f.png": "dee73c656e13bf3e6349ed9a7d20266c",
"assets/assets/game_screens/theWitcher3/b193fda6-585d-4c7d-8bf0-637f76f7f3c9.png": "6d7900fb1397cc2dd587a3adb3ab4114",
"assets/assets/game_screens/theWitcher3/720bff16-e9c1-4a96-8b02-6c3e66a00c92.png": "2f20b16d49ec9742674502d3b78654f8",
"assets/assets/game_screens/theWitcher3/cc8fd88d-2eca-489e-9beb-3e4606c83163.png": "df030da0601e92b31fb1bd8c4988e441",
"assets/assets/game_screens/theWitcher3/ec02a238-cb87-4fc7-96c1-e3741cfadf62.png": "825371e7788e60cf9894f1d1a7f6a76a",
"assets/assets/game_screens/theWitcher3/5667ea15-2f56-42d3-9a84-3e39c40b653e.png": "7562f724833b0330f2927bbba744aa1f",
"assets/assets/game_screens/theWitcher3/gameBackground.jpg": "75ce503519b18cf47c96d91e7ed5be93",
"assets/assets/game_screens/theWitcher3/394e5a0c-6023-4ac5-a92d-0a70d9e2c350.png": "aa417577eae5c2f150021c215bc6923b",
"assets/assets/game_screens/theWitcher3/5717a68f-f70a-49f0-8116-5d1a0b542b2f.png": "cb0905766e5b900cf5313ac971672e44",
"assets/assets/game_screens/theWitcher3/eefac956-cb8f-4899-ae80-4b1fd88cfaf0.png": "3fd3db428ea87cd44290c58bcb6217d6",
"assets/assets/game_screens/theWitcher3/9282da3e-f679-432d-82bd-544f023db1aa_0.png": "713bd7b91cee75901bf5b37773f0d675",
"assets/assets/game_screens/theWitcher3/4e67a602-2ad1-44ad-96ab-bc1520143e8d.png": "3359c914e0cb3deae7fcca02090e0a62",
"assets/assets/game_screens/theWitcher3/a0ea2f62-1d68-41cd-a6e4-0537cef1b264.png": "6e474177ff23c09b1921e622664c5cb6",
"assets/assets/game_screens/theWitcher3/be990073-9e24-40ac-a986-dac539b82301.png": "dc27117f74f57c70d81709918ef3e0f9",
"assets/assets/game_screens/theWitcher3/thumbnails/1b8461a3-5edb-4130-8973-02ee07519674.png": "1ab31106e3601783806b1ae89b8231a5",
"assets/assets/game_screens/theWitcher3/thumbnails/49a1451a-ef76-4f6f-b785-a9af4eebf6e4_0.png": "b6a0a980a5483b5ab72d9e94cccd9a62",
"assets/assets/game_screens/theWitcher3/thumbnails/84907c67-fc83-45d0-a489-df42288dbbef.png": "be7c08af6df1e468a93003e4263d3768",
"assets/assets/game_screens/theWitcher3/thumbnails/ee3c3952-33f3-4737-a44d-b4ec59f5eefd.png": "96fce4d142c3429f903ee4b6cefc70bb",
"assets/assets/game_screens/theWitcher3/thumbnails/62627be6-4c70-4625-b3cb-5019769a6e3c.png": "8a3dbd6c18133317cee6c557e6615f58",
"assets/assets/game_screens/theWitcher3/thumbnails/2d3b513d-e2b8-4d73-a4b6-5f8151bb57e2.png": "5abb61c1f325c99b0189046d35f665e8",
"assets/assets/game_screens/theWitcher3/thumbnails/66c0eea6-ad54-4a48-b8a0-cad82235dab1.png": "0e82a5c9db311c4a0f38386805c110fe",
"assets/assets/game_screens/theWitcher3/thumbnails/371155c2-ade5-4581-bfcc-2ad80ad6541e.png": "d55a414d61512277a2f8616eb8b0bcfb",
"assets/assets/game_screens/theWitcher3/thumbnails/c4707fdf-df9d-4d0e-b341-4cf63b98edfc.png": "148a1b4cd97fa5ce2a5027cd06892722",
"assets/assets/game_screens/theWitcher3/thumbnails/bf573185-8ed1-4dc9-9521-64984e76d249.png": "4600e42d2a01fd6c61163e8a2026e38e",
"assets/assets/game_screens/theWitcher3/thumbnails/47f2ce8d-d3a5-490f-bdaa-508144fd822f_0.png": "fb0b263dde1ce778716a9e4063f579db",
"assets/assets/game_screens/theWitcher3/thumbnails/ef738eac-880e-4722-b762-e5fa86edaf0b_0.png": "26bba2ad0de492ad3450b9fa2b36d366",
"assets/assets/game_screens/theWitcher3/thumbnails/cb3d04bd-4535-4941-8348-04ca26809a9f.png": "c63ed9e7ca6bca7b75d39a79ce775e5a",
"assets/assets/game_screens/theWitcher3/thumbnails/b193fda6-585d-4c7d-8bf0-637f76f7f3c9.png": "ce006044e832a0e96a1139f901bac9ed",
"assets/assets/game_screens/theWitcher3/thumbnails/720bff16-e9c1-4a96-8b02-6c3e66a00c92.png": "64856509fabc8c66d7e16b97f3a042ac",
"assets/assets/game_screens/theWitcher3/thumbnails/cc8fd88d-2eca-489e-9beb-3e4606c83163.png": "0217f83f88a7ee6bbf68132a4e47b9bc",
"assets/assets/game_screens/theWitcher3/thumbnails/ec02a238-cb87-4fc7-96c1-e3741cfadf62.png": "f857038322c9bb632fda4e8744f3c6f9",
"assets/assets/game_screens/theWitcher3/thumbnails/5667ea15-2f56-42d3-9a84-3e39c40b653e.png": "2def80c7a7fdcfe8806d40344587b082",
"assets/assets/game_screens/theWitcher3/thumbnails/394e5a0c-6023-4ac5-a92d-0a70d9e2c350.png": "5d65741a0bc8fdde320f63dffe3f228d",
"assets/assets/game_screens/theWitcher3/thumbnails/5717a68f-f70a-49f0-8116-5d1a0b542b2f.png": "c0ecb736dca40fed0e94053204e5b85d",
"assets/assets/game_screens/theWitcher3/thumbnails/eefac956-cb8f-4899-ae80-4b1fd88cfaf0.png": "c3afd56747164545da27a6d0b85ab566",
"assets/assets/game_screens/theWitcher3/thumbnails/9282da3e-f679-432d-82bd-544f023db1aa_0.png": "d0fcdab233a8cb320259e9ce80f7b82d",
"assets/assets/game_screens/theWitcher3/thumbnails/4e67a602-2ad1-44ad-96ab-bc1520143e8d.png": "04ab70f287b6dde8b79982229ccb721d",
"assets/assets/game_screens/theWitcher3/thumbnails/a0ea2f62-1d68-41cd-a6e4-0537cef1b264.png": "a86e563e953ae6e6ad529ec9cadaa4f5",
"assets/assets/game_screens/theWitcher3/thumbnails/be990073-9e24-40ac-a986-dac539b82301.png": "0919db1cda700fe86c4598e507102594",
"assets/assets/game_screens/borderlands2/49520_screenshots_thumbnails_20170829205455_1.jpg": "34d218be8ee7b66979fcf5c32d860f5b",
"assets/assets/game_screens/borderlands2/49520_screenshots_thumbnails_20170822192219_1.jpg": "a25badeb2d7f0db11598f7619422b990",
"assets/assets/game_screens/borderlands2/49520_screenshots_thumbnails_20170822141125_1.jpg": "f7b77fddd8b8154272cc81dc0e33e947",
"assets/assets/game_screens/borderlands2/49520_screenshots_thumbnails_20170829205334_1.jpg": "3b4930a78c1adb3b1989f3077ba00e92",
"assets/assets/game_screens/borderlands2/gameThumb.jpg": "ab289faebf8bba1c93353e454c76d9d8",
"assets/assets/game_screens/borderlands2/49520_screenshots_thumbnails_20170822192425_1.jpg": "3768332f4521dfb5383a34f3f4d2130a",
"assets/assets/game_screens/borderlands2/49520_screenshots_thumbnails_20170822192050_1.jpg": "f20ff256492e90057cb4e2e8370ebfbe",
"assets/assets/game_screens/borderlands2/49520_screenshots_thumbnails_20170814223258_1.jpg": "6b81779bea5a493325ef1c19e4e74cad",
"assets/assets/game_screens/borderlands2/49520_screenshots_thumbnails_20170822140023_1.jpg": "977caccf38d20211a5657c68c96011dc",
"assets/assets/game_screens/borderlands2/49520_screenshots_thumbnails_20170822202511_1.jpg": "4d57225fe502244d02aab7d4c299424e",
"assets/assets/game_screens/borderlands2/gameBackground.jpg": "4466d35f8e0104ad01db5b1832b16231",
"assets/assets/game_screens/borderlands2/thumbnails/49520_screenshots_thumbnails_20170829205455_1.jpg": "606d9e37ad8f506dba66bdb974dbf8e1",
"assets/assets/game_screens/borderlands2/thumbnails/49520_screenshots_thumbnails_20170822192219_1.jpg": "5fb7e5d3f45fa0593d2ea6ae3192b17a",
"assets/assets/game_screens/borderlands2/thumbnails/49520_screenshots_thumbnails_20170822141125_1.jpg": "bc46d9a7c052e7d29bf439f2f0f80574",
"assets/assets/game_screens/borderlands2/thumbnails/49520_screenshots_thumbnails_20170829205334_1.jpg": "02b4570c92a53f9fce9cc12eed5566be",
"assets/assets/game_screens/borderlands2/thumbnails/49520_screenshots_thumbnails_20170822192425_1.jpg": "a632e32da3130a2ac031da315abb9955",
"assets/assets/game_screens/borderlands2/thumbnails/49520_screenshots_thumbnails_20170822192050_1.jpg": "b373a272e3bc03089cfd433b803cbeba",
"assets/assets/game_screens/borderlands2/thumbnails/49520_screenshots_thumbnails_20170814223258_1.jpg": "136a1f8b0330b990c63d2e5cdbebde20",
"assets/assets/game_screens/borderlands2/thumbnails/49520_screenshots_thumbnails_20170822140023_1.jpg": "b86ea6f7b63312cc72128be7a7098c91",
"assets/assets/game_screens/borderlands2/thumbnails/49520_screenshots_thumbnails_20170822202511_1.jpg": "4d3fb30355d887f4ff33c2bb5bcd2e2e",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170716125129_1.jpg": "f5702a10839520b20e12447b4b165ca0",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170716123920_1.jpg": "4c2ceef4cb806635fb7a46eb474bbd3a",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170716124340_1.jpg": "cd650b8da3222b41461e44808bda0016",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170716123848_1.jpg": "f1352bba52ce1f689f1bbece575bdfa3",
"assets/assets/game_screens/bioShockInfinite/gameThumb.jpg": "d042e62c885b0f5f5f79b0ffd6cd8b75",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170627163428_1.jpg": "b32a7060b43d39baca7a180342a96cc2",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170716124135_1.jpg": "486912a0ba0326a84fcaf297bd00bf2b",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170716124032_1.jpg": "fba4e14f3c2095834509d258d189c7bf",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170716123544_1.jpg": "fcd07ac09935eef34b46d5f799a31a58",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170716123851_1.jpg": "c0ae80c8f6b8eed33dff10fdbef4dd9b",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170711175038_1.jpg": "5e0201204970589e153826de643dd4fe",
"assets/assets/game_screens/bioShockInfinite/gameBackground.jpg": "a73d9d0f1827155c6322110fbdd82c7f",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170623221714_1.jpg": "b986fefea1e6c9e2bb994f2afd182506",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170627163424_1.jpg": "53ffea1698cea90164fc0bda99d90d19",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170626231639_1.jpg": "ef247ab50912a3ea9daddc65734614de",
"assets/assets/game_screens/bioShockInfinite/8870_screenshots_20170716123542_1.jpg": "de54bfc12da2e0bf45cc40b3cc27b2a3",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170716125129_1.jpg": "453173e049fe2776a4a91c68357b3703",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170716123920_1.jpg": "8111edbcd6426ec39454e00a0584e3a9",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170716124340_1.jpg": "0cc0606a5c156afaae1296960aafc42f",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170716123848_1.jpg": "69cf9b1e93297209abf6606b510b19c9",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170627163428_1.jpg": "266c446e489316c9e554ece2e1f74e4a",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170716124135_1.jpg": "023389cfba12f4d854e945f1e9a25768",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170716124032_1.jpg": "7b1cc9e44ee19cecefcce46fb4448f89",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170716123544_1.jpg": "fedb8320e421d5b7dd00e6f43f620d6f",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170716123851_1.jpg": "3dc1b922dad88fedf581d105ca207b7d",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170711175038_1.jpg": "d5d3d2c996dd87d7253130fd47ec1766",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170623221714_1.jpg": "b2ddb9c2e4faf0dbe3d2774cb1968558",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170627163424_1.jpg": "36f522465406e25aba9bfc2b1caa6b2d",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170626231639_1.jpg": "abbd0a3cdf1a58794718ae0bd652022f",
"assets/assets/game_screens/bioShockInfinite/thumbnails/8870_screenshots_20170716123542_1.jpg": "5c29363483a948843abe72ae150624d1",
"assets/assets/game_screens/guJian3/20181222185805_1.jpg": "87722fee4720c5a22e3dfe4d82abbfeb",
"assets/assets/game_screens/guJian3/20181222190419_1.jpg": "a7b16877a23cba98b10cee3270149378",
"assets/assets/game_screens/guJian3/20181222105523_1.jpg": "4e69bd2029133d9f364bdff14cb27ec6",
"assets/assets/game_screens/guJian3/gameThumb.jpeg": "4678153a9dbb7c27f2d2ff4316b28949",
"assets/assets/game_screens/guJian3/20181219221508_1.jpg": "5e18ad0d76341ffd377996ab9818ad49",
"assets/assets/game_screens/guJian3/20181221234453_1.jpg": "a3e6e0178e25529cf4ed5d0ac41e90c4",
"assets/assets/game_screens/guJian3/20181217215643_1.jpg": "4e5ca86423e9c6a2f669aed1297e6ccd",
"assets/assets/game_screens/guJian3/20181222134718_1.jpg": "c3331d85683b313ba5b03f02cc356afe",
"assets/assets/game_screens/guJian3/20181222133355_1.jpg": "e275135f0ac103f5fdc4a73b929b1809",
"assets/assets/game_screens/guJian3/20181220193758_1.jpg": "5a2607bbd1b8d2b76fa9627dd6e93039",
"assets/assets/game_screens/guJian3/20181221235442_1.jpg": "54a5e02b378605dcac1ad8e9d2c8d738",
"assets/assets/game_screens/guJian3/20181220193803_1.jpg": "8fd6e85e54a47d7e1bb0f1b6d3449c66",
"assets/assets/game_screens/guJian3/gameBackground.jpeg": "8a03c06ede99768890c8da70ba927dde",
"assets/assets/game_screens/guJian3/20181222122617_1.jpg": "f82039bbbd99ff84ad2fddc4efcde224",
"assets/assets/game_screens/guJian3/20181218230844_1.jpg": "736c355c54a8407193900cdf9dadb37a",
"assets/assets/game_screens/guJian3/20181220194443_1.jpg": "e41c9d31be8923385b57067183dc8087",
"assets/assets/game_screens/guJian3/20181221214110_1.jpg": "427ccf91c570bc2eb55e598b8d27d8a6",
"assets/assets/game_screens/guJian3/20181219221504_1.jpg": "c0f9e6ed825883e764dfb7537eba7a7a",
"assets/assets/game_screens/guJian3/20181222184314_1.jpg": "1642c79944f33ce66d7deea696207d7f",
"assets/assets/game_screens/guJian3/20181217212359_1.jpg": "462ef52b138aa405914d327533237268",
"assets/assets/game_screens/guJian3/thumbnails/20181222185805_1.jpg": "45a824811019e304d3ee9ee4a2d4920b",
"assets/assets/game_screens/guJian3/thumbnails/20181222190419_1.jpg": "f04cf196c7c321a84c68c869c564d50b",
"assets/assets/game_screens/guJian3/thumbnails/20181222105523_1.jpg": "aadc21aa871f90adc95f6f417635d2d1",
"assets/assets/game_screens/guJian3/thumbnails/20181219221508_1.jpg": "ce1a4af07e6681aa5354bffb6e6505ff",
"assets/assets/game_screens/guJian3/thumbnails/20181221234453_1.jpg": "f5e7744d295556be90fdcf3d290a6a70",
"assets/assets/game_screens/guJian3/thumbnails/20181217215643_1.jpg": "ede46f2638b3165a59bcfd4f765ad158",
"assets/assets/game_screens/guJian3/thumbnails/20181222134718_1.jpg": "e93ccf3d50c3e67745b8611b0110c69e",
"assets/assets/game_screens/guJian3/thumbnails/20181222133355_1.jpg": "be98811195ad17df9241c2f9944e1bbd",
"assets/assets/game_screens/guJian3/thumbnails/20181220193758_1.jpg": "1281ac1eb98618ee36116d8b2ed2bca8",
"assets/assets/game_screens/guJian3/thumbnails/20181221235442_1.jpg": "9d40db88e59bf3aeddcb7101afe9d7a5",
"assets/assets/game_screens/guJian3/thumbnails/20181220193803_1.jpg": "9c29a123f5cffff140705d61c51068f8",
"assets/assets/game_screens/guJian3/thumbnails/20181222122617_1.jpg": "93cde5bc64318e17367712cc869221b9",
"assets/assets/game_screens/guJian3/thumbnails/20181218230844_1.jpg": "eea2b557b481abb951ac8537ad592396",
"assets/assets/game_screens/guJian3/thumbnails/20181220194443_1.jpg": "98ce52b3082250e10528ac3293ced80c",
"assets/assets/game_screens/guJian3/thumbnails/20181221214110_1.jpg": "2063dbf941688be3d43d68c47cf23953",
"assets/assets/game_screens/guJian3/thumbnails/20181219221504_1.jpg": "c0d1d00c7618b554e543a354ed7b8a92",
"assets/assets/game_screens/guJian3/thumbnails/20181222184314_1.jpg": "ee5b5ecc2299febaf76aea2d79577aac",
"assets/assets/game_screens/guJian3/thumbnails/20181217212359_1.jpg": "6dd0222834ae99acd15d1ee66be58b19",
"assets/assets/game_screens/guJian3/thumbnails/20181219204018_1.jpg": "dedbdb7eec9d247e4fbbec0f64687b72",
"assets/assets/game_screens/guJian3/20181219204018_1.jpg": "a2f6c3718422df72f11bf8f778830608",
"assets/assets/game_screens/darkSouls3/20181215224816_1.jpg": "68ca017e494b092019dae91d069b3c5d",
"assets/assets/game_screens/darkSouls3/20181002130004_1.jpg": "a5d69e5ad24218a3687ef65a35060190",
"assets/assets/game_screens/darkSouls3/20181215224947_1.jpg": "23ded6b0644ff191a309a7217d4e39af",
"assets/assets/game_screens/darkSouls3/20181215224849_1.jpg": "3a1f3970ce897fb342fc17b6e2836ffb",
"assets/assets/game_screens/darkSouls3/20181216144756_1.jpg": "ee7b4883ef7bfee1631ed7b384baf4a4",
"assets/assets/game_screens/darkSouls3/20181215224955_1.jpg": "2281e7b437d4a9010f2f7cba21cbb9f5",
"assets/assets/game_screens/darkSouls3/20181216182716_1.jpg": "b3b0036576ebd616f779bb9aacc76c01",
"assets/assets/game_screens/darkSouls3/20181002130013_1.jpg": "9c3efc5a722e168a8e63b15026a56010",
"assets/assets/game_screens/darkSouls3/20181215224625_1.jpg": "9c457ede9e78b31db7d5015153eb8037",
"assets/assets/game_screens/darkSouls3/gameThumb.jpeg": "86f41478d4651c8e1ff9403dcefadbc0",
"assets/assets/game_screens/darkSouls3/20181216182849_1.jpg": "fecc459db05f38f6235ace0feafe0516",
"assets/assets/game_screens/darkSouls3/20181216182832_1.jpg": "9f4fcbd1b3f718f7406494ac26b11a40",
"assets/assets/game_screens/darkSouls3/20181217200501_1.jpg": "f03ac51382f6cab885503d39e40e72fa",
"assets/assets/game_screens/darkSouls3/20181215224532_1.jpg": "00f78e638329b7a7aa60f98d54cc7aa1",
"assets/assets/game_screens/darkSouls3/20181215223441_1.jpg": "b0e5493e9566c90a7f8ffbf5708dbb39",
"assets/assets/game_screens/darkSouls3/20181217201818_1.jpg": "acbc3ed3ffe05d52e4742691851faf23",
"assets/assets/game_screens/darkSouls3/20181223195857_1.jpg": "af005d5492b0269fc71546349a940d45",
"assets/assets/game_screens/darkSouls3/20181215224956_1.jpg": "aaa8e056629be8453cc6ab9255b54750",
"assets/assets/game_screens/darkSouls3/20181125140252_1.jpg": "3e90bbd7dc5fea8f493e917cc8a8c9db",
"assets/assets/game_screens/darkSouls3/20181223201803_1.jpg": "8a4cfd8c2498b855980393765ed469e0",
"assets/assets/game_screens/darkSouls3/gameBackground.jpg": "1dbb7f417a7cc4d0eb908b6a77ce16ff",
"assets/assets/game_screens/darkSouls3/20181215224732_1.jpg": "2464a93a2c673d48198b016f598b7983",
"assets/assets/game_screens/darkSouls3/20181215223559_1.jpg": "b0468698b4bd7c394dcab831378da537",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215224816_1.jpg": "ac49bdac129de2e83dba910557b21eec",
"assets/assets/game_screens/darkSouls3/thumbnails/20181002130004_1.jpg": "a56628c963115dc2640872997a54b55e",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215224947_1.jpg": "cc24ef25360931c5054b2e2d2ffb0ee7",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215224849_1.jpg": "ae25a3a03a4fbc9cd9d82398755bfa3f",
"assets/assets/game_screens/darkSouls3/thumbnails/20181216144756_1.jpg": "a2f45f2254c98f916b905a567db2bc54",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215224955_1.jpg": "ccd39290b55c33daf914ed7857e8777e",
"assets/assets/game_screens/darkSouls3/thumbnails/20181216182716_1.jpg": "fc71529b4edc658e57a0687fb45a971b",
"assets/assets/game_screens/darkSouls3/thumbnails/20181002130013_1.jpg": "bd05b3972a95ad5469fdd7d3b41d4e5b",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215224625_1.jpg": "dcd2c4982295a580048ae9b78bc78125",
"assets/assets/game_screens/darkSouls3/thumbnails/20181216182849_1.jpg": "55ccd056930ebdab20d891f077bb509b",
"assets/assets/game_screens/darkSouls3/thumbnails/20181216182832_1.jpg": "9d5f3e3285afe57f24c7bf6ae9454b28",
"assets/assets/game_screens/darkSouls3/thumbnails/20181217200501_1.jpg": "7eec99d68904c82a3ac523b4ecac49fb",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215224532_1.jpg": "e415e1e093353383cd5322cc7554bf9e",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215223441_1.jpg": "043e9210aa2f7f2a48c6841f8f7eacde",
"assets/assets/game_screens/darkSouls3/thumbnails/20181217201818_1.jpg": "4c613343cfab444447f79be3ee92b38c",
"assets/assets/game_screens/darkSouls3/thumbnails/20181223195857_1.jpg": "5531b7a4cfe57ac70833e31ad2aae335",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215224956_1.jpg": "4696274c96903e87be5311ddedf5505d",
"assets/assets/game_screens/darkSouls3/thumbnails/20181125140252_1.jpg": "0c386b4804e487e95217f072b852cdb6",
"assets/assets/game_screens/darkSouls3/thumbnails/20181223201803_1.jpg": "2f73eb343462439e74797ec67bcdcf82",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215224732_1.jpg": "cd6ab88ad1cc62b35f22db848a8f35c7",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215223559_1.jpg": "fc7f1505545898df552a90d3b1702786",
"assets/assets/game_screens/darkSouls3/thumbnails/20181215214909_1.jpg": "4d24cd5387109eb0f267d89317b5cc59",
"assets/assets/game_screens/darkSouls3/thumbnails/20181217201824_1.jpg": "f1ed7cc325164cd856e1996019ba5f3f",
"assets/assets/game_screens/darkSouls3/20181215214909_1.jpg": "2e0d828ba9eab9fcedbe15f82288af9d",
"assets/assets/game_screens/darkSouls3/20181217201824_1.jpg": "aa7cfd0b2262bd576f7c98d979f6ef54",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/shaders/ink_sparkle.frag": "1b0090f7ba7a21ca058df39458216a4e",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/FontManifest.json": "d8202a603e794d61ae88a3811645a0dc",
"assets/NOTICES": "e04131dc12226583215f1b8abf949f41",
"flutter.js": "f85e6fb278b0fd20c349186fb46ae36d",
"index.html": "2c094410cf50edf55413084f8e39d216",
"/": "2c094410cf50edf55413084f8e39d216",
"favicon.png": "43a7a8aa911ac20600297c413160a32c",
"version.json": "e295eea9e581da6c5011023a7996f457",
"manifest.json": "9cf5264d5107b0b5db1fc036cae0e131",
"icons/Icon-192.png": "c272ed6503898850493a9fadfdfe44c8",
"icons/Icon-512.png": "8d6e2a81246fb0595cd0e61576988b8c"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}

export class ApiConstant {
  // 获取登陆二维码Key
  static readonly URL_QRCODE_KEY = "/login/qr/key"
  // 获取登陆二维码Value
  static readonly URL_QRCODE_VALUE = "/login/qr/create"
  // 查询登陆鉴权
  static readonly URL_CHECK_QRCODE = "/login/qr/check"
  // 获取账户信息
  static readonly URL_ACCOUNT_INFO = "/user/account"
  // 获取用户详细信息
  static readonly URL_USER_DETAIL = "/user/detail"
  // 获取用户歌单列表
  static readonly URL_USER_PLAY_LIST = "/user/playlist"
  // 获取已收藏专辑列表
  static readonly URL_COLLECT_ALBUM_LIST = "/album/sublist"
  // 获取歌单详情
  static readonly URL_PLAY_LIST_DETAIL = "/playlist/detail"
  // 获取歌曲详情
  static readonly URL_SONG_DETAIL = "/song/detail"
  // 获取歌曲url
  static readonly URL_SONG_URL = "/song/url"
  // 获取动态
  static readonly URL_DYNAMIC = "/event"
  // 获取用户动态
  static readonly URL_USER_DYNAMIC = "/user/event"
  // 获取动态评论
  static readonly URL_DYNAMIC_COMMENT = "/comment/event"
  // 获取歌词
  static readonly URL_LYRIC = "/lyric"
}
/** 用户歌单列表请求结果实体类 */
import { BaseResultBean } from 'lib_common'

/**
 * 歌单列表请求结果实体类
 */
export class UserPlaylistResultBean extends BaseResultBean {
  playlist: UserPlaylistBean[]
}

export class UserPlayListDetailResultBean extends BaseResultBean {
  playlist: UserPlaylistBean
}

export class UserPlaylistBean {
  tracks: TrackBean[]
  trackIds: TrackIdBean[]
  creator: SubscribersBean
  name: string
  coverImgUrl: string
  trackCount: number
  id: number
  playCount: number
  description: string
  shareCount: number
  commentCount: number
  subscribedCount: number
  userId: number
}

export class TrackBean {
  name: string
  id: number
  mv: number
  ar: ArBean[]
  al: AlBean
}

export class TrackIdBean {
  id: number
  v: number
  alg: string
}

export class SubscribersBean {
  userId: number
  avatarUrl: string
  nickname: string
}

export class ArBean {
  id: number
  name: string
}

export class AlBean {
  id: number
  v: number
  alg: string
}

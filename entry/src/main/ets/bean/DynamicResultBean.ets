import { BaseResultBean } from 'lib_common'
import { Al, Ar, ProfileBean, UserPlaylistBean } from '.'

/** 动态请求结果实体类 */
export class DynamicResultBean extends BaseResultBean {
  event: DynamicBean[]
  lasttime: number
}

/** 用户动态请求结果实体类 */
export class UserDynamicResultBean extends BaseResultBean {
  events: DynamicBean[]
  lasttime: number
}

export class DynamicBean {
  threadId: string
  info: DynamicInfo
  user: ProfileBean
  eventTime: number
  pics: DynamicPics[]
  json: string
  jsonBean: DynamicJsonBean | null
}

export class DynamicJsonBean {
  msg: string
  playlist: UserPlaylistBean
  song: DynamicSongBean
}


export class DynamicSongBean {
  //歌曲id
  id: number
  //歌曲名称
  name: string
  artists: Ar[]
  album: Al
}


export class DynamicInfo {
  resourceType: number
  resourceId: number
  liked: boolean
  commentCount: number
  likedCount: number
  shareCount: number
  hotCount: number
}

export class DynamicPics {
  originUrl: string
  squareUrl: string
  rectangleUrl: string
  height: number
  width: number
}

/**
 * 专辑请求结果实体类
 */
import { BaseResultBean } from 'lib_common/src/main/ets/bean/BaseResultBean'
import { ArBean } from './UserPlaylistResultBean'

export class AlbumResultBean extends BaseResultBean {
  count: number
  hasMore: boolean
  paidCount: number
  data: AlbumBean[]
}

export class AlbumBean {
  subTime: number
  artists: ArBean[]
  picUrl: string
  name: string
  size: number
}
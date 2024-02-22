import { BaseResultBean } from 'lib_common'

/**
 * 歌曲url请求结果实体类
 */
export class SongUrlResultBean extends BaseResultBean {
  data: SongUrlBean[]
}

export class SongUrlBean {
  url: string
}
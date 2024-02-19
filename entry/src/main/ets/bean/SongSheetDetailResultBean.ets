import { BaseResultBean } from 'lib_common'

/** 歌单详情请求结果实体类 */
export class SongSheetDetailResultBean extends BaseResultBean {
  songs: SongBean[]
}

export class SongBean {
  //歌曲id
  id: number
  //歌曲名称
  name: string
  al: Al
  ar: Ar[]
}

export class Ar {
  id: number
  name: string
}

export class Al {
  id: number
  name: string
  picUrl: string
}

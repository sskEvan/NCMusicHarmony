import { BaseResultBean } from 'lib_common'

export class SongUrlResultBean extends BaseResultBean {
  data: SongUrlBean[]
}

export class SongUrlBean {
  url: string
}
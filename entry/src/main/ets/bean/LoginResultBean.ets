import { BaseResultBean } from 'lib_common'

/** 登陆二维码key请求结果实体类 */
export class QrcodeKeyResultBean extends BaseResultBean {
  data: QrcodeKeyBean
}

export class QrcodeKeyBean {
  unikey: string
}

/** 登陆二维码value请求结果实体类 */
@Observed
export class QrcodeValueResultBean extends BaseResultBean {
  data: QrcodeValueBean
}

@Observed
export class QrcodeValueBean {
  qrurl: string
  qrimg: string
}

/** 二维码鉴权请求结果实体类 */
@Observed
export class QrcodeAuthResultBean extends BaseResultBean {
  cookie: string
  nickname: string
  avatarUrl: string
}


/** 账户信息请求结果实体类 */
@Observed
export class AccountInfoResultBean extends BaseResultBean {
  account: AccountBean
  profile: ProfileBean
}

@Observed
export class AccountBean {
  id: number
  userName: string
  type: number
  status: number
  whitelistAuthority: number
  createTime: number
  tokenVersion: number
  ban: number
  baoyueVersion: number
  donateVersion: number
  vipType: number
  viptypeVersion: number
  anonimousUser: boolean
}

export class ProfileBean {
  followed: boolean
  userId: number
  defaultAvatar: boolean
  avatarUrl: string
  nickname: string
  birthday: number
  province: number
  accountStatus: number
  vipType: number
  gender: number
  djStatus: number
  mutual: boolean
  authStatus: number
  backgroundImgId: number
  userType: number
  city: number
  backgroundUrl: string
  followeds: number
  follows: number
  eventCount: number
  playlistCount: number
  playlistBeSubscribedCount: number
}


/** 用户详细信息请求结果实体类 */
export class UserDetailResultBean extends BaseResultBean {
  level: number
  listenSongs: number
  createTime: number
  createDays: number
  profile: UserDetailProfile
}

@Observed
export class UserDetailProfile {
  avatarUrl: string
  backgroundUrl: string
  gender: number
  nickname: string
  userId: string
  followeds: number
  follows: number
  playlistCount: number
}

export interface IUserInfoBean {
  detail: UserDetailResultBean | null
  cookie: string | null
}

export class UserInfoBean {
  detail: UserDetailResultBean
  cookie: string | null

  constructor(model: IUserInfoBean) {
    this.detail = model.detail
    this.cookie = model.cookie
  }
}

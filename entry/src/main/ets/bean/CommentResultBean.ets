import { BaseResultBean } from 'lib_common'

/**
 * 评论请求结果实体类
 */
export class CommentResultBean extends BaseResultBean {
  comments: CommentBean[]
}

export class CommentBean {
  user: CommentUserBean
  beReplied: object // todo
  commentId: number
  content: string
  time: number
  timeStr: string
  likedCount: number
  owner: boolean
  liked: boolean
}

export class CommentUserBean {
  avatarUrl: string
  nickname: string
  userId: number
}
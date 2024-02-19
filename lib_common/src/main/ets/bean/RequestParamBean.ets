import { PagingLayoutMediator, ViewState } from '..'

/**
 * 请求数据模型
 */
export interface IRequestBean {
  // 请求url
  url: string
  // 请求参数
  data?: object
  // 和页面绑定的ViewState
  viewState?: ViewState,
  // 分页协调工具
  pagingMediator?: PagingLayoutMediator,
  // 请求成功条件，默认code==200
  successCondition?: (result: object) => boolean
  // 范围空条件
  emptyCondition?: (result: object) => boolean
  // 分页数据转换
  pagingListConverter?: (result: object) => object[]
  // 请求失败时是否还返回result
  interceptWhenNoSuccess?: boolean
}

export class RequestBean {
  url: string
  data?: object
  viewState?: ViewState
  pagingMediator?: PagingLayoutMediator = null
  successCondition?: (result: object) => boolean = null
  emptyCondition?: (result: object) => boolean = null
  pagingListConverter?: (result: object) => object[] = null
  interceptWhenNoSuccess?: boolean = true

  constructor(bean: IRequestBean) {
    this.url = bean.url
    this.data = bean.data
    this.viewState = bean.viewState
    this.pagingMediator = bean.pagingMediator
    this.pagingListConverter = bean.pagingListConverter
    this.successCondition = bean.successCondition
    this.emptyCondition = bean.emptyCondition
    if (bean.interceptWhenNoSuccess != undefined) {
      this.interceptWhenNoSuccess = bean.interceptWhenNoSuccess
    }
  }
}
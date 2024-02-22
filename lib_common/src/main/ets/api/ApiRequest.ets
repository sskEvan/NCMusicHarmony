import { BaseResultBean, KVUtil, PagingLayoutMediator, RequestOptions, ViewState, ViewStateType } from '..'
import http from '@ohos.net.http'
import { LogUtil } from '../util/LogUtil';

const BASE_URL = "https://ncmusic.sskevan.cn"

export const KEY_COOKIE = "KEY_COOKIE"

interface EmptyInterface {}

async function sendRequest<T extends BaseResultBean>(
    url: string,
    method: http.RequestMethod,
    data?: object,
    viewState?: ViewState,
    pagingMediator?: PagingLayoutMediator,
    successCondition?: (result: object) => boolean,
    emptyCondition?: (result: object) => boolean,
    pagingListConverter?: (result: object) => object[],
    interceptWhenNoSuccess?: boolean,
): Promise<T> {
  const handleLoadingViewState = viewState && ((pagingMediator && pagingMediator.page == 1 && pagingMediator.lazyDataSource.totalCount() == 0) || !pagingMediator)
  const handleOtherViewState = viewState && ((pagingMediator && pagingMediator.page == 1) || !pagingMediator)
  try {
    if (handleLoadingViewState) {
      viewState.type = ViewStateType.LOADING
    }

    let requestUrl = BASE_URL + url

    let urlParam = ""
    const localCookie = await KVUtil.getString("KEY_COOKIE")
    if (method === http.RequestMethod.GET) {
      if (data && Object.keys(data).length) {
        urlParam += "?" + Object.keys(data).map(key => {
          if (data[key]) {
            return `${key}=${encodeURIComponent(data[key])}`
          }
          return ""
        }).join("&")
        if (localCookie) {
          urlParam += "&cookie=" + encodeURIComponent(localCookie)
        }
      } else {
        if (localCookie) {
          urlParam += "?cookie=" + encodeURIComponent(localCookie)
        }
      }
    }

    requestUrl += urlParam
    LogUtil.debug(`sendRequest=>url=${requestUrl}`)
    const res = await http.createHttp().request(requestUrl, {
      method: method,
      extraData: method === http.RequestMethod.GET ? "" : data || {} as EmptyInterface,
      header: {
        'Content-Type': 'application/json',
      }
    })
    // const result = plainToInstance(Object, JSON.parse(res.result as string)) as T
    const result = JSON.parse(res.result as string) as T
    LogUtil.debug(`sendRequest=>result=${res.result as string}`)
    let isEmpty = emptyCondition && emptyCondition(result)
    if (successCondition ? successCondition(result) : result.code == 200) {
      if (handleOtherViewState) {
        if (isEmpty) {
          viewState.type = ViewStateType.EMPTY
        } else {
          viewState.type = ViewStateType.SUCCESS

        }
      }
      if (pagingMediator) {
        const isRefresh = pagingMediator.page == 1
        const list = isEmpty ? [] : pagingListConverter(result)
        if (isRefresh) {
          pagingMediator.finishRefresh(true, list)
        } else {
          pagingMediator.finishLoadMore(true, list)
        }
      }
      return result
    } else {
      if (handleOtherViewState) {
        viewState.type = ViewStateType.ERROR
        viewState.errorCode = result.code
        viewState.errorMessage = result.message
      }
      if (pagingMediator) {
        const isRefresh = pagingMediator.page == 1
        if (isRefresh) {
          pagingMediator.finishRefresh(false)
        } else {
          pagingMediator.finishLoadMore(false)
        }
      }
      if (!interceptWhenNoSuccess) {
        return result
      } else {
        return
      }
    }
  } catch (error) {
    LogUtil.debug(`sendRequest=>error=${JSON.stringify(error)}`)
    if (handleOtherViewState) {
      viewState.type = ViewStateType.ERROR
      if (error.code && error.message) {
        viewState.errorCode = error.code
        viewState.errorMessage = error.message
      } else {
        viewState.errorCode = -1
        viewState.errorMessage = "未知错误"
      }
    }
    if (pagingMediator) {
      const isRefresh = pagingMediator.page == 1
      if (isRefresh) {
        pagingMediator.finishRefresh(false)
      } else {
        pagingMediator.finishLoadMore(false)
      }
    }
  }
}

export class ApiRequest {
  static async get<T extends BaseResultBean>(
    options: RequestOptions
  ): Promise<T> {
    return sendRequest(options.url,
      http.RequestMethod.GET,
      options.data,
      options.viewState,
      options.pagingMediator,
      options.successCondition,
      options.emptyCondition,
      options.pagingListConverter,
      options.interceptWhenNoSuccess)
  }

  static async post<T extends BaseResultBean>(
    options: RequestOptions
  ): Promise<T> {
    return sendRequest(options.url,
      http.RequestMethod.POST,
      options.data,
      options.viewState,
      options.pagingMediator,
      options.successCondition,
      options.emptyCondition,
      options.pagingListConverter,
      options.interceptWhenNoSuccess)
  }
}



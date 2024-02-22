import { BaseResultBean, RequestOptions, ApiRequest } from '..'

export class BaseViewModel {
  async get<T extends BaseResultBean>(
    requestBean: RequestOptions
  ): Promise<T> {
    return ApiRequest.get(requestBean)
  }


  async post<T extends BaseResultBean>(
    requestBean: RequestOptions
  ): Promise<T> {
    return ApiRequest.post(requestBean)
  }
}



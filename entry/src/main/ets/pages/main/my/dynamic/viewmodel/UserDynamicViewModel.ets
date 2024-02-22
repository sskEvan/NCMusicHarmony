import { BaseViewModel, PagingLayoutMediator, RequestOptions, ViewState } from 'lib_common';
import { DynamicBean, UserDynamicResultBean, ApiConstant } from '../../../../..';

/**
 * 首页-我的-动态ViewModel
 */
export class UserDynamicViewModel extends BaseViewModel {

   lastTime : number = -1

  async getUserDynamicList(uid: string,
                           viewState: ViewState,
                           pagingMediator: PagingLayoutMediator) {

    const result = await this.get<UserDynamicResultBean>(
      new RequestOptions({
        url: ApiConstant.URL_USER_DYNAMIC,
        data: {
          "uid": uid,
          "limit": pagingMediator.pageCount,
          "lasttime": pagingMediator.page == 1 ? -1 : this.lastTime
        },
        viewState: viewState,
        pagingMediator: pagingMediator,
        pagingListConverter: (result: UserDynamicResultBean) => {
          return result.events.map((item: DynamicBean) => {
            item.jsonBean = JSON.parse(item.json.replace("\\\"", "\"")
              .replace("\\n", "/")
            )
            return item
          })
        },
        emptyCondition: (result: UserDynamicResultBean) => {
          return (!result.events) || result.events.length == 0
        }
      }))
    if (result) {
      this.lastTime = result.lasttime
    }
  }
}

export const userDynamicViewModel = new UserDynamicViewModel();


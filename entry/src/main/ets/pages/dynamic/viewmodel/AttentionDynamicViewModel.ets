import { BaseViewModel, PagingLayoutMediator, RequestOptions, ViewState } from 'lib_common';
import { DynamicBean, DynamicResultBean, ApiConstant } from '../../..';

/**
 * 动态-关注ViewModel
 */
export class AttentionDynamicViewModel extends BaseViewModel {
  private lastTime: number = -1

  async getDynamicList(viewState: ViewState,
                       pagingMediator: PagingLayoutMediator) {

    const result = await this.get<DynamicResultBean>(
      new RequestOptions({
        url: ApiConstant.URL_DYNAMIC,
        data: {
          "pagesize": pagingMediator.pageCount,
          "lasttime": pagingMediator.page == 1 ? -1 : this.lastTime
        },
        viewState: viewState,
        pagingMediator: pagingMediator,
        pagingListConverter: (result: DynamicResultBean) => {
          return result.event.map((item: DynamicBean) => {
            item.jsonBean = JSON.parse(item.json.replace("\\\"", "\"")
              .replace("\\n", "/")
            )
            return item
          })
        },
        emptyCondition: (result: DynamicResultBean) => {
          return (!result.event) || result.event.length == 0
        }
      }))
    if (result) {
      this.lastTime = result.lasttime
    }
  }


}

export const attentionDynamicViewModel = new AttentionDynamicViewModel()
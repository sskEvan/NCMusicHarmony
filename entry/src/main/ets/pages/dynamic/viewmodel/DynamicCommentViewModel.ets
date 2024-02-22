import { BaseViewModel, PagingLayoutMediator, RequestOptions, ViewState } from 'lib_common';
import { CommentResultBean, ApiConstant } from '../../..';

/**
 * 动态评论ViewModel
 */
export class DynamicCommentViewModel extends BaseViewModel {
  async getCommentList(threadId: string, viewState: ViewState, pagingMediator: PagingLayoutMediator) {

    this.get<CommentResultBean>(
      new RequestOptions({
        url: ApiConstant.URL_DYNAMIC_COMMENT,
        data: {
          "limit": pagingMediator.pageCount,
          "offset": (pagingMediator.page - 1) * pagingMediator.pageCount,
          "threadId": threadId
        },
        viewState: viewState,
        pagingMediator: pagingMediator,
        pagingListConverter: (result: CommentResultBean) => {
          return result.comments
        },
        emptyCondition: (result: CommentResultBean) => {
          return result.comments.length == 0
        }
      }))

  }
}

export const dynamicCommentViewModel = new DynamicCommentViewModel()
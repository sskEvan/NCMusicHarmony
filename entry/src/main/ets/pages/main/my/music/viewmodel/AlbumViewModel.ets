import { BaseViewModel, PagingLayoutMediator, RequestOptions, ViewState } from 'lib_common'
import { AlbumResultBean, ApiConstant } from '../../../../..'

/**
 * 首页-我的-音乐-专辑ViewModel
 */
export class AlbumViewModel extends BaseViewModel {
  async getAlbumList(viewState: ViewState,
                     pagingMediator: PagingLayoutMediator) {

    this.get<AlbumResultBean>(
      new RequestOptions({
        url: ApiConstant.URL_COLLECT_ALBUM_LIST,
        data: {
          "limit": pagingMediator.pageCount,
          "offset": (pagingMediator.page - 1) * pagingMediator.pageCount
        },
        viewState: viewState,
        pagingMediator: pagingMediator,
        pagingListConverter: (result: AlbumResultBean) => {
          return result.data
        }
      }))
  }
}

export const albumViewModel = new AlbumViewModel()

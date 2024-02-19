import { BaseViewModel, PagingLayoutMediator, RequestBean, ViewState } from 'lib_common';
import { UserPlaylistBean, UserPlaylistResultBean } from '../../../../../bean/UserPlaylistResultBean';
import { ApiConstant } from '../../../../../common';

export class SongSheetViewModel extends BaseViewModel {
  async getUserPlayList(uid: string,
                        isSelfCreate: boolean,
                        viewState: ViewState,
                        pagingMediator: PagingLayoutMediator) {

    this.get<UserPlaylistResultBean>(
      new RequestBean({
        url: ApiConstant.URL_USER_PLAY_LIST,
        data: { "uid": uid },
        viewState: viewState,
        pagingMediator: pagingMediator,
        pagingListConverter: (result: UserPlaylistResultBean) => {
          return result.playlist.filter((item: UserPlaylistBean) => {
            return isSelfCreate ? item.userId.toString() == uid : item.userId.toString() != uid
          })
        }
      }))
  }
}

export const songSheetViewModel = new SongSheetViewModel();

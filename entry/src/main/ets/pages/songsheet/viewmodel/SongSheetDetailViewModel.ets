import { BaseViewModel, PagingLayoutMediator, RequestOptions, ViewState } from 'lib_common';
import { SongSheetDetailResultBean, ApiConstant, UserPlayListDetailResultBean } from '../../..';


/**
 * 歌单详情ViewModel
 */
export class SongSheetDetailViewModel extends BaseViewModel {
  async getSongDetail(id: number,
                      viewState: ViewState,
                      pagingMediator: PagingLayoutMediator): Promise<UserPlayListDetailResultBean> {

    const playlistDetailResultBean = await this.get<UserPlayListDetailResultBean>(
      new RequestOptions({
        url: ApiConstant.URL_PLAY_LIST_DETAIL,
        data: { "id": id },
        viewState: viewState,
      }))
    if (playlistDetailResultBean) {
      const trackIdBeans = playlistDetailResultBean.playlist.trackIds
      let ids = ""
      if (trackIdBeans) {
        for (let index = 0; index < trackIdBeans.length; index++) {
          ids += trackIdBeans[index].id;
          if (index != trackIdBeans.length - 1) {
            ids += ","
          }
        }
      }
      this.get<SongSheetDetailResultBean>(
        new RequestOptions({
          url: ApiConstant.URL_SONG_DETAIL,
          data: { "ids": ids },
          viewState: viewState,
          pagingMediator: pagingMediator,
          pagingListConverter: (result: SongSheetDetailResultBean) => {
            return result.songs
          }
        }))
    }
    return playlistDetailResultBean
  }
}

export const songSheetDetailViewModel = new SongSheetDetailViewModel();

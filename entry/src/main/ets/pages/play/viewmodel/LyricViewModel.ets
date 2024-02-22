import { BaseViewModel, RequestOptions, ViewState } from 'lib_common';
import { ApiConstant } from '../../..';
import { LyricModel, LyricResultBean } from '../../../bean/LyricResultBean';
import { LyricUtil } from '../../../common/util/LyricUtil';

export class LyricViewModel extends BaseViewModel {
  async fetchData(id: number, viewState: ViewState) : Promise<LyricModel[]> {
    const lyricResult = await this.get<LyricResultBean>(
      new RequestOptions({
        url: ApiConstant.URL_LYRIC,
        data: { "id": id},
        viewState: viewState
      }))

    const lyricModels = LyricUtil.parse(lyricResult)
    return lyricModels
  }
}

export const lyricViewModel = new LyricViewModel()
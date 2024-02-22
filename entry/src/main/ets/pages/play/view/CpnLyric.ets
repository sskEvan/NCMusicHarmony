import { ListDataSource, SizeConstant, ViewStateLayout, ViewState } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { MusicPlayController, LyricModel, lyricViewModel } from '../../..'

/**
 * 歌词组件
 */
@Component
export struct CpnLyric {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  lazyDataSource: ListDataSource = new ListDataSource()
  @Prop @Watch("indexChange") index: number
  @Prop @Watch("currentDuringChange") currentDuring: number
  @State @Watch("currentPlayLineChange") currentPlayLine: number = 0
  viewState: ViewState | undefined = undefined
  scroller: Scroller = new Scroller()

  build() {
    ViewStateLayout({ onLoadData: async (viewState) => {
      this.viewState = viewState
      this.lazyDataSource.reloadData(await lyricViewModel.fetchData(MusicPlayController.playList[this.index].id, viewState))
    } }) {
      List({ space: 0, scroller: this.scroller }) {
        LazyForEach(this.lazyDataSource, (item: LyricModel, index: number) => {
          ListItem() {
            Column() {
              if (item.lyric) {
                Text(item.lyric)
                  .textAlign(TextAlign.Center)
                  .fontSize(SizeConstant.TEXT_M)
                  .fontColor(this.currentPlayLine != index ? Color.White : AppTheme.palette(this.themeType).primary)
                  .width("100%")
                  .margin(SizeConstant.SPACE_S)
              }
              if (item.tLyric) {
                Text(item.tLyric)
                  .textAlign(TextAlign.Center)
                  .fontSize(SizeConstant.TEXT_S)
                  .fontColor(this.currentPlayLine != index ? Color.White : AppTheme.palette(this.themeType).primary)
                  .width("100%")
                  .margin(SizeConstant.SPACE_S)
              }
            }.padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
          }
        }, (item: object, _) => {
          return JSON.stringify(item)
        })
      }.margin({ top: SizeConstant.SPACE_XXL, bottom: SizeConstant.SPACE_XXL }).width("100%")
    }
  }

  currentDuringChange() {
    for (let index = 0; index < this.lazyDataSource.dataArray.length; index++) {
      const model = this.lazyDataSource.dataArray[index] as LyricModel
      if (this.currentDuring < model.time) {
        this.currentPlayLine = Math.max(0, index - 1)
        return
      }
    }
  }

  async indexChange() {
    this.lazyDataSource.reloadData(await lyricViewModel.fetchData(MusicPlayController.playList[this.index].id, this.viewState))
  }

  currentPlayLineChange() {
    this.scroller.scrollToIndex(this.currentPlayLine)
  }
}

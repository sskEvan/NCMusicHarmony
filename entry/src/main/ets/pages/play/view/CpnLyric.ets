
import { ListDataSource, SizeConstant } from 'lib_common'

/**
 * 歌词组件
 */
@Component
export struct CpnLyric {
  lazyDataSource: ListDataSource = new ListDataSource()

  aboutToAppear() {
    for (let index = 0; index < 100; index++) {
      this.lazyDataSource.pushData({ index })
    }
  }

  build() {
    List({ space: 0 }) {
      LazyForEach(this.lazyDataSource, (_, index) => {
        ListItem() {
          Text(`歌词 item ${index}`)
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .width("100%")
        }
      })
    }.margin({ top: SizeConstant.SPACE_XXL, bottom: SizeConstant.SPACE_XXL }).width("100%")
  }
}
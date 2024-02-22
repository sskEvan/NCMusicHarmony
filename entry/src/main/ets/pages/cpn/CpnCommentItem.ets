import { CommonNetworkImage, SizeConstant, TimeUtil } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { CommentBean } from '../..'

/**
 * 评论item组件
 */
@Component
export struct CpnCommentItem {
  bean: CommentBean
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT

  build() {
    Row() {
      CommonNetworkImage({url: this.bean.user.avatarUrl, placeHolder: $r('app.media.ic_default_avatar')})
        .width(34)
        .height(34)
        .borderRadius(17)
        .clip(true)
        .margin({ right: SizeConstant.SPACE_M })

      Column() {
        this.HeaderBuilder()
        this.ContentBuilder()
        this.DividerBuilder()
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }
    .width("100%")
    .alignItems(VerticalAlign.Top)
    .padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L, top: SizeConstant.SPACE_M })

  }

  @Builder HeaderBuilder() {
    Row() {
      Column() {
        Text(this.bean.user.nickname)
          .fontSize(SizeConstant.TEXT_M)
          .fontColor(AppTheme.palette(this.themeType).firstText)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: SizeConstant.SPACE_S })

        Text(TimeUtil.formatDate(this.bean.time))
          .fontSize(SizeConstant.TEXT_S)
          .fontColor(AppTheme.palette(this.themeType).thirdText)
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)

      Row() {
        Text(this.bean.likedCount.toString())
          .fontSize(SizeConstant.TEXT_M)
          .fontColor(AppTheme.palette(this.themeType).thirdText)

        Image($r('app.media.ic_like'))
          .width(SizeConstant.ICON_S)
          .height(SizeConstant.ICON_S)
          .margin({ left: SizeConstant.SPACE_M })
          .fillColor(AppTheme.palette(this.themeType).thirdIcon)
      }.justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
    }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder ContentBuilder() {
    Text(this.bean.content)
      .fontSize(SizeConstant.TEXT_L)
      .fontColor(AppTheme.palette(this.themeType).firstText)
      .margin({ top: SizeConstant.SPACE_L, bottom: SizeConstant.SPACE_L })
  }

  @Builder DividerBuilder() {
    Stack().width("100%").height("1px").backgroundColor(AppTheme.palette(this.themeType).divider)
  }
}
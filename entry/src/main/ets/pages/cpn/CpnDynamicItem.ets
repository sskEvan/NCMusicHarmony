import { ClickEffectLayout, CommonNetworkImage, RouterUrls, SizeConstant, TimeUtil } from 'lib_common'
import { AppTheme, THEME_TYPE, ThemeType } from 'lib_theme'
import router from '@ohos.router'
import {
  DynamicBean,
  DynamicPics,
  DynamicSongBean,
  UserPlaylistBean,
  PicturePreviewRouterParams,
  PicturePreviewBean,
  DynamicDetailPageParam,
} from '../..'
import promptAction from '@ohos.promptAction'

@Component
export struct CpnDynamicItem {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  dynamicBean: DynamicBean
  isInList: boolean = true
  dataChangedCallback: () => void
  @State liked: boolean = false
  @State likedCount: number = 0

  aboutToAppear() {
    this.liked = this.dynamicBean.info.liked
    this.likedCount = this.dynamicBean.info.likedCount
  }

  build() {
    ClickEffectLayout({ click: this.isInList ? () => {
      router.pushUrl({ url: RouterUrls.DynamicDetail, params: new DynamicDetailPageParam(this.dynamicBean) })
    } : null }) {
      Row() {
        CommonNetworkImage({ url: this.dynamicBean.user.avatarUrl, placeHolder: $r('app.media.ic_default_avatar') })
          .width(34)
          .height(34)
          .borderRadius(17)
          .margin({ right: SizeConstant.SPACE_M })
          .clip(true)
        Column() {
          this.HeaderBuilder()
          this.ContentBuilder()
          if (this.isInList) {
            this.BottomBuilder()
            this.DividerBuilder()
          }
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      }
      .padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L, top: SizeConstant.SPACE_M })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Top)
      .backgroundColor(AppTheme.palette(this.themeType).commonBackground)
    }
  }

  @Builder HeaderBuilder() {
    Column() {
      Text(this.dynamicBean.user.nickname)
        .fontSize(SizeConstant.TEXT_L)
        .fontColor(AppTheme.palette(this.themeType).firstText)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: SizeConstant.SPACE_S })

      Text(TimeUtil.formatDate(this.dynamicBean.eventTime))
        .fontSize(SizeConstant.TEXT_S)
        .fontColor(AppTheme.palette(this.themeType).thirdText)
    }.alignItems(HorizontalAlign.Start)
  }

  @Builder ContentBuilder() {
    Column() {
      Text(this.dynamicBean.jsonBean?.msg || "")
        .fontSize(SizeConstant.TEXT_M)
        .fontColor(AppTheme.palette(this.themeType).firstText)
      if (this.dynamicBean.pics.length) {
        this.ContentPicBuilder(this.dynamicBean.pics)
      }
      if (this.dynamicBean.jsonBean?.playlist) {
        this.PlayListItemBuilder(this.dynamicBean.jsonBean.playlist)
      }
      if (this.dynamicBean.jsonBean.song) {
        this.SongItemBuilder(this.dynamicBean.jsonBean.song)
      }
    }.margin({ top: SizeConstant.SPACE_M }).alignItems(HorizontalAlign.Start)
  }

  @Builder ContentPicBuilder(pics: DynamicPics[]) {
    if (pics.length == 1) {
      ClickEffectLayout({ click: () => {
        router.pushUrl({ url: RouterUrls.PicturePreview,
          params: new PicturePreviewRouterParams(0, pics.map((item: DynamicPics) => {
            return new PicturePreviewBean(item.originUrl)
          })) })
      } }) {
        CommonNetworkImage({ url: pics[0].originUrl })
          .width(this.getImageSize(1, pics[0]).width)
          .height(this.getImageSize(1, pics[0]).height)
          .borderRadius(SizeConstant.RADIUS_L)
          .margin({ top: SizeConstant.SPACE_M })
          .clip(true)
          .sharedTransition(`picPreview:${pics[0].originUrl}`, {
            duration: 300,
            curve: Curve.Linear
          })
      }

    } else {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(pics, (pic: DynamicPics, index: number) => {
          ClickEffectLayout({ click: () => {
            router.pushUrl({ url: RouterUrls.PicturePreview,
              params: new PicturePreviewRouterParams(index, pics.map((item: DynamicPics) => {
                return new PicturePreviewBean(item.originUrl)
              })) })
          } }) {
            CommonNetworkImage({ url: pic.originUrl })
              .width(this.getImageSize(pics.length, pic).width)
              .height(this.getImageSize(pics.length, pic).height)
              .margin({ bottom: this.getImageMarginBottom(pics.length, index) })
              .sharedTransition(`picPreview:${pics[index].originUrl}`, {
                duration: 300,
                curve: Curve.Linear
              })
          }
        })
      }.width('100%')
      .clip(true)
      .borderRadius(SizeConstant.RADIUS_L)
      .margin({ top: SizeConstant.SPACE_M })
    }

  }

  getImageSize(count: number, pic: DynamicPics): SizeOptions {
    if (count == 1) {
      const maxSize = 200
      let width = maxSize
      let height = maxSize
      if (pic.width && pic.width != 0 && pic.height && pic.height != 0) {
        if (pic.width > pic.height) {
          height *= (pic.height * 1.0 / pic.width)
        } else {
          width *= (pic.width * 1.0 / pic.height)
        }
      }
      return { width: width, height: height }
    } else if (count <= 4) {
      return { width: 143, height: 143 }
    } else {
      return { width: 94.67, height: 94.67 }
    }
  }

  getImageMarginBottom(count: number, index: number): number {
    if (count <= 4) {
      return (index + 1) / 2.0 <= 1 ? 2 : 0
    } else {
      return (index + 1) / 3.0 <= Math.floor(((count + 2) / 3.0 - 1)) ? 2 : 0
    }
  }

  @Builder PlayListItemBuilder(playListBean: UserPlaylistBean) {
    Row() {
      CommonNetworkImage({ url: playListBean.coverImgUrl })
        .width(SizeConstant.ICON_XXL)
        .height(SizeConstant.ICON_XXL)
        .borderRadius(SizeConstant.RADIUS_M)
        .margin({ right: SizeConstant.SPACE_M })
        .clip(true)

      Column() {
        Text(playListBean.name)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(SizeConstant.TEXT_M)
          .fontColor(AppTheme.palette(this.themeType).firstText)
          .margin({ bottom: SizeConstant.SPACE_S })
        Text(playListBean.creator.nickname)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(SizeConstant.TEXT_S)
          .fontColor(AppTheme.palette(this.themeType).thirdText)
      }.alignItems(HorizontalAlign.Start)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width("100%")
    .height(44)
    .backgroundColor(AppTheme.palette(this.themeType).deepenBackground)
    .margin({ top: SizeConstant.SPACE_M })
    .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
    .borderRadius(SizeConstant.RADIUS_M)
  }

  @Builder SongItemBuilder(songBean: DynamicSongBean) {
    Row() {
      Image(songBean.album.picUrl)
        .width(SizeConstant.ICON_XXL)
        .height(SizeConstant.ICON_XXL)
        .borderRadius(SizeConstant.RADIUS_M)
        .fillColor(AppTheme.palette(this.themeType).thirdIcon)
        .margin({ right: SizeConstant.SPACE_M })

      Column() {
        Text(songBean.name)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(SizeConstant.TEXT_M)
          .fontColor(AppTheme.palette(this.themeType).firstText)
          .margin({ bottom: SizeConstant.SPACE_S })
        Text(songBean.artists[0].name)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(SizeConstant.TEXT_S)
          .fontColor(AppTheme.palette(this.themeType).thirdText)
      }.alignItems(HorizontalAlign.Start)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width("100%")
    .height(44)
    .backgroundColor(AppTheme.palette(this.themeType).deepenBackground)
    .margin({ top: SizeConstant.SPACE_M })
    .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
    .borderRadius(SizeConstant.RADIUS_M)
  }

  @Builder BottomBuilder() {
    Row() {
      Row() {
        CpnActionItem({
          icon: $r('app.media.ic_comment'),
          value: this.dynamicBean.info.commentCount.toString(),
          isChecked: false,
          click: () => {
            router.pushUrl({ url: RouterUrls.DynamicDetail, params: new DynamicDetailPageParam(this.dynamicBean, 0) })
          }
        })
        CpnActionItem({
          icon: $r('app.media.ic_share'),
          value: this.dynamicBean.info.shareCount.toString(),
          isChecked: false,
          click: () => {
            router.pushUrl({ url: RouterUrls.DynamicDetail, params: new DynamicDetailPageParam(this.dynamicBean, 1) })
          }
        })
        CpnActionItem({ icon: $r('app.media.ic_like'),
          value: this.likedCount.toString(),
          isChecked: this.liked,
          click: () => {
            // item局部更新，写起来实在是真鸡儿麻烦
            // 通过DataSource通知更新item，整个item重建会造成图片闪烁
            // 目前实现方式是item内部定义状态变量，同时更新item bean的属性值
            promptAction.showToast({ message: `测试：${this.dynamicBean.info.liked ? "取消点赞" : "点赞"}` })
            this.liked = !this.liked
            this.likedCount = this.likedCount + (this.liked ? 1 : -1)
            this.dynamicBean.info.liked = this.liked
            this.dynamicBean.info.likedCount = this.likedCount
          } })
      }

      Image($r('app.media.ic_more'))
        .width(SizeConstant.ICON_M)
        .height(SizeConstant.ICON_M)
        .fillColor(AppTheme.palette(this.themeType).thirdIcon)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width("100%")
    .margin({ bottom: SizeConstant.SPACE_M, top: SizeConstant.SPACE_M })
  }

  @Builder DividerBuilder() {
    Stack().width("100%").height("1px").backgroundColor(AppTheme.palette(this.themeType).divider)
  }
}


@Component
struct CpnActionItem {
  icon: Resource
  @Prop value: string
  @Prop isChecked: boolean
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  click: () => void = null

  build() {
    ClickEffectLayout({ click: this.click }) {
      Row() {
        Image(this.icon)
          .width(SizeConstant.ICON_S)
          .height(SizeConstant.ICON_S)
          .fillColor(this.isChecked
            ? AppTheme.palette(this.themeType).primary
            : AppTheme.palette(this.themeType).thirdIcon)
          .margin({ right: SizeConstant.SPACE_S })
        Text(this.value)
          .fontSize(SizeConstant.TEXT_S)
          .fontColor(this.isChecked
            ? AppTheme.palette(this.themeType).primary
            : AppTheme.palette(this.themeType).thirdText)
      }.padding({ right: 34 }).height(26).alignItems(VerticalAlign.Center)
    }

  }
}
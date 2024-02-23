import {
  ClickEffectLayout,
  CollapsibleLayout,
  CollapsibleMediator,
  CommonAppBar,
CommonNetworkImage,
LogUtil,
  PagingLayoutMediator,
  RouterUrls,
  ScreenUtils,
  SizeConstant,
  StringUtil,
  ViewState,
  ViewStatePagingLayout
} from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import router from '@ohos.router'
import {
  CpnMusicPlayBar,
  EventIds,
  MusicPlayController,
  PlayerStatus,
  SongBean,
  UserPlaylistBean,
  UserPlayListDetailResultBean,
  songSheetDetailViewModel
} from '../../..'
import emitter from '@ohos.events.emitter'

/**
 * 歌单详情页面
 */
@Entry
@Component
struct SongSheetDetailPage {
  @State private collapsibleProgress: number = 0
  @State private collapsibleMediator: CollapsibleMediator = new CollapsibleMediator((progress: number) => {
    this.collapsibleProgress = progress
  })
  @Provide playListBean: Partial<UserPlaylistBean> = {}
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  // 播放状态
  @State playerStatus: PlayerStatus | undefined = undefined

  aboutToAppear() {
    this.playListBean = router.getParams() as UserPlaylistBean
    // 监听播放状态
    emitter.on({ eventId: EventIds.PLAYER_STATUS }, (data) => {
      this.playerStatus = data.data.status
    })
  }

  // aboutToDisappear() {
  //   emitter.off(EventIds.PLAYER_STATUS)
  // }

  @Builder CustomerTitleBuilder() {
    Text(this.collapsibleProgress >= 0.4 ? this.playListBean.name : "歌单")
      .fontSize(SizeConstant.TEXT_XL)
      .fontWeight(FontWeight.Bold)
      .fontColor(Color.White)
      .maxLines(1)
      .width("100%")
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .margin({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
  }

  @Builder AppBarBuilder() {
    CommonAppBar({
      contentColor: Color.White,
      bgColor: Color.Transparent,
      titleCenter: false,
      leftIcon: $r('app.media.ic_back'),
      rightIcons: [$r('app.media.ic_search')],
      CustomerTitleBuilder: () => {
        this.CustomerTitleBuilder()
      }
    })
  }

  @Builder ScrollableHeaderBuilder() {
    SongSheetDetailScrollableHeader({
      collapsibleProgress: this.collapsibleProgress
    })
  }

  @Builder StickyHeaderBuilder() {
    Stack() {
      Row() {
        Image($r('app.media.ic_play_start'))
          .width(SizeConstant.ICON_L)
          .height(SizeConstant.ICON_L)
          .fillColor(AppTheme.palette(this.themeType).primary)
          .margin({ right: SizeConstant.SPACE_L })
        Text("播放全部")
          .fontSize(SizeConstant.TEXT_L)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.palette(this.themeType).firstText)
        Text(`(${this.playListBean.trackCount})`)
          .fontSize(SizeConstant.TEXT_M)
          .fontColor(AppTheme.palette(this.themeType).thirdText)
      }
      .width("100%")
      .height(42)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(AppTheme.palette(this.themeType).commonBackground)
      .padding({ left: SizeConstant.SPACE_L })
    }
  }

  @Builder ContentBuilder() {
    SongSheetDetailContent({ mediator: this.collapsibleMediator })
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      CollapsibleLayout({
        AppBarBuilder: () => {
          this.AppBarBuilder()
        },
        ScrollableHeaderBuilder: () => {
          this.ScrollableHeaderBuilder()
        },
        StickyHeaderBuilder: () => {
          this.StickyHeaderBuilder()
        },
        ContentBuilder: () => {
          this.ContentBuilder()
        },
        mediator: this.collapsibleMediator
      }).margin({
        bottom: (this.playerStatus ?? PlayerStatus.NONE !== PlayerStatus.NONE) ? SizeConstant.MUSIC_PLAY_BAR_HEIGHT : 0
      })
      if (this.playerStatus ?? PlayerStatus.NONE !== PlayerStatus.NONE) {
        CpnMusicPlayBar()
      }
    }
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 300, curve: Curve.Linear })
      .opacity(0)
    PageTransitionEnter({ type: RouteType.Pop, duration: 300, curve: Curve.Linear })
      .opacity(1)
    PageTransitionExit({ type: RouteType.Push, duration: 300, curve: Curve.Linear })
      .opacity(1)
    PageTransitionExit({ type: RouteType.Pop, duration: 300, curve: Curve.Linear })
      .opacity(0)
  }
}

@Component
struct SongSheetDetailScrollableHeader {
  @Consume @Watch("playListBeanChange") playListBean: UserPlaylistBean
  @Prop collapsibleProgress: number
  @State shareCount: number = 0

  playListBeanChange() {
    LogUtil.debug("SongSheetDetailScrollableHeader playListBeanChange result.playlist.shareCount=" + this.playListBean.shareCount)
    this.shareCount = this.playListBean.shareCount || 0
  }

  build() {
    Stack() {
      Stack() {
        Image(this.playListBean.coverImgUrl)
          .width("100%")
          .height("100%")
          .backgroundColor(Color.Black)
          .blur(100)
        Stack().width("100%")
          .height("100%").backgroundColor("#55000000")
      }.width("100%")
      .height("100%")

      Column() {
        Row() {
          Image(this.playListBean.coverImgUrl)
            .width(96)
            .height(96)
            .margin({ right: SizeConstant.SPACE_M })
            .borderRadius(SizeConstant.RADIUS_M)
            .opacity(1 - this.collapsibleProgress)

          Column() {
            Text(this.playListBean.name)
              .fontSize(SizeConstant.TEXT_L)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .margin({ bottom: SizeConstant.SPACE_M })
              .opacity(1 - this.collapsibleProgress)
            Row() {
              CommonNetworkImage({url : this.playListBean.creator?.avatarUrl, placeHolder : $r('app.media.ic_default_avatar')})
                .width(18)
                .height(18)
                .borderRadius(9)
                .clip(true)
                .margin({ right: SizeConstant.SPACE_S })
                .opacity(1 - this.collapsibleProgress)

              Text(this.playListBean.creator?.nickname || "未知")
                .fontSize(SizeConstant.TEXT_M)
                .fontColor("#FFEEEEEE")
            }.alignItems(VerticalAlign.Center)
            .margin({ bottom: SizeConstant.SPACE_M })
            .opacity(1 - this.collapsibleProgress)

            Text(`简介：${this.playListBean.description || "暂无"}`)
              .fontSize(SizeConstant.TEXT_S)
              .fontColor("#FFEEEEEE")
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .opacity(1 - this.collapsibleProgress)
          }.layoutWeight(1).height(96).justifyContent(FlexAlign.Start).alignItems(HorizontalAlign.Start)
        }.width("100%").layoutWeight(1).justifyContent(FlexAlign.Start)

        Row() {
          this.ActionItemBuilder($r('app.media.ic_share'), "分享")
          this.ActionItemBuilder($r('app.media.ic_comment'), "评论")
          this.ActionItemBuilder($r('app.media.ic_collect'), "收藏")
        }
        .width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .opacity(1 - this.collapsibleProgress)
        .margin({ top: SizeConstant.SPACE_L, bottom: SizeConstant.SPACE_L })
      }
      .width("100%")
      .height("100%")
      .padding({
        top: SizeConstant.APP_BAR_HEIGHT + ScreenUtils.getStatusBarHeight() + SizeConstant.SPACE_L,
        left: SizeConstant.SPACE_L,
        right: SizeConstant.SPACE_L
      })
      .justifyContent(FlexAlign.Start)
    }.height(SizeConstant.APP_BAR_HEIGHT + ScreenUtils.getStatusBarHeight() + 170)
  }

  @Builder ActionItemBuilder(icon: Resource, text: string) {
    Row() {
      Image(icon)
        .width(SizeConstant.ICON_M)
        .height(SizeConstant.ICON_M)
        .margin({ right: SizeConstant.SPACE_S })
        .fillColor(Color.White)
      Text(this.getActionItemText(text))
        .fontSize(SizeConstant.TEXT_M)
        .fontColor(Color.White)
    }
    .backgroundColor("#33000000")
    .height(30)
    .borderRadius(15)
    .width(85)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 值传递Builder无法更新UI...臣妾实在是无法接受
   * @param text
   * @returns
   */
  getActionItemText(text): string {
    let resultText: string = text
    if (text == "分享" && this.playListBean.shareCount) {
      resultText = StringUtil.friendlyNumber(this.playListBean.shareCount)
    } else if (text == "评论" && this.playListBean.commentCount) {
      resultText = StringUtil.friendlyNumber(this.playListBean.commentCount)
    } else if (text == "收藏" && this.playListBean.subscribedCount) {
      resultText = StringUtil.friendlyNumber(this.playListBean.subscribedCount)
    }
    return resultText
  }
}


@Component
struct SongSheetDetailContent {
  @State pagingLayoutMediator: PagingLayoutMediator = new PagingLayoutMediator({})
  mediator: CollapsibleMediator
  @Consume playListBean: UserPlaylistBean
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT

  aboutToAppear() {
    this.pagingLayoutMediator = new PagingLayoutMediator({
      enableLoadMore: false,
      enableRefresh: false,
      collapsibleMediator: this.mediator,
      scroller: this.mediator.getCurrentInnerScroller()
    })
  }

  build() {
    Stack() {
      ViewStatePagingLayout({
        mediator: $pagingLayoutMediator,
        ItemBuilder: (item: object, index: number) => {
          this.SongItemBuilder(item as SongBean, index)
        },
        onLoadData: async (viewState: ViewState) => {
          const result: UserPlayListDetailResultBean = await songSheetDetailViewModel.getSongDetail(this.playListBean.id, viewState, this.pagingLayoutMediator)
          if (result) {
            this.playListBean = result.playlist
          }
        },
      }).backgroundColor(AppTheme.palette(this.themeType).commonBackground)
    }

  }

  @Builder SongItemBuilder(item: SongBean, index: number) {
    ClickEffectLayout({ click: () => {
      MusicPlayController.setDataSource(this.playListBean.id, this.pagingLayoutMediator.lazyDataSource.dataArray as SongBean[])
      MusicPlayController.play(index)
      router.pushUrl({ url: RouterUrls.MusicPlay })
    } }) {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Text(`${index + 1}`)
            .fontSize(SizeConstant.TEXT_L)
            .fontColor(AppTheme.palette(this.themeType).thirdText)
        }.width(42).height("100%")

        Column() {
          Text(item.name)
            .fontSize(SizeConstant.TEXT_M)
            .fontColor(AppTheme.palette(this.themeType).firstText)
            .margin({ bottom: SizeConstant.SPACE_S })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${item.ar[0].name}-${item.al.name}`)
            .fontSize(SizeConstant.TEXT_M)
            .fontColor(AppTheme.palette(this.themeType).secondText)
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Start).layoutWeight(1)

        Image($r('app.media.ic_more'))
          .width(SizeConstant.ICON_M + SizeConstant.SPACE_S * 2)
          .height(SizeConstant.ICON_M + SizeConstant.SPACE_S * 2)
          .padding(SizeConstant.SPACE_S)
          .fillColor(AppTheme.palette(this.themeType).thirdIcon)
      }.height(52).width("100%").padding({ right: SizeConstant.SPACE_L }).alignItems(VerticalAlign.Center)
    }
  }
}

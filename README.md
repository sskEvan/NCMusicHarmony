# NCMusicHarmony

### 前言
2024鸿蒙元年，写个鸿蒙的项目练练手～   
写什么项目？之前学习的时候写过Jetpack Compose的仿网易云应用[NCMusic](https://github.com/sskEvan/NCMusic)、
Compose Desktop的仿网易云桌面应用[NCMusicDesktop](https://github.com/sskEvan/NCMusicDesktop)、Flutter的仿段子乐应用[joke_fun_flutter](https://github.com/sskEvan/joke_fun_flutter)，
这次选择了网易云，写个鸿蒙版的仿网易云NCMusicHarmony。  
普通开发者不配像企业开发者有api11的开发权限，只能基于api9来开发。不写不知道，一写吓一跳，基于api9已有的组件想要来实现一些常见的交互效果并不太好搞。莎士比亚说放不放弃这是一个问题～最后还是决定强撸一把直至灰飞烟没吧。   
撸出来的效果还算差强任意，but～无图言吊？上动图先   
![img](https://github.com/sskEvan/NCMusicHarmony/blob/master/screenshot/首页.gif)
![img](https://github.com/sskEvan/NCMusicHarmony/blob/master/screenshot/广场.gif)
![img](https://github.com/sskEvan/NCMusicHarmony/blob/master/screenshot/音乐播放.gif)
![img](https://github.com/sskEvan/NCMusicHarmony/blob/master/screenshot/主题切换.gif)

### 状态管理
先简单概括一下ArkUI中的状态管理
- @State 用该修饰符修饰的变量表明该变量具有状态
- @Prop 父子组件之间的状态传递，单向驱动，api9只支持基础数据类型
- @Link 父子组件之间的数状态传递，双向驱动
- @Observed、@ObjectLink  父子组件之间的状态传递，处理具有嵌套类型变量的场景
- @Provide、@Consume 多层级后代组件的数据传递，双向驱动
- @Watch 状态变量变化监听
- LocalStorage 内存级别，不会写入硬盘，UIAbility内状态共享
- AppStorage 内存级别，不会写入硬盘，应用内状态共享
- PersistentStorage 状态持久化，配合AppStorage实现应用内写入磁盘

### 项目结构
![img](https://github.com/sskEvan/NCMusicHarmony/blob/master/screenshot/project_structure_1.jpg)
![img](https://github.com/sskEvan/NCMusicHarmony/blob/master/screenshot/project_structure_2.jpg)

### TabLayout、TabPager
官方虽然提供了Tabs、TabContent组件，在api9中，能够实现类似android中TabLayout+ViewPager的联动切换效果，但是实际开发中，有一些效果却不好实现，
例如Tab切换时候Indicator的偏移动画，而且构建UI的时候，标签栏和标签对应的内容是写在一起的，对于标签栏可以随着屏幕滚动并且吸顶的效果，不好实现。
所以自己定义了TabLayout和TabPager，二者配合TabLayoutPagerMediator实现联动。使用伪代码如下：
```
  @State tabediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({
    tabItems: [],  // Tab数据源
    cacheCount: 1,  // 页面缓存数量
    indexChangedCallback: (index: number) => {
      // tab索引变化回调
    }
  })
  TabLayout({mediator: this.tabMediator})
  TabPager({ mediator: this.tabMediator,
       TabPageBuilder: (index: number) => {
         // 页面插槽
       }})
```
最开始的版本TabPager并不支持懒加载，在做音乐播放界面的时候，有一个唱片左右滑动切歌的效果，是使用TabPager实现的，当歌曲列表有700多首歌时，
滑动切换起来很卡。临时替换成官方的Swiper来实现，虽然指定了Swiper的cacheCount，还是卡卡的，模拟了10000条数据，直接卡死。
不知道Swiper的cacheCount是怎么实现的。后面把自定义的TabLayout也改造成支持懒加载，
像Swiper一样通过指定cacheCount来缓存页面，模拟了10000条数据操作起来效果还行。

### CollapsibleLayout
嵌套滑动在日常开发中随处可见，但是在api9中，却没有简单的api提供给开发者快速实现
（在b站看到一个视频，在api10中，官方已经新增相关的nested api来处理这类场景，可惜我还不配使用api10），所以自定义了CollapsibleLayout来处理这种场景。  
先看一张图  
![img](https://github.com/sskEvan/NCMusicHarmony/blob/master/screenshot/CollapsibleLayout.png)  
- AppBar：固定在页面顶部的标题栏  
- ScrollHeader：可滚动头部
- StickyHeader：粘性头部，随着页面滚动后吸附在AppBar下方
- Content：内容区域  
CollapsibleLayout实现的大概思路在ScrollHeader、StickyHeader、Content外层套一个OuterScroller，Content内部如果有多个滚动区域（例如Content是个TabPager），
每个可滚动区域都提供一个InnerScroller，通过Scroller的onScrollFrameBegin方法来处理滑动逻辑。对外提供CollapsibleMediator来实现嵌套滑动。

### RefreshLayout
自定义了RefreshLayout来实现下拉刷新、上拉加载功能，使用伪代码如下：

```
  refreshMediator: RefreshMediator = new RefreshMediator()
  RefreshLayout({ refreshMediator: this.refreshMediator,
      ContentBuilder: () => { 
        // 内容区域
        this.ContentBuilder()
      },
      onRefresh: () => {
          // 刷新逻辑
          this.refreshMediator.finishRefresh(true)
      },
      onLoadMore: () => {
        // 加载更多逻辑
        this.refreshMediator.finishLoadMore()
      }
    })
   @Builder ContentBuilder() {
      List() {
      }.onReachEnd(() => {
          this.refreshMediator.scrollerReachEnd()
      })
      .onAreaChange((_, newValue: Area) => {
          this.refreshMediator.scrollerAreaChange(newValue)
      })
      .onScrollFrameBegin((offset: number, _) => {
         this.mediator.refreshMediator.getScrollerFrameRemainOffset(offset)
      })
  }
```
使用起来还挺复杂，还需调用refreshMediator的scrollerReachEnd()、scrollerAreaChange()、getScrollerFrameRemainOffset()这三坨方法～
其实最开始的实现是在RefreshLayout内部嵌了一个Scroll组件来协调滑动，这样在外层调用就不用写那三坨方法了。但是有一个问题：列表嵌套在Scroller里面，
必须指定列表的高度，不指定高度的话就算列表用了LazyForEach,ArkUI也是一次性全部加载所有item的，这样数据源一多就会卡卡卡，如果指了列表的高度，
那么内嵌的Scroll组件的onReachEnd()又不会回调，无法实现上拉加载更多的功能。所以后面把内嵌的Scroll组件去掉，由外层调用来通知refreshMediator。  
另外还有一点，RefreshLayout只能在List上工作，对于网格列表Grid，瀑布流WaterFlow是不起作用的。因为在api9中，Grid和WaterFlow没有提供onReachEnd()和onScrollFrameBegin()
的api，只有List组件才有，离离原上谱～本来List、Grid、WaterFlow是同一系列的组件，提供的api却有点割裂～不过在万能b站上看到，api10上面onReachEnd()这些api在Grid、WaterFlow组件上应该是有了，
后面再看看吧。

### 动画
官方文档中可以看到属性动画、显式动画、页面间转场、路径动画。就不细说了。  
属性动画、显式动画用起来很简单，不过却找不到暂停动画、停止动画、获取当前动画进度的api。整的我很难受。
后面发现要暂停动画、停止动画、获取当前动画进度，应该调用AnimatorResult、AnimatorOptions这类api，需要用到请自行查看相关使用方法。  
另外，对于页面间转场动画，一直找不到如何统一设置整个应用的页面转场动画，不在各个页面重写pageTransition的话，默认都是左右slide的动画～
有大佬知道麻烦告知弟弟。

### 网络请求
项目中的网络请求，直接用了官方的http，没有引入第三方框架，只是做了简单的封装。  
一般页面涉及到网络请求，都会有页面态、下拉刷新结果状态、上拉加载更多结果状态的切换，ArkUI中的组件又没有继承的概念，各个组件都要单独处理的话也是很难受。 
最后项目中定义了ViewStateLayout、ViewStatePagingLayout、请求时构建RequestOptions时传入对于组件的ViewState、PagingLayoutMediator来统一处理。  
ViewStateLayout会自动切换页面加载态、正常态、错误态、空白态，ViewStatePagingLayout除了页面态、还会自动切换刷新头部、加载更多尾部的状态
- RequestOptions的定义
```
export interface IRequestOptions {
  // 请求url
  url: string
  // 请求参数
  data?: object
  // 和页面绑定的ViewState
  viewState?: ViewState,
  // 分页协调工具
  pagingMediator?: PagingLayoutMediator,
  // 请求成功条件，默认code==200
  successCondition?: (result: object) => boolean
  // 判断空条件
  emptyCondition?: (result: object) => boolean
  // 分页数据转换
  pagingListConverter?: (result: object) => object[]
  // 请求失败时是否还返回result
  interceptWhenNoSuccess?: boolean
}
```
- ViewStateLayout使用伪代码
```
 @State: result: Result
 ViewStateLayout({ onLoadData: async (viewState) => {
      // 网络请求
      this.result = await viewModel.fetchData(viewState)
    } }) {
      // 正常态布局
    }
    
 class ViewModel extends BaseViewModel {
   async fetchData(viewState: ViewState) : Promise<Result> {
     await this.get<Result>(
       new RequestOptions({
          url: "",
          data: "",
          viewState: viewState
      }))
   }
 }
```
- ViewStatePagingLayout使用伪代码
```
  @State pagingLayoutMediator: PagingLayoutMediator = new PagingLayoutMediator({})
  ViewStatePagingLayout({
      mediator: $pagingLayoutMediator,
      ItemBuilder: (item: object, _) => {
        this.ItemBuilder(item)
      },
      onLoadData: async (viewState: ViewState) => {
        viewModel.fetchData((viewState, this.pagingLayoutMediator)
      },
   })
  class ViewModel extends BaseViewModel {
    async fetchData(viewState: ViewState, pagingMediator: PagingLayoutMediator) : Promise<Result> {
     this.get<Result>(
      new RequestOptions({
        url: "",
        data: "",
        viewState: viewState,
        pagingMediator: pagingMediator,
        pagingListConverter: (result: Result) => {
          // 将result转换成list数据源
        }
      }))
   }
 }
```


### 音乐播放
音乐播放功能，用的是官方的AVPlayer。项目中封装了NCPlayer负责实际的播放功能，MusicPlayController来调用NCPlayer和驱动各个音乐播放相关组件的渲染。
关于如何驱动各个播放相关组件UI渲染的问题，最开始实现是想利用AppStorage，往AppStorage中更新一些播放的关键信息来驱动UI渲染，
后面发现在音乐播放界面，AppStorage更新时，唱片旋转动画会卡顿。索性都改写成利用emitter来通信，实现播放相关组件UI渲染。


### 主题切换
主题切换，大概思路是仿照Compose的那套主题切换，首先定义一个基础的取色盘IThemePalette
```
export interface IThemePalette {
  primary: ResourceColor
  secondary: ResourceColor,
  pure: ResourceColor,
  divider: ResourceColor,
  commonBackground: ResourceColor,
  deepenBackground: ResourceColor,
  titleBackground: ResourceColor,
  navBarBackground: ResourceColor,
  drawerBackground: ResourceColor,
  firstText: ResourceColor,
  secondText: ResourceColor,
  thirdText: ResourceColor,
  firstIcon: ResourceColor,
  secondIcon: ResourceColor,
  thirdIcon: ResourceColor,
}
```
然后各个主题的取色盘都实现IThemePalette，例如默认主题取色盘DefaultThemePalette
```
export class DefaultThemePalette implements IThemePalette {
  primary: ResourceColor = "#FFF0484E"
  secondary: ResourceColor = "#FFF0888C"
  pure: ResourceColor = "#FFFFFFFF"
  divider: ResourceColor = "#FFDDDDDD"
  commonBackground: ResourceColor = "#FFFFFFFF"
  deepenBackground: ResourceColor = "#FFEEEEEE"
  titleBackground: ResourceColor = "#FFFAFAFA"
  navBarBackground: ResourceColor = "#FFFAFAFA"
  drawerBackground: ResourceColor = "#FFFAFAFA"
  firstText: ResourceColor = "#FF333333"
  secondText: ResourceColor = "#FF666666"
  thirdText: ResourceColor = "#FF999999"
  firstIcon: ResourceColor = "#FF333333"
  secondIcon: ResourceColor = "#FF666666"
  thirdIcon: ResourceColor = "#FF999999"
}
```
然后定义AppTheme共外部使用
```
// 默认主题
export const defaultThemePalette = new DefaultThemePalette()
// 黑色主题
export const darkThemePalette = new DarkThemePalette()
// 橙色主题
export const originThemePalette = new OriginThemePalette()
// 绿色主题
export const greenThemePalette = new GreenThemePalette()

export class AppTheme {
  /**
   * 获取主题取色盘
   */
  static palette(themeType: ThemeType): IThemePalette {
    if (themeType == ThemeType.DEFAULT) {
      return defaultThemePalette
    } else if (themeType == ThemeType.DARK) {
      return darkThemePalette
    } else if (themeType == ThemeType.ORIGIN) {
      return originThemePalette
    } else if (themeType == ThemeType.GREEN) {
      return greenThemePalette
    } else {
      return defaultThemePalette
    }
  }
}

// 主题类型
export const THEME_TYPE = "THEME_TYPE"
```
至于如何使用，需要用到AppStorage，在组件内先获取当前主题色类型，然后调用AppTheme的palette()方法，获取到对应主题的取色盘的颜色，
当AppStorage中的主题类型发送变化时，组件就会自动切换颜色。
```
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  Text(item.name).fontColor(AppTheme.palette(this.themeType).firstText)
```

### 最后
累了，不想写了。新手鸿蒙开发，代码不规范请不吝指教，如若有帮助请给个star

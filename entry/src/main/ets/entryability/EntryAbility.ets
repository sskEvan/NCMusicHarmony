import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { RouterUrls, ScreenUtils } from 'lib_common';

export default class EntryAbility extends UIAbility {
  async onCreate() {
    window.getLastWindow(this.context, async (_, w) => {
      w.setWindowLayoutFullScreen(true)

      let win = await window.getLastWindow(this.context)
      let area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      AppStorage.SetOrCreate("STATUS_BAR_HEIGHT", area.topRect.height)
      ScreenUtils.init(area)
    })
  }

  onDestroy() {
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent(RouterUrls.Splash);
  }

  onWindowStageDestroy() {
  }

  onForeground() {
  }

  onBackground() {
  }

}

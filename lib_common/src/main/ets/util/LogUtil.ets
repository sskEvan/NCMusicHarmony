import hilog from '@ohos.hilog';

/**
 * 日志工具类
 */
export class LogUtil {
  private static domain: number = 0xFF00;
  private static prefix: string = '[NCMusicLog]';
  private static format: string = '%{public}s';

  static debug(...args: string[]) {
    hilog.debug(this.domain, this.prefix, this.format, args);
  }

  static info(...args: string[]) {
    hilog.info(this.domain, this.prefix, this.format, args);
  }

  static warn(...args: string[]) {
    hilog.warn(this.domain, this.prefix, this.format, args);
  }

  static error(...args: string[]) {
    hilog.error(this.domain, this.prefix, this.format, args);
  }
}


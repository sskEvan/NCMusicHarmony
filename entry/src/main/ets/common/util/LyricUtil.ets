import { LyricModel, LyricResultBean } from '../../bean/LyricResultBean';

export class LyricUtil {
  static PATTERN_LINE = new RegExp("((\\[\\d\\d:\\d\\d\\.\\d{2,3}\\])+)(.+)")
  static PATTERN_TIME = /\[(\d\d):(\d\d)\.(\d{2,3})\]/

  static parse(lyricResult: LyricResultBean): LyricModel[] {
    const originLrcTexts = lyricResult.lrc?.lyric || "";
    const originTLyricTexts = lyricResult.tlyric?.lyric || "";
    const lyricModelList = LyricUtil.parseLyrics(originLrcTexts);
    const tLyricModelList = LyricUtil.parseTLyrics(originTLyricTexts);
    lyricModelList.forEach(lyricModel => {
      tLyricModelList.forEach(tLyricModel => {
        if (lyricModel.time === tLyricModel.time) {
          lyricModel.tLyric = tLyricModel.tLyric;
        }
      });
    });

    return lyricModelList;
  }

  static parseLyrics(lyric: string): LyricModel[] {
    const entryList: LyricModel[] = [];

    if (!lyric) {
      return entryList;
    }

    const lines = lyric.split(/\r?\n/);

    lines.forEach(line => {
      const match = line.match(LyricUtil.PATTERN_LINE);
      if (match) {
        const timeMatch = match[0].match(LyricUtil.PATTERN_TIME);
        if (timeMatch) {
          const min = parseInt(timeMatch[1], 10);
          const sec = parseInt(timeMatch[2], 10);
          const milString = timeMatch[3];
          let mil = parseInt(milString, 10);

          // 如果毫秒是两位数，需要乘以10
          if (milString.length === 2) {
            mil *= 10;
          }

          const time = min * 60000 + sec * 1000 + mil;
          const text = match[3].trim();
          entryList.push(new LyricModel(time, text));
        }
      }
    });

    return entryList;
  }

  static parseTLyrics(lyric: string): LyricModel[] {
    const entryList: LyricModel[] = [];

    if (!lyric) {
      return entryList;
    }

    const lines = lyric.split(/\r?\n/);

    lines.forEach(line => {
      const match = line.match(LyricUtil.PATTERN_LINE);
      if (match) {
        const timeMatch = match[0].match(LyricUtil.PATTERN_TIME);
        if (timeMatch) {
          const min = parseInt(timeMatch[1], 10);
          const sec = parseInt(timeMatch[2], 10);
          const milString = timeMatch[3];
          let mil = parseInt(milString, 10);

          // 如果毫秒是两位数，需要乘以10
          if (milString.length === 2) {
            mil *= 10;
          }

          const time = min * 60000 + sec * 1000 + mil;
          const text = match[3].trim();
          entryList.push(new LyricModel(time, null, text));
        }
      }
    });

    return entryList;
  }
}
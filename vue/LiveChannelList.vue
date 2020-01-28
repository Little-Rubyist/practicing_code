<template>
  <section id="live-channel-list">
    <!-- 未入力一覧 -->
    <v-row no-gutters justify="center" class="mb-8">
      <v-col cols="9">
        <v-sheet max-width="1297px">
          <h1 class="headline py-2">まだ設定されていないコンテンツ</h1>
          <v-divider class="mb-3" />
          <v-row no-gutters id="scroll-target" class="overflow-y-auto" style="max-height: 30vh">
            <v-col v-for="content in liveUnscheduledContents" :key="content.contentId">
              <v-card
                class="ma-1"
                outlined
                min-width="180px"
                max-width="200px"
                @click.stop="callModal(content)"
                :disabled="!$store.getters.permissions.contentsWrite"
              >
                <p class="text-truncate text-center mb-0">{{content.contentId}}</p>
                <p class="text-truncate text-center mb-0">{{content.title}}</p>
                <p class="text-truncate text-center">{{content.episodeIdName}} {{content.subTitle}}</p>
              </v-card>
            </v-col>
          </v-row>
        </v-sheet>
      </v-col>
    </v-row>

    <v-row no-gutters justify="center" class="pt-3">
      <v-col cols="9">
        <v-sheet max-width="1297px">
          <v-row no-gutters class="pt-3">
            <!-- 配信日検索 -->
            <v-col offset="1" cols="3" class="xs3 px-4">
              <VDateTimePickerExt
                v-model="focus"
                @input="selectBaseDate"
                backgroundColor="white"
                label="配信日"
              />
            </v-col>

            <!-- コンテンツID検索 -->
            <v-col cols="3" class="px-4">
              <v-text-field
                v-model="searchId"
                label="コンテンツID"
                append-icon="mdi-magnify"
                clearable
                :error-messages="errorMessageOfSearchId"
                @keydown.enter="searchContents"
                @click:append="searchContents"
                @input="errorMessageOfSearchId = ''"
              />
            </v-col>

            <!-- 現在時刻へ戻る -->
            <v-col cols="5" class="mt-3">
              <v-btn
                color="steelblue"
                width="140px"
                class="caption white--text"
                @click="resetFocus"
              >
                <v-icon class="my-auto" width="15%" color="white">mdi-clock</v-icon>
                <span class="my-auto text">現在時刻を表示</span>
              </v-btn>
            </v-col>
          </v-row>

          <!-- 日付表示 -->
          <v-row align="center" class="mx-2 text-center">
            <v-btn text icon class="hdate-icon" @click="focusOnYesterday">
              <v-icon>mdi-chevron-left</v-icon>
            </v-btn>
            <v-col>
              <p
                class="caption font-weight-bold hdate-ym my-0"
              >{{ displayDate.year() }}.{{ displayDate.month() + 1 }}</p>
              <p
                :class="[isDayOff ? 'red--text' : 'weekday']"
                class="text-uppercase overline my-0"
              >{{ dayOfWeek[displayDate.day()] }}</p>
              <v-btn
                fab
                :class="[isDayOff ? 'red' : 'steelblue']"
                dark
                depressed
                :ripple="false"
              >{{ displayDate.date() }}</v-btn>
            </v-col>
            <v-btn text icon class="hdate-icon" @click="focusOnTomorrow">
              <v-icon>mdi-chevron-right</v-icon>
            </v-btn>
          </v-row>
        </v-sheet>
      </v-col>
    </v-row>

    <!-- ラテ欄 -->
    <v-row no-gutters justify="center" class="py-0">
      <v-col cols="9">
        <v-sheet max-width="1297px" height="700px" id="scroll-target" class="overflow-y-auto sheet">
          <v-divider />
          <v-row class="ml-8 scroll-x channel-border-x">
            <v-col v-for="(channel, index) in channels" :key="channel" class="channel-column mx-3">
              <span class="channel-border-y" :style="getChannelBorder(index)" />
              <span>{{channel}}ch</span>
            </v-col>
          </v-row>
          <p class="caption">0:00</p>
          <p
            v-for="time in 24"
            :key="time"
            class="caption"
            :style="getTimeHeight(time)"
          >
            {{time}}:00
            <span class="time-border-x" />
          </p>
          <!-- バッファは下にするため先に表示 -->
          <template v-for="buffer in showingScheduledContentBuffers">
            <template v-for="channel in buffer.channels">
              <v-card
                :key="`${buffer.contentId}-${channel.channelId}-buffer`"
                :disabled="!$store.getters.permissions.contentsWrite"
                width="60px"
                max-width="67px"
                :height="getCardHeight(buffer.startTime,buffer.endTime)"
                :style="getContentPosition(buffer.startTime, channel.channelId)"
                :class="[channel.activeFlg ? 'light-blue accent-1' : 'gray lighten-3']"
                class="white--text buffer"
                :outlined="true"
              />
            </template>
          </template>
          <template v-for="content in showingScheduledContents">
            <template v-for="channel in content.channels">
              <v-hover
                :key="`${content.contentId}-${channel.channelId}`"
                v-slot:default="{ hover }"
              >
                <v-card
                  :disabled="!$store.getters.permissions.contentsWrite"
                  @click.stop="callModal(content)"
                  width="60px"
                  max-width="67px"
                  :height="getCardHeight(content.streamStartTime,content.streamEndTime)"
                  :style="getContentPosition(content.streamStartTime, channel.channelId)"
                  :color="channel.activeFlg ? 'steelblue' : 'grey'"
                  class="white--text"
                >
                  <v-tooltip v-model="hover" top max-width="150px">
                    <template v-slot:activator="{ on }">
                      <span v-on="on">
                        <p class="mb-0 caption text-truncate" v-if="channel.activeFlg">＜アクティブ＞</p>
                        <p class="mb-0 caption text-truncate">{{content.title}}</p>
                        <p class="mb-0 caption text-truncate">{{content.subTitle}}</p>
                        <p class="mb-0 caption text-truncate">{{content.episodeIdName}}</p>
                      </span>
                    </template>
                    <p class="mb-0 caption text-truncate" v-if="channel.activeFlg">＜アクティブ＞</p>
                    <p class="mb-0 caption text-truncate">{{formatDate(content.streamStartTime)}}</p>
                    <p class="mb-0 caption text-truncate">{{content.contentId}}</p>
                    <p class="mb-0 caption text-truncate">{{content.title}}</p>
                    <p class="mb-0 caption text-truncate">{{content.subTitle}}</p>
                    <p class="mb-0 caption text-truncate">{{content.episodeIdName}}</p>
                  </v-tooltip>
                </v-card>
              </v-hover>
            </template>
          </template>
        </v-sheet>
      </v-col>
    </v-row>
    <LiveChannelUpdateModal
      v-if="isVisible"
      @onClose="isVisible = false"
      @update="updateLiveContent"
      :content="content"
      :scheduledContents="allScheduledContents"
      :changeLimitHour="changeLimitHour"
    />
  </section>
</template>

<script lang="ts">
    import { Component, Vue, Prop, Emit } from 'vue-property-decorator';
    import Timer from '@/util/timer.ts';
    import LiveChannelUpdateModal from '@/components/liveChannel/OverviewModal.vue';
    import dayjs, { Dayjs } from 'dayjs';
    import { Content, Channel, UpdateLiveContentParam, Buffer } from '@/repository/@types/LiveChannel.ts';

    @Component({
        components: { LiveChannelUpdateModal }
    })
    export default class LiveChannelList extends Vue {
        @Prop(Array) public contents!: Array<Content>;
        @Prop(Number) public changeLimitHour!: number;
        private isVisible: boolean = false;
        private errorMessageOfSearchId: string = '';
        private content: Content = {} as Content;
        private focus: string = dayjs().format('YYYY-MM-DD');
        private displayDate: Dayjs = {} as Dayjs;
        private searchId: string = '';
        private dayOfWeek: Array<string> = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        private channels = this.$store.state.constant.channels;
        private show: boolean = false;

        @Emit('getListWithDate')
        public getListWithDate(): string {
            // FIXME: 消すのではなくAPI後に再評価する
            this.searchId = '';
            this.displayDate = dayjs(this.focus);
            return this.focus;
        }

        @Emit('updateLiveContent')
        public updateLiveContent(param: UpdateLiveContentParam): UpdateLiveContentParam {
            return param;
        }

        public callModal(content: Content) {
            this.content = content;
            this.isVisible = true;
        }

        private created() {
            this.displayDate = dayjs().startOf('date');
        }

        private get allScheduledContents(): Array<Content> {
            if (!this.contents) return [];
            return this.contents.filter(
                (x) => x.channels !== null && x.streamStartTime !== null && x.streamEndTime !== null
            );
        }

        private get showingScheduledContentBuffers(): Array<Buffer> {
            if (!this.contents) return [];
            return this.contents
                .filter((x) => x.channels !== null && x.streamStartTime !== null && x.streamEndTime !== null)
                .filter(
                    (x) =>
                        dayjs(x.streamStartTime).subtract(3, 'hour').format('YYYY-MM-DD') <= this.displayDate.format('YYYY-MM-DD') &&
                        dayjs(x.streamEndTime).add(1, 'hour').format('YYYY-MM-DD') >= this.displayDate.format('YYYY-MM-DD')
                )
                .map((x) => ({
                    contentId: x.contentId,
                    startTime: dayjs(x.streamStartTime).subtract(3, 'hour').toDate(),
                    endTime: dayjs(x.streamEndTime).add(1, 'hour').toDate(),
                    channels: [...x.channels ?? []]
                } as Buffer ));
        }

        private get showingScheduledContents(): Array<Content> {
            if (!this.contents) return [];
            return this.contents
                .filter((x) => x.channels !== null && x.streamStartTime !== null && x.streamEndTime !== null)
                .filter(
                    (x) =>
                        dayjs(x.streamStartTime).format('YYYY-MM-DD') <= this.displayDate.format('YYYY-MM-DD') &&
                        dayjs(x.streamEndTime).format('YYYY-MM-DD') >= this.displayDate.format('YYYY-MM-DD')
                );
        }

        private get liveUnscheduledContents(): Array<Content> {
            if (!this.contents) return [];
            return this.contents.filter(
                (x) => x.streamStartTime === null || x.streamEndTime === null || !this.hasActiveChannel(x)
            );
        }

        private hasActiveChannel(content: Content): boolean {
            if (!content.channels) {
                return false;
            }
            return content.channels.some((x) => x.activeFlg);
        }

        private selectBaseDate() {
            if (this.displayDate.format('YYYY-MM-DD') === this.focus) {
                return;
            }

            this.getListWithDate();
        }

        // 期間内コンテンツID検索
        private searchContents() {
            if (!this.contents.filter((s) => s.contentId === this.searchId).length) {
                this.errorMessageOfSearchId = '二週間前または一ヶ月先に指定コンテンツは存在しません';
                return;
            }
            if (this.liveUnscheduledContents.filter((x) => x.contentId === this.searchId).length) {
                this.errorMessageOfSearchId = 'まだ指定コンテンツは設定されていません';
                return;
            }
            this.errorMessageOfSearchId = '';
            const startTimes = this.contents.filter((s) => s.contentId === this.searchId).map((s) => s.streamStartTime);
            if (!startTimes.length || !startTimes[0]) {
                return;
            }
            this.displayDate = dayjs(startTimes[0]).startOf('date');
            this.focus = this.displayDate.format('YYYY-MM-DD');
        }

        private focusOnYesterday() {
            const endGetDate = dayjs(this.focus).add(-14, 'day');
            this.displayDate = dayjs(this.displayDate).add(-1, 'day');
            if (endGetDate.diff(this.displayDate, 'day') === -3) {
                this.focus = this.displayDate.format('YYYY-MM-DD');
                this.getListWithDate();
            }
        }

        private focusOnTomorrow() {
            const firstGetDate = dayjs(this.focus).add(1, 'month');
            this.displayDate = dayjs(this.displayDate).add(1, 'day');
            if (firstGetDate.diff(this.displayDate, 'day') === 3) {
                this.focus = this.displayDate.format('YYYY-MM-DD');
                this.getListWithDate();
            }
        }

        private resetFocus() {
            this.displayDate = dayjs().startOf('date');
            this.focus = dayjs().format('YYYY-MM-DD');
            this.getListWithDate();
        }

        // 画面表示系
        private formatDate(date: Date): string {
            return date ? dayjs(date).format('HH:mm') : '未登録';
        }

        private getChannelBorder(channel: number): string {
            const width = this.getChannelWidth(channel + 1);
            const position = `position:absolute; top: 0px; left: ${width - 5}px`;
            return position;
        }

        private getChannelWidth(id: number): number {
            if (id <= 10) {
                return (id - 1) * 74 + 40;
            }
            return (id - 11) * 84 + 784;
        }

        private get isDayOff(): boolean {
            return this.displayDate.day() === 0 || this.displayDate.day() === 6;
        }

        private getTimeHeight(time: number): string {
            const minutes = time * 60;
            const position = `position:absolute; top: ${minutes + 24}px`;
            return position;
        }

        private getContentPosition(streamStartTime: Date, channelId: number): string {
            if (!streamStartTime) return '';
            const startTime = dayjs(streamStartTime);

            const top = this.getContentTop(startTime);
            const width  = this.getChannelWidth(channelId);

            return `position:absolute; top: ${top + 33}px; left: ${width}px`;
        }

        private getContentTop(startTime: dayjs.Dayjs): number {
            return (startTime.startOf('date').diff(this.displayDate, 'day') < 0) ? 0 : this.getMinutesOfDay(startTime.toDate());
        }

        private getCardHeight(streamStartTime: Date, streamEndTime: Date): number {
            if (!streamStartTime || !streamEndTime) return 0;

            const startTime = dayjs(streamStartTime);
            const endTime = dayjs(streamEndTime);

            const conparedStartDateWithDisplayDate = startTime
                .startOf('date')
                .diff(this.displayDate, 'day');
            const conparedEndDateWithDisplayDate = endTime
                .startOf('date')
                .diff(this.displayDate, 'day');

            const minHeight = 0;
            const maxHeight = 1460;

            // 配信開始日が今日より後の場合は必ず表示されない
            if (conparedStartDateWithDisplayDate > 0) return minHeight;
            // 配信終了日が今日より前の場合は必ず表示されない
            if (conparedEndDateWithDisplayDate < 0) return minHeight;

            let top: number;
            let buttom: number;
            if (conparedStartDateWithDisplayDate < 0) {
                top = minHeight;
            } else {
                top = this.getMinutesOfDay(startTime.toDate());
            }

            if (conparedEndDateWithDisplayDate > 0) {
                buttom = maxHeight;
            } else {
                buttom = this.getMinutesOfDay(endTime.toDate());
            }

            return buttom - top;
        }

        private getMinutesOfDay(date: Date): number {
            const day = new Date(date);
            const hour = day.getHours();
            const minutes = day.getMinutes();
            return hour * 60 + minutes;
        }
    }
</script>

<style lang="scss" scoped>
  .scroll-x {
    display: table;
    overflow-x: auto;
    white-space: nowrap;
  }

  .channel-column {
    display: inline;
  }

  .weekday {
    color: steelblue;
  }

  .hdate-icon {
    cursor: pointer;
  }

  .hdate {
    flex: 1 1 auto;
    display: inherit;
  }

  .channel-border-x {
    border-bottom: solid 1px gray;
  }

  .channel-border-y {
    border-left: solid 1px gray;
    height: 1500px;
  }

  .time-border-x {
    border-top: dotted 1px gray;
    width: 1250px;
    position: absolute;
    top: 10px;
    left: 32px;
  }

  .sheet {
    display: block;
    position: relative;
  }

  .buffer {
    background-image:
      repeating-linear-gradient(-60deg,transparent 1px 11px, white 11px 21px);
  }
</style>

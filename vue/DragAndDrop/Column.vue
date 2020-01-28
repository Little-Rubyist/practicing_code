<template>
  <section id="content-preparation-update-priotity">
    <v-container>
      <v-row>
        <v-col>
          <h1 class="display-1">優先度変更</h1>
        </v-col>
      </v-row>
      <v-divider class="my-3" />
      <v-row>
        <v-col cols="6">
          <v-text-field
            v-model="contentId"
            label="コンテンツID"
            background-color="white"
            outlined
            dense
            hide-details
            autofocus
          />
        </v-col>
        <v-col cols="6">
          <v-text-field
            v-model="title"
            label="タイトル"
            background-color="white"
            outlined
            dense
            hide-details
          />
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="6">
          <v-select
            v-model="status"
            :items="encodeStatusSelect"
            label="配信準備ステータス"
            item-text="label"
            item-value="value"
            background-color="white"
            multiple
            clearable
            chips
            dense
            outlined
            hide-details
          />
        </v-col>
        <v-col cols="6">
          <v-select
            v-model="sourceType"
            :items="sourceTypeSelect"
            item-text="label"
            label="搬入区分"
            clearable
            dense
            outlined
            hide-details
            background-color="white"
          />
        </v-col>
      </v-row>
      <v-row justify="end">
        <v-col cols="9" class="py-0">
          <v-row justify="end">
            <v-col cols="2">
              <v-text-field
                v-model="searchLimit"
                label="検索数上限"
                type="number"
                background-color="white"
                outlined
                dense
                hide-details
              />
            </v-col>
            <v-col cols="2">
              <v-btn
                color="blue"
                class="white--text"
                @click="getContents"
                v-shortkey.once="['ctrl','enter']"
                @shortkey="getContents"
              >検索</v-btn>
            </v-col>
          </v-row>
        </v-col>
      </v-row>
      <v-divider class="my-5" />
      <v-row>
        <v-col class="red--text">※同優先度内で処理順は順不同です。</v-col>
      </v-row>
      <v-row no-gutters>
        <v-col v-for="priority in priorities" :key="priority.value" cols="4">
          <!-- カラム部分 -->
          <v-card min-width="220px" class="mr-3">
            <v-toolbar color="steelblue" dark>
              <v-toolbar-title>{{ priority.label }}</v-toolbar-title>
            </v-toolbar>
            <v-container id="scroll-target" class="overflow-y-auto" style="max-height: 70vh">
              <!-- ローディング -->
              <v-progress-circular
                v-show="loadingCircleKeys ? loadingCircleKeys.some(x => x === priority.value) : false"
                color="primary"
                indeterminate
              />
              <!-- データ表示部 -->
              <draggable
                group="content"
                :list="contents[priority.value]"
                :options="{animation:150, column:priority.value}"
                :move="beforeMove"
                :sort="false"
                :disabled="!$store.getters.permissions.contentsWrite"
                class="drag-target"
                @start="start"
                @remove="remove"
              >
                <!-- 準備状況カード -->
                <transition-group>
                  <PriorityChangeCard
                    @callModal="displayModal(element)"
                    v-for="element in contents[priority.value]"
                    :preparation="element"
                    :key="element.contentId"
                    class="my-3 mx-auto"
                    :title="`${element.title ? element.title : ''}${element.subTitle ? '\r\n' + element.subTitle : ''}${element.episodeIdName ? '\r\n' + element.episodeIdName : ''}`"
                  />
                </transition-group>
              </draggable>
              <!-- 100件超過 -->
              <p
                v-show="searchOmittedNoticeKeys ? searchOmittedNoticeKeys.some(x => x === priority.value) : false"
              >{{`※検索結果が${searchLimit}件を超えたため、表示が省略されました。条件を設定してください。`}}</p>
            </v-container>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
    <!-- 概要表示 -->
    <OverviewModal
      @onClose="isVisible = false"
      @repossession="repossession"
      :schema="element"
      :isVisible="isVisible"
      :priorities="priorities.find(x => x.value == element.priority)"
    />
  </section>
</template>

<script lang="ts">
    import { Component, Vue } from 'vue-property-decorator';
    import draggable from 'vuedraggable';
    import PriorityChangeCard from '@/components/contentPreparation/UpdatePriorityCard.vue';
    import OverviewModal from '@/components/contentPreparation/OverviewModal.vue';
    import RepositoryFactory, { TypeUnwrap } from '@/repository/repositoryManager';
    import { Content, GetListParam, UpdatePriorityParam } from '@/repository/@types/ContentPreparation';

    const preparationRepository = RepositoryFactory.getContentPreparationRepos();

    interface PrioritySelectBox {
        label: string;
        value: number;
    }

    interface StatusSelectBox {
        label: string;
        value: string;
    }

    @Component({
        components: {
            PriorityChangeCard,
            OverviewModal,
            draggable
        }
    })
    export default class EncodePriorityChange extends Vue {
        private contents = new Array<Array<Content>>();
        private isVisible: boolean = false;
        private element: Content = {} as Content;
        private drag: boolean = false;
        private dragToColumn!: number;
        private dragElement!: Content;
        private oldContents = new Array<Array<Content>>();
        private priorities: Array<PrioritySelectBox> = this.$store.state.constant.priorityLabel;

        // 検索条件
        private contentId = '';
        private title = '';
        private status: Array<string> = [];
        private searchLimit = 100;
        private sourceType: string = '';

        /// UI
        private loadingCircleKeys: Array<number> = [];
        private searchOmittedNoticeKeys: Array<number> = [];

        private get encodeStatusSelect(): Array<StatusSelectBox> {
            const originalStatusList: Array<StatusSelectBox> = this.$store.state.constant.preparationStatusMessage;
            return originalStatusList.filter((x) => x.value !== 'completed')
        }

        private get sourceTypeSelect(): Array<StatusSelectBox> {
            const sourceType: { [key: string]: string } = this.$store.state.constant.sourceTypeName;
            const arr = [] as Array<StatusSelectBox>;
            for (const x in sourceType) {
                if (sourceType.hasOwnProperty(x)) {
                    const element = sourceType[x];
                    arr.push({
                        label: element,
                        value: x
                    });
                }
            }
            return arr;
        }

        private async getContents() {
            this.contents = [];
            this.searchOmittedNoticeKeys.splice(0, this.searchOmittedNoticeKeys.length);
            for (const priority of this.priorities.map((x) => x.value)) {
                // ローディングアイコン表示
                this.loadingCircleKeys.push(priority);

                const param = {
                    limit: this.searchLimit,
                    offset: 0,
                    searchCriteria: {
                        contentId: this.contentId ? this.contentId.padStart(6, '0') : '' ,
                        contentIdForwardMatch: true,
                        title: this.title,
                        status: this.status.length ? this.status : ['not-completed'],
                        priority,
                        sourceType: this.sourceType
                    }
                } as GetListParam;

                preparationRepository.getList(param).then((res) => {
                    // リストの設定
                    Vue.set(this.contents, priority, res.contents ?? []);
                    // ローディングアイコン除去
                    this.loadingCircleKeys.splice(this.loadingCircleKeys.findIndex((x) => x === priority), 1);
                    // 件数超過表示の設定
                    if (res.contentCount > this.searchLimit) {
                        this.searchOmittedNoticeKeys.push(priority);
                    }
                });
            }
        }

        private async created() {
            const canRead = this.$store.getters.permissions.contentsRead;
            const canEdit = this.$store.getters.permissions.contentsWrite;
            if (!canRead && !canEdit) {
                this.$router.push({ name: 'unauth' });
            }
            await this.getContents();
        }

        private async repossession() {
            this.isVisible = false;
            await this.getContents();
        }

        private displayModal(element: Content) {
            this.element = element;
            this.isVisible = true;
        }

        // draggable の処理系
        private start(evt: any) {
            this.oldContents = this.contents.map((x) => x.slice());
            this.drag = true;
        }
        private beforeMove(evt: any) {
            this.dragToColumn = evt.relatedContext.component.$options.propsData.options.column; // Priority
            this.dragElement = evt.dragged._underlying_vm_; // Content
            return evt.draggedContext.element.status !== 'preparing' && evt.draggedContext.element.status !== 'completed';
        }
        private async remove(evt: any) {
            const res = window.confirm('本当に変更しますか？');
            if (!res) {
                for (const priority of this.priorities.map((x) => x.value)) {
                    Vue.set(this.contents, priority, this.oldContents[priority]);
                }
                return;
            }

            this.dragElement.selectedPriority = this.dragToColumn;
            const content = {
                contents: [
                    {
                        contentId: this.dragElement.contentId,
                        priority: this.dragToColumn
                    }
                ]
            } as UpdatePriorityParam;
            await preparationRepository.updatePriority(content);
            this.getContents();
        }
    }
</script>

<style lang="scss" scoped>
  .drag-target {
    display: flex;
    flex-direction: column;
    justify-content: center;
  }
</style>

<style lang="scss">
  .drag-target > span {
    display: inline-block;
    min-height: 100px;
  }
</style>


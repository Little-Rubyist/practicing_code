<template>
  <section id="content-preparation-overview-modal">
    <v-row no-gutters justify="center">
      <v-dialog v-model="isVisible" max-width="800" @keydown.esc="onClose" @input="onClose">
        <v-card>
          <v-card-actions>
            <v-btn color="grey" @click="onClose" class="white--text">戻る</v-btn>
            <v-spacer />
          </v-card-actions>
          <v-col text-xs-center class="pb-2">
            <v-stepper v-model="schema.status" alt-labels>
              <v-stepper-header>
                <!-- 2.0betaではiconの変更できないので保留 -->
                <template v-for="status in 4">
                  <v-stepper-step
                    :complete="convertStatusToValue(schema) >= status"
                    :step="status"
                    :key="status"
                    :color="stepColor"
                  >{{stepperText(status)}}</v-stepper-step>
                  <v-divider v-if="status != 4" :key="status+'-divider'" />
                </template>
              </v-stepper-header>
            </v-stepper>
            <v-container>
              <v-simple-table>
                <tbody>
                <tr>
                  <td class="title">進捗度</td>
                  <td class="title">{{ `${schema.displayStatusForOperator}（${schema.displayStatusForAdmin}）` }}</td>
                </tr>
                <tr>
                  <td class="title">リトライ回数</td>
                  <td class="title" v-if="priorities">{{ schema.retryCount || 0 }}</td>
                </tr>
                <tr>
                  <td class="title">コンテンツID</td>
                  <td class="title">
                    <router-link
                      :to="{name: 'content', query: {id: schema.contentId}}"
                      target="_blank"
                    >{{schema.contentId}}</router-link>
                  </td>
                </tr>
                <tr>
                  <td class="title">タイトル</td>
                  <td class="title">{{ schema.title }}</td>
                </tr>
                <tr>
                  <td class="title">サブタイトル</td>
                  <td class="title">{{ schema.subTitle }}</td>
                </tr>
                <tr>
                  <td class="title">話数</td>
                  <td class="title">{{ schema.episodeIdName }}</td>
                </tr>
                <tr>
                  <td class="title">搬入区分</td>
                  <td class="title">{{ sourceTypeName[schema.sourceType] }}</td>
                </tr>
                <tr>
                  <td class="title">配信期間</td>
                  <td
                    class="title"
                  >{{ formatDate(schema.streamStartTime) }} ~ {{ formatDate(schema.streamEndTime) }}</td>
                </tr>
                <tr>
                  <td class="title">エンコード優先度</td>
                  <td class="title" v-if="priorities">{{ priorities.label }}</td>
                </tr>
                </tbody>
              </v-simple-table>
              <v-row>
                <v-col offset="2">
                  <v-chip
                    :disabled="!schema.fileUploadFlg"
                    color="steelblue"
                    class="white--text ml-1"
                  >{{`ファイリングステータス：${schema.fileUploadFlg ? 'ON' : 'OFF'}`}}</v-chip>
                </v-col>
                <v-col>
                  <v-chip
                    :disabled="!schema.techCheckFlg"
                    color="steelblue"
                    class="white--text ml-1"
                  >{{`技術チェックステータス：${schema.techCheckFlg ? 'ON' : 'OFF'}`}}</v-chip>
                </v-col>
              </v-row>
              <v-row
                justify="end"
                class="mt-3"
                v-if="$store.getters.permissions.contentsWrite && (schema.status === 'preparing' || schema.status !== 'waiting')"
              >
                <v-btn
                  v-if="schema.status === 'preparing'"
                  color="red"
                  title="配信準備をキャンセルします"
                  class="white--text"
                  @click="encodeCancelDialog = true;"
                >準備中止</v-btn>
                <v-btn
                  v-if="schema.status !== 'preparing' && schema.status !== 'waiting'"
                  color="orange"
                  title="配信準備をもう一度行います"
                  class="white--text"
                  @click="rePreparingDialog = true"
                >再準備する</v-btn>
              </v-row>
            </v-container>
          </v-col>
        </v-card>
      </v-dialog>
    </v-row>
    <v-dialog v-model="encodeCancelDialog" persistent max-width="50%">
      <v-card class="px-0 py-1">
        <v-container fluid>
          <v-row no-gutters>
            <v-col cols="12" class="my-2">
              <template>
                <v-alert color="error" icon="mdi-alert" dark dense>警告</v-alert>
                <p class="body-1 px-2">本当に中止しますか？</p>
              </template>
            </v-col>
          </v-row>
          <v-divider />
          <v-row no-gutters>
            <v-col cols="12">
              <v-card-actions>
                <v-btn color="gray" class="white--text" @click="encodeCancelDialog = false">いいえ</v-btn>
                <v-spacer />
                <v-btn color="red" class="white--text" @click="cancelPreparing()">配信準備を中止する</v-btn>
              </v-card-actions>
            </v-col>
          </v-row>
        </v-container>
      </v-card>
    </v-dialog>
    <ConfirmationModal
      v-if="rePreparingDialog"
      :body="'再準備を行いますか？'"
      @ok="rePreparing"
      @cancel="rePreparingDialog = false"
    />
  </section>
</template>

<script lang="ts">
    import ConfirmationModal from '@/components/common/ConfirmationModal.vue';
    import { Component, Vue, Prop, Watch, Emit } from 'vue-property-decorator';
    import RepositoryFactory, { TypeUnwrap } from '@/repository/repositoryManager';
    import { Content, RePreparingParam } from '@/repository/@types/ContentPreparation';
    import dayjs, { Dayjs } from 'dayjs';
    import { Snackbar } from '@/store';
    const preparationRepository = RepositoryFactory.getContentPreparationRepos();

    interface DataLabel {
        id: number;
        label: string;
    }

    @Component({
        components: { ConfirmationModal }
    })
    export default class PriorityChangeModal extends Vue {
        @Prop(Object) private schema!: Content;
        @Prop(Boolean) private isVisible: boolean = false;
        @Prop(Object) private priorities!: DataLabel;
        private encodeCancelDialog: boolean = false;
        private rePreparingDialog: boolean = false;
        private stepColor: string = 'steelblue';

        private get sourceTypeName(): { [key: string]: string } {
            return this.$store.state.constant.sourceTypeName;
        }

        @Emit('onClose')
        public onClose() {}

        @Emit('repossession')
        public repossession() {}

        private convertStatusToValue(schema: Content) {
            switch (schema.status) {
                case 'waiting':
                    this.stepColor = 'gray';
                    return 1;
                    break;
                case 'preparing':
                    this.stepColor = 'orange';
                    if (schema.category === 'fileingest') return 2;
                    if (schema.category === 'streaming') return 3;
                    break;
                case 'canceled':
                    this.stepColor = 'gray';
                    return 0;
                    break;
                case 'failed':
                    this.stepColor = 'red';
                    if (schema.category === 'fileingest') return 2;
                    if (schema.category === 'streaming') return 3;
                    return 4;
                    break;
                case 'completed':
                    this.stepColor = 'steelblue';
                    return 4;
                    break;
            }
        }

        private stepperText(step: number): string {
            switch (step) {
                case 1:
                    return '納品待ち';
                case 2:
                    return '納品完了';
                case 3:
                    return 'エンコード中';
                case 4:
                    return '配信準備完了';
                default:
                    return '';
            }
        }

        private formatDate(sourceDate: Date | string, formatString: string = 'YYYY/MM/DD HH:mm'): string {
            return sourceDate ? dayjs(sourceDate).format(formatString) : '未登録';
        }

        private async cancelPreparing() {
            this.encodeCancelDialog = false;
            this.onClose();
            await preparationRepository.cancelPreparation({ contentId: this.schema.contentId });
            // TODO: 成功したらという条件を付与する
            this.$store.commit('setSnackbar', {
                visible: true,
                message: '準備を中止しました',
                color: 'success'
            } as Snackbar);
            this.repossession();
        }

        private async rePreparing() {
            this.rePreparingDialog = false;
            this.onClose();
            await preparationRepository.rePreparing({ contentId: this.schema.contentId });
            // TODO: 成功したらという条件を付与する
            this.$store.commit('setSnackbar', {
                visible: true,
                message: '再準備を開始しました',
                color: 'success'
            } as Snackbar);
            this.repossession();
        }
    }
</script>

<style lang='scss'>
  span.v-stepper__step__step.primary {
    background-color: #4682b4 !important;
    border-color: #4682b4 !important;
  }
</style>


<template>
  <v-card class="pb-2 text-xs-center" :class="cardStyles">
    <div class="pt-4" v-if="!isWaiting">
      <v-progress-linear
        :buffer-value="StreamStatus"
        :stream="isPreparing"
        :color="progressBarColor"
        :value="encodeStatusSet"
        class="mb-2"
      />
    </div>
    <v-card-text class="black--text pb-0">{{ preparation.contentId }}</v-card-text>
    <v-card-title class="title pt-0">{{ preparation.title }}</v-card-title>
    <v-card-subtitle class="pb-0">{{ preparation.subTitle }}</v-card-subtitle>
    <v-card-text class="pb-0">{{ preparation.episodeIdName ? preparation.episodeIdName : '-' }}</v-card-text>
    <v-card-actions class="justify-center">
      <v-btn color="steelblue" @click.stop="callModal" dark>詳細を確認する</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script lang="ts">
    import { Component, Vue, Prop, Emit } from 'vue-property-decorator';
    import { Content } from '@/repository/@types/ContentPreparation';

    @Component
    export default class PriorityChangeCard extends Vue {
        @Prop(Object) private preparation!: Content;

        @Emit('callModal')
        public callModal() {}

        private get isPreparing(): boolean {
            return this.preparation.status === 'preparing';
        }
        private get isFailed(): boolean {
            return this.preparation.status === 'failed';
        }
        private get isWaiting(): boolean {
            return this.preparation.status === 'waiting';
        }
        private get isCanceled(): boolean {
            return this.preparation.status === 'canceled';
        }
        private get isCompleted(): boolean {
            return this.preparation.status === 'completed';
        }

        private get cardStyles(): string {
            if (this.isPreparing) return 'orange lighten-4 not-draggable';
            if (this.isFailed) return 'red lighten-4 draggable';
            if (this.isWaiting) return 'draggable';
            if (this.isCanceled) return 'grey lighten-4 draggable';
            if (this.isCompleted) return 'blue lighten-4 not-draggable';
            return 'draggable';
        }

        private get progressBarColor(): string {
            if (this.isFailed) return 'red';
            if (this.isCanceled) return 'primary';
            if (this.isCompleted) return 'steelblue';
            return 'orange';
        }

        private get StreamStatus(): number {
            if (this.isPreparing || this.isWaiting) return 0;
            return 100;
        }

        private get encodeStatusSet(): number {
            if (this.isWaiting || this.isCanceled) return 0;
            if (this.isPreparing || this.isFailed) {
                if (this.preparation.category === 'fileingest') return 33;
                if (this.preparation.category === 'streaming') return 66;
            }
            if (this.isCompleted) return 100;
            return 0;
        }
    }
</script>

<style lang="scss" scoped>
  .draggable {
    cursor: grab;
  }
  .not-draggable {
    cursor: not-allowed;
  }
</style>

<template>
  <div class="flow-shell" :class="themeClass">
    <div class="flow-background" aria-hidden="true">
      <div class="cloud cloud--a"></div>
      <div class="cloud cloud--b"></div>
      <div class="cloud cloud--c"></div>
      <div class="cloud cloud--d"></div>
      <span class="wave-band wave-band--1"></span>
      <span class="wave-band wave-band--2"></span>
      <span class="wave-band wave-band--3"></span>
      <span class="wave-band wave-band--4"></span>
      <div class="grain"></div>
      <div class="vignette"></div>
    </div>

    <div class="flow-content">
      <slot />
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { useAuthThemeMode } from '@/composables/useAuthThemeMode'

export default defineComponent({
  name: 'FlowBackgroundPanel',
  setup () {
    const { themeClass } = useAuthThemeMode()
    return { themeClass }
  }
})
</script>

<style scoped>
.flow-shell {
  position: relative;
  width: 100%;
  min-height: calc(100vh - 160px);
  padding: 28px 0 56px;
}

/* 背景层固定铺满整个视口，侧边栏与内容共享同一片背景，消除收放割裂 */
.flow-background {
  position: fixed;
  inset: 0;
  z-index: 0;
  overflow: hidden;
  pointer-events: none;
  background:
    radial-gradient(ellipse 80% 60% at 50% 0%, #e8e1ff 0%, transparent 55%),
    radial-gradient(ellipse 70% 50% at 100% 30%, #d6e2ff 0%, transparent 60%),
    radial-gradient(ellipse 60% 50% at 0% 60%, #ddd5f7 0%, transparent 60%),
    linear-gradient(180deg, #f4f0ff 0%, #ebe7fc 50%, #e4ebff 100%);
  transition: background 0.45s ease;
}

.flow-shell.theme-dark .flow-background {
  background:
    radial-gradient(ellipse 90% 55% at 50% -8%, rgba(124, 92, 255, 0.1) 0%, transparent 50%),
    linear-gradient(180deg, #0a0a0c 0%, #0b0b0e 60%, #0a0a0d 100%);
}

.cloud {
  position: absolute;
  border-radius: 50%;
  filter: blur(90px);
  opacity: 0.7;
  will-change: transform;
}

.cloud--a {
  width: 55vw;
  height: 55vw;
  min-width: 480px;
  min-height: 480px;
  top: -18%;
  left: -10%;
  background: radial-gradient(circle, #c5b6ff 0%, transparent 65%);
  animation: cloud-drift-a 22s ease-in-out infinite;
}

.cloud--b {
  width: 50vw;
  height: 50vw;
  min-width: 440px;
  min-height: 440px;
  top: -10%;
  right: -14%;
  background: radial-gradient(circle, #b4cdff 0%, transparent 65%);
  animation: cloud-drift-b 26s ease-in-out infinite;
}

.cloud--c {
  width: 60vw;
  height: 45vw;
  min-width: 520px;
  min-height: 360px;
  bottom: -22%;
  left: 8%;
  background: radial-gradient(circle, #d4c1ff 0%, transparent 65%);
  opacity: 0.55;
  animation: cloud-drift-c 30s ease-in-out infinite;
}

.cloud--d {
  width: 36vw;
  height: 36vw;
  min-width: 300px;
  min-height: 300px;
  top: 40%;
  right: 20%;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.85) 0%, transparent 65%);
  opacity: 0.6;
  animation: cloud-drift-d 24s ease-in-out infinite;
}

.theme-dark .cloud--a { background: radial-gradient(circle, rgba(124, 92, 255, 0.12) 0%, transparent 66%); }
.theme-dark .cloud--b { background: radial-gradient(circle, rgba(92, 108, 200, 0.08) 0%, transparent 66%); }
.theme-dark .cloud--c { background: radial-gradient(circle, rgba(118, 92, 210, 0.09) 0%, transparent 66%); }
.theme-dark .cloud--d { background: radial-gradient(circle, rgba(150, 160, 220, 0.05) 0%, transparent 66%); }

.grain {
  position: absolute;
  inset: 0;
  opacity: 0.14;
  mix-blend-mode: overlay;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.55'/%3E%3C/svg%3E");
}

.theme-dark .grain {
  opacity: 0.09;
}

.vignette {
  position: absolute;
  inset: 0;
  background: radial-gradient(ellipse 100% 70% at 50% 100%, transparent 50%, rgba(255, 255, 255, 0.35) 100%);
  pointer-events: none;
}

.theme-dark .vignette {
  background: radial-gradient(ellipse 100% 70% at 50% 100%, transparent 55%, rgba(8, 8, 11, 0.55) 100%);
}

/* 流动声波带（与登录页一致，更淡，不干扰内容） */
.wave-band {
  position: absolute;
  left: 0;
  width: 100%;
  background-repeat: repeat-x;
  pointer-events: none;
}

.wave-band--1 {
  top: 16%;
  height: 120px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='520' height='120'%3E%3Cpath d='M0 60 Q130 18 260 60 T520 60' fill='none' stroke='%237c5cff' stroke-width='2.5'/%3E%3C/svg%3E");
  background-size: 520px 120px;
  opacity: 0.16;
  animation: fwave1 11s linear infinite;
}

.wave-band--2 {
  top: 40%;
  height: 150px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='640' height='150'%3E%3Cpath d='M0 75 Q160 15 320 75 T640 75' fill='none' stroke='%235a8bff' stroke-width='2.5'/%3E%3C/svg%3E");
  background-size: 640px 150px;
  opacity: 0.14;
  animation: fwave2 15s linear infinite;
}

.wave-band--3 {
  top: 62%;
  height: 110px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='460' height='110'%3E%3Cpath d='M0 55 Q115 16 230 55 T460 55' fill='none' stroke='%2322b4d8' stroke-width='2.5'/%3E%3C/svg%3E");
  background-size: 460px 110px;
  opacity: 0.12;
  animation: fwave3 9s linear infinite;
}

.wave-band--4 {
  top: 80%;
  height: 160px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='720' height='160'%3E%3Cpath d='M0 80 Q180 14 360 80 T720 80' fill='none' stroke='%23a78bfa' stroke-width='2.5'/%3E%3C/svg%3E");
  background-size: 720px 160px;
  opacity: 0.12;
  animation: fwave4 19s linear infinite;
}

.theme-dark .wave-band--1 { opacity: 0.18; }
.theme-dark .wave-band--2 { opacity: 0.16; }
.theme-dark .wave-band--3 { opacity: 0.11; }
.theme-dark .wave-band--4 { opacity: 0.16; }

@keyframes fwave1 { to { background-position-x: -520px; } }
@keyframes fwave2 { to { background-position-x: 640px; } }
@keyframes fwave3 { to { background-position-x: -460px; } }
@keyframes fwave4 { to { background-position-x: 720px; } }

.flow-content {
  position: relative;
  z-index: 1;
  width: 100%;
  animation: flow-page-enter 0.45s cubic-bezier(0.16, 1, 0.3, 1) both;
}

@keyframes flow-page-enter {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes cloud-drift-a {
  0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
  50% { transform: translate3d(60px, 40px, 0) scale(1.05); }
}
@keyframes cloud-drift-b {
  0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
  50% { transform: translate3d(-50px, 50px, 0) scale(1.08); }
}
@keyframes cloud-drift-c {
  0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
  50% { transform: translate3d(40px, -30px, 0) scale(1.06); }
}
@keyframes cloud-drift-d {
  0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
  50% { transform: translate3d(-30px, -40px, 0) scale(1.1); }
}

@media (prefers-reduced-motion: reduce) {
  .cloud { animation: none; }
  .wave-band { animation: none; }
  .flow-content { animation: none; }
}
</style>

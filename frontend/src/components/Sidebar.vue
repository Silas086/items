<template>
  <aside class="sidebar-drawer-host" :class="{ 'is-open': drawerOpen }">
    <div class="sidebar-panel">
      <div class="sidebar-topbar">
        <button
          type="button"
          class="sidebar-toggle"
          :aria-expanded="drawerOpen"
          :aria-label="drawerOpen ? '收起功能导航' : '展开功能导航'"
          @click="toggleDrawer"
        >
          <el-icon><component :is="drawerOpen ? Fold : Expand" /></el-icon>
        </button>
        <div class="sidebar-heading" :class="{ 'is-collapsed': !drawerOpen }">
          <span class="sidebar-kicker">功能导航</span>
          <strong>语音工作台</strong>
        </div>
      </div>

      <el-menu
        :key="activeMenu"
        :default-active="activeMenu"
        class="custom-sidebar"
        @select="handleSelect"
      >
        <el-menu-item index="/" class="menu-card voice-to-text" :title="drawerOpen ? '' : '录音转文字'">
          <div class="menu-item-content">
            <span class="menu-icon-shell">
              <el-icon><Microphone /></el-icon>
            </span>
            <span class="menu-label">录音转文字</span>
          </div>
        </el-menu-item>
        <el-menu-item index="/TextToVoice" class="menu-card text-to-voice" :title="drawerOpen ? '' : '文字转语音'">
          <div class="menu-item-content">
            <span class="menu-icon-shell">
              <el-icon><Document /></el-icon>
            </span>
            <span class="menu-label">文字转语音</span>
          </div>
        </el-menu-item>

        <el-menu-item index="/MeetingNotes" class="menu-card meeting-notes" :title="drawerOpen ? '' : '智能纪要'">
          <div class="menu-item-content">
            <span class="menu-icon-shell">
              <el-icon><Tickets /></el-icon>
            </span>
            <span class="menu-label">智能纪要</span>
          </div>
        </el-menu-item>

        <el-menu-item index="/RealtimeVoice" class="menu-card realtime-voice" :title="drawerOpen ? '' : '实时语音'">
          <div class="menu-item-content">
            <span class="menu-icon-shell">
              <el-icon><Headset /></el-icon>
            </span>
            <span class="menu-label">实时语音</span>
          </div>
        </el-menu-item>

        <el-menu-item index="/VoicePrintCompare" class="menu-card voiceprint-compare" :title="drawerOpen ? '' : '声纹对比'">
          <div class="menu-item-content">
            <span class="menu-icon-shell">
              <el-icon><Connection /></el-icon>
            </span>
            <span class="menu-label">声纹对比</span>
          </div>
        </el-menu-item>
      </el-menu>
    </div>
  </aside>
</template>

<script lang="ts" setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import {
  Connection,
  Microphone,
  Document,
  Tickets,
  Headset,
  Fold,
  Expand
} from '@element-plus/icons-vue'
import { useRouter, useRoute } from 'vue-router'

const SIDEBAR_STORAGE_KEY = 'voice_factory_sidebar_open'
const MOBILE_COLLAPSE_WIDTH = 1400

const router = useRouter()
const route = useRoute()
const drawerOpen = ref(true)

const applySidebarOffset = () => {
  document.documentElement.style.setProperty('--voice-sidebar-offset', drawerOpen.value ? '300px' : '112px')
}

const activeMenu = computed(() => {
  if (route.path === '/' || route.path === '/HomeResult') {
    return '/'
  }
  return route.path
})

const syncInitialDrawerState = () => {
  const cached = localStorage.getItem(SIDEBAR_STORAGE_KEY)
  if (cached === 'open' || cached === 'closed') {
    drawerOpen.value = cached === 'open'
    return
  }
  drawerOpen.value = window.innerWidth > MOBILE_COLLAPSE_WIDTH
}

const persistDrawerState = () => {
  localStorage.setItem(SIDEBAR_STORAGE_KEY, drawerOpen.value ? 'open' : 'closed')
}

const toggleDrawer = () => {
  drawerOpen.value = !drawerOpen.value
}

const handleSelect = (key: string) => {
  router.push({
    path: key
  })

  if (window.innerWidth <= MOBILE_COLLAPSE_WIDTH) {
    drawerOpen.value = false
  }
}

watch(drawerOpen, () => {
  persistDrawerState()
  applySidebarOffset()
})

onMounted(() => {
  syncInitialDrawerState()
  applySidebarOffset()
})

onBeforeUnmount(() => {
  document.documentElement.style.setProperty('--voice-sidebar-offset', '0px')
})
</script>

<style scoped>
.sidebar-drawer-host {
  position: fixed;
  top: 94px;
  left: 18px;
  z-index: 120;
}

.sidebar-panel {
  width: 272px;
  overflow: hidden;
  border-radius: 22px;
  padding: 16px 12px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.78) 0%, rgba(243, 247, 255, 0.9) 100%);
  border: 1px solid rgba(122, 152, 243, 0.16);
  box-shadow: 0 24px 44px rgba(16, 31, 62, 0.09);
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
  transition: width 0.38s cubic-bezier(0.22, 1, 0.36, 1), padding 0.3s cubic-bezier(0.22, 1, 0.36, 1), border-radius 0.3s ease, background 0.36s ease, border-color 0.3s ease, box-shadow 0.3s ease;
  will-change: width;
}

.sidebar-drawer-host:not(.is-open) .sidebar-panel {
  width: 86px;
  padding-inline: 12px;
  border-radius: 18px;
  box-shadow: 0 18px 30px rgba(16, 31, 62, 0.1);
}

.sidebar-topbar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  padding: 0 6px 8px;
}

.sidebar-toggle {
  width: 46px;
  height: 46px;
  border-radius: 12px;
  border: 1px solid rgba(121, 154, 255, 0.18);
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.94) 0%, rgba(233, 241, 255, 0.88) 100%);
  box-shadow: 0 12px 24px rgba(38, 72, 145, 0.12);
  color: #4968d8;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: transform 0.22s ease, box-shadow 0.22s ease, background 0.28s ease, color 0.28s ease;
}

.sidebar-toggle:hover {
  transform: translateY(-1px);
  box-shadow: 0 16px 28px rgba(38, 72, 145, 0.16);
}

.sidebar-toggle :deep(.el-icon) {
  font-size: 18px;
  transition: transform 0.26s ease;
}

.sidebar-drawer-host.is-open .sidebar-toggle :deep(.el-icon) {
  transform: rotate(0deg);
}

.sidebar-drawer-host:not(.is-open) .sidebar-toggle :deep(.el-icon) {
  transform: rotate(-180deg);
}

.sidebar-heading {
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 3px;
  overflow: hidden;
  max-width: 160px;
  white-space: nowrap;
  transition: max-width 0.28s ease, max-height 0.28s ease, opacity 0.18s ease, transform 0.22s ease;
}

.sidebar-heading.is-collapsed {
  max-width: 0;
  max-height: 0;
  opacity: 0;
  transform: translateX(-10px);
}

.sidebar-kicker {
  font-size: 11px;
  letter-spacing: 0.16em;
  color: #7c8cb4;
}

.sidebar-heading strong {
  font-size: 16px;
  color: #1e2d56;
}

.custom-sidebar {
  background: transparent !important;
  border: none !important;
  padding: 8px 8px 2px;
  width: 100%;
  transition: background 0.45s ease, padding 0.28s ease;
}

.menu-card {
  --menu-accent: #4b7dff;
  --menu-accent-soft: rgba(76, 123, 255, 0.12);
  position: relative;
  height: auto !important;
  min-height: 70px;
  margin-bottom: 12px !important;
  border-radius: 16px !important;
  padding: 14px 16px !important;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.74) 0%, rgba(247, 250, 255, 0.84) 100%) !important;
  color: #2c3b57 !important;
  border: 1px solid rgba(121, 154, 255, 0.14) !important;
  box-shadow: 0 16px 34px rgba(21, 39, 74, 0.08);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  transition: transform 0.24s ease, box-shadow 0.24s ease, background 0.34s ease, color 0.3s ease, border-color 0.3s ease, padding 0.3s cubic-bezier(0.22, 1, 0.36, 1), min-height 0.3s ease, border-radius 0.3s ease;
}

.menu-card::before {
  content: '';
  position: absolute;
  left: 0;
  top: 18px;
  bottom: 18px;
  width: 3px;
  border-radius: 999px;
  background: transparent;
  transition: background 0.28s ease, opacity 0.28s ease;
}

.menu-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 20px 36px rgba(21, 39, 74, 0.12);
}

.menu-card.is-active {
  background: linear-gradient(135deg, rgba(75, 125, 255, 0.16) 0%, rgba(96, 158, 255, 0.22) 100%) !important;
  color: #22324f !important;
  border-color: rgba(75, 125, 255, 0.3) !important;
  box-shadow: 0 22px 40px rgba(64, 114, 244, 0.14);
}

.menu-card.is-active::before {
  background: linear-gradient(180deg, var(--menu-accent) 0%, rgba(255, 255, 255, 0.82) 100%);
}

.menu-item-content {
  display: flex;
  align-items: center;
  width: 100%;
  min-width: 0;
  gap: 14px;
  justify-content: flex-start;
}

.menu-icon-shell {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  background: linear-gradient(135deg, var(--menu-accent-soft) 0%, rgba(255, 255, 255, 0.92) 100%);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.76), 0 8px 18px rgba(25, 40, 74, 0.08);
  border: 1px solid rgba(226, 234, 247, 0.82);
  flex-shrink: 0;
}

.menu-card :deep(.menu-icon-shell .el-icon) {
  font-size: 20px;
  color: var(--menu-accent);
}

.menu-card.is-active .menu-icon-shell {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.96) 0%, rgba(233, 241, 255, 0.94) 100%) !important;
  border-color: rgba(255, 255, 255, 0.42);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.16), 0 10px 20px rgba(47, 81, 177, 0.08);
}

.menu-label {
  flex: 1;
  min-width: 0;
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 0.01em;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  transition: opacity 0.18s ease, transform 0.22s ease;
}

.sidebar-drawer-host:not(.is-open) .sidebar-topbar {
  justify-content: flex-start;
}

.sidebar-drawer-host:not(.is-open) .custom-sidebar {
  padding-inline: 4px;
}

.sidebar-drawer-host:not(.is-open) .menu-card {
  padding: 10px 8px !important;
  min-height: 64px;
  border-radius: 14px !important;
}

.sidebar-drawer-host:not(.is-open) .menu-item-content {
  justify-content: center;
  gap: 0;
}

.sidebar-drawer-host:not(.is-open) .menu-icon-shell {
  width: 44px;
  height: 44px;
  margin-right: 0;
}

.sidebar-drawer-host:not(.is-open) .menu-label {
  opacity: 0;
  transform: translateX(-6px);
  width: 0;
  flex: 0 0 0;
  pointer-events: none;
}

.sidebar-drawer-host:not(.is-open) .sidebar-kicker,
.sidebar-drawer-host:not(.is-open) .sidebar-heading strong {
  opacity: 0;
  transform: translateX(-8px);
  pointer-events: none;
}

.voice-to-text {
  --menu-accent: #62bb44;
  --menu-accent-soft: rgba(98, 187, 68, 0.16);
}

.text-to-voice {
  --menu-accent: #3b8cff;
  --menu-accent-soft: rgba(59, 140, 255, 0.16);
}

.realtime-voice {
  --menu-accent: #ff9b22;
  --menu-accent-soft: rgba(255, 155, 34, 0.16);
}

.meeting-notes {
  --menu-accent: #22b3a7;
  --menu-accent-soft: rgba(34, 179, 167, 0.16);
}

.voiceprint-compare {
  --menu-accent: #8f58f6;
  --menu-accent-soft: rgba(143, 88, 246, 0.16);
}

:global(html[data-auth-theme-mode='dark'] .sidebar-panel) {
  background: linear-gradient(180deg, rgba(13, 13, 15, 0.9) 0%, rgba(9, 16, 31, 0.94) 100%) !important;
  border-color: rgba(255, 255, 255, 0.14);
  box-shadow: 0 28px 42px rgba(10, 10, 12, 0.34);
}

:global(html[data-auth-theme-mode='dark'] .sidebar-drawer-host:not(.is-open) .sidebar-panel) {
  box-shadow: 0 20px 34px rgba(10, 10, 12, 0.38);
}

:global(html[data-auth-theme-mode='dark'] .sidebar-toggle) {
  background: linear-gradient(135deg, rgba(17, 29, 56, 0.96) 0%, rgba(19, 19, 22, 0.98) 100%);
  border-color: rgba(255, 255, 255, 0.22);
  box-shadow: 0 14px 22px rgba(10, 10, 12, 0.22);
  color: #9ec2ff;
}

:global(html[data-auth-theme-mode='dark'] .sidebar-kicker) {
  color: #8ea0c7;
}

:global(html[data-auth-theme-mode='dark'] .sidebar-heading strong) {
  color: #eef4ff;
}

:global(html[data-auth-theme-mode='dark'] .menu-card) {
  background: linear-gradient(145deg, rgba(17, 17, 20, 0.76) 0%, rgba(22, 22, 26, 0.82) 100%) !important;
  color: #e5eefc !important;
  border-color: rgba(255, 255, 255, 0.18) !important;
  box-shadow: 0 18px 34px rgba(10, 10, 12, 0.24);
}

:global(html[data-auth-theme-mode='dark'] .menu-card:hover) {
  background: linear-gradient(145deg, rgba(22, 22, 26, 0.98) 0%, rgba(18, 31, 58, 0.96) 100%) !important;
  box-shadow: 0 20px 34px rgba(10, 10, 12, 0.38);
}

:global(html[data-auth-theme-mode='dark'] .menu-card.is-active) {
  background: linear-gradient(145deg, rgba(27, 27, 32, 0.94) 0%, rgba(36, 36, 41, 0.92) 100%) !important;
  color: #ffffff !important;
  border-color: rgba(255, 255, 255, 0.26) !important;
  box-shadow: 0 20px 40px rgba(18, 18, 22, 0.34);
}

:global(html[data-auth-theme-mode='dark'] .menu-icon-shell) {
  background: linear-gradient(135deg, rgba(28, 28, 32, 0.96) 0%, rgba(20, 20, 24, 0.94) 100%);
  border-color: rgba(255, 255, 255, 0.1);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.04), 0 8px 16px rgba(10, 10, 12, 0.22);
}

/* 夜间：模块图标统一收敛到柔和紫，浅色模式保留彩色区分 */
:global(html[data-auth-theme-mode='dark'] .menu-card) {
  --menu-accent: #9b8cf7;
  --menu-accent-soft: rgba(124, 92, 255, 0.16);
}

</style>

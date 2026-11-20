// 浏览器接管 · 指纹削减初始化脚本（每个页面加载前执行）
// 目的：让自动化浏览器看起来更像普通用户开的 Edge，降低淘宝风控误判概率。
// 只改浏览器侧可读的少量属性，不拦截、不篡改任何网络请求，不影响页面功能。
(() => {
  try {
    Object.defineProperty(navigator, 'webdriver', { get: () => undefined, configurable: true });
  } catch (e) {}

  try {
    if (!window.chrome) {
      Object.defineProperty(window, 'chrome', {
        value: { runtime: {}, loadTimes: () => {}, csi: () => {} },
        writable: true,
        configurable: true,
      });
    }
  } catch (e) {}

  try {
    Object.defineProperty(navigator, 'languages', { get: () => ['zh-CN', 'zh'], configurable: true });
  } catch (e) {}

  try {
    const zone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    if (zone !== 'Asia/Shanghai') {
      // 时区已由 contextOptions 指定；此处仅兜底，不做替换。
      void zone;
    }
  } catch (e) {}

  try {
    const origQuery = window.navigator.permissions && window.navigator.permissions.query;
    if (origQuery) {
      window.navigator.permissions.query = (params) =>
        params && params.name === 'notifications'
          ? Promise.resolve({ state: Notification.permission })
          : origQuery.call(window.navigator.permissions, params);
    }
  } catch (e) {}
})();
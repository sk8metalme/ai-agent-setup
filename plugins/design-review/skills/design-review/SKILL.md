---
name: design-review
description: |
  UIデザインレビューガイド。
  アクセシビリティ、レスポンシブ、UXパターン、パフォーマンスをチェック。
allowed-tools: Read, Grep, Glob
---

# デザインレビュースキル

## 目的

UIデザインの品質を評価し、アクセシビリティ、レスポンシブデザイン、UXパターン、パフォーマンスの観点から改善提案を行う。

## レビューの4つの観点

### 1. アクセシビリティ（A11y）
### 2. レスポンシブデザイン
### 3. UXパターン
### 4. パフォーマンス

---

## レビュー実行方法

### 効率的なレビュー（推奨）

**4つの観点を並列でレビュー**することで、コンテキストを節約しながら網羅的にチェックできます。

**並列レビューの実施方法:**

Taskツールで複数のサブエージェントを並列起動し、各観点を同時にレビュー：

1. **アクセシビリティ観点** - コントラスト、キーボード操作、ARIA、セマンティックHTML
2. **レスポンシブデザイン観点** - ブレークポイント、タッチターゲット、フルードグリッド
3. **UXパターン観点** - フォーム、フィードバック、ナビゲーション、モーダル
4. **パフォーマンス観点** - Core Web Vitals（LCP, FID, CLS）

各観点のレビュー結果を統合し、最終レポートを作成します。

**メリット:**
- コンテキスト使用量を削減
- 各観点を独立して評価
- 並列実行による時間短縮
- 漏れのない網羅的チェック

---

## 1. アクセシビリティ（WCAG 2.1 AA準拠）

### 重要な原則

#### POUR原則

| 原則 | 説明 |
|------|------|
| **P**erceivable（知覚可能） | すべてのユーザーが情報を知覚できる |
| **O**perable（操作可能） | すべてのユーザーがUIを操作できる |
| **U**nderstandable（理解可能） | 情報とUIが理解可能 |
| **R**obust（堅牢） | 多様な技術で解釈可能 |

### チェックリスト

#### 1.1 テキストの代替

```html
<!-- ❌ 悪い例 -->
<img src="logo.png">
<button><i class="icon-save"></i></button>

<!-- ✅ 良い例 -->
<img src="logo.png" alt="Company Logo">
<button aria-label="保存"><i class="icon-save" aria-hidden="true"></i></button>
```

#### 1.2 コントラスト比

**WCAG 2.1 AA基準:**
- 通常テキスト: 4.5:1 以上
- 大きなテキスト（18pt以上 or 14pt太字以上）: 3:1 以上

**確認ツール:**
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Chrome DevTools: Lighthouse

```css
/* ❌ 悪い例: コントラスト比 2.5:1 */
.text {
  color: #999;
  background: #fff;
}

/* ✅ 良い例: コントラスト比 7:1 */
.text {
  color: #555;
  background: #fff;
}
```

#### 1.3 キーボード操作

```html
<!-- ❌ 悪い例: キーボード操作不可 -->
<div onclick="submit()">送信</div>

<!-- ✅ 良い例 -->
<button type="submit">送信</button>

<!-- ✅ カスタム要素の場合 -->
<div role="button" tabindex="0" onclick="submit()" onkeydown="handleKey(event)">
  送信
</div>
```

**チェック項目:**
- [ ] すべての操作がキーボードで可能か
- [ ] Tab順序が論理的か
- [ ] フォーカスインジケーターが視認可能か
- [ ] Escキーでモーダルが閉じるか

#### 1.4 フォーカスの可視化

```css
/* ❌ 悪い例: フォーカスを消す */
button:focus {
  outline: none;
}

/* ✅ 良い例 */
button:focus {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* ✅ より良い例 */
button:focus-visible {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}
```

#### 1.5 セマンティックHTML

```html
<!-- ❌ 悪い例 -->
<div class="header">
  <div class="nav">
    <div class="link">Home</div>
    <div class="link">About</div>
  </div>
</div>

<!-- ✅ 良い例 -->
<header>
  <nav>
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/about">About</a></li>
    </ul>
  </nav>
</header>
```

#### 1.6 ARIAの適切な使用

```html
<!-- ❌ 悪い例: 不要なARIA -->
<button role="button">送信</button>

<!-- ✅ 良い例: 必要最小限 -->
<button>送信</button>

<!-- ✅ 良い例: カスタムコンポーネントで必要 -->
<div role="dialog" aria-labelledby="dialog-title" aria-modal="true">
  <h2 id="dialog-title">確認</h2>
  <p>本当に削除しますか？</p>
  <button>削除</button>
  <button>キャンセル</button>
</div>
```

#### 1.7 フォームのラベル

```html
<!-- ❌ 悪い例 -->
<input type="text" placeholder="メールアドレス">

<!-- ✅ 良い例 -->
<label for="email">メールアドレス</label>
<input type="email" id="email" name="email" required>

<!-- ✅ エラーメッセージの関連付け -->
<label for="email">メールアドレス</label>
<input type="email" id="email" name="email" aria-describedby="email-error" required>
<span id="email-error" role="alert">有効なメールアドレスを入力してください</span>
```

### アクセシビリティツール

| ツール | 用途 |
|--------|------|
| [axe DevTools](https://www.deque.com/axe/devtools/) | 自動検出ツール |
| [WAVE](https://wave.webaim.org/) | ページ全体の評価 |
| [Lighthouse](https://developers.google.com/web/tools/lighthouse) | Chrome DevTools統合 |
| [NVDA](https://www.nvaccess.org/) | スクリーンリーダー（Windows） |
| [VoiceOver](https://www.apple.com/accessibility/voiceover/) | スクリーンリーダー（Mac/iOS） |

---

## 2. レスポンシブデザイン

### ブレークポイント標準

| デバイス | 幅 | 備考 |
|---------|-----|------|
| Mobile（縦） | 320px - 480px | iPhone SE, etc. |
| Mobile（横） | 481px - 767px | |
| Tablet（縦） | 768px - 1024px | iPad, etc. |
| Tablet（横） | 1025px - 1280px | |
| Desktop | 1281px - 1920px | 標準的なPC |
| Large Desktop | 1921px+ | 4K, ウルトラワイド |

### レスポンシブチェックリスト

#### 2.1 ビューポート設定

```html
<!-- ✅ 必須 -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

#### 2.2 フルードグリッド

```css
/* ❌ 悪い例: 固定幅 */
.container {
  width: 1200px;
}

/* ✅ 良い例: 可変幅 */
.container {
  max-width: 1200px;
  width: 100%;
  padding: 0 16px;
}

/* ✅ より良い例: CSS Grid */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 16px;
}
```

#### 2.3 フレキシブル画像

```css
/* ✅ 基本 */
img {
  max-width: 100%;
  height: auto;
}

/* ✅ レスポンシブ画像 */
<picture>
  <source media="(min-width: 1024px)" srcset="large.jpg">
  <source media="(min-width: 768px)" srcset="medium.jpg">
  <img src="small.jpg" alt="説明">
</picture>
```

#### 2.4 メディアクエリ

```css
/* モバイルファースト推奨 */

/* Base: Mobile */
.menu {
  display: none;
}

/* Tablet以上 */
@media (min-width: 768px) {
  .menu {
    display: flex;
  }
}

/* Desktop以上 */
@media (min-width: 1280px) {
  .menu {
    font-size: 18px;
  }
}
```

#### 2.5 タッチターゲットサイズ

**最小サイズ: 44x44px（Apple HIG）/ 48x48px（Material Design）**

```css
/* ❌ 悪い例: タップしづらい */
.button {
  width: 30px;
  height: 30px;
}

/* ✅ 良い例 */
.button {
  min-width: 44px;
  min-height: 44px;
  padding: 12px 16px;
}
```

### レスポンシブテストツール

- Chrome DevTools: Device Toolbar
- Firefox: Responsive Design Mode
- [BrowserStack](https://www.browserstack.com/): 実機テスト
- [Responsively App](https://responsively.app/): 複数デバイス同時表示

---

## 3. UXパターン

### 3.1 フォームデザイン

#### フォームのベストプラクティス

```html
<!-- ✅ 良いフォーム -->
<form>
  <!-- ラベルは上に配置 -->
  <label for="name">お名前 <span aria-label="必須">*</span></label>
  <input type="text" id="name" name="name" required autocomplete="name">

  <!-- ヘルプテキスト -->
  <label for="password">パスワード</label>
  <input type="password" id="password" name="password"
         aria-describedby="password-help" required>
  <small id="password-help">8文字以上、英数字を含む</small>

  <!-- エラーメッセージ -->
  <label for="email">メールアドレス</label>
  <input type="email" id="email" name="email"
         aria-describedby="email-error" aria-invalid="true" required>
  <span id="email-error" role="alert" class="error">
    有効なメールアドレスを入力してください
  </span>

  <!-- ボタン -->
  <button type="submit">送信</button>
  <button type="button">キャンセル</button>
</form>
```

**チェック項目:**
- [ ] ラベルがすべての入力フィールドに付いているか
- [ ] 必須項目が明示されているか
- [ ] プレースホルダーをラベルの代わりにしていないか
- [ ] エラーメッセージが具体的か
- [ ] 送信ボタンが明確か

#### フォームバリデーション

```javascript
// ✅ リアルタイムバリデーション（onBlurで）
input.addEventListener('blur', (e) => {
  if (!e.target.validity.valid) {
    showError(e.target, getErrorMessage(e.target));
  } else {
    clearError(e.target);
  }
});

// ✅ 送信時の全体バリデーション
form.addEventListener('submit', (e) => {
  if (!form.checkValidity()) {
    e.preventDefault();
    // 最初のエラーフィールドにフォーカス
    const firstError = form.querySelector('[aria-invalid="true"]');
    firstError?.focus();
  }
});
```

### 3.2 フィードバック

#### ローディング状態

```html
<!-- ✅ ローディング表示 -->
<button type="submit" aria-busy="true" disabled>
  <span class="spinner" aria-hidden="true"></span>
  送信中...
</button>

<!-- スクリーンリーダー用 -->
<div role="status" aria-live="polite" class="sr-only">
  データを送信しています。しばらくお待ちください。
</div>
```

#### 成功/エラー通知

```html
<!-- ✅ 成功メッセージ -->
<div role="alert" aria-live="assertive" class="success">
  ✓ 保存しました
</div>

<!-- ✅ エラーメッセージ -->
<div role="alert" aria-live="assertive" class="error">
  ✗ 保存に失敗しました。もう一度お試しください。
</div>
```

### 3.3 ナビゲーション

#### パンくずリスト

```html
<!-- ✅ セマンティックなパンくずリスト -->
<nav aria-label="パンくずリスト">
  <ol>
    <li><a href="/">ホーム</a></li>
    <li><a href="/products">商品</a></li>
    <li aria-current="page">商品詳細</li>
  </ol>
</nav>
```

#### ページネーション

```html
<!-- ✅ アクセシブルなページネーション -->
<nav aria-label="ページネーション">
  <ul>
    <li><a href="?page=1" aria-label="前のページ">←</a></li>
    <li><a href="?page=1">1</a></li>
    <li><span aria-current="page">2</span></li>
    <li><a href="?page=3">3</a></li>
    <li><a href="?page=3" aria-label="次のページ">→</a></li>
  </ul>
</nav>
```

### 3.4 モーダル/ダイアログ

```html
<!-- ✅ アクセシブルなモーダル -->
<div role="dialog" aria-labelledby="modal-title" aria-modal="true">
  <h2 id="modal-title">確認</h2>
  <p>本当に削除しますか？この操作は取り消せません。</p>
  <button autofocus>削除</button>
  <button>キャンセル</button>
</div>
```

**モーダルのJavaScript要件:**
- [ ] 開いたときに最初の要素にフォーカス
- [ ] Tabキーでモーダル内を循環
- [ ] Escキーで閉じる
- [ ] 背景をスクロール不可にする
- [ ] 閉じたときに元の位置にフォーカスを戻す

---

## 4. パフォーマンス（Core Web Vitals）

### Core Web Vitals 基準

| 指標 | 良好 | 改善が必要 | 不良 |
|------|------|-----------|------|
| **LCP** (Largest Contentful Paint) | ≤ 2.5s | 2.5s - 4.0s | > 4.0s |
| **FID** (First Input Delay) | ≤ 100ms | 100ms - 300ms | > 300ms |
| **CLS** (Cumulative Layout Shift) | ≤ 0.1 | 0.1 - 0.25 | > 0.25 |

### 4.1 LCP（最大コンテンツの描画）

**改善方法:**

```html
<!-- ✅ 画像の最適化 -->
<img src="hero.jpg"
     width="1200"
     height="600"
     loading="eager"
     fetchpriority="high"
     alt="Hero image">

<!-- ✅ WebPフォーマット -->
<picture>
  <source type="image/webp" srcset="hero.webp">
  <img src="hero.jpg" alt="Hero image">
</picture>
```

**チェック項目:**
- [ ] 画像をWebP形式で提供しているか
- [ ] 画像サイズを指定しているか（width, height）
- [ ] Critical CSSをインライン化しているか
- [ ] 不要なJavaScriptをレンダリングブロックしていないか

### 4.2 FID（初回入力遅延）

**改善方法:**

```html
<!-- ✅ JavaScriptの遅延読み込み -->
<script src="analytics.js" defer></script>
<script src="non-critical.js" async></script>

<!-- ✅ Code Splitting -->
<script type="module">
  import('./critical.js');

  // 必要なときだけ読み込み
  button.addEventListener('click', async () => {
    const module = await import('./heavy-feature.js');
    module.init();
  });
</script>
```

**チェック項目:**
- [ ] JavaScriptバンドルサイズを最小化しているか
- [ ] Tree Shakingを有効にしているか
- [ ] 不要なpolyfillを削除したか
- [ ] Long Tasksを分割したか

### 4.3 CLS（累積レイアウトシフト）

**改善方法:**

```css
/* ✅ 画像/動画のサイズ指定 */
img, video {
  aspect-ratio: 16 / 9;
  width: 100%;
  height: auto;
}

/* ✅ フォント読み込み時のレイアウトシフト防止 */
@font-face {
  font-family: 'CustomFont';
  src: url('font.woff2') format('woff2');
  font-display: swap; /* または optional */
}
```

**チェック項目:**
- [ ] 画像・動画にwidth/height属性を指定しているか
- [ ] Webフォント読み込み中のフォールバックが適切か
- [ ] 広告・埋め込みコンテンツの領域を確保しているか
- [ ] アニメーションでtransformを使用しているか（topではなく）

### パフォーマンステストツール

| ツール | 用途 |
|--------|------|
| [Lighthouse](https://developers.google.com/web/tools/lighthouse) | 総合評価 |
| [PageSpeed Insights](https://pagespeed.web.dev/) | 実ユーザーデータ |
| [WebPageTest](https://www.webpagetest.org/) | 詳細分析 |
| Chrome DevTools: Performance | プロファイリング |

---

## レビューレポートフォーマット

### テンプレート

```markdown
# デザインレビューレポート

## サマリー
- レビュー日時: YYYY-MM-DD
- ページ/コンポーネント: [対象]
- 総合評価: [A/B/C/D]

## 1. アクセシビリティ（評価: X/10）

### Critical（即時対応）
- [ ] **コントラスト不足**: ボタンのコントラスト比が3:1（推奨: 4.5:1）
  - 場所: `.primary-button`
  - 推奨: `color: #005A9C` に変更

### Warning（対応推奨）
- [ ] **フォーカス不明**: フォーカスインジケーターが視認困難
  - 場所: `input:focus`
  - 推奨: `outline: 2px solid #0066cc` を追加

### Info（改善提案）
- [ ] **ARIA不足**: モーダルに `aria-modal="true"` がない
  - 場所: `.modal`
  - 推奨: 属性を追加

## 2. レスポンシブデザイン（評価: X/10）

### Critical
- [ ] **横スクロール発生**: Mobile (375px) で横スクロール
  - 原因: `.container { width: 400px }`
  - 推奨: `max-width: 100%` に変更

### Info
- [ ] **タッチターゲット小**: ボタンが40x40px
  - 推奨: 最小 44x44px に拡大

## 3. UXパターン（評価: X/10）

### Warning
- [ ] **エラーメッセージ不明確**: "Invalid input"
  - 推奨: 「メールアドレスの形式が正しくありません」

### Info
- [ ] **ローディング状態なし**: 送信ボタンにフィードバックなし
  - 推奨: `aria-busy="true"` とスピナー表示

## 4. パフォーマンス（評価: X/10）

### Core Web Vitals
- LCP: 3.2s（改善が必要）
- FID: 80ms（良好）
- CLS: 0.15（改善が必要）

### Critical
- [ ] **LCP遅延**: Hero画像 (2.5MB) が最適化されていない
  - 推奨: WebP形式 (300KB) に変換

### Warning
- [ ] **CLS発生**: Webフォント読み込み時にレイアウトシフト
  - 推奨: `font-display: swap` を設定

## 推奨アクション

### 優先度1（即時対応）
1. コントラスト比の改善
2. 横スクロールの修正
3. 画像の最適化

### 優先度2（1週間以内）
1. フォーカスインジケーターの改善
2. エラーメッセージの具体化
3. Webフォントの最適化

### 優先度3（任意）
1. ARIA属性の追加
2. タッチターゲットの拡大
```

---

## 参考資料

### アクセシビリティ
- [WCAG 2.1 ガイドライン](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM](https://webaim.org/)
- [A11y Project](https://www.a11yproject.com/)
- [MDN Accessibility](https://developer.mozilla.org/ja/docs/Web/Accessibility)

### レスポンシブデザイン
- [Responsive Web Design Basics](https://web.dev/responsive-web-design-basics/)
- [CSS Grid Layout](https://developer.mozilla.org/ja/docs/Web/CSS/CSS_Grid_Layout)

### UXパターン
- [Material Design](https://material.io/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Nielsen Norman Group](https://www.nngroup.com/)

### パフォーマンス
- [Web Vitals](https://web.dev/vitals/)
- [Lighthouse Performance Scoring](https://developer.chrome.com/docs/lighthouse/performance/performance-scoring/)

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

`baiyuan-tech/pif-whitepaper` 是 **PIF AI 平台的技術白皮書**（非程式碼專案，是文件專案）。雙語（繁中 `zh-TW/` + 英文 `en/`），描述同團隊主 app（`baiyuan-tech/pif`，本機 `../pif`）的架構。授權 CC BY-NC 4.0，已登錄 Zenodo DOI。

兩種發佈管道：(1) **Jekyll → GitHub Pages** 網頁版（`baiyuan-tech.github.io/pif-whitepaper`）；(2) **Pandoc + XeLaTeX → PDF**，由 CI 編譯後掛到 **GitHub Releases**。

---

## 內容模型（先讀）

- **一章一檔**：`zh-TW/chNN-slug.md`、`en/chNN-slug.md`，外加 `appendix-a..d-*.md` 與目錄頁 `README.md`。撰寫規範見 [FORMAT.md](FORMAT.md)。
- **雙語對等是鐵則**：`zh-TW/` 與 `en/` 必須章節一一對應。改一邊就要改另一邊。
- **每檔開頭有 YAML frontmatter**（`title:` 等）+ 可選的 AI-friendly JSON-LD `<script>` 區塊。這些在 PDF 建置時會被 `concat.sh` 剝除（PDF 改用 `assets/pdf/metadata-<lang>.yaml`）。
- 頂層 `README.md` 是雙語入口，含 PDF 下載連結（`releases/latest/download/whitepaper-<lang>.pdf`，恆指向最新 release）。

---

## PDF 章節串接（concat.sh）

PDF 由 [assets/pdf/concat.sh](assets/pdf/concat.sh) 把章節串成單一 `.md` 再交給 Pandoc。**章節清單採動態 glob**（`ls chNN-*.md | sort -V`，再接 `appendix-*-*.md`），所以**新增 `chNN-*.md` 會自動進 PDF**，不需改腳本 —— 維持零padding 編號（ch01、ch02…ch13）即可正確排序。

> 史鑑：concat.sh 曾寫死 `ch01..ch12`，導致 v0.2 新增的 `ch13` 只進網頁版、**所有 v0.2–v0.2.3 的 PDF 都缺第 13 章**（2026-06 改為動態 glob 修正）。**不要再退回寫死清單。**

`concat.sh` 同時會剝除：YAML frontmatter、`<!-- AI-friendly` 註解區塊、`<script type="application/ld+json">`、`**導覽**` / `**Nav**` 導覽頁尾。

---

## 常用指令

```bash
# Markdown lint（CI 用同一套；config = .markdownlint.jsonc）
markdownlint '**/*.md' --ignore 'node_modules/**' --config .markdownlint.jsonc

# 本地產 PDF（需 pandoc + xelatex + Noto CJK 字型；CI 為權威來源）
bash assets/pdf/concat.sh zh-TW > whitepaper-zh-TW.md
pandoc whitepaper-zh-TW.md --pdf-engine=xelatex \
  --metadata-file=assets/pdf/metadata-zh-TW.yaml --toc --toc-depth=3 \
  -V CJKmainfont="Noto Serif CJK TC" -V geometry:a4paper -o whitepaper-zh-TW.pdf

# 本地預覽 Jekyll 網頁版（若裝了 bundler）
bundle exec jekyll serve

# 查 / 下載已發佈 PDF
gh release list -R baiyuan-tech/pif-whitepaper
gh release download <tag> -R baiyuan-tech/pif-whitepaper -p '*.pdf'
```

生成物（`whitepaper-*.md` / `whitepaper-*.pdf`）皆被 `.gitignore` 排除 —— **不要 commit PDF 進 repo**，它們只存在於 Releases。

---

## CI / 發佈流程

三個 workflow（`.github/workflows/`）：
- **build-pdf.yml** — Pandoc + XeLaTeX 編譯中/英 PDF（matrix `lang: [zh-TW, en]`）。觸發：`zh-TW/** en/** assets/pdf/**` 的 push、release published、`workflow_dispatch`。字型用 `-V CLI flags` 注入（非 header-includes），`lang: zh-Hant-TW` 避免 Pandoc ctex hook 套到簡中字型。
- **lint.yml** — markdownlint。
- **update-sitemap-lastmod.yml** — 從 git history 自動更新 sitemap，會 auto-commit（帶 `[skip ci]`）。pull 前注意遠端可能多出這種 commit。

**發佈一個版本**：建 git tag → 在 GitHub 發 Release（published 事件）→ `build-pdf.yml` 自動編譯並把 `whitepaper-<lang>.pdf` 掛到**該 release**。

> PDF 掛載步驟的 `tag_name` 用 `github.event.release.tag_name`（release 事件）/ 退回 `v0.1-draft`（master push 的滾動草稿）。**曾有 bug 把它寫死成 `v0.1-draft`**，導致 v0.2.x 各 release 都沒 PDF（2026-06 已修，commit `a10fe58`）。

---

## ⚠️ 推送 workflow 檔案要走 SSH

本機 `gh` 的 OAuth token 缺 `workflow` scope，用 HTTPS push 任何更動 `.github/workflows/*` 的 commit 會被 GitHub 拒絕。**改 workflow 檔請用 SSH 推**：

```bash
git push git@github.com:baiyuan-tech/pif-whitepaper.git master
```

非 workflow 檔的一般 push 走預設 HTTPS 即可。

---

## 引用 / 版本

- `CITATION.cff` + README 內 JSON-LD 帶 Zenodo DOI；改 DOI / 版本時兩處要同步。
- 結構刻意對齊姊妹專案 `baiyuan-tech/geo-whitepaper`（FORMAT.md 明載）。
- 修訂記錄維護在 `README.md` 的 Revision History 表與 `appendix-d-changelog.md`。

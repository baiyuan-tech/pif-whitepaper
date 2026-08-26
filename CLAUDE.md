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

## 推送 workflow 檔案

歷史註記說「本機 `gh` token 缺 `workflow` scope,改 workflow 必須走 SSH」——
**2026-08-26 實測已不成立**:`gh auth status` 顯示 scopes 含 `workflow`,
HTTPS 可直接推送 `.github/workflows/*`。若日後重新授權後又被拒,再改用 SSH:

```bash
git push git@github.com:baiyuan-tech/pif-whitepaper.git master
```

先用 `gh auth status` 確認 scope,不要憑這段註記假設。

---

## 引用 / 版本

- `CITATION.cff` + README 內 JSON-LD 帶 Zenodo DOI；改 DOI / 版本時兩處要同步。
- **Zenodo 存放已自動化**(build-pdf.yml 的 `zenodo` job,release 事件才跑):
  把建好的 PDF 存成 concept DOI 底下的新版本。腳本 `assets/pdf/zenodo_deposit.py`,
  可本機 `--dry-run` 演練(建草稿不發佈)。需 `secrets.ZENODO_TOKEN` + `vars.ZENODO_CONCEPT`。
  ⚠ **GitHub↔Zenodo webhook 必須維持關閉** —— 兩者並存每次發版會產生兩筆記錄,
  且 webhook 若較晚完成,concept DOI 會指向沒有 PDF 的那筆。
  背景:官方整合只封存原始碼 ZIP,不碰 release assets,導致 Zenodo 落地頁一直沒有
  `citation_pdf_url`,Google Scholar 因此抓不到全文(2026-08-26 實測確認並補齊)。
- **PDF 頁首與標題頁日期由 `CITATION.cff` 推導**(build-pdf.yml 的 `Stamp version` 步驟),
  不要再去改 `assets/pdf/metadata-*.yaml` 裡的 `ancyhead[R]{...}` 與 `date:` ——
  那兩個值曾寫死在 v0.1,導致 v0.2/v0.3/v0.4 的 PDF 頁首全印著 `v0.1 · 2026-04`。
  發版時只要更新 `CITATION.cff`,頁首自動跟上;錨點命中數不為 1 時 CI 會 fail-fast。
- 結構刻意對齊姊妹專案 `baiyuan-tech/geo-whitepaper`（FORMAT.md 明載）。
- 修訂記錄維護在 `README.md` 的 Revision History 表與 `appendix-d-changelog.md`。

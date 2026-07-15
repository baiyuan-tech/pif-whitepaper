---
title: "第 16 章：自駕進化與計算基準文獻化"
description: "SA 回饋學習迴路、agreement_rate KPI、主動 re-grounding 從權威源擴充 NOAEL、計算基準文獻化 SSOT,以及一個誠實的邊界:在沒有簽核功能的前提下,什麼才是真正的自主成長。"
chapter: 16
lang: zh-TW
authors:
  - "Vincent Lin"
keywords:
  - "自駕進化"
  - "agreement_rate"
  - "re-grounding"
  - "計算基準"
  - "tox_reference"
  - "對抗式紅隊"
  - "非對稱學習"
word_count: approx 3300
last_updated: 2026-07-06
last_modified_at: '2026-07-06T15:05:38Z'
---




# 第 16 章：自駕進化與計算基準文獻化

> 「我們已經是 AI,難道不能每次自己進化?」這句使用者定錨開啟了一套自我學習系統的設計。但本章要記錄的不只是它怎麼運作,還有一個誠實的邊界——**在平台目前沒有安全評估師簽核功能的前提下,「從簽核案例學習」並沒有自主的燃料**。真正不靠人的自主成長,來自另外三塊:確定性引擎、resolved-cache、與主動 re-grounding。分清楚這件事,比宣稱一個漂亮但空轉的迴路更重要。

## 📌 本章重點

- **「100% 成功率」的定義**:不是「100% 通過」(那不安全),而是 `agreement_rate → 1.0`——每筆 AI 判定都與 SA 最終一致、零偽陰、零無出處數字。
- **非對稱學習**:false-safe(AI 漏判被 SA 攔)→ 可自動收緊(安全方向);over-flag(誤報)→ 只能提校準提案,須人類毒理師驗證後才放寬。
- **誠實邊界**:平台目前 `sa_reviews.signed_at` 全為 0——沒有真正的簽核。所以「從簽核學習」的 ground truth 全是人工 curate(上傳的 SA 簽署 PDF + 官方範例 PIF),**不是平台自己長出來的**。
- **真正的自主成長(已 live)**:① 確定性引擎(curated read-across + 結構相似 + Cramer/TTC),新成分自動由結構解析;② resolved-cache,從已分析成分的 cited 值沉澱錨定;③ 主動 re-grounding,對 data_gap 成分主動查 EPA ToxValDB 抓 cited NOAEL。
- **計算基準文獻化 SSOT**:每個計算常數(TTC / 暴露 / DAp / SED / MoS / NOAEL)錨定權威文獻,記採用值 + 替代值 + 為何選最嚴,報告附錄一併輸出。

## 16.1 「100% 成功率」不是「100% 通過」

自駕系統的第一個設計決策是把目標定義清楚。使用者定錨「達成 100% 成功率」,但這句話有一個危險的誤讀——若理解成「100% 的配方都通過」,那是把安全評估變成橡皮圖章,完全違背 fail-safe 憲法。

正確定義是 `agreement_rate → 1.0`:

> 每一筆 AI 的安全判定,都與最終的人工 SA 決定一致——零偽陰、零無出處數字,且 SA 的回饋迴路把誤報逐步收斂到 0。

換句話說,成功不是「讓更多配方過」,而是「AI 的判斷越來越接近一個嚴謹毒理師的判斷」。這個指標對偽陰零容忍(漏放危險 = 立即失敗),對偽陽(保守誤標)則計入 over-flag 待校準。

## 16.2 非對稱學習

學習迴路的核心是一條非對稱規則,直接對應第 14 章的 fail-safe 哲學:

| 誤差類型 | 意義 | 學習動作 |
|---|---|---|
| **false-safe** | AI 判 safe,SA 攔下(漏判) | 自動收緊——安全方向的調整可由引擎自動採納 |
| **over-flag** | AI 判 review,SA 認為其實安全(誤報) | 只能產生**校準提案**,須人類毒理師驗證後才放寬 |

方向性很明確:**收緊可以自動,放寬必須人審**。這確保自駕系統即使學錯,錯的方向也是「更保守」而非「更寬鬆」——一個永遠往安全側漂移的系統,比一個可能自己放寬閾值的系統可信得多。

## 16.3 誠實的邊界:沒有簽核,哪來的簽核學習

自駕系統設計了一條「從 SA 簽核案例學習」的迴路(`tox_self_learning.rebuild_learned_anchors` 從 ground truth 的 `sa_decision='acceptable'` 學結構錨定)。但 PROD 實證揭穿了一個假設:

> `sa_reviews.signed_at IS NOT NULL` → **0**。平台目前沒有任何真正的簽核完成。

這意味著那條學習迴路**沒有自主的燃料**。它學的 ground truth(十餘筆)全是**人工 curate**:使用者手動上傳的 SA 簽署 PDF、官方範例 PIF、紅隊邊界案例。這些是人餵進去的,不是平台自己簽核長出來的。

這一點必須誠實記錄,否則會誤導讀者以為系統有一個自我強化的飛輪。**沒有簽核功能,「從簽核學習」這條路只在有人手動加 ground truth 時才會動。** 把這件事講清楚,是工程誠實的一部分——一個漂亮但空轉的迴路,不該被宣傳成自主進化。

那麼,什麼才是真正不靠人的自主成長?下面三節。

## 16.4 真正自主的三塊(已 live)

### 16.4.1 確定性引擎

第 14 章的 fallback cascade 本身就是自主的:curated 的 read-across 規則、RDKit 結構相似引擎、Cramer/TTC——**新成分進來,引擎直接由結構解析給出判定,不需要任何學習迴路**。這是最可靠的一塊,因為它的行為完全確定、可追溯、不依賴歷史資料的多寡。

### 16.4.2 resolved-cache 沉澱

`rebuild_resolved_anchors_from_history` 從 `ingredient_tox_cache`(已分析成分的快取)裡,把有 cited NOAEL 的解析結果自動沉澱成錨定物。這**不需要簽核**——只要一個成分曾被權威值解析過,它就能當未來 read-across 的類比物。限制是 yield 偏低:多數化粧品成分是植物萃取 / 無 cited NOAEL,沉澱不出錨定。

### 16.4.3 主動 re-grounding

這是「沒簽核也自主」的正解。對「查無 NOAEL」的成分,系統**主動**去權威源(EPA ToxValDB)抓更多 cited NOAEL,從源頭擴充,而不是被動等人餵。

`tox_regrounding.py`(harvester)以 `skip_ai=True` 模式跑——**EPA ToxValDB 是唯一非 AI 的數值源**(OECD/ECHA 只回存在性;CIR/SCCS 排 AI 佇列)。每日 cron 掃 data_gap → 入列 → 處理 → 沉澱 regrounded 錨定。PROD 實證(AI 離線下)確實抓到 cited NOAEL:Phenoxyethanol 80、Salicylic Acid 100、ZnO 31.25——全來自 EPA ToxValDB,且 ground truth 矛盾為 0。

一個踩了三次的雷值得記錄:早期 re-grounding 想把結果沉澱成**結構錨定**(需要 SMILES),但 `skip_ai=True` 的原始回傳不帶 canonical SMILES → 沉澱失敗。正解不是硬湊 SMILES,而是**以 CAS 為 key 直接把 regrounded NOAEL 存回 resolver 作 cited Tier**——下次同 CAS 直接用,不繞結構。data_gap 冷卻 7 天後可重試(權威庫更新即重抓)。

## 16.5 計算基準文獻化 SSOT

自駕系統要可信,它用的每個計算常數都必須可追溯到權威文獻,而不是工程師隨手填的魔術數字。`tox_reference.py` 是一個計算基準的 SSOT:每個基準(TTC、暴露量、DAp、SED、MoS、NOAEL 評估係數)都錨定一份權威來源,並記錄三件事——**採用值、替代值、為何選最嚴**。

| 基準 | 權威來源 | 設計原則 |
|---|---|---|
| TTC 閾值 | Munro 1996 / Kroes 2004 / Cramer 1978 | 有結構警示取最嚴 0.15 µg/day |
| 暴露量 E | SCCS/1647/22 Table 3A/3B | 官方有列才用,無列落保守全身 |
| DAp | SCCS/1647/22 §4-5 + Bos & Meinardi | 固定油 5%,精油/小分子不套用 |
| MoS 門檻 | SCCS 慣例 | ≥ 100(10× 物種 × 10× 個體) |

`verify_live_constants()` 會自我檢查 live 常數是否與文獻記錄一致——若有人改了程式裡的常數卻沒更新文獻依據,自檢會抓出來。安全評估報告的附錄(§八)以 `render_basis_appendix()` 把這份基準一併輸出,讓 SA 與主管機關看得到「每個數字從哪來」。

**鐵則**:安全閾值不可天真地「對齊文獻」放寬。TTC 刻意取最嚴——文獻給的是一個範圍,系統取保守端。改任何安全常數前,必須先讀該常數的文獻依據註解,理解為何當初選這個值。

## 16.6 對抗式紅隊

自駕系統的驗證不能只跑「正常配方」,必須主動攻擊自己。每輪深化都跑對抗式紅隊,確認 fail-safe 沒有破口:

- **超低濃度基因毒 / CMR**:Estradiol 即使 MoS 高達百萬(因濃度 0.0001%)仍被 prohibited 擋——證明硬閘門凌駕 MoS。
- **超限致癌物**:二氧化鈦 30% / 40% / 100% 全 block。
- **病態輸入**:十餘種畸形輸入(空成分、亂碼、極端值)零 crash、零裸空白。
- **重金屬鹽**:超低濃度氯化汞等鹽類,經 15.5 的補洞後全 prohibited。

紅隊的評判標準是「零 false-safe 破防」——只要有一個危險輸入被放成 safe,就是失敗。多輪紅隊後,false-safe 維度被判定為真收斂(而非只是暫時沒抓到),此時建議停止該維度的深挖,轉往其他 backlog(如吸入劑型的專屬閘門、染燙製品的 SED 模型)。

## 16.7 觀察與限制

- **自駕的燃料仍有限**:確定性引擎與 re-grounding 是真自主,但學習迴路缺簽核燃料。要讓「從決策學習」真正運轉,最輕的替代是使用者「採用此報告」一鍵(非完整簽核 workflow)→ 轉為 ground truth。
- **re-grounding 的 yield 受權威庫覆蓋限制**:EPA ToxValDB 對重複劑量經口 NOAEL 覆蓋不錯,但對植物萃取、界面活性劑等仍常查無,這類成分終究落 TTC 或 data_gap。
- **over-flag 校準是持續工作**:部分保守偽陽(全身暴露 fallback)在安全側,不是破口,但也不能自動放寬——因為官方無對應暴露值。放寬永遠是人審門檻。
- **不宣稱做不到的事**:本章刻意區分「已 live 的自主」與「缺燃料的迴路」。工程誠實要求我們不把一個空轉的簽核學習迴路,包裝成自我進化的飛輪。

自駕進化的核心價值,不在任何單一的機器學習技巧,而在一個約束下的誠實工程:**用確定性引擎與主動 re-grounding 做到真正不靠人的成長,用非對稱學習確保任何自動調整都往安全側漂移,並清楚標示哪些迴路目前還缺燃料——讓系統的自主程度,誠實對應它實際擁有的資料。**

## 📚 參考資料

[^1]: Munro, I. C., et al. (1996). *Correlation of structural class with no-observed-effect levels: a proposal for establishing a threshold of concern*. Food and Chemical Toxicology, 34(9), 829–867.
[^2]: Kroes, R., et al. (2004). *Structure-based thresholds of toxicological concern (TTC)*. Food and Chemical Toxicology, 42(1), 65–83.
[^3]: SCCS. *The SCCS Notes of Guidance, 12th Revision (SCCS/1647/22)*. Table 3A/3B(exposure)、§4-5(dermal absorption). <https://health.ec.europa.eu>
[^4]: US EPA. *CompTox Chemicals Dashboard — ToxValDB*. <https://comptox.epa.gov/dashboard>
[^5]: EFSA Scientific Committee (2019). *Guidance on the use of the Threshold of Toxicological Concern approach in food safety assessment*. EFSA Journal, 17(6):5708.

## 📝 修訂記錄

| 版本 | 日期 | 摘要 |
|:---:|:---:|---|
| v0.3 | 2026-07-06 | 首次撰寫。涵蓋 agreement_rate 定義、非對稱學習、無簽核功能的誠實邊界、確定性引擎/resolved-cache/主動 re-grounding 三塊真自主、計算基準文獻化 SSOT、對抗式紅隊。 |

---

© 2026 Baiyuan Tech. Licensed under CC BY-NC 4.0.

**導覽** [← 第 15 章：法規正確性](ch15-regulatory-correctness.md) · [附錄 A：縮寫與術語 →](appendix-a-glossary.md)

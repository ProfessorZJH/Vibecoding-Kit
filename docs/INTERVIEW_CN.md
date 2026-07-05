# Vibecoding Kit 中文面试话术

这份文档不是项目设计文档，也不是任务卡。它的用途很直接：把
Vibecoding Kit 讲成一套能在中文面试里稳定输出的话术，而不是临场发挥。

## 使用原则

- 不要把它讲成新的 AI 模型。
- 不要把它讲成“万能防跑偏系统”。
- 不要只讲 prompt，要讲 repository contract、policy、guard、report。
- 面试官如果偏业务后端，就多讲工程治理和 Java 项目价值。
- 面试官如果偏 AI 工程，就多讲多工具适配和 drift governance。

## 一句话定位

Vibecoding Kit 不是业务系统，也不是新的 AI 编程模型。它是 AI 辅助开发外面的仓库级治理层，用任务卡、锁定计划、策略文件、守卫脚本和收尾报告，把 AI 长任务中的漂移变成可检测、可阻断、可审计的工程问题。

## 30 秒版本

我做的不是一个新的 Agent，而是 Agent 外面的治理层。因为我在用 Codex、Claude Code 这类工具做长任务时发现，聊天上下文、原始计划、仓库状态和最终 diff 很容易逐渐不一致。Vibecoding Kit 的做法是把当前任务、当前步骤、允许改哪些文件、禁止碰哪些路径、需要哪些检查都落到仓库里，再用 guard 脚本和报告机制去验证，所以它解决的是 AI 开发过程里的工程治理问题，而不是替代模型本身。

## 1 分钟主讲稿

### Java 后端侧重版

这个项目我通常把它讲成“面向 AI 协作开发的工程治理模板”。因为我主方向还是 Java 后端，我更关心的是，当 AI 参与一个真实项目开发时，怎么让它不要越权改配置、不要跳过计划、不要没有 checkpoint 就说自己做完了。Vibecoding Kit 的做法是把任务卡、需求、设计、执行计划、AI 状态、allowed files、forbidden paths 这些信息都变成仓库内文件，然后用 shell guard 去检查计划有没有锁、当前 step 对不对、改动文件有没有超出范围、有没有碰敏感路径、有没有留下 closeout evidence。这样它对 Java 项目的价值，不是帮我生成几个类，而是把 AI 纳入接近正常工程流程的治理框架里，降低长任务时的失控成本。

### Agent 工程侧重版

如果面试官更偏 AI 工程，我会强调这是一个 repository-level governance kit。很多 AI coding 工具本身会提供计划、上下文压缩、工具调用，但这些能力大多是通用的，不会天然理解某个项目此刻允许改什么文件、要求什么 checkpoint、哪些命令风险过高。Vibecoding Kit 做的是把这些项目内约束变成 repository contract，再通过 prompt layer、policy layer、guard layer、report layer 去约束和审计不同工具的行为。它不依赖某一家模型或某一个 IDE，而是让 Codex、Claude Code、Cursor、Cline、Windsurf、Gemini 这些工具都尽量对齐到同一套项目状态和执行边界上。

## 深挖问答

### 1. 这个项目到底是干什么的？

它是一个给新项目安装的 AI 协作开发模板。安装后，项目里会有 AI 状态文件、任务卡、需求/设计/计划目录、policy 文件、guard 脚本、closeout 报告和工具适配入口。核心目标不是“让 AI 更聪明”，而是“让 AI 更受工程约束”。

### 2. 它能帮助做什么？

- 让仓库而不是聊天窗口成为 source of truth。
- 让当前任务和当前步骤有明确落点。
- 让 allowed files / forbidden paths 变成可检查的规则。
- 让高风险命令、敏感路径、越权改动更早暴露。
- 让任务结束时不只是“AI 说做完了”，而是留下 closeout evidence。

### 3. 为什么 Codex、Claude Code 这些工具自己不直接做成这样？

因为它们首先是通用 AI coding product，不是某个团队、某个仓库、某个项目流程的专属治理系统。通用产品会优先保证易用性、跨项目泛化和低摩擦体验，但一个真实项目往往需要非常具体的 repository contract，比如当前任务只允许动一个 service 文件、禁止碰 runtime config、要求本地 commit checkpoint、要求 closeout report。这种约束天然更适合放在仓库里，而不是完全依赖工具内置逻辑。

### 4. 你为什么要自己做这个？

因为这是我自己在实际使用 AI coding 工具时遇到的真实痛点。我发现一旦任务长、上下文多、涉及规划和多轮修改，AI 很容易出现三类问题：第一，计划和实际改动逐渐不一致；第二，顺手改了计划外文件；第三，做完后缺少测试、checkpoint 和收尾证据。所以我做的不是再写一套大 prompt，而是把这些约束落到仓库里，让流程可验证。

### 5. 核心设计是什么？

我一般用四层来讲：

1. Prompt layer：告诉 AI 应该怎么探索、规划、实施、收尾。
2. Policy layer：定义敏感路径、命令分类、风险分级。
3. Guard layer：检查 plan lock、current step、file scope、secrets、command risk。
4. Report layer：沉淀 risk report 和 closeout report，方便审计和交接。

关键点在于 prompt 是软约束，真正硬一点的边界在 policy 和 guard 上。

### 6. 为什么不只靠 prompt？

因为 prompt 最多只能提高“倾向性”，不能提供可信校验。AI 可能理解错，也可能执行时跑偏。只靠 prompt，本质上还是在相信模型自己会记住规则。仓库文件和 guard 脚本的价值在于，哪怕它没完全听话，至少你能发现它哪里越界了。

### 7. 它的效果有多少？

不能讲成“完全防跑偏”。更准确的说法是：

- 它对显式漂移很有效，比如改了未授权文件、计划没锁、step 不匹配、碰了敏感路径、用了明显高风险命令。
- 它对流程证据很有效，比如能留下计划状态、风险报告、closeout report。
- 它对语义正确性不是充分条件，业务逻辑对不对、设计是不是合理、测试是不是足够，仍然要靠工程判断。

所以它的价值不是保证 AI 不出错，而是明显降低“无约束、无证据、无边界”的风险。

### 8. 这个项目为什么对 Java 后端岗位有价值？

因为它本质上还是工程治理问题，而不是纯 prompt 工程。Java 后端项目通常更强调分层、配置安全、接口契约、CI、变更边界和可审计性。Vibecoding Kit 把这些工程习惯迁移到了 AI 协作开发场景里。你可以把它理解成：不是单纯让 AI 帮我写代码，而是把 AI 也放进一套比较接近正常团队开发纪律的框架里。

### 9. 这个项目为什么又带一点 Agent 工程倾向？

因为它处理的是多 AI 工具协作时的统一约束问题。它需要考虑 prompt routing、adapter entry、long-session memory、task handoff、command governance、risk evidence 这些问题。这些问题和普通 CRUD 项目不一样，更接近 agent workflow engineering，但它最终落地的形式仍然是仓库内协议和脚本，而不是重新训练模型。

### 10. 这个项目现在的边界和局限是什么？

- 当前实现仍然偏 shell-based MVP，不是成熟 CLI 产品。
- policy 已经抽出来了，但第一版不是完全 policy-driven parser。
- 它更擅长暴露流程问题，不直接证明业务正确性。
- 它更适合新项目或愿意接受这套流程的项目，接管历史仓库会更重。

这些局限要主动讲出来，反而更可信。

## 岗位切换建议

### 面 Java 后端时

优先强调：

- 工程治理
- 边界控制
- 配置和敏感路径风险
- DDD / API contract / CI / Git checkpoint 的协作关系
- 为什么 AI 也需要被纳入正常研发流程

一句话抓手：

> 我不是在做一个替代开发者的 AI，而是在做一层能把 AI 纳入工程纪律的仓库级治理工具。

### 面 Agent / AI 工程时

优先强调：

- repository-level contract
- tool-agnostic adapter design
- prompt / policy / guard / report 四层结构
- long-session drift
- handoff and evidence preservation

一句话抓手：

> 我关注的不是让某个模型在单次对话里表现更强，而是让不同 AI coding tools 在真实仓库里更可控、更可审计。

## 表达禁区

不要这样讲：

- “这个项目能保证 AI 不跑偏。”
- “这就是一套 prompt 工程。”
- “我做了一个新的 AI 编程模型。”
- “有了它就不需要代码评审和测试了。”
- “它已经完全产品化了。”

更稳的表达：

- “它降低了 AI 长任务里的显式漂移风险。”
- “它把很多原本只存在于聊天上下文里的约束落成了仓库内协议。”
- “它更像 AI 协作开发的治理层，而不是模型层能力。”
- “它对工程流程正确性更有帮助，对业务语义正确性不是充分保证。”

## 收束版结论

如果只留一句最稳的话术，我建议用这一句：

> Vibecoding Kit 是一个面向 AI 辅助开发的仓库级治理工具。它不替代 Codex、Claude Code 这类模型或产品，而是把任务状态、计划边界、风险规则和收尾证据落到仓库里，用 guard 和 report 去检测、阻断和审计 AI 在真实项目里的任务漂移。

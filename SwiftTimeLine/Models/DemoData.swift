import Foundation

enum DemoData {
    static func groups(language: AppLanguage) -> [TimelineGroup] {
        [llmHistory(language: language), dotnetHistory(language: language)]
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }

    // MARK: - LLM history

    private static func llmHistory(language: AppLanguage) -> TimelineGroup {
        let zh = language == .chinese

        let paper = Tag(name: zh ? "论文" : "Papers", color: "#4A90D9")
        let release = Tag(name: zh ? "模型发布" : "Model Releases", color: "#9B59B6")
        let milestone = Tag(name: zh ? "里程碑" : "Milestones", color: "#E74C3C")

        let events: [TimelineEvent] = [
            TimelineEvent(
                title: zh ? "《Attention Is All You Need》" : "Attention Is All You Need",
                description: zh ? "提出 Transformer 架构，奠定现代大语言模型的基础。" : "Introduces the Transformer architecture, the foundation of modern LLMs.",
                date: date(2017, 6, 12),
                tagIDs: [paper.id],
                color: paper.color
            ),
            TimelineEvent(
                title: zh ? "GPT-1 发布" : "GPT-1 released",
                description: zh ? "OpenAI 首个生成式预训练模型，验证了无监督预训练的有效性。" : "OpenAI's first generative pre-trained model, validating unsupervised pre-training.",
                date: date(2018, 6, 11),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: zh ? "GPT-2 发布" : "GPT-2 released",
                description: zh ? "15 亿参数，展现出强大的零样本能力。" : "1.5B parameters, showing surprising zero-shot abilities.",
                date: date(2019, 2, 14),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: zh ? "GPT-3 发布" : "GPT-3 released",
                description: zh ? "1750 亿参数，few-shot 学习能力引发广泛关注。" : "175B parameters; its few-shot abilities drew wide attention.",
                date: date(2020, 5, 28),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: zh ? "ChatGPT 发布" : "ChatGPT launched",
                description: zh ? "对话式 AI 引爆全球，两个月内用户破亿。" : "Conversational AI went global, reaching 100M users in two months.",
                date: date(2022, 11, 30),
                tagIDs: [release.id, milestone.id],
                color: milestone.color
            ),
            TimelineEvent(
                title: zh ? "GPT-4 发布" : "GPT-4 released",
                description: zh ? "支持多模态输入，推理能力显著提升。" : "Multimodal input with markedly stronger reasoning.",
                date: date(2023, 3, 14),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: zh ? "Llama 2 开源" : "Llama 2 open-sourced",
                description: zh ? "Meta 开放可商用的大模型，推动开源生态。" : "Meta released commercially usable LLMs, boosting the open ecosystem.",
                date: date(2023, 7, 18),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: zh ? "Gemini 1.0 发布" : "Gemini 1.0 released",
                description: zh ? "Google 发布原生多模态模型家族。" : "Google introduced its natively multimodal model family.",
                date: date(2023, 12, 6),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: zh ? "Claude 3 发布" : "Claude 3 released",
                description: zh ? "Anthropic 推出多档模型，长上下文表现突出。" : "Anthropic's model family with strong long-context performance.",
                date: date(2024, 3, 4),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: zh ? "Llama 3.1 405B" : "Llama 3.1 405B",
                description: zh ? "当时规模最大的开源稠密模型。" : "The largest openly available dense model at the time.",
                date: date(2024, 7, 23),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: zh ? "DeepSeek-R1 发布" : "DeepSeek-R1 released",
                description: zh ? "开源推理模型，展示出强大的思维链能力。" : "An open reasoning model with strong chain-of-thought abilities.",
                date: date(2025, 1, 20),
                tagIDs: [release.id, milestone.id],
                color: milestone.color
            ),
        ]

        return TimelineGroup(
            name: zh ? "LLM 发展史" : "History of LLMs",
            color: "#9B59B6",
            emoji: "🤖",
            tags: [release, paper, milestone],
            events: events.sorted { $0.date < $1.date }
        )
    }

    // MARK: - .NET history

    private static func dotnetHistory(language: AppLanguage) -> TimelineGroup {
        let zh = language == .chinese

        let release = Tag(name: zh ? "版本发布" : "Releases", color: "#2ECC71")
        let milestone = Tag(name: zh ? "里程碑" : "Milestones", color: "#F39C12")

        let events: [TimelineEvent] = [
            TimelineEvent(
                title: zh ? ".NET 愿景发布" : ".NET announced",
                description: zh ? "微软在 PDC 2000 上提出 .NET 战略。" : "Microsoft unveiled the .NET vision at PDC 2000.",
                date: date(2000, 6, 22),
                tagIDs: [milestone.id],
                color: milestone.color
            ),
            TimelineEvent(
                title: ".NET Framework 1.0",
                description: zh ? "随 Visual Studio .NET 正式发布。" : "Shipped alongside Visual Studio .NET.",
                date: date(2002, 2, 13),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: ".NET Framework 2.0",
                description: zh ? "引入泛型、ASP.NET 2.0 等特性。" : "Added generics, ASP.NET 2.0 and more.",
                date: date(2005, 11, 7),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: ".NET Framework 3.0",
                description: zh ? "带来 WPF、WCF 与 WF。" : "Introduced WPF, WCF and WF.",
                date: date(2006, 11, 6),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: ".NET Framework 3.5",
                description: zh ? "引入语言集成查询 LINQ。" : "Introduced Language Integrated Query (LINQ).",
                date: date(2007, 11, 19),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: ".NET Framework 4.0",
                description: zh ? "支持动态类型与并行编程。" : "Added dynamic typing and parallel programming.",
                date: date(2010, 4, 12),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: zh ? ".NET Core 开源" : ".NET open-sourced",
                description: zh ? "微软宣布 .NET 跨平台与开源。" : "Microsoft announced a cross-platform, open-source .NET.",
                date: date(2014, 11, 12),
                tagIDs: [milestone.id],
                color: milestone.color
            ),
            TimelineEvent(
                title: ".NET Core 1.0",
                description: zh ? "跨平台运行时正式发布。" : "The cross-platform runtime reached 1.0.",
                date: date(2016, 6, 27),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: ".NET Core 3.0",
                description: zh ? "重新支持桌面端 WinForms 与 WPF。" : "Brought back desktop WinForms and WPF support.",
                date: date(2019, 9, 23),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: ".NET 5",
                description: zh ? "统一平台，迈向单一 .NET。" : "Unified the platform toward a single .NET.",
                date: date(2020, 11, 10),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: ".NET 6 (LTS)",
                description: zh ? "长期支持版本，跨平台高度统一。" : "A long-term support release with a unified cross-platform stack.",
                date: date(2021, 11, 8),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: ".NET 7",
                description: zh ? "性能进一步提升。" : "Further performance improvements.",
                date: date(2022, 11, 8),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: ".NET 8 (LTS)",
                description: zh ? "长期支持版本，强化云原生与 AOT。" : "A long-term support release focused on cloud-native and AOT.",
                date: date(2023, 11, 14),
                tagIDs: [release.id],
                color: release.color
            ),
            TimelineEvent(
                title: ".NET 9",
                description: zh ? "聚焦性能、AI 与云原生。" : "Focused on performance, AI and cloud-native.",
                date: date(2024, 11, 12),
                tagIDs: [release.id],
                color: release.color
            ),
        ]

        return TimelineGroup(
            name: zh ? ".NET 发展史" : "History of .NET",
            color: "#512BD4",
            symbol: "chevron.left.forwardslash.chevron.right",
            tags: [release, milestone],
            events: events.sorted { $0.date < $1.date }
        )
    }
}

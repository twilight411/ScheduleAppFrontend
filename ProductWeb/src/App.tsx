import { useEffect, useState } from "react";
import bubbleSphereBg from "@schedule/images/光合日历气泡球背景.png";
import pcBg from "@schedule/images/PC背景.png";
import spiritAir from "@schedule/public/spirits/spirit_air.png";
import spiritLight from "@schedule/public/spirits/spirit_light.png";
import spiritNutrition from "@schedule/public/spirits/spirit_nutrition.png";
import spiritSoil from "@schedule/public/spirits/spirit_soil.png";
import spiritWater from "@schedule/public/spirits/spirit_water.png";

/** 立绘顺序与角色对应：光→晴、水→滴、云→朵、壤→壤、养→星（沿用现有五张原画） */
const SPIRITS: { img: string; name: string; meta: string; tag: string; blurb: string }[] = [
  {
    img: spiritLight,
    name: "卷卷晴",
    meta: "ENTJ · 太阳意象",
    tag: "成就",
    blurb: "工作学习的「发动机」：拆解复杂任务、给出高效规划，陪你克服拖延、把成就感一点点攒回来。",
  },
  {
    img: spiritWater,
    name: "嘻嘻滴",
    meta: "ESFP · 水滴意象",
    tag: "积极情绪",
    blurb: "快乐补给站：挖掘日程里的小确幸，用正向反馈让记录不只是压力，而是能点亮情绪的光。",
  },
  {
    img: spiritAir,
    name: "贴贴朵",
    meta: "ESFJ · 云朵意象",
    tag: "关系",
    blurb: "人际关系维护师：在忙碌里替你惦记家人与朋友，守护那些容易被「理性牺牲」掉的亲密时间。",
  },
  {
    img: spiritSoil,
    name: "慢慢壤",
    meta: "INFP · 小团子意象",
    tag: "意义与身心",
    blurb: "温和边界的守护者：在身体与情绪需要托底时靠近你，允许疲惫与不完美，一起找回节奏。",
  },
  {
    img: spiritNutrition,
    name: "新新星",
    meta: "ENTP · 星星意象",
    tag: "投入与心流",
    blurb: "兴趣试验家：为见效慢却长久幸福的爱好争取空间，鼓励你从微小、具体的行动重新玩起来。",
  },
];

const PILLARS = [
  {
    title: "从「监工」到「伙伴」",
    body: "AI 不只做冰冷提醒：五位性格鲜明的精灵用自然语言贴近你的状态（例如「最近很累」），动态调整计划，在做事的同时给你情绪支持与接纳感。",
  },
  {
    title: "生命树看见「多维平衡」",
    body: "学习、休闲、运动、关系……各维度的投入会长成一棵生命树。长期被忽视的维度会以枯萎等方式温柔预警，帮你从「只赶任务」回到好好生活。",
  },
  {
    title: "Balance Tree：取舍与守住整块时间",
    body: "借助 Balance Tree 思路识别日程冲突，在堆积如山的待办里协助你做取舍，优先守住属于自己的整块时间，对抗健康与兴趣最先被牺牲的惯性。",
  },
];

const VOICES = [
  {
    quote: "我不是不想努力，是怕一打开待办就被审判；这里更像有人蹲在旁边说「我们先从这一小步开始」。",
    who: "拖延自责型 · 使用情境示意",
  },
  {
    quote: "树枯了一块我才意识到：这周又是只有工作绿、其他全灰——比数字统计更扎心，也更愿意改。",
    who: "隐性耗竭型 · 使用情境示意",
  },
  {
    quote: "卷卷晴催进度，嘻嘻滴又把我从内疚里拎出来一点；像一个小团队，而不是一个闹钟。",
    who: "高压多任务 · 使用情境示意",
  },
];

const FAQ = [
  {
    q: "光合日历和 Balance Tree、生命树是什么关系？",
    a: "光合日历（Balance Tree）是一套基于积极心理学 PERMA 的多维生活管理系统：五位 AI 伙伴对应不同幸福维度，生命树则把这些维度从抽象数字变成一眼能懂的生长状态。桌面端会持续把这一理念落到日常交互里。",
  },
  {
    q: "我的数据会离开电脑吗？",
    a: "以当前设计方向为主：时间线与录音等能力默认偏向本地处理。若未来接入云端能力，会在隐私政策里逐项说明，并由你在设置中明确授权。",
  },
  {
    q: "网页上的角色和软件里一致吗？",
    a: "视觉与气质与客户端对齐；角色命名与故事以官网表述为准，具体互动能力以各端正式发布版本为准。",
  },
];

const GUIDES = [
  {
    title: "PERMA 与幸福：为什么用五个伙伴而不是一个「全能助手」？",
    desc: "积极心理学把幸福拆成积极情绪、投入、关系、意义与成就；拆成五位精灵，是为了让提醒与鼓励更具体、更有人味。",
    href: "#spirits",
  },
  {
    title: "生命树：从数据到「我过得怎么样」",
    desc: "当各生活维度被看见，失衡就不再只是内疚，而会变成可以行动的信号。",
    href: "#pillars",
  },
  {
    title: "桌面气泡球：伙伴在桌边，而不是在另一个 App 里",
    desc: "轻打扰入口，随时把自然语言对话和状态感知拉到手边。",
    href: "#bubble",
  },
];

const MOBILE_PILLARS = [
  {
    title: "一分钟，看见「今天过得平衡吗」",
    body: "移动端优先给「扫一眼」：生命树与多维色带占主视觉，弱网也尽量可读；适合通勤、排队、睡前的快速自检，而不是打开又一整页待办。",
  },
  {
    title: "短句与小卡：精灵接力点火",
    body: "通知、小组件与卡片式对话承担「点火」——一句提醒、一张小结；深度拆解、长对话与大块编辑更适合回到桌面，避免拇指在小程序里写论文。",
  },
  {
    title: "手机是桌面的「遥控器」",
    body: "与桌面同源 PERMA 与五位伙伴设定：路上做确认、打卡与情绪温度调节；写方案、拆项目、长时段专注仍交给电脑，两端合成一条生活线。",
  },
];

const MOBILE_VOICES = [
  {
    quote: "地铁上不敢开电脑版，手机上看一眼树况就下车——知道今天哪块太干，心里反而踏实。",
    who: "通勤族 · 使用情境示意",
  },
  {
    quote: "以前移动端像把桌面硬塞进来；现在更像「帮我收个尾」，不逼我在小屏里干重活。",
    who: "跨端用户 · 使用情境示意",
  },
  {
    quote: "贴贴朵一条短消息问我这周有没有留给人——比长篇大论更能点醒我。",
    who: "关系敏感型 · 使用情境示意",
  },
];

const MOBILE_GUIDES = [
  {
    title: "为什么移动端不讲「桌边气泡球」？",
    desc: "气泡球是桌面场景的轻入口；在手机上我们用卡片、列表与小组件完成同样的「伸手可及」。",
    href: "#m-preview",
  },
  {
    title: "随身 PERMA：同一套伙伴，不同节奏",
    desc: "五位精灵在手机上更偏短句与情境触发，把陪伴拆成路上能消化的一口大小。",
    href: "#m-spirits",
  },
  {
    title: "与桌面如何分工？",
    desc: "大编辑在桌面，小决策在口袋；生命树两端同步，失衡预警不会因为换设备而断档。",
    href: "#m-pillars",
  },
];

const MOBILE_FAQ = [
  {
    q: "移动端和桌面端数据会同步吗？",
    a: "产品目标是同一套 Balance Tree 与生命树状态在多端一致呈现；具体同步策略、离线能力与隐私边界以正式发布说明为准。",
  },
  {
    q: "手机上能做哪些事、哪些事建议回桌面？",
    a: "手机侧重查看平衡、快速记录、精灵短互动与日程确认；复杂任务拆解、长文本与深度对话仍以桌面体验为主，避免小屏过载。",
  },
  {
    q: "iOS 和 Android 都会支持吗？",
    a: "双端均在产品路线中；上线顺序与测试渠道会通过官网与预约通知同步，请以届时公告为准。",
  },
];

type ProductSurface = "desktop" | "mobile";

function PlatformSwitch({
  value,
  onChange,
}: {
  value: ProductSurface;
  onChange: (next: ProductSurface) => void;
}) {
  return (
    <div
      className="inline-flex rounded-full border border-emerald-900/15 bg-emerald-50/40 p-1 shadow-soft"
      role="group"
      aria-label="选择查看桌面端或移动端介绍"
    >
      {(
        [
          { id: "desktop" as const, label: "桌面端" },
          { id: "mobile" as const, label: "移动端" },
        ] as const
      ).map((opt) => (
        <button
          key={opt.id}
          type="button"
          onClick={() => onChange(opt.id)}
          aria-pressed={value === opt.id}
          className={`rounded-full px-4 py-1.5 text-sm font-semibold transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400/80 ${
            value === opt.id
              ? "bg-white text-emerald-900 shadow-sm ring-1 ring-emerald-900/10"
              : "text-gl-muted hover:text-emerald-900"
          }`}
        >
          {opt.label}
        </button>
      ))}
    </div>
  );
}

export default function App() {
  const [surface, setSurface] = useState<ProductSurface>("desktop");

  useEffect(() => {
    window.scrollTo({ top: 0, left: 0, behavior: "auto" });
  }, [surface]);

  const navItems =
    surface === "desktop"
      ? [
          { href: "#pillars", label: "亮点" },
          { href: "#voices", label: "回声" },
          { href: "#spirits", label: "五位伙伴" },
          { href: "#bubble", label: "气泡球" },
          { href: "#faq", label: "常见问题" },
        ]
      : [
          { href: "#m-pillars", label: "亮点" },
          { href: "#m-voices", label: "回声" },
          { href: "#m-spirits", label: "五位伙伴" },
          { href: "#m-preview", label: "界面预览" },
          { href: "#m-faq", label: "常见问题" },
        ];

  return (
    <div className="min-h-screen antialiased">
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:absolute focus:left-4 focus:top-4 focus:z-[100] focus:rounded-lg focus:bg-white focus:px-3 focus:py-2 focus:text-sm focus:shadow-soft"
      >
        跳到主要内容
      </a>

      <header className="sticky top-0 z-50 border-b border-emerald-900/10 bg-white/70 backdrop-blur-md">
        <div className="mx-auto flex max-w-6xl items-center gap-3 px-4 py-3 sm:gap-4 sm:px-6">
          <a
            href={surface === "desktop" ? "#top" : "#m-top"}
            className="group flex min-w-0 shrink-0 items-center gap-3 text-gl-ink"
            aria-label="光合日历 · 返回顶部"
          >
            <span className="relative isolate h-10 w-10 shrink-0 overflow-hidden rounded-full shadow-soft ring-1 ring-emerald-900/15 transition group-hover:-translate-y-px">
              <img
                src={bubbleSphereBg}
                alt=""
                className="absolute inset-0 h-full w-full object-cover"
                style={{ objectPosition: "center 32%" }}
                draggable={false}
              />
            </span>
            <div className="min-w-0 leading-tight">
              <div className="font-display text-base font-semibold tracking-tight sm:text-lg">光合日历</div>
              <div className="text-xs text-gl-muted sm:text-[13px]">
                {surface === "desktop" ? "Balance Tree · 多维生活管理" : "Balance Tree · 随身多维平衡"}
              </div>
            </div>
          </a>

          <div className="flex min-w-0 flex-1 justify-center sm:justify-start sm:pl-2">
            <PlatformSwitch value={surface} onChange={setSurface} />
          </div>

          <nav className="ml-auto hidden items-center gap-6 text-sm font-medium text-gl-ink/80 lg:flex lg:gap-7">
            {navItems.map((item) => (
              <a key={item.href} className="whitespace-nowrap transition hover:text-emerald-800" href={item.href}>
                {item.label}
              </a>
            ))}
          </nav>
          <a
            href={surface === "desktop" ? "#cta" : "#m-cta"}
            className="shrink-0 rounded-full bg-gradient-to-r from-emerald-600 to-lime-600 px-3 py-2 text-sm font-semibold text-white shadow-lift transition hover:brightness-105 sm:px-4"
          >
            预约更新通知
          </a>
        </div>
      </header>

      <main id="main">
        {surface === "desktop" && (
          <>
        <section id="top" className="relative overflow-hidden">
          <div className="pointer-events-none absolute inset-0">
            <img
              src={pcBg}
              alt=""
              className="h-full min-h-[440px] w-full object-cover opacity-[0.38] sm:min-h-[560px]"
              style={{ objectPosition: "center 26%" }}
            />
            <div className="absolute inset-0 bg-gradient-to-b from-white/35 via-white/86 to-gl-surface" />
            <div className="absolute inset-0 bg-[radial-gradient(900px_420px_at_70%_18%,oklch(0.93_0.06_150/0.55),transparent_60%)]" />
          </div>

          <div className="relative mx-auto max-w-6xl px-4 pb-16 pt-12 sm:px-6 sm:pb-24 sm:pt-20">
            <p className="mb-4 inline-flex max-w-full flex-wrap items-center gap-2 rounded-full border border-emerald-900/10 bg-white/70 px-3 py-1.5 text-xs font-medium text-gl-ink/85 shadow-soft backdrop-blur">
              <span className="rounded-full bg-emerald-600/10 px-2 py-0.5 text-[11px] font-semibold text-emerald-900">
                官方网站
              </span>
              <span className="text-gl-muted">Balance Tree · Windows 桌面版筹备中</span>
            </p>

            <h1 className="max-w-3xl font-display text-[clamp(2.1rem,4.6vw,3.35rem)] font-semibold leading-[1.08] tracking-tight text-gl-ink">
              不止「完成任务」，
              <span className="bg-gradient-to-r from-emerald-700 via-emerald-600 to-lime-600 bg-clip-text text-transparent">
                用伙伴与生命树，好好照顾多维生活
              </span>
            </h1>
            <p className="mt-6 max-w-2xl text-pretty text-base leading-relaxed text-gl-muted sm:text-lg">
              光合日历（Balance Tree）融合积极心理学的 PERMA 模型与 AI：用拟人化精灵与生命树可视化，把学习、关系、休息、兴趣与成就放在同一张地图上；桌面气泡球与时间线，则把这些陪伴留在你手边，而不是另一个冷冰冰的监工日历。
            </p>

            <div id="cta" className="mt-9 flex flex-wrap items-center gap-3">
              <span className="rounded-full border border-emerald-900/10 bg-white/85 px-4 py-2 text-sm font-medium text-gl-ink shadow-soft">
                预约产品与更新通知
              </span>
              <a
                className="rounded-full border border-emerald-900/10 bg-white px-5 py-2.5 text-sm font-semibold text-emerald-900 shadow-soft transition hover:border-emerald-300/80"
                href="#faq"
              >
                常见问题
              </a>
              <span className="w-full text-sm text-gl-muted sm:w-auto">
                正式开放下载前，我们会在这里公布获取方式。
              </span>
            </div>
          </div>
        </section>

        <section className="border-y border-emerald-900/10 bg-white/55 py-10 backdrop-blur-sm">
          <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-6 px-4 sm:flex-row sm:px-6">
            <div className="text-center sm:text-left">
              <p className="font-display text-2xl font-semibold text-gl-ink sm:text-3xl">温柔、但有骨架</p>
              <p className="mt-2 max-w-xl text-sm text-gl-muted sm:text-base">
                为拖延自责与隐性耗竭留出不评判的空间，同时用结构与可视化帮你找回平衡。
              </p>
            </div>
            <div className="grid w-full max-w-md grid-cols-3 gap-3 sm:max-w-lg">
              {[
                { k: "PERMA", v: "科学幸福模型打底" },
                { k: "五位伙伴", v: "分维度具象陪伴" },
                { k: "生命树", v: "失衡一眼可见" },
              ].map((s) => (
                <div
                  key={s.k}
                  className="rounded-2xl border border-emerald-900/10 bg-gl-mist/60 px-3 py-4 text-center shadow-soft"
                >
                  <div className="font-display text-lg font-semibold text-emerald-900">{s.k}</div>
                  <div className="mt-1 text-[11px] text-gl-muted">{s.v}</div>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section id="pillars" className="mx-auto max-w-6xl px-4 py-16 sm:px-6 sm:py-24">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="font-display text-3xl font-semibold tracking-tight text-gl-ink sm:text-4xl">三件我们笃定要做的事</h2>
            <p className="mt-3 text-sm leading-relaxed text-gl-muted sm:text-base">
              伙伴感、可视化平衡与智能取舍——都服务于同一句承诺：从「赶任务」回到「好好生活」。
            </p>
          </div>
          <div className="mt-12 grid gap-6 lg:grid-cols-3">
            {PILLARS.map((card, i) => (
              <article
                key={card.title}
                className="animate-rise rounded-3xl border border-emerald-900/10 bg-white/80 p-7 shadow-soft"
                style={{ animationDelay: `${i * 70}ms` }}
              >
                <div className="mb-4 h-1.5 w-12 rounded-full bg-gradient-to-r from-emerald-400 to-lime-400" />
                <h3 className="font-display text-lg font-semibold text-gl-ink sm:text-xl">{card.title}</h3>
                <p className="mt-3 text-sm leading-relaxed text-gl-muted sm:text-[15px]">{card.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="bg-gradient-to-b from-white/40 via-gl-mist/50 to-white/30 py-16 sm:py-22">
          <div className="mx-auto max-w-6xl px-4 sm:px-6">
            <h2 className="text-center font-display text-3xl font-semibold text-gl-ink sm:text-4xl">从光里长出的短文</h2>
            <p className="mx-auto mt-3 max-w-2xl text-center text-sm text-gl-muted sm:text-base">
              从 PERMA 到生命树与桌面入口，用几篇短文把产品哲学串成一条线。
            </p>
            <div className="mt-10 grid gap-5 md:grid-cols-3">
              {GUIDES.map((g) => (
                <a
                  key={g.title}
                  href={g.href}
                  className="group rounded-3xl border border-emerald-900/10 bg-white/85 p-6 shadow-soft transition hover:-translate-y-0.5 hover:shadow-lift"
                >
                  <h3 className="font-display text-lg font-semibold text-gl-ink group-hover:text-emerald-800">{g.title}</h3>
                  <p className="mt-3 text-sm leading-relaxed text-gl-muted">{g.desc}</p>
                  <p className="mt-5 text-sm font-semibold text-emerald-800">
                    继续阅读 <span aria-hidden="true">→</span>
                  </p>
                </a>
              ))}
            </div>
          </div>
        </section>

        <section id="voices" className="mx-auto max-w-6xl px-4 py-16 sm:px-6 sm:py-24">
          <h2 className="text-center font-display text-3xl font-semibold text-gl-ink sm:text-4xl">回声墙</h2>
          <p className="mx-auto mt-3 max-w-2xl text-center text-sm text-gl-muted sm:text-base">
            以下为用户故事化表述，帮助你想象日常使用情境；正式版上线后会逐步替换为可溯源的真实评价。
          </p>
          <div className="mt-12 grid gap-6 md:grid-cols-3">
            {VOICES.map((v) => (
              <figure
                key={v.who}
                className="relative overflow-hidden rounded-3xl border border-emerald-900/10 bg-white/85 p-7 shadow-soft"
              >
                <div className="absolute -right-10 -top-10 h-36 w-36 rounded-full bg-gradient-to-br from-emerald-200/40 to-lime-200/30 blur-2xl" />
                <blockquote className="relative text-sm leading-relaxed text-gl-ink sm:text-[15px]">“{v.quote}”</blockquote>
                <figcaption className="relative mt-5 text-xs font-medium text-gl-muted">{v.who}</figcaption>
              </figure>
            ))}
          </div>
        </section>

        <section id="spirits" className="border-y border-emerald-900/10 bg-white/50 py-16 sm:py-24">
          <div className="mx-auto max-w-6xl px-4 sm:px-6">
            <div className="mx-auto max-w-2xl text-center">
              <h2 className="font-display text-3xl font-semibold text-gl-ink sm:text-4xl">五位 AI 伙伴</h2>
              <p className="mt-3 text-sm leading-relaxed text-gl-muted sm:text-base">
                每位精灵对应 PERMA 中的一个幸福维度，把抽象的心理学语言变成会说话的陪伴；下图为现有立绘示意，正式上线时交互与文案会持续打磨。
              </p>
            </div>

            <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-5">
              {SPIRITS.map((s) => (
                <article
                  key={s.name}
                  className="group flex flex-col overflow-hidden rounded-3xl border border-emerald-900/10 bg-white/90 shadow-soft transition hover:-translate-y-0.5 hover:shadow-lift"
                >
                  <div className="relative aspect-square overflow-hidden bg-gradient-to-br from-emerald-100/70 to-lime-100/55">
                    <img
                      src={s.img}
                      alt={s.name}
                      className="h-full w-full object-cover transition duration-500 will-change-transform group-hover:scale-[1.03]"
                      style={{ objectPosition: "center 34%" }}
                      loading="lazy"
                      decoding="async"
                    />
                    <div className="pointer-events-none absolute inset-x-0 bottom-0 h-2/5 bg-gradient-to-t from-emerald-950/40 to-transparent" />
                    <span className="absolute bottom-3 left-3 rounded-full bg-white/90 px-2.5 py-1 text-[11px] font-semibold text-emerald-950 shadow-soft">
                      {s.tag}
                    </span>
                  </div>
                  <div className="flex flex-1 flex-col p-4">
                    <h3 className="font-display text-base font-semibold text-gl-ink">{s.name}</h3>
                    <p className="mt-1 text-[11px] leading-snug text-gl-muted/90">{s.meta}</p>
                    <p className="mt-2 flex-1 text-xs leading-relaxed text-gl-muted sm:text-sm">{s.blurb}</p>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section id="bubble" className="mx-auto max-w-6xl px-4 py-16 sm:px-6 sm:py-24">
          <div className="grid items-center gap-12 lg:grid-cols-2">
            <div>
              <h2 className="font-display text-3xl font-semibold text-gl-ink sm:text-4xl">桌面气泡球</h2>
              <p className="mt-4 text-sm leading-relaxed text-gl-muted sm:text-base">
                气泡球是桌边的轻入口：用自然语言和实时状态与五位伙伴对话，而不必跳进另一个巨型待办应用。
              </p>
              <ul className="mt-7 space-y-3 text-sm text-gl-ink/90">
                <li className="flex gap-3">
                  <span className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-emerald-500" />
                  右键菜单、拖动位移、双击回到主界面 —— 轻打扰、强可达，需要专注时它不抢戏。
                </li>
                <li className="flex gap-3">
                  <span className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-lime-500" />
                  与主面板同一套光合视觉：柔和绿色、通透白底与轻阴影，让「养护自我」的氛围延续到每一次点开。
                </li>
              </ul>
            </div>

            <div className="flex justify-center lg:justify-end">
              <div className="relative">
                <div
                  className="relative h-60 w-60 overflow-hidden rounded-full border-[5px] border-white shadow-lift sm:h-72 sm:w-72"
                  aria-label="气泡球圆形预览"
                >
                  <img
                    src={bubbleSphereBg}
                    alt="光合日历气泡球背景预览"
                    className="h-full w-full bg-emerald-50/35 object-contain"
                    loading="lazy"
                    decoding="async"
                  />
                </div>
                <p className="absolute -bottom-6 left-1/2 w-[118%] max-w-none -translate-x-1/2 rounded-2xl border border-emerald-900/10 bg-white/85 px-4 py-2 text-center text-xs text-gl-muted shadow-soft backdrop-blur sm:text-sm">
                  与桌面端同款视觉，柔和不抢眼。
                </p>
              </div>
            </div>
          </div>
        </section>

        <section id="faq" className="bg-white/60 py-16 sm:py-24">
          <div className="mx-auto max-w-3xl px-4 sm:px-6">
            <h2 className="text-center font-display text-3xl font-semibold text-gl-ink sm:text-4xl">常见问题</h2>
            <p className="mx-auto mt-3 max-w-xl text-center text-sm text-gl-muted">
              短问短答，便于快速扫读；展开后可见完整说明。
            </p>
            <div className="mt-10 space-y-4">
              {FAQ.map((item) => (
                <details
                  key={item.q}
                  className="group rounded-3xl border border-emerald-900/10 bg-gl-mist/40 p-5 shadow-soft open:bg-white/90"
                >
                  <summary className="cursor-pointer list-none font-semibold text-gl-ink outline-none ring-emerald-400/40 focus-visible:ring-4 [&::-webkit-details-marker]:hidden">
                    <span className="flex items-start justify-between gap-3">
                      <span>{item.q}</span>
                      <span className="mt-0.5 text-emerald-700 transition group-open:rotate-45">＋</span>
                    </span>
                  </summary>
                  <p className="mt-3 text-sm leading-relaxed text-gl-muted">{item.a}</p>
                </details>
              ))}
            </div>
          </div>
        </section>
          </>
        )}

        {surface === "mobile" && (
          <>
            <section id="m-top" className="relative overflow-hidden">
              <div className="pointer-events-none absolute inset-0">
                <img
                  src={pcBg}
                  alt=""
                  className="h-full min-h-[400px] w-full object-cover opacity-[0.22] sm:min-h-[500px]"
                  style={{ objectPosition: "center 30%" }}
                />
                <div className="absolute inset-0 bg-gradient-to-b from-white/90 via-white/95 to-gl-surface" />
                <div className="absolute inset-0 bg-[radial-gradient(700px_380px_at_50%_12%,oklch(0.94_0.05_150/0.45),transparent_55%)]" />
              </div>
              <div className="relative mx-auto max-w-6xl px-4 pb-16 pt-12 sm:px-6 sm:pb-20 sm:pt-16">
                <p className="mb-4 inline-flex max-w-full flex-wrap items-center gap-2 rounded-full border border-emerald-900/10 bg-white/80 px-3 py-1.5 text-xs font-medium text-gl-ink/85 shadow-soft backdrop-blur">
                  <span className="rounded-full bg-emerald-600/10 px-2 py-0.5 text-[11px] font-semibold text-emerald-900">
                    官方网站
                  </span>
                  <span className="text-gl-muted">移动端 · iOS / Android 筹备中</span>
                </p>
                <h1 className="max-w-3xl font-display text-[clamp(2rem,4.2vw,3.1rem)] font-semibold leading-[1.1] tracking-tight text-gl-ink">
                  口袋里的一棵树，
                  <span className="bg-gradient-to-r from-emerald-700 via-emerald-600 to-lime-600 bg-clip-text text-transparent">
                    碎片时间也能看见多维平衡
                  </span>
                </h1>
                <p className="mt-6 max-w-2xl text-pretty text-base leading-relaxed text-gl-muted sm:text-lg">
                  光合日历移动端与桌面同源：同一套 PERMA、五位伙伴与生命树。不同之处在于节奏——我们更在意「一眼扫清状态、一句被接住」，把重活留给大屏；路上、睡前与换乘间隙，用手机完成轻确认、轻记录与轻疗愈，而不是再塞一个监工式待办。
                </p>
                <div id="m-cta" className="mt-9 flex flex-wrap items-center gap-3">
                  <span className="rounded-full border border-emerald-900/10 bg-white/90 px-4 py-2 text-sm font-medium text-gl-ink shadow-soft">
                    预约移动端上线通知
                  </span>
                  <a
                    className="rounded-full border border-emerald-900/10 bg-white px-5 py-2.5 text-sm font-semibold text-emerald-900 shadow-soft transition hover:border-emerald-300/80"
                    href="#m-faq"
                  >
                    常见问题
                  </a>
                  <span className="w-full text-sm text-gl-muted sm:w-auto">正式开放下载前，会在此公布 TestFlight / 各应用商店信息。</span>
                </div>
              </div>
            </section>

            <section className="border-y border-emerald-900/10 bg-emerald-50/35 py-10 backdrop-blur-sm">
              <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-6 px-4 sm:flex-row sm:px-6">
                <div className="text-center sm:text-left">
                  <p className="font-display text-2xl font-semibold text-gl-ink sm:text-3xl">随身，不把均衡落下</p>
                  <p className="mt-2 max-w-xl text-sm text-gl-muted sm:text-base">
                    移动端不复制桌面的气泡球逻辑，而用卡片、列表与推送完成「伸手可及」的陪伴。
                  </p>
                </div>
                <div className="grid w-full max-w-md grid-cols-3 gap-3 sm:max-w-lg">
                  {[
                    { k: "一眼平衡", v: "生命树主舞台" },
                    { k: "短句接力", v: "通知与小组件" },
                    { k: "跨端一体", v: "与桌面同一棵树" },
                  ].map((s) => (
                    <div
                      key={s.k}
                      className="rounded-2xl border border-emerald-900/10 bg-white/75 px-3 py-4 text-center shadow-soft"
                    >
                      <div className="font-display text-lg font-semibold text-emerald-900">{s.k}</div>
                      <div className="mt-1 text-[11px] text-gl-muted">{s.v}</div>
                    </div>
                  ))}
                </div>
              </div>
            </section>

            <section id="m-pillars" className="mx-auto max-w-6xl px-4 py-16 sm:px-6 sm:py-24">
              <div className="mx-auto max-w-2xl text-center">
                <h2 className="font-display text-3xl font-semibold tracking-tight text-gl-ink sm:text-4xl">三件移动端笃定要做的事</h2>
                <p className="mt-3 text-sm leading-relaxed text-gl-muted sm:text-base">
                  不与小屏较劲，而是把「看见自己过得怎么样」这件事变轻、变近。
                </p>
              </div>
              <div className="mt-12 grid gap-6 lg:grid-cols-3">
                {MOBILE_PILLARS.map((card, i) => (
                  <article
                    key={card.title}
                    className="animate-rise rounded-3xl border border-emerald-900/10 bg-white/85 p-7 shadow-soft"
                    style={{ animationDelay: `${i * 70}ms` }}
                  >
                    <div className="mb-4 h-1.5 w-12 rounded-full bg-gradient-to-r from-teal-400 to-emerald-500" />
                    <h3 className="font-display text-lg font-semibold text-gl-ink sm:text-xl">{card.title}</h3>
                    <p className="mt-3 text-sm leading-relaxed text-gl-muted sm:text-[15px]">{card.body}</p>
                  </article>
                ))}
              </div>
            </section>

            <section id="m-guides" className="bg-gradient-to-b from-white/50 via-gl-mist/45 to-white/35 py-16 sm:py-22">
              <div className="mx-auto max-w-6xl px-4 sm:px-6">
                <h2 className="text-center font-display text-3xl font-semibold text-gl-ink sm:text-4xl">路上读完的短文</h2>
                <p className="mx-auto mt-3 max-w-2xl text-center text-sm text-gl-muted sm:text-base">
                  三篇与移动端节奏相关的导读，帮你理解「和桌面有什么不一样」。
                </p>
                <div className="mt-10 grid gap-5 md:grid-cols-3">
                  {MOBILE_GUIDES.map((g) => (
                    <a
                      key={g.title}
                      href={g.href}
                      className="group rounded-3xl border border-emerald-900/10 bg-white/90 p-6 shadow-soft transition hover:-translate-y-0.5 hover:shadow-lift"
                    >
                      <h3 className="font-display text-lg font-semibold text-gl-ink group-hover:text-emerald-800">{g.title}</h3>
                      <p className="mt-3 text-sm leading-relaxed text-gl-muted">{g.desc}</p>
                      <p className="mt-5 text-sm font-semibold text-emerald-800">
                        继续阅读 <span aria-hidden="true">→</span>
                      </p>
                    </a>
                  ))}
                </div>
              </div>
            </section>

            <section id="m-voices" className="mx-auto max-w-6xl px-4 py-16 sm:px-6 sm:py-24">
              <h2 className="text-center font-display text-3xl font-semibold text-gl-ink sm:text-4xl">回声墙</h2>
              <p className="mx-auto mt-3 max-w-2xl text-center text-sm text-gl-muted sm:text-base">
                以下为用户故事化表述，偏移动与跨端场景；正式版上线后会替换为可溯源评价。
              </p>
              <div className="mt-12 grid gap-6 md:grid-cols-3">
                {MOBILE_VOICES.map((v) => (
                  <figure
                    key={v.who}
                    className="relative overflow-hidden rounded-3xl border border-emerald-900/10 bg-white/90 p-7 shadow-soft"
                  >
                    <div className="absolute -right-10 -top-10 h-36 w-36 rounded-full bg-gradient-to-br from-teal-200/35 to-emerald-200/30 blur-2xl" />
                    <blockquote className="relative text-sm leading-relaxed text-gl-ink sm:text-[15px]">“{v.quote}”</blockquote>
                    <figcaption className="relative mt-5 text-xs font-medium text-gl-muted">{v.who}</figcaption>
                  </figure>
                ))}
              </div>
            </section>

            <section id="m-spirits" className="border-y border-emerald-900/10 bg-white/55 py-16 sm:py-24">
              <div className="mx-auto max-w-6xl px-4 sm:px-6">
                <div className="mx-auto max-w-2xl text-center">
                  <h2 className="font-display text-3xl font-semibold text-gl-ink sm:text-4xl">五位 AI 伙伴</h2>
                  <p className="mt-3 text-sm leading-relaxed text-gl-muted sm:text-base">
                    角色与 PERMA 维度与桌面版一致；在手机上，他们更常以小句、卡片与推送出现，适配单手与碎片时间。下图为现有立绘示意。
                  </p>
                </div>
                <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-5">
                  {SPIRITS.map((s) => (
                    <article
                      key={`m-${s.name}`}
                      className="group flex flex-col overflow-hidden rounded-3xl border border-emerald-900/10 bg-white/90 shadow-soft transition hover:-translate-y-0.5 hover:shadow-lift"
                    >
                      <div className="relative aspect-square overflow-hidden bg-gradient-to-br from-emerald-100/70 to-teal-100/50">
                        <img
                          src={s.img}
                          alt={s.name}
                          className="h-full w-full object-cover transition duration-500 will-change-transform group-hover:scale-[1.03]"
                          style={{ objectPosition: "center 34%" }}
                          loading="lazy"
                          decoding="async"
                        />
                        <div className="pointer-events-none absolute inset-x-0 bottom-0 h-2/5 bg-gradient-to-t from-emerald-950/40 to-transparent" />
                        <span className="absolute bottom-3 left-3 rounded-full bg-white/90 px-2.5 py-1 text-[11px] font-semibold text-emerald-950 shadow-soft">
                          {s.tag}
                        </span>
                      </div>
                      <div className="flex flex-1 flex-col p-4">
                        <h3 className="font-display text-base font-semibold text-gl-ink">{s.name}</h3>
                        <p className="mt-1 text-[11px] leading-snug text-gl-muted/90">{s.meta}</p>
                        <p className="mt-2 flex-1 text-xs leading-relaxed text-gl-muted sm:text-sm">{s.blurb}</p>
                      </div>
                    </article>
                  ))}
                </div>
              </div>
            </section>

            <section id="m-preview" className="mx-auto max-w-6xl px-4 py-16 sm:px-6 sm:py-24">
              <div className="grid items-center gap-12 lg:grid-cols-2">
                <div>
                  <h2 className="font-display text-3xl font-semibold text-gl-ink sm:text-4xl">界面预览</h2>
                  <p className="mt-4 text-sm leading-relaxed text-gl-muted sm:text-base">
                    下方为移动端界面预览图，呈现当前设计气质与信息层级；正式上架 UI 以应用商店版本为准。核心结构：顶部生命树周览、下方伙伴卡片与「今日一句」式轻互动。
                  </p>
                  <ul className="mt-7 space-y-3 text-sm text-gl-ink/90">
                    <li className="flex gap-3">
                      <span className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-teal-500" />
                      首屏优先「状态」而非「清单」：先看见树与色带，再决定是否下钻任务。
                    </li>
                    <li className="flex gap-3">
                      <span className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-emerald-500" />
                      拇指热区放高频动作：打卡、延后、给精灵一句心情，复杂编辑引导回桌面。
                    </li>
                  </ul>
                </div>
                <div className="flex justify-center lg:justify-end">
                  <figure className="relative mx-auto w-full max-w-[min(100%,320px)] shrink-0">
                    <div className="overflow-hidden rounded-[2rem] border border-emerald-900/10 bg-white shadow-[0_24px_60px_-12px_rgba(15,40,30,0.26)] ring-1 ring-emerald-900/5">
                      <img
                        src="/官网移动端界面展示.jpg"
                        alt="光合日历移动端界面预览"
                        className="block h-auto w-full object-cover object-top"
                        loading="lazy"
                        decoding="async"
                      />
                    </div>
                    
                  </figure>
                </div>
              </div>
            </section>

            <section id="m-faq" className="bg-white/65 py-16 sm:py-24">
              <div className="mx-auto max-w-3xl px-4 sm:px-6">
                <h2 className="text-center font-display text-3xl font-semibold text-gl-ink sm:text-4xl">常见问题</h2>
                <p className="mx-auto mt-3 max-w-xl text-center text-sm text-gl-muted">
                  关于移动端与桌面端分工的短问答。
                </p>
                <div className="mt-10 space-y-4">
                  {MOBILE_FAQ.map((item) => (
                    <details
                      key={item.q}
                      className="group rounded-3xl border border-emerald-900/10 bg-gl-mist/40 p-5 shadow-soft open:bg-white/90"
                    >
                      <summary className="cursor-pointer list-none font-semibold text-gl-ink outline-none ring-emerald-400/40 focus-visible:ring-4 [&::-webkit-details-marker]:hidden">
                        <span className="flex items-start justify-between gap-3">
                          <span>{item.q}</span>
                          <span className="mt-0.5 text-emerald-700 transition group-open:rotate-45">＋</span>
                        </span>
                      </summary>
                      <p className="mt-3 text-sm leading-relaxed text-gl-muted">{item.a}</p>
                    </details>
                  ))}
                </div>
              </div>
            </section>
          </>
        )}
      </main>

      <footer className="border-t border-emerald-900/10 bg-gradient-to-r from-emerald-50/70 via-white/70 to-lime-50/70 py-12 text-center">
        <p className="font-display text-base font-semibold text-gl-ink">光合日历</p>
        <p className="mx-auto mt-2 max-w-md text-xs leading-relaxed text-gl-muted">
          {surface === "desktop"
            ? "为「拖延自责」与「隐性耗竭」留出不评判的空间，用 PERMA、生命树与 Balance Tree 思路，陪你从完成任务走向多维度的温柔平衡。"
            : "桌面负责深度与整块时间，手机负责一眼平衡与轻陪伴——两端都是光合日历，只是节奏不同。"}
        </p>
        <p className="mt-6 text-xs text-gl-muted">© {new Date().getFullYear()} 光合日历</p>
      </footer>
    </div>
  );
}

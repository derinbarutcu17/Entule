import { HeroVisual } from "@/components/hero-visual";
import { Reveal } from "@/components/reveal";
import { SiteHeader } from "@/components/site-header";
import { WaitlistForm } from "@/components/waitlist-form";

const FOR_WHOM = [
  {
    title: "Designers",
    text: "Keep Figma, references, notes, and export folders ready for the next sprint session.",
  },
  {
    title: "Developers",
    text: "Resume coding context with your editor, docs, issue boards, and local project folders.",
  },
  {
    title: "Researchers",
    text: "Pick up threads across papers, datasets, docs, and browser links without setup friction.",
  },
  {
    title: "Founders / Operators",
    text: "Reopen the operating stack fast: metrics, planning docs, communication tools, and trackers.",
  },
];

const FAQ = [
  {
    q: "Is Entule Mac-only?",
    a: "Yes. Entule v1 is built specifically for macOS as a menu bar utility.",
  },
  {
    q: "What does a session mean here?",
    a: "A lightweight checkpoint of apps, files, folders, and URLs that help you return to active work quickly.",
  },
  {
    q: "Does it restore everything exactly?",
    a: "No. v1 does not claim full internal app-state restoration or exact monitor/window layout recovery.",
  },
  {
    q: "Is there a beta?",
    a: "Early access is opening in small batches. Waitlist members get first invites and updates.",
  },
  {
    q: "How will early access work?",
    a: "You join the list, we review fit and usage patterns, then invite people in waves with setup notes.",
  },
];

export default function Home() {
  return (
    <div id="top" className="relative overflow-hidden">
      <div className="ambient-orb -left-28 top-20 bg-amber-100/25" />
      <div className="ambient-orb -right-32 top-[30rem] bg-slate-100/20" />
      <SiteHeader />

      <main>
        <section className="mx-auto grid max-w-6xl gap-10 px-6 pb-20 pt-16 md:grid-cols-[1.1fr_1fr] md:items-center lg:px-8 lg:pt-20">
          <Reveal>
            <p className="eyebrow">Early access</p>
            <h1 className="section-title mt-3 text-5xl leading-[1.05] text-slate-100 sm:text-6xl">
              Return to work instantly.
            </h1>
            <p className="mt-6 max-w-xl text-lg text-dim">
              Entule is a macOS menu bar utility that saves lightweight work checkpoints and reopens them later,
              so you can resume real work without rebuilding context from scratch.
            </p>

            <div className="mt-8 flex flex-wrap items-center gap-3">
              <a href="#early-access" className="btn-primary rounded-full px-5 py-3 text-sm font-semibold transition">
                Join early access
              </a>
              <a href="#how-it-works" className="btn-secondary rounded-full px-5 py-3 text-sm font-semibold transition">
                See how it works
              </a>
            </div>

            <p className="mt-5 text-sm text-slate-400">
              Built for designers, developers, researchers, founders, and anyone who actually sits down to get focused
              work done.
            </p>
          </Reveal>

          <Reveal delay={0.1}>
            <HeroVisual />
          </Reveal>
        </section>

        <section className="mx-auto max-w-6xl px-6 pb-20 lg:px-8">
          <Reveal className="panel-soft rounded-3xl p-7 md:p-10">
            <p className="eyebrow">The problem</p>
            <h2 className="section-title mt-2 text-3xl text-slate-100 md:text-4xl">
              Work is fast. Re-entry is slow.
            </h2>
            <p className="mt-4 max-w-3xl text-dim">
              Most friction is not starting work. It is getting back into it. Sessions scatter across apps, folders,
              files, links, and notes. Rebuilding that stack every time burns momentum.
            </p>
            <p className="mt-3 max-w-3xl text-dim">
              Entule gives you a clear return point: save a checkpoint, review it, and reopen it later.
            </p>
          </Reveal>
        </section>

        <section id="how-it-works" className="mx-auto max-w-6xl px-6 pb-20 lg:px-8">
          <p className="eyebrow">How it works</p>
          <h2 className="section-title mt-2 text-3xl text-slate-100 md:text-4xl">A short path back into flow</h2>

          <div className="mt-8 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            {[
              ["01", "Save checkpoint", "Capture apps, files, folders, and URLs as a lightweight work state."],
              ["02", "Review what stays", "Uncheck noise, keep signal, and add anything missing manually."],
              ["03", "Resume later", "Open the last session when you return to your desk or context."],
              ["04", "Continue working", "Skip setup churn and move straight into meaningful output."],
            ].map(([num, title, text], idx) => (
              <Reveal key={title} delay={idx * 0.05} className="panel-soft rounded-2xl p-5">
                <div className="text-sm font-semibold text-amber-200/85">{num}</div>
                <h3 className="mt-2 text-lg font-semibold text-slate-100">{title}</h3>
                <p className="mt-2 text-sm text-dim">{text}</p>
              </Reveal>
            ))}
          </div>
        </section>

        <section id="v1-capabilities" className="mx-auto max-w-6xl px-6 pb-20 lg:px-8">
          <div className="grid gap-5 md:grid-cols-2">
            <Reveal className="panel rounded-3xl p-7">
              <p className="eyebrow">What v1 does</p>
              <ul className="mt-4 space-y-3 text-sm text-slate-200">
                <li>• Create presets with apps, files, folders, and URLs</li>
                <li>• Detect a current session, review it, and save it</li>
                <li>• Resume your last saved session</li>
                <li>• Optionally run a macOS Shortcut before launch or resume</li>
                <li>• Manually add apps, files, folders, and URLs while saving</li>
              </ul>
            </Reveal>

            <Reveal delay={0.08} className="panel rounded-3xl p-7">
              <p className="eyebrow">What v1 does not do</p>
              <ul className="mt-4 space-y-3 text-sm text-slate-200">
                <li>• No fake AI features</li>
                <li>• No magical total app-state reconstruction</li>
                <li>• No full browser session-manager behavior</li>
                <li>• No layout / monitor restoration in v1</li>
                <li>• No cloud sync in v1</li>
              </ul>
            </Reveal>
          </div>
        </section>

        <section className="mx-auto max-w-6xl px-6 pb-20 lg:px-8">
          <p className="eyebrow">Who it is for</p>
          <h2 className="section-title mt-2 text-3xl text-slate-100 md:text-4xl">People with scattered context</h2>
          <div className="mt-8 grid gap-4 md:grid-cols-2">
            {FOR_WHOM.map((item, idx) => (
              <Reveal key={item.title} delay={idx * 0.05} className="panel-soft rounded-2xl p-6">
                <h3 className="text-lg font-semibold text-slate-100">{item.title}</h3>
                <p className="mt-2 text-sm text-dim">{item.text}</p>
              </Reveal>
            ))}
          </div>
        </section>

        <section id="early-access" className="mx-auto max-w-6xl px-6 pb-24 lg:px-8">
          <div className="grid gap-8 md:grid-cols-[1fr_1.05fr] md:items-start">
            <Reveal>
              <p className="eyebrow">Join early access</p>
              <h2 className="section-title mt-2 text-3xl text-slate-100 md:text-4xl">Get invited as we open v1 in waves</h2>
              <p className="mt-4 text-dim">
                Tell us how you work, and we will prioritize people who need fast context return on macOS.
              </p>
            </Reveal>
            <Reveal delay={0.08}>
              <WaitlistForm source="landing-final-cta" />
            </Reveal>
          </div>
        </section>

        <section id="faq" className="mx-auto max-w-6xl px-6 pb-24 lg:px-8">
          <p className="eyebrow">FAQ</p>
          <h2 className="section-title mt-2 text-3xl text-slate-100 md:text-4xl">Practical details</h2>
          <div className="mt-7 space-y-3">
            {FAQ.map((item, idx) => (
              <Reveal key={item.q} delay={idx * 0.03}>
                <details className="panel-soft rounded-2xl p-5">
                  <summary className="cursor-pointer list-none text-base font-semibold text-slate-100">{item.q}</summary>
                  <p className="mt-3 text-sm text-dim">{item.a}</p>
                </details>
              </Reveal>
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}

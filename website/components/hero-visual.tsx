export function HeroVisual() {
  return (
    <div className="panel relative overflow-hidden rounded-3xl p-5 md:p-7">
      <div className="absolute -left-16 -top-20 h-44 w-44 rounded-full bg-amber-200/15 blur-3xl" />
      <div className="absolute -right-10 -bottom-20 h-52 w-52 rounded-full bg-slate-200/10 blur-3xl" />

      <div className="relative space-y-4">
        <div className="flex items-center justify-between rounded-xl border border-white/10 bg-[#101620]/80 px-4 py-2">
          <div className="text-xs text-slate-300">Entule • Menu Bar</div>
          <div className="rounded-full border border-amber-200/30 px-2 py-0.5 text-[10px] uppercase tracking-[0.16em] text-amber-200/90">
            Active
          </div>
        </div>

        <div className="grid gap-3 rounded-2xl border border-white/10 bg-[#0f141d]/85 p-4">
          <div className="text-sm font-semibold text-slate-100">Save Current Session</div>
          <div className="grid gap-2 text-xs text-slate-300">
            <div className="rounded-lg border border-white/8 bg-white/4 px-3 py-2">
              Apps: Cursor, Figma, Slack
            </div>
            <div className="rounded-lg border border-white/8 bg-white/4 px-3 py-2">
              Files/Folders: roadmap.md, /Research/Sprint
            </div>
            <div className="rounded-lg border border-white/8 bg-white/4 px-3 py-2">
              URLs: docs, issue board, spec links
            </div>
          </div>
          <div className="flex items-center justify-between rounded-lg border border-amber-100/20 bg-amber-100/5 px-3 py-2 text-xs">
            <span className="text-amber-100/90">Shortcut (optional): Focus Mode</span>
            <span className="text-amber-100/70">before save</span>
          </div>
        </div>

        <div className="grid gap-2 rounded-2xl border border-white/10 bg-[#121925]/85 p-4 text-sm text-slate-200">
          <div className="font-semibold">Resume Last Session</div>
          <div className="flex items-center justify-between rounded-lg border border-white/8 bg-white/4 px-3 py-2 text-xs text-slate-300">
            <span>Attempted</span>
            <span>16 items</span>
          </div>
          <div className="flex items-center justify-between rounded-lg border border-emerald-300/20 bg-emerald-200/5 px-3 py-2 text-xs text-emerald-200/90">
            <span>Succeeded</span>
            <span>14</span>
          </div>
          <div className="flex items-center justify-between rounded-lg border border-rose-300/20 bg-rose-200/5 px-3 py-2 text-xs text-rose-200/90">
            <span>Failed</span>
            <span>2</span>
          </div>
        </div>
      </div>
    </div>
  );
}

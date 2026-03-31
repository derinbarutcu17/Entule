export function SiteHeader() {
  return (
    <header className="sticky top-0 z-30 border-b border-white/6 bg-[#0b0e13]/70 backdrop-blur-xl">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4 lg:px-8">
        <a href="#top" className="flex items-center gap-2">
          <span className="inline-flex h-2.5 w-2.5 rounded-full bg-amber-200 shadow-[0_0_16px_rgba(245,204,135,0.8)]" />
          <span className="font-serif text-2xl leading-none tracking-wide text-slate-100">Entule</span>
        </a>

        <nav aria-label="Main" className="hidden items-center gap-7 text-sm text-slate-300 md:flex">
          <a className="hover:text-slate-100" href="#how-it-works">
            How it works
          </a>
          <a className="hover:text-slate-100" href="#v1-capabilities">
            V1 scope
          </a>
          <a className="hover:text-slate-100" href="#faq">
            FAQ
          </a>
        </nav>

        <a
          href="#early-access"
          className="btn-secondary rounded-full px-4 py-2 text-sm font-medium transition"
        >
          Join early access
        </a>
      </div>
    </header>
  );
}

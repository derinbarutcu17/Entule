# Entule Website (Static Preview)

This is a GitHub Pages-friendly static landing site for Entule.

## What is included

- Premium dark-mode landing UI
- Product messaging grounded in the real Entule app scope
- Responsive sections (hero, problem, flow, v1 scope, FAQ, CTA)
- Static waitlist form UI preview state

## What is intentionally excluded in this Pages version

- Backend/API routes
- Supabase storage
- Resend transactional email
- Protected admin/export utilities

## Local Development

1. Install dependencies:
   - `pnpm install`
   - or `npx -y pnpm@10.18.3 install`
2. Run:
   - `pnpm dev`
3. Build static export:
   - `pnpm build`

Static output is generated into `out/`.

## GitHub Pages deployment

A workflow is included at:

- `.github/workflows/deploy-pages.yml`

It triggers on pushes to `main` that touch `website/**` and deploys `website/out` to GitHub Pages.

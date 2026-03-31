"use client";

import { FormEvent, useMemo, useState } from "react";

type FormStatus = "idle" | "loading" | "success" | "error";

const ROLE_OPTIONS = [
  "Designer",
  "Developer",
  "Researcher",
  "Founder / Operator",
  "Student",
  "Knowledge Worker",
  "Other",
];

export function WaitlistForm({ source }: { source: string }) {
  const [status, setStatus] = useState<FormStatus>("idle");
  const [message, setMessage] = useState<string>("");
  const [selectedRole, setSelectedRole] = useState<string>("");
  const [roleDetail, setRoleDetail] = useState<string>("");

  const isLoading = status === "loading";
  const isSuccess = status === "success";

  const roleOrUseCase = useMemo(() => {
    const trimmedDetail = roleDetail.trim();
    if (!selectedRole) {
      return trimmedDetail;
    }
    if (selectedRole === "Other") {
      return trimmedDetail || "Other";
    }
    return trimmedDetail ? `${selectedRole}: ${trimmedDetail}` : selectedRole;
  }, [selectedRole, roleDetail]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const formData = new FormData(form);

    void formData;
    void roleOrUseCase;

    setStatus("loading");
    setMessage("");

    await new Promise((resolve) => setTimeout(resolve, 500));
    setStatus("success");
    setMessage(
      "Thanks. This is a static preview on GitHub Pages for now, so signup storage is disabled.",
    );
    form.reset();
    setSelectedRole("");
    setRoleDetail("");
  }

  return (
    <form onSubmit={handleSubmit} className="panel rounded-3xl p-6 sm:p-7" noValidate>
      <div className="grid gap-4">
        <div>
          <label htmlFor="name" className="mb-1 block text-sm text-slate-300">
            Name (optional)
          </label>
          <input
            id="name"
            name="name"
            autoComplete="name"
            className="w-full rounded-xl border border-white/12 bg-white/4 px-3 py-2.5 text-sm text-slate-100 outline-none transition focus:border-amber-200/50 focus:ring-2 focus:ring-amber-200/20"
            placeholder="Derin"
          />
        </div>

        <div>
          <label htmlFor="email" className="mb-1 block text-sm text-slate-300">
            Email
          </label>
          <input
            id="email"
            name="email"
            type="email"
            required
            autoComplete="email"
            className="w-full rounded-xl border border-white/12 bg-white/4 px-3 py-2.5 text-sm text-slate-100 outline-none transition focus:border-amber-200/50 focus:ring-2 focus:ring-amber-200/20"
            placeholder="you@domain.com"
          />
        </div>

        <div>
          <label htmlFor="role" className="mb-1 block text-sm text-slate-300">
            Role / use case (optional)
          </label>
          <select
            id="role"
            value={selectedRole}
            onChange={(event) => setSelectedRole(event.target.value)}
            className="w-full rounded-xl border border-white/12 bg-white/4 px-3 py-2.5 text-sm text-slate-100 outline-none transition focus:border-amber-200/50 focus:ring-2 focus:ring-amber-200/20"
          >
            <option value="" className="bg-slate-900">
              Select one
            </option>
            {ROLE_OPTIONS.map((option) => (
              <option key={option} value={option} className="bg-slate-900">
                {option}
              </option>
            ))}
          </select>
          <input
            value={roleDetail}
            onChange={(event) => setRoleDetail(event.target.value)}
            className="mt-2 w-full rounded-xl border border-white/12 bg-white/4 px-3 py-2.5 text-sm text-slate-100 outline-none transition focus:border-amber-200/50 focus:ring-2 focus:ring-amber-200/20"
            placeholder="Optional details (tools, workflow, team)"
          />
        </div>

        <div className="hidden" aria-hidden="true">
          <label htmlFor="website">Website</label>
          <input
            id="website"
            name="website"
            tabIndex={-1}
            autoComplete="off"
            className="hidden"
          />
        </div>

        <label className="flex items-start gap-3 rounded-lg border border-white/8 bg-white/2 p-3 text-sm text-slate-300">
          <input
            type="checkbox"
            name="consent"
            required
            className="mt-1 h-4 w-4 rounded border-white/30 bg-transparent text-amber-300"
          />
          <span>I agree to receive product updates and early-access invites for Entule.</span>
        </label>

        <button
          type="submit"
          disabled={isLoading}
          className="btn-primary rounded-xl px-4 py-3 text-sm font-semibold transition disabled:cursor-not-allowed disabled:opacity-70"
        >
          {isLoading ? "Saving your spot..." : "Join early access"}
        </button>

        <p
          aria-live="polite"
          className={`min-h-5 text-sm ${
            status === "error"
              ? "text-rose-300"
              : isSuccess
                ? "text-emerald-200"
                : "text-slate-400"
          }`}
        >
          {message || `No spam. Source: ${source}.`}
        </p>
      </div>
    </form>
  );
}

import path from "node:path";
import { fileURLToPath } from "node:url";
import type { NextConfig } from "next";

const isGithubActions = process.env.GITHUB_ACTIONS === "true";
const repoName = "Entule";
const dirname = path.dirname(fileURLToPath(import.meta.url));

const nextConfig: NextConfig = {
  output: "export",
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
  outputFileTracingRoot: dirname,
  ...(isGithubActions
    ? {
        basePath: `/${repoName}`,
        assetPrefix: `/${repoName}/`,
      }
    : {}),
};

export default nextConfig;

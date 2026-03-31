import type { Metadata } from "next";
import { Cormorant_Garamond, Manrope } from "next/font/google";
import "./globals.css";

const manrope = Manrope({
  variable: "--font-manrope",
  subsets: ["latin"],
});

const cormorant = Cormorant_Garamond({
  variable: "--font-cormorant",
  subsets: ["latin"],
  weight: ["500", "600", "700"],
});

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL;
const metadataBase = siteUrl ? new URL(siteUrl) : new URL("https://entule.app");

export const metadata: Metadata = {
  metadataBase,
  title: {
    default: "Entule | Return to work instantly",
    template: "%s | Entule",
  },
  description:
    "Entule is a macOS menu bar utility for saving lightweight work checkpoints so you can reopen apps, files, folders, and URLs and get back into work faster.",
  openGraph: {
    title: "Entule | Return to work instantly",
    description:
      "Save lightweight work checkpoints on macOS and reopen your flow without rebuilding context.",
    url: siteUrl ?? "https://entule.app",
    siteName: "Entule",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Entule | Return to work instantly",
    description:
      "Save lightweight work checkpoints on macOS and return to focused work in seconds.",
  },
  alternates: {
    canonical: "/",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className={`${manrope.variable} ${cormorant.variable} antialiased`}>
        {children}
      </body>
    </html>
  );
}

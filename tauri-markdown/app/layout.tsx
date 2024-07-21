"use client"
import "@/styles/globals.css";
import { Metadata, Viewport } from "next";
import { Link } from "@nextui-org/link";
import clsx from "clsx";

import { Providers } from "./providers";

import { fontMono, fontSans } from "@/config/fonts";
import { Navbar } from "@/components/navbar";
import './style.css';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {

  return (
    <html suppressHydrationWarning lang="en">
      <head />
      <body
        className={clsx(
          "min-h-screen font-sans antialiased w-screen overflow-hidden",
          fontMono.variable,
        )}
      >
        <Providers themeProps={{ attribute: "class", defaultTheme: "light" }}>
          <div className="relative flex w-screen flex-col h-screen">
            <Navbar />

            <main className="mx-0 w-screen bg-default-100  py-2 px-2">
                {children}
            </main>
          </div>
        </Providers>
      </body>
    </html>
  );
}

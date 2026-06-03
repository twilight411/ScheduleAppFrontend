/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        display: ['"Bricolage Grotesque"', "system-ui", "sans-serif"],
        sans: ['"Noto Sans SC"', "system-ui", "sans-serif"],
      },
      colors: {
        gl: {
          ink: "oklch(0.28 0.045 158)",
          muted: "oklch(0.45 0.03 158)",
          surface: "oklch(0.985 0.018 150)",
          mist: "oklch(0.96 0.028 152)",
          leaf: "oklch(0.72 0.14 155)",
          canopy: "oklch(0.58 0.12 155)",
        },
      },
      boxShadow: {
        lift: "0 18px 45px -18px oklch(0.35 0.08 155 / 0.35)",
        soft: "0 10px 30px -12px oklch(0.45 0.06 155 / 0.22)",
      },
      keyframes: {
        rise: {
          "0%": { opacity: "0", transform: "translateY(10px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
      },
      animation: {
        rise: "rise 0.7s ease-out both",
      },
    },
  },
  plugins: [],
};

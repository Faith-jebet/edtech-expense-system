/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // 60% Base canvas: Cream White / Ivory
        canvas: '#FFFDF9',
        
        // 30% Secondary: Deep Navy (matching table headers in framework doc)
        brand: {
          DEFAULT: '#1F4E79',
          light: '#E3EDF7',
          dark: '#163858',
        },
        
        // 10% Accent: Amber
        accent: {
          DEFAULT: '#D98E04',
          light: '#F5B942',
          dark: '#B87804',
        },
        
        // Text colors
        ink: '#1B2733',
        muted: '#5D6B7A',
        
        // Borders
        line: '#E6E0D4',
        
        // Status colors (semantic, always with text label)
        success: '#1D7A4A',
        danger: '#B3261E',
        warning: '#D98E04',
        info: '#1F4E79',
      },
      fontFamily: {
        serif: ['Cambria', 'Georgia', 'serif'],
        sans: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Helvetica', 'Arial', 'sans-serif'],
      },
    },
  },
  plugins: [],
}

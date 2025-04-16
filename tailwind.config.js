const plugin = require('tailwindcss/plugin');
const colors = require('tailwindcss/colors');
const contrastColors = require('./app/javascript/contrast_colors');

const safeList = [];
contrastColors.forEach((_, i) => {
  safeList.push(`contrast-${i}`);
  safeList.push(`bg-contrast-${i}`);
  safeList.push(`border-contrast-${i}`);
  safeList.push(`text-contrast-${i}`);
  safeList.push('.ts-control');
  safeList.push('.ts-dropdown');
});

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/components/**/*.html.erb',
    './app/components/**/*.rb',
    './app/renders/**/*.rb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
  ],
  safelist: safeList,
  theme: {
    backgroundColor: (theme) => ({
      ...theme('colors'),
    }),
    colors: {
      transparent: 'transparent',
      current: 'currentColor',
      black: colors.black,
      white: colors.white,
      gray: colors.gray,
      red: colors.red,
      yellow: colors.yellow,
    },
    extend: {
      screens: {
        '3xl': '1920px',
        '4xl': '2560px',
      },
      colors: {
        brand: {
          lightest: '#fef6ef',
          lighter: '#e5c9b1',
          light: '#eb862e',
          DEFAULT: '#de7012',
          dark: '#d16a0f',
        },
        positive: {
          light: '#8fbb67',
          DEFAULT: '#80ac57',
          dark: '#7eac53',
        },
        gray: {
          50: '#FCFAF8',
          100: '#F5F3F1',
          200: '#E8E5E3',
          300: '#D6D4D0',
          400: '#A6A29D',
          500: '#75716C',
          600: '#57524F',
          700: '#44403A',
          800: '#27231F',
          900: '#181512',
        },
        contrast: { ...contrastColors },
      },
      fontFamily: {
        sans: 'Inter, sans-serif',
      },
      // use as animate-fade
      animation: {
        highlight: 'fadeOut 5s ease-in-out',
      },
      keyframes: (theme) => ({
        fadeOut: {
          '0%': {
            backgroundColor: theme('colors.yellow.100'),
          },
          '100%': {
            backgroundColor: theme('colors.transparent'),
          },
        },
      }),
    },
  },
  plugins: [
    require('@tailwindcss/forms'), // eslint-disable-line global-require
    plugin(({ addVariant }) => {
      // Add a `selected` variant, ie. `selected:bg-opacity-75`
      addVariant('selected', '&[selected]');
    }),
  ],
};

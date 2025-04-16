const locale = document.documentElement.lang;

const i18n = {
  de: {
    tomSelect: {
      loading: 'Laden...',
      noResults: 'Keine Ergebnisse',
      noMoreResults: 'Keine weiter Ergebnisse',
    },
  },
  en: {
    tomSelect: {
      loading: 'Loading...',
      noResults: 'No results',
      noMoreResults: 'No more results',
    },
  },
  fr: {
    tomSelect: {
      loading: 'Chargement...',
      noResults: 'Pas de résultats',
      noMoreResults: 'Plus de résultats',
    },
  },
};

export default i18n[locale];

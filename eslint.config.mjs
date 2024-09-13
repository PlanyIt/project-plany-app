import globals from 'globals';
import jsPlugin from '@eslint/js'; // ESLint plugin pour JavaScript
import tsPlugin from '@typescript-eslint/eslint-plugin'; // ESLint plugin pour TypeScript
import tsParser from '@typescript-eslint/parser'; // Parser pour TypeScript

export default [
  {
    files: ['**/*.{js,mjs,cjs,ts}'],
    languageOptions: {
      parser: tsParser, // Utiliser le parser TypeScript
      ecmaVersion: 'latest', // Dernière version d'ECMAScript
      sourceType: 'module', // Modules ES
      globals: { ...globals.browser, ...globals.node }, // Globales pour navigateur et Node.js
    },
    plugins: {
      ts: tsPlugin, // Plugin TypeScript
    },
    rules: {
      'no-unused-vars': 'warn', // Avertissement pour les variables inutilisées
      eqeqeq: 'error', // Enforcer === et !==
      curly: 'error', // Toujours utiliser des accolades
      semi: ['error', 'always'], // Points-virgules obligatoires
    },
  },
  // Configuration recommandée pour JS (ESLint de base)
  {
    files: ['**/*.js'],
    rules: {
      ...jsPlugin.configs.recommended.rules, // Inclure les règles recommandées pour JS
    },
  },
  // Configuration recommandée pour TypeScript
  {
    files: ['**/*.ts'],
    rules: {
      ...tsPlugin.configs.recommended.rules, // Inclure les règles recommandées pour TS
    },
  },
];

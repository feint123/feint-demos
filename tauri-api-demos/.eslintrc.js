module.exports = {
  root: true,
  env: {
    node: true,
  },
  extends: ['plugin:vue/vue3-recommended', 'prettier'],
  // "plugin:import/errors", "plugin:import/warnings", "plugin:prettier/recommended", "prettier"
  parserOptions: {
    ecmaVersion: 2021,
  },
  rules: {
    'no-var': 'error',
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'comma-dangle': ['error', 'only-multiline'],
  },
  globals: {
    defineProps: 'readonly',
    defineEmits: 'readonly',
    defineExpose: 'readonly',
    withDefaults: 'readonly',
  },
  ignorePatterns: ['.eslintrc.js'],
};
